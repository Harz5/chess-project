import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../services/ai_service.dart';

/// Provider für die Verwaltung der KI-Funktionalität
class AIProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  bool _isInitialized = false;
  bool _isThinking = false;
  String _difficulty = "Mittel";

  // Getter
  bool get isInitialized => _isInitialized;
  bool get isThinking => _isThinking;
  String get difficulty => _difficulty;

  /// Initialisiert den AI-Provider
  Future<void> initialize() async {
    if (!_isInitialized) {
      await _aiService.initialize();
      _aiService.setDifficulty(_difficulty);
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Setzt die Schwierigkeit der KI
  void setDifficulty(String difficulty) {
    _difficulty = difficulty;
    if (_isInitialized) {
      _aiService.setDifficulty(difficulty);
      notifyListeners();
    }
  }

  /// Berechnet den besten Zug für die aktuelle Spielposition
  Future<Move?> calculateBestMove(ChessBoard board,
      {int thinkingTimeMs = 1000}) async {
    if (!_isInitialized || _isThinking) return null;

    _isThinking = true;
    notifyListeners();

    try {
      final move = await _aiService.calculateBestMove(board,
          thinkingTimeMs: thinkingTimeMs);
      return move;
    } finally {
      _isThinking = false;
      notifyListeners();
    }
  }

  /// Gibt zurück, ob die KI bereit ist
  bool get isReady => _isInitialized && !_isThinking;

  @override
  void dispose() {
    _aiService.dispose();
    super.dispose();
  }
}
