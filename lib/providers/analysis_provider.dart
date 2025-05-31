import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../services/analysis_service.dart';

/// Provider für die Verwaltung der Spielanalyse
class AnalysisProvider extends ChangeNotifier {
  final AnalysisService _analysisService = AnalysisService();

  Map<String, dynamic>? _gameAnalysis;
  Map<String, dynamic>? _movementHeatmap;
  Map<String, dynamic>? _controlHeatmap;
  List<Map<String, dynamic>>? _bestMoves;
  Map<String, dynamic>? _masterGameComparison;
  List<Map<String, dynamic>>? _improvementSuggestions;

  bool _isLoading = false;

  // Getter
  Map<String, dynamic>? get gameAnalysis => _gameAnalysis;
  Map<String, dynamic>? get movementHeatmap => _movementHeatmap;
  Map<String, dynamic>? get controlHeatmap => _controlHeatmap;
  List<Map<String, dynamic>>? get bestMoves => _bestMoves;
  Map<String, dynamic>? get masterGameComparison => _masterGameComparison;
  List<Map<String, dynamic>>? get improvementSuggestions =>
      _improvementSuggestions;
  bool get isLoading => _isLoading;

  /// Analysiert das aktuelle Spiel
  Future<void> analyzeGame(ChessBoard board) async {
    _isLoading = true;
    notifyListeners();

    // Führe die Analysen parallel aus
    await Future.wait([
      Future(() {
        _gameAnalysis = _analysisService.analyzeGame(board, board.moveHistory);
      }),
      Future(() {
        _movementHeatmap =
            _analysisService.generateMovementHeatmap(board.moveHistory);
      }),
      Future(() {
        _controlHeatmap = _analysisService.generateControlHeatmap(board);
      }),
      Future(() {
        _bestMoves = _analysisService.findBestMoves(board);
      }),
      Future(() {
        _masterGameComparison =
            _analysisService.compareWithMasterGame(board.moveHistory);
      }),
      Future(() {
        _improvementSuggestions =
            _analysisService.generateImprovementSuggestions(board.moveHistory);
      }),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  /// Findet die besten Züge in der aktuellen Position
  Future<void> findBestMoves(ChessBoard board) async {
    _isLoading = true;
    notifyListeners();

    _bestMoves = _analysisService.findBestMoves(board);

    _isLoading = false;
    notifyListeners();
  }

  /// Generiert Verbesserungsvorschläge für das Spiel
  Future<void> generateImprovementSuggestions(ChessBoard board) async {
    _isLoading = true;
    notifyListeners();

    _improvementSuggestions =
        _analysisService.generateImprovementSuggestions(board.moveHistory);

    _isLoading = false;
    notifyListeners();
  }

  /// Löscht alle Analysedaten
  void clearAnalysis() {
    _gameAnalysis = null;
    _movementHeatmap = null;
    _controlHeatmap = null;
    _bestMoves = null;
    _masterGameComparison = null;
    _improvementSuggestions = null;
    notifyListeners();
  }
}
