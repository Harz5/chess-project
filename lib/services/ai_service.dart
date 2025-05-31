import 'package:stockfish/stockfish.dart';
import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';

/// Service für die KI-Gegner-Funktionalität mit Stockfish-Integration.
class AIService {
  late Stockfish _stockfish;
  bool _isInitialized = false;
  bool _isThinking = false;
  
  // Schwierigkeitsgrade als ELO-Werte
  static const Map<String, int> difficultyLevels = {
    'Anfänger': 800,
    'Leicht': 1200,
    'Mittel': 1600,
    'Fortgeschritten': 2000,
    'Experte': 2400,
    'Meister': 2800,
  };

  /// Initialisiert die Stockfish-Engine.
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _stockfish = Stockfish();
    await _stockfish.start();
    
    // Grundlegende Konfiguration der Engine
    _stockfish.stdin = 'uci';
    _stockfish.stdin = 'isready';
    
    _isInitialized = true;
  }

  /// Setzt die Schwierigkeit der KI.
  void setDifficulty(String level) {
    if (!_isInitialized) return;
    
    final elo = difficultyLevels[level] ?? 1600; // Standardmäßig mittlere Schwierigkeit
    
    // Konfiguriere die Engine entsprechend der Schwierigkeit
    _stockfish.stdin = 'setoption name Skill Level value ${_mapEloToSkillLevel(elo)}';
    _stockfish.stdin = 'setoption name UCI_LimitStrength value true';
    _stockfish.stdin = 'setoption name UCI_Elo value $elo';
  }

  /// Konvertiert ELO-Werte in Stockfish Skill Level (0-20).
  int _mapEloToSkillLevel(int elo) {
    // Einfache lineare Abbildung von ELO auf Skill Level
    // 800 ELO -> Skill Level 0
    // 2800 ELO -> Skill Level 20
    return ((elo - 800) / 100).round().clamp(0, 20);
  }

  /// Berechnet den besten Zug für die aktuelle Spielposition.
  Future<Move?> calculateBestMove(ChessBoard board, {int thinkingTimeMs = 1000}) async {
    if (!_isInitialized || _isThinking) return null;
    
    _isThinking = true;
    
    try {
      // Konvertiere das Schachbrett in FEN-Notation
      final fen = _boardToFen(board);
      
      // Setze die Position in der Engine
      _stockfish.stdin = 'position fen $fen';
      
      // Starte die Berechnung mit begrenzter Zeit
      _stockfish.stdin = 'go movetime $thinkingTimeMs';
      
      // Warte auf die Antwort der Engine
      String bestMoveString = '';
      await for (final line in _stockfish.stdout) {
        if (line.startsWith('bestmove')) {
          bestMoveString = line.split(' ')[1];
          break;
        }
      }
      
      if (bestMoveString.isEmpty) return null;
      
      // Konvertiere die Antwort in einen Move
      return _stringToMove(bestMoveString, board);
    } finally {
      _isThinking = false;
    }
  }

  /// Konvertiert das Schachbrett in FEN-Notation (Forsyth-Edwards Notation).
  String _boardToFen(ChessBoard board) {
    final StringBuffer fen = StringBuffer();
    
    // 1. Figurenpositionen
    for (int row = 0; row < 8; row++) {
      int emptyCount = 0;
      
      for (int col = 0; col < 8; col++) {
        final piece = board.getPiece(Position(row, col));
        
        if (piece == null) {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            fen.write(emptyCount);
            emptyCount = 0;
          }
          
          String pieceChar = _getPieceChar(piece);
          fen.write(pieceChar);
        }
      }
      
      if (emptyCount > 0) {
        fen.write(emptyCount);
      }
      
      if (row < 7) {
        fen.write('/');
      }
    }
    
    // 2. Aktiver Spieler
    fen.write(' ${board.currentTurn == PieceColor.white ? 'w' : 'b'} ');
    
    // 3. Rochaderechte (vereinfacht)
    String castlingRights = '';
    // Hier müsste eine komplexere Logik implementiert werden, um die tatsächlichen Rochaderechte zu bestimmen
    castlingRights = 'KQkq';
    fen.write('$castlingRights ');
    
    // 4. En-passant-Feld (vereinfacht)
    fen.write('- ');
    
    // 5. Halbzugzähler (für 50-Züge-Regel, vereinfacht)
    fen.write('0 ');
    
    // 6. Vollzugzähler
    fen.write('1');
    
    return fen.toString();
  }

  /// Gibt das Zeichen für eine Schachfigur in FEN-Notation zurück.
  String _getPieceChar(ChessPiece piece) {
    String char = '';
    
    switch (piece.type) {
      case PieceType.pawn:
        char = 'p';
        break;
      case PieceType.knight:
        char = 'n';
        break;
      case PieceType.bishop:
        char = 'b';
        break;
      case PieceType.rook:
        char = 'r';
        break;
      case PieceType.queen:
        char = 'q';
        break;
      case PieceType.king:
        char = 'k';
        break;
    }
    
    if (piece.color == PieceColor.white) {
      char = char.toUpperCase();
    }
    
    return char;
  }

  /// Konvertiert einen Zug in Stringform (z.B. "e2e4") in ein Move-Objekt.
  Move? _stringToMove(String moveString, ChessBoard board) {
    if (moveString.length < 4) return null;
    
    final fromAlgebraic = moveString.substring(0, 2);
    final toAlgebraic = moveString.substring(2, 4);
    
    final from = Position.fromAlgebraic(fromAlgebraic);
    final to = Position.fromAlgebraic(toAlgebraic);
    
    final piece = board.getPiece(from);
    if (piece == null) return null;
    
    final capturedPiece = board.getPiece(to);
    
    // Überprüfe auf Bauernumwandlung
    bool isPromotion = false;
    PieceType? promotionType;
    
    if (moveString.length > 4 && piece.type == PieceType.pawn) {
      if ((piece.color == PieceColor.white && to.row == 0) ||
          (piece.color == PieceColor.black && to.row == 7)) {
        isPromotion = true;
        
        // Das letzte Zeichen gibt den Typ der Umwandlungsfigur an
        final promotionChar = moveString.length > 4 ? moveString[4] : 'q';
        
        switch (promotionChar) {
          case 'q':
            promotionType = PieceType.queen;
            break;
          case 'r':
            promotionType = PieceType.rook;
            break;
          case 'b':
            promotionType = PieceType.bishop;
            break;
          case 'n':
            promotionType = PieceType.knight;
            break;
          default:
            promotionType = PieceType.queen; // Standard ist Dame
        }
      }
    }
    
    // Überprüfe auf Rochade
    bool isCastling = false;
    if (piece.type == PieceType.king && (from.col - to.col).abs() > 1) {
      isCastling = true;
    }
    
    // Überprüfe auf En Passant
    bool isEnPassant = false;
    if (piece.type == PieceType.pawn && 
        from.col != to.col && 
        capturedPiece == null) {
      isEnPassant = true;
    }
    
    return Move(
      from: from,
      to: to,
      capturedPiece: capturedPiece,
      isPromotion: isPromotion,
      promotionType: promotionType,
      isCastling: isCastling,
      isEnPassant: isEnPassant,
    );
  }

  /// Gibt zurück, ob die Engine bereit ist.
  bool get isReady => _isInitialized && !_isThinking;

  /// Beendet die Stockfish-Engine.
  void dispose() {
    if (_isInitialized) {
      _stockfish.stdin = 'quit';
      _stockfish.dispose();
      _isInitialized = false;
    }
  }
}
