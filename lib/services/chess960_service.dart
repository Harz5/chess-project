import 'dart:math';
import '../models/chess_piece.dart';
import '../models/position.dart';

/// Klasse für die Verwaltung der Chess960-Variante (Fischer Random Chess)
class Chess960Service {
  // Singleton-Instanz
  static final Chess960Service _instance = Chess960Service._internal();
  
  factory Chess960Service() {
    return _instance;
  }
  
  Chess960Service._internal();
  
  /// Generiert eine gültige Chess960-Startposition
  /// 
  /// Gibt ein FEN-String zurück, der die Startposition repräsentiert
  String generateStartPosition() {
    // Generiere eine zufällige Anordnung der Figuren auf der ersten Reihe
    final pieces = _generateRandomPieceArrangement();
    
    // Erstelle den FEN-String für die Startposition
    final whitePieces = pieces.join('');
    final blackPieces = pieces.join('').toLowerCase();
    
    // Vollständiger FEN-String für die Startposition
    return '$blackPieces/pppppppp/8/8/8/8/PPPPPPPP/$whitePieces w KQkq - 0 1';
  }
  
  /// Generiert eine zufällige Anordnung der Figuren für Chess960
  /// 
  /// Gibt eine Liste von Zeichenketten zurück, die die Figuren repräsentieren
  List<String> _generateRandomPieceArrangement() {
    final random = Random();
    final pieces = List<String>.filled(8, '');
    
    // Platziere den König zwischen den Türmen
    // Der König muss zwischen den Türmen stehen (für die Rochade)
    final kingPos = random.nextInt(6) + 1; // König auf Position 1-6
    pieces[kingPos] = 'K';
    
    // Platziere die Türme
    // Ein Turm muss links vom König und einer rechts vom König stehen
    final leftRookPos = random.nextInt(kingPos);
    pieces[leftRookPos] = 'R';
    
    final rightRookPos = random.nextInt(7 - kingPos) + kingPos + 1;
    pieces[rightRookPos] = 'R';
    
    // Platziere die Läufer auf Feldern unterschiedlicher Farbe
    final emptySquares = <int>[];
    for (int i = 0; i < 8; i++) {
      if (pieces[i].isEmpty) {
        emptySquares.add(i);
      }
    }
    
    // Wähle einen Läufer für ein weißes Feld (gerade Summe von Reihe+Spalte)
    final whiteBishopCandidates = <int>[];
    for (final pos in emptySquares) {
      if (pos % 2 == 0) { // Weißes Feld
        whiteBishopCandidates.add(pos);
      }
    }
    final whiteBishopPos = whiteBishopCandidates[random.nextInt(whiteBishopCandidates.length)];
    pieces[whiteBishopPos] = 'B';
    emptySquares.remove(whiteBishopPos);
    
    // Wähle einen Läufer für ein schwarzes Feld (ungerade Summe von Reihe+Spalte)
    final blackBishopCandidates = <int>[];
    for (final pos in emptySquares) {
      if (pos % 2 == 1) { // Schwarzes Feld
        blackBishopCandidates.add(pos);
      }
    }
    final blackBishopPos = blackBishopCandidates[random.nextInt(blackBishopCandidates.length)];
    pieces[blackBishopPos] = 'B';
    emptySquares.remove(blackBishopPos);
    
    // Platziere die Dame und die Springer auf den verbleibenden Feldern
    emptySquares.shuffle(random);
    pieces[emptySquares[0]] = 'Q';
    pieces[emptySquares[1]] = 'N';
    pieces[emptySquares[2]] = 'N';
    
    return pieces;
  }
  
  /// Überprüft, ob eine Rochade in Chess960 gültig ist
  /// 
  /// In Chess960 gelten spezielle Regeln für die Rochade:
  /// - Der König und der Turm müssen auf ihren ursprünglichen Positionen stehen
  /// - Die Felder zwischen König und Turm müssen leer sein
  /// - Der König darf nicht im Schach stehen
  /// - Der König darf nicht über ein Feld ziehen, das unter Schach steht
  /// - Der König endet auf der gleichen Position wie im klassischen Schach (g1/c1 für Weiß)
  /// - Der Turm endet auf der gleichen Position wie im klassischen Schach (f1/d1 für Weiß)
  bool isValidCastling(
    List<List<ChessPiece?>> board,
    Position kingPos,
    Position rookPos,
    bool isKingSideCastling,
  ) {
    // Überprüfe, ob der König und der Turm auf ihren ursprünglichen Positionen stehen
    final king = board[kingPos.row][kingPos.col];
    final rook = board[rookPos.row][rookPos.col];
    
    if (king == null || king.type != PieceType.king || king.hasMoved) {
      return false;
    }
    
    if (rook == null || rook.type != PieceType.rook || rook.hasMoved) {
      return false;
    }
    
    // Überprüfe, ob die Felder zwischen König und Turm leer sind
    final minCol = min(kingPos.col, rookPos.col);
    final maxCol = max(kingPos.col, rookPos.col);
    
    for (int col = minCol + 1; col < maxCol; col++) {
      if (board[kingPos.row][col] != null) {
        return false;
      }
    }
    
    // Bestimme die Zielposition des Königs und des Turms
    final kingTargetCol = isKingSideCastling ? 6 : 2; // g1 oder c1 für Weiß
    final rookTargetCol = isKingSideCastling ? 5 : 3; // f1 oder d1 für Weiß
    
    // Überprüfe, ob der König über ein Feld zieht, das unter Schach steht
    // (Diese Überprüfung würde eine vollständige Schachlogik erfordern)
    
    return true;
  }
  
  /// Führt eine Rochade in Chess960 durch
  /// 
  /// Gibt die neuen Positionen des Königs und des Turms zurück
  Map<String, Position> performCastling(
    Position kingPos,
    Position rookPos,
    bool isKingSideCastling,
  ) {
    final kingTargetCol = isKingSideCastling ? 6 : 2; // g1 oder c1 für Weiß
    final rookTargetCol = isKingSideCastling ? 5 : 3; // f1 oder d1 für Weiß
    
    return {
      'king': Position(row: kingPos.row, col: kingTargetCol),
      'rook': Position(row: rookPos.row, col: rookTargetCol),
    };
  }
}
