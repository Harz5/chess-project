import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';

/// Service für Offline-Funktionalität
class OfflineService {
  // Singleton-Instanz
  static final OfflineService _instance = OfflineService._internal();
  
  factory OfflineService() {
    return _instance;
  }
  
  OfflineService._internal();
  
  /// Speichert ein Spiel lokal
  Future<bool> saveGame(ChessBoard board, String gameName, String variant) async {
    try {
      final gameData = {
        'name': gameName,
        'variant': variant,
        'date': DateTime.now().toIso8601String(),
        'board': _serializeBoard(board),
        'currentTurn': board.currentTurn == PieceColor.white ? 'white' : 'black',
        'moveHistory': _serializeMoveHistory(board.moveHistory),
        'gameOver': board.gameOver,
        'winner': board.winner == null 
            ? null 
            : (board.winner == PieceColor.white ? 'white' : 'black'),
      };
      
      final directory = await _getStorageDirectory();
      final file = File('${directory.path}/games/$gameName.json');
      
      // Erstelle das Verzeichnis, falls es nicht existiert
      await Directory('${directory.path}/games').create(recursive: true);
      
      // Speichere die Daten
      await file.writeAsString(jsonEncode(gameData));
      
      return true;
    } catch (e) {
      print('Fehler beim Speichern des Spiels: $e');
      return false;
    }
  }
  
  /// Lädt ein Spiel aus dem lokalen Speicher
  Future<Map<String, dynamic>?> loadGame(String gameName) async {
    try {
      final directory = await _getStorageDirectory();
      final file = File('${directory.path}/games/$gameName.json');
      
      if (!await file.exists()) {
        return null;
      }
      
      final jsonString = await file.readAsString();
      final gameData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return gameData;
    } catch (e) {
      print('Fehler beim Laden des Spiels: $e');
      return null;
    }
  }
  
