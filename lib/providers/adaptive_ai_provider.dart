import 'package:flutter/material.dart';
import '../services/adaptive_ai_service.dart';
import '../models/chess_board.dart';
import '../models/position.dart';

/// Provider für die Verwaltung der adaptiven KI-Funktionalität
class AdaptiveAIProvider extends ChangeNotifier {
  final AdaptiveAIService _aiService = AdaptiveAIService();
  
  // Status
  bool _isInitialized = false;
  bool _isThinking = false;
  String _errorMessage = '';
  
  // KI-Einstellungen
  String _difficulty = 'Mittel';
  bool _adaptiveDifficultyEnabled = true;
  String _playStyle = 'Ausgewogen';
  
  // Leistungsmetriken
  int _playerRating = 1200;
  int _aiRating = 1200;
  
  // Getter
  bool get isInitialized => _isInitialized;
  bool get isThinking => _isThinking;
  String get errorMessage => _errorMessage;
  String get difficulty => _difficulty;
  bool get adaptiveDifficultyEnabled => _adaptiveDifficultyEnabled;
  String get playStyle => _playStyle;
  int get playerRating => _playerRating;
  int get aiRating => _aiRating;
  
  // Verfügbare Optionen
  List<String> get availableDifficulties => _aiService.getAvailableDifficulties();
  List<String> get availablePlayStyles => _aiService.getAvailablePlayStyles();
  
  AdaptiveAIProvider() {
    _initializeService();
  }
  
  /// Initialisiert den AI-Service
  Future<void> _initializeService() async {
    try {
      await _aiService.initialize();
      _isInitialized = true;
      _updateSettings();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Fehler bei der Initialisierung der KI: $e';
      notifyListeners();
    }
  }
  
  /// Aktualisiert die KI-Einstellungen
  void _updateSettings() {
    _aiService.setDifficulty(_difficulty);
    _aiService.setAdaptiveDifficulty(_adaptiveDifficultyEnabled);
    _aiService.setPlayStyle(_playStyle);
    
    // Aktualisiere die Leistungsmetriken
    _playerRating = _aiService.getPlayerRating();
    _aiRating = _aiService.getAIRating();
  }
  
  /// Setzt die Schwierigkeit der KI
  void setDifficulty(String difficulty) {
    if (_difficulty != difficulty) {
      _difficulty = difficulty;
      if (_isInitialized) {
        _aiService.setDifficulty(_difficulty);
        notifyListeners();
      }
    }
  }
  
  /// Aktiviert oder deaktiviert die adaptive Schwierigkeitsanpassung
  void setAdaptiveDifficulty(bool enabled) {
    if (_adaptiveDifficultyEnabled != enabled) {
      _adaptiveDifficultyEnabled = enabled;
      if (_isInitialized) {
        _aiService.setAdaptiveDifficulty(_adaptiveDifficultyEnabled);
        notifyListeners();
      }
    }
  }
  
  /// Setzt den Spielstil der KI
  void setPlayStyle(String playStyle) {
    if (_playStyle != playStyle) {
      _playStyle = playStyle;
      if (_isInitialized) {
        _aiService.setPlayStyle(_playStyle);
        notifyListeners();
      }
    }
  }
  
  /// Berechnet den besten Zug für die aktuelle Spielposition
  Future<Move?> calculateBestMove(ChessBoard board, {int thinkingTimeMs = 1000}) async {
    if (!_isInitialized) {
      await _initializeService();
    }
    
    if (_isThinking) return null;
    
    _isThinking = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final move = await _aiService.calculateBestMove(board, thinkingTimeMs: thinkingTimeMs);
      _isThinking = false;
      notifyListeners();
      return move;
    } catch (e) {
      _errorMessage = 'Fehler bei der Berechnung des Zugs: $e';
      _isThinking = false;
      notifyListeners();
      return null;
    }
  }
  
  /// Aktualisiert die Spielerleistung nach einem Spiel
  void updatePlayerPerformance(bool playerWon, int moveCount, int capturedPieces) {
    if (_isInitialized) {
      _aiService.updatePlayerPerformance(playerWon, moveCount, capturedPieces);
      
      // Aktualisiere die Leistungsmetriken
      _playerRating = _aiService.getPlayerRating();
      _aiRating = _aiService.getAIRating();
      
      // Aktualisiere die aktuelle Schwierigkeit, falls sie sich geändert hat
      _difficulty = _aiService.getCurrentDifficulty();
      
      notifyListeners();
    }
  }
  
  /// Analysiert die Spielweise des Spielers
  void analyzePlayerStyle(List<Move> playerMoves, ChessBoard board) {
    if (_isInitialized) {
      _aiService.analyzePlayerStyle(playerMoves, board);
    }
  }
  
  @override
  void dispose() {
    if (_isInitialized) {
      _aiService.dispose();
    }
    super.dispose();
  }
}
