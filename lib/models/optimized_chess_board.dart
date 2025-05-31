import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../services/performance_optimization_service.dart';

/// Eine optimierte Version der ChessBoard-Klasse mit Leistungsverbesserungen
class OptimizedChessBoard extends ChessBoard {
  // Performance-Optimierungsservice
  final PerformanceOptimizationService _performanceService = PerformanceOptimizationService();
  
  OptimizedChessBoard() : super() {
    // Initialisiere den Cache-Bereinigungstimer
    _performanceService.initCacheCleanup();
  }
  
  @override
  List<Move> getValidMovesForPiece(Position position) {
    final piece = getPiece(position);
    if (piece == null || piece.color != currentTurn) {
      return [];
    }
    
    // Verwende den Optimierungsservice, um die Berechnung zu beschleunigen
    return _performanceService.optimizeValidMoveCalculation(
      _board, 
      position, 
      currentTurn,
      (pos) => super.getValidMovesForPiece(pos)
    );
  }
  
  @override
  bool isPositionUnderAttack(Position position, PieceColor color) {
    // Verwende den Optimierungsservice, um die Überprüfung zu beschleunigen
    return _performanceService.optimizeCheckDetection(
      _board,
      color,
      (kingColor) => super.isPositionUnderAttack(position, kingColor)
    );
  }
  
  @override
  bool makeMove(Move move) {
    final result = super.makeMove(move);
    
    // Wenn der Zug erfolgreich war, invalidiere den Cache
    if (result) {
      _performanceService.invalidateCacheForBoard(_board);
    }
    
    return result;
  }
  
  /// Gibt Ressourcen frei, wenn das Brett nicht mehr benötigt wird
  void dispose() {
    _performanceService.dispose();
  }
}
