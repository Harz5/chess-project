import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chess_board.dart';
import '../models/position.dart';
import '../models/chess_piece.dart';

/// Service für die Online-Multiplayer-Funktionalität.
class OnlineGameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Erstellt ein neues Online-Spiel und gibt die Spiel-ID zurück.
  Future<String> createGame() async {
    // Stelle sicher, dass der Benutzer angemeldet ist
    User? user = _auth.currentUser;
    user ??= await _signInAnonymously();

    // Erstelle ein neues Spiel in Firestore
    final gameRef = await _firestore.collection('games').add({
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': user.uid,
      'whitePlayer': user.uid,
      'blackPlayer': null,
      'status': 'waiting', // waiting, active, completed
      'currentTurn': 'white',
      'winner': null,
      'moves': [],
      'board': _serializeInitialBoard(),
    });

    return gameRef.id;
  }

  /// Tritt einem existierenden Spiel bei.
  Future<bool> joinGame(String gameId) async {
    // Stelle sicher, dass der Benutzer angemeldet ist
    User? user = _auth.currentUser;
    user ??= await _signInAnonymously();

    // Überprüfe, ob das Spiel existiert und noch auf einen Spieler wartet
    final gameDoc = await _firestore.collection('games').doc(gameId).get();
    if (!gameDoc.exists) {
      return false;
    }

    final gameData = gameDoc.data() as Map<String, dynamic>;
    if (gameData['status'] != 'waiting') {
      return false;
    }

    // Verhindere, dass der Ersteller auch als zweiter Spieler beitritt
    if (gameData['createdBy'] == user.uid) {
      return false;
    }

    // Trete dem Spiel bei
    await _firestore.collection('games').doc(gameId).update({
      'blackPlayer': user.uid,
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return true;
  }

  /// Führt einen Zug in einem Online-Spiel aus.
  Future<bool> makeMove(String gameId, Position from, Position to) async {
    // Stelle sicher, dass der Benutzer angemeldet ist
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    // Überprüfe, ob das Spiel existiert und aktiv ist
    final gameDoc = await _firestore.collection('games').doc(gameId).get();
    if (!gameDoc.exists) {
      return false;
    }

    final gameData = gameDoc.data() as Map<String, dynamic>;
    if (gameData['status'] != 'active') {
      return false;
    }

    // Überprüfe, ob der Benutzer am Zug ist
    final isWhiteTurn = gameData['currentTurn'] == 'white';
    final isUserWhite = gameData['whitePlayer'] == user.uid;
    final isUserBlack = gameData['blackPlayer'] == user.uid;

    if ((isWhiteTurn && !isUserWhite) || (!isWhiteTurn && !isUserBlack)) {
      return false;
    }

    // Deserialisiere das Spielbrett
    final board = _deserializeBoard(gameData['board']);

    // Überprüfe, ob der Zug gültig ist
    final validMoves = board.getValidMovesForPiece(from);
    final move = validMoves.firstWhere(
      (m) => m.from == from && m.to == to,
      orElse: () => Move(from: from, to: to),
    );

    final success = board.makeMove(move);
    if (!success) {
      return false;
    }

    // Aktualisiere das Spiel in Firestore
    await _firestore.collection('games').doc(gameId).update({
      'board': _serializeBoard(board),
      'currentTurn': isWhiteTurn ? 'black' : 'white',
      'moves': FieldValue.arrayUnion([
        {
          'from': from.toAlgebraic(),
          'to': to.toAlgebraic(),
          'player': isWhiteTurn ? 'white' : 'black',
          'timestamp': FieldValue.serverTimestamp(),
        }
      ]),
      'status': board.gameOver ? 'completed' : 'active',
      'winner': board.gameOver
          ? (board.winner == PieceColor.white
              ? 'white'
              : board.winner == PieceColor.black
                  ? 'black'
                  : 'draw')
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return true;
  }

  /// Hört auf Änderungen in einem Spiel.
  Stream<DocumentSnapshot> listenToGame(String gameId) {
    return _firestore.collection('games').doc(gameId).snapshots();
  }

  /// Meldet den Benutzer anonym an.
  Future<User> _signInAnonymously() async {
    final userCredential = await _auth.signInAnonymously();
    return userCredential.user!;
  }

  /// Serialisiert das initiale Schachbrett für Firestore.
  Map<String, dynamic> _serializeInitialBoard() {
    final board = ChessBoard();
    return _serializeBoard(board);
  }

  /// Serialisiert ein Schachbrett für Firestore.
  Map<String, dynamic> _serializeBoard(ChessBoard board) {
    final serializedBoard = <String, dynamic>{
      'currentTurn': board.currentTurn == PieceColor.white ? 'white' : 'black',
      'gameOver': board.gameOver,
      'winner': board.winner == null
          ? null
          : board.winner == PieceColor.white
              ? 'white'
              : 'black',
      'pieces': <Map<String, dynamic>>[],
    };

    // Serialisiere alle Figuren
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final position = Position(row, col);
        final piece = board.getPiece(position);
        if (piece != null) {
          serializedBoard['pieces'].add({
            'position': position.toAlgebraic(),
            'type': piece.type.toString().split('.').last,
            'color': piece.color == PieceColor.white ? 'white' : 'black',
            'hasMoved': piece.hasMoved,
          });
        }
      }
    }

    return serializedBoard;
  }

  /// Deserialisiert ein Schachbrett aus Firestore.
  ChessBoard _deserializeBoard(Map<String, dynamic> data) {
    final board = ChessBoard.custom();

    // Setze den aktuellen Spieler
    board.currentTurn =
        data['currentTurn'] == 'white' ? PieceColor.white : PieceColor.black;

    // Setze den Spielstatus
    board.gameOver = data['gameOver'] ?? false;
    if (data['winner'] == 'white') {
      board.winner = PieceColor.white;
    } else if (data['winner'] == 'black') {
      board.winner = PieceColor.black;
    } else {
      board.winner = null;
    }

    // Setze die Figuren
    final pieces = data['pieces'] as List<dynamic>;
    for (final pieceData in pieces) {
      final position = Position.fromAlgebraic(pieceData['position']);
      final color =
          pieceData['color'] == 'white' ? PieceColor.white : PieceColor.black;

      PieceType type;
      switch (pieceData['type']) {
        case 'pawn':
          type = PieceType.pawn;
          break;
        case 'knight':
          type = PieceType.knight;
          break;
        case 'bishop':
          type = PieceType.bishop;
          break;
        case 'rook':
          type = PieceType.rook;
          break;
        case 'queen':
          type = PieceType.queen;
          break;
        case 'king':
          type = PieceType.king;
          break;
        default:
          throw ArgumentError('Ungültiger Figurentyp: ${pieceData['type']}');
      }

      final piece = ChessPiece(color, type);
      piece.hasMoved = pieceData['hasMoved'] ?? false;
      board.setPiece(position, piece);
    }

    return board;
  }
}