  /// Gibt eine Liste aller gespeicherten Spiele zurück
  Future<List<Map<String, dynamic>>> getSavedGames() async {
    try {
      final directory = await _getStorageDirectory();
      final gamesDir = Directory('${directory.path}/games');
      
      if (!await gamesDir.exists()) {
        await gamesDir.create(recursive: true);
        return [];
      }
      
      final files = await gamesDir.list().where((entity) => 
          entity is File && entity.path.endsWith('.json')).toList();
      
      List<Map<String, dynamic>> games = [];
      
      for (var file in files) {
        if (file is File) {
          final jsonString = await file.readAsString();
          final gameData = jsonDecode(jsonString) as Map<String, dynamic>;
          games.add(gameData);
        }
      }
      
      // Sortiere nach Datum (neueste zuerst)
      games.sort((a, b) => 
          DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
      
      return games;
    } catch (e) {
      print('Fehler beim Abrufen der gespeicherten Spiele: $e');
      return [];
    }
  }
  
  /// Löscht ein gespeichertes Spiel
  Future<bool> deleteGame(String gameName) async {
    try {
      final directory = await _getStorageDirectory();
      final file = File('${directory.path}/games/$gameName.json');
      
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      
      return false;
    } catch (e) {
      print('Fehler beim Löschen des Spiels: $e');
      return false;
    }
  }
  
  /// Exportiert ein Spiel im PGN-Format (Portable Game Notation)
  Future<String?> exportGameAsPGN(String gameName) async {
    try {
      final gameData = await loadGame(gameName);
      if (gameData == null) return null;
      
      final variant = gameData['variant'];
      final date = DateTime.parse(gameData['date']);
      final formattedDate = '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
      
      // PGN-Header
      StringBuffer pgn = StringBuffer();
      pgn.writeln('[Event "Offline Game"]');
      pgn.writeln('[Site "Chess App"]');
      pgn.writeln('[Date "$formattedDate"]');
      pgn.writeln('[White "Player"]');
      pgn.writeln('[Black "Opponent"]');
      pgn.writeln('[Result "${_getPGNResult(gameData)}"]');
      pgn.writeln('[Variant "$variant"]');
      pgn.writeln();
      
      // Züge
      final moveHistory = gameData['moveHistory'] as List;
      for (int i = 0; i < moveHistory.length; i++) {
        final move = moveHistory[i];
        if (i % 2 == 0) {
          pgn.write('${(i ~/ 2) + 1}. ');
        }
        pgn.write('${move['notation']} ');
        if (i % 2 == 1) {
          pgn.writeln();
        }
      }
      
      // Ergebnis
      pgn.writeln(_getPGNResult(gameData));
      
      // Speichere die PGN-Datei
      final directory = await _getStorageDirectory();
      final file = File('${directory.path}/exports/$gameName.pgn');
      
      // Erstelle das Verzeichnis, falls es nicht existiert
      await Directory('${directory.path}/exports').create(recursive: true);
      
      // Speichere die Daten
      await file.writeAsString(pgn.toString());
      
      return file.path;
    } catch (e) {
      print('Fehler beim Exportieren des Spiels: $e');
      return null;
    }
  }
  
  /// Importiert ein Spiel im PGN-Format
  Future<bool> importGameFromPGN(String pgnContent, String gameName) async {
    try {
      // PGN-Parser implementieren
      // Dies ist eine vereinfachte Version, die nur grundlegende PGN-Dateien verarbeitet
      
      Map<String, String> headers = {};
      List<String> moves = [];
      
      final lines = pgnContent.split('\n');
      bool inMoveSection = false;
      
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) {
          inMoveSection = true;
          continue;
        }
        
        if (!inMoveSection && line.startsWith('[') && line.endsWith(']')) {
          // Header-Zeile
          final headerMatch = RegExp(r'\[(.*) "(.*?)"\]').firstMatch(line);
          if (headerMatch != null) {
            headers[headerMatch.group(1)!] = headerMatch.group(2)!;
          }
        } else if (inMoveSection) {
          // Zug-Zeile
          // Entferne Zugnummern und Kommentare
          var cleanLine = line.replaceAll(RegExp(r'\d+\.'), '');
          cleanLine = cleanLine.replaceAll(RegExp(r'\{.*?\}'), '');
          
          // Teile die Zeile in einzelne Züge
          final movesInLine = cleanLine.split(' ')
              .where((m) => m.isNotEmpty && !m.contains('1-0') && !m.contains('0-1') && !m.contains('1/2-1/2') && !m.contains('*'))
              .toList();
          
          moves.addAll(movesInLine);
        }
      }
      
      // Erstelle ein neues Spiel basierend auf den PGN-Daten
      final variant = headers['Variant'] ?? 'standard';
      final result = headers['Result'] ?? '*';
      
      // Hier würde man das Spiel rekonstruieren und speichern
      // Dies erfordert eine komplexe Implementierung, die über den Rahmen dieses Beispiels hinausgeht
      
      // Für dieses Beispiel speichern wir einfach die PGN-Daten
      final directory = await _getStorageDirectory();
      final file = File('${directory.path}/imports/$gameName.pgn');
      
      // Erstelle das Verzeichnis, falls es nicht existiert
      await Directory('${directory.path}/imports').create(recursive: true);
      
      // Speichere die Daten
      await file.writeAsString(pgnContent);
      
      return true;
    } catch (e) {
      print('Fehler beim Importieren des Spiels: $e');
      return false;
    }
  }
  
  /// Synchronisiert lokale Spiele mit dem Server
  Future<bool> synchronizeGames() async {
    // Diese Funktion würde lokale Spiele mit einem Server synchronisieren
    // Dies erfordert eine Server-Implementierung, die über den Rahmen dieses Beispiels hinausgeht
    return true;
  }
  
  // Private Hilfsmethoden
  
  Future<Directory> _getStorageDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }
  
  Map<String, dynamic> _serializeBoard(ChessBoard board) {
    List<List<Map<String, dynamic>?>> serializedBoard = List.generate(
      8, (_) => List.generate(8, (_) => null)
    );
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.getPiece(Position(row: row, col: col));
        if (piece != null) {
          serializedBoard[row][col] = {
            'type': piece.type.toString().split('.').last,
            'color': piece.color == PieceColor.white ? 'white' : 'black',
            'hasMoved': piece.hasMoved,
          };
        }
      }
    }
    
    return {
      'pieces': serializedBoard,
    };
  }
  
  List<Map<String, dynamic>> _serializeMoveHistory(List<Move> moveHistory) {
    return moveHistory.map((move) {
      return {
        'from': {
          'row': move.from.row,
          'col': move.from.col,
        },
        'to': {
          'row': move.to.row,
          'col': move.to.col,
        },
        'capturedPiece': move.capturedPiece == null ? null : {
          'type': move.capturedPiece!.type.toString().split('.').last,
          'color': move.capturedPiece!.color == PieceColor.white ? 'white' : 'black',
        },
        'isPromotion': move.isPromotion,
        'promotionType': move.promotionType?.toString().split('.').last,
        'isCastling': move.isCastling,
        'isEnPassant': move.isEnPassant,
        'notation': _moveToAlgebraicNotation(move),
      };
    }).toList();
  }
  
  String _moveToAlgebraicNotation(Move move) {
    // Vereinfachte Implementierung der algebraischen Notation
    final from = String.fromCharCode('a'.codeUnitAt(0) + move.from.col) + (8 - move.from.row).toString();
    final to = String.fromCharCode('a'.codeUnitAt(0) + move.to.col) + (8 - move.to.row).toString();
    
    return '$from$to';
  }
  
  String _getPGNResult(Map<String, dynamic> gameData) {
    if (!gameData['gameOver']) return '*';
    
    if (gameData['winner'] == null) {
      return '1/2-1/2'; // Unentschieden
    } else if (gameData['winner'] == 'white') {
      return '1-0'; // Weiß gewinnt
    } else {
      return '0-1'; // Schwarz gewinnt
    }
  }
}
