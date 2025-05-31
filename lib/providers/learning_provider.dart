import 'package:flutter/material.dart';
import '../services/learning_service.dart';
import '../models/lesson.dart';
import '../models/puzzle.dart';
import '../models/opening.dart';
import '../models/user_progress.dart';

/// Provider für die Verwaltung der erweiterten Lernfunktionen
class LearningProvider extends ChangeNotifier {
  final LearningService _learningService = LearningService();
  
  // Lektionen
  List<Lesson> _lessons = [];
  bool _isLoadingLessons = false;
  String _lessonsError = '';
  
  // Schachprobleme
  List<Puzzle> _puzzles = [];
  bool _isLoadingPuzzles = false;
  String _puzzlesError = '';
  
  // Eröffnungen
  List<Opening> _openings = [];
  bool _isLoadingOpenings = false;
  String _openingsError = '';
  
  // Benutzerfortschritt
  UserProgress? _userProgress;
  bool _isLoadingProgress = false;
  String _progressError = '';
  
  // Empfehlungen
  List<dynamic> _recommendations = [];
  bool _isLoadingRecommendations = false;
  String _recommendationsError = '';
  
  // Tägliche Herausforderungen
  List<dynamic> _dailyChallenges = [];
  bool _isLoadingChallenges = false;
  String _challengesError = '';
  
  // Lernstatistiken
  Map<String, dynamic> _learningStats = {};
  bool _isLoadingStats = false;
  String _statsError = '';
  
  // Getter
  List<Lesson> get lessons => _lessons;
  bool get isLoadingLessons => _isLoadingLessons;
  String get lessonsError => _lessonsError;
  
  List<Puzzle> get puzzles => _puzzles;
  bool get isLoadingPuzzles => _isLoadingPuzzles;
  String get puzzlesError => _puzzlesError;
  
  List<Opening> get openings => _openings;
  bool get isLoadingOpenings => _isLoadingOpenings;
  String get openingsError => _openingsError;
  
  UserProgress? get userProgress => _userProgress;
  bool get isLoadingProgress => _isLoadingProgress;
  String get progressError => _progressError;
  
  List<dynamic> get recommendations => _recommendations;
  bool get isLoadingRecommendations => _isLoadingRecommendations;
  String get recommendationsError => _recommendationsError;
  
  List<dynamic> get dailyChallenges => _dailyChallenges;
  bool get isLoadingChallenges => _isLoadingChallenges;
  String get challengesError => _challengesError;
  
  Map<String, dynamic> get learningStats => _learningStats;
  bool get isLoadingStats => _isLoadingStats;
  String get statsError => _statsError;
  
  // Konstruktor
  LearningProvider() {
    _initialize();
  }
  
  // Initialisierung
  Future<void> _initialize() async {
    await loadUserProgress();
    await loadLearningStats();
    await loadRecommendations();
    await loadDailyChallenges();
  }
  
  // Lektionen laden
  Future<void> loadLessons({String? category, String? difficulty}) async {
    _isLoadingLessons = true;
    _lessonsError = '';
    notifyListeners();
    
    try {
      _lessons = await _learningService.getLessons(
        category: category,
        difficulty: difficulty,
      );
      _isLoadingLessons = false;
      notifyListeners();
    } catch (e) {
      _lessonsError = 'Fehler beim Laden der Lektionen: $e';
      _isLoadingLessons = false;
      notifyListeners();
    }
  }
  
  // Einzelne Lektion laden
  Future<Lesson?> loadLesson(String lessonId) async {
    _isLoadingLessons = true;
    _lessonsError = '';
    notifyListeners();
    
    try {
      final lesson = await _learningService.getLesson(lessonId);
      _isLoadingLessons = false;
      notifyListeners();
      return lesson;
    } catch (e) {
      _lessonsError = 'Fehler beim Laden der Lektion: $e';
      _isLoadingLessons = false;
      notifyListeners();
      return null;
    }
  }
  
  // Schachprobleme laden
  Future<void> loadPuzzles({String? difficulty, String? category}) async {
    _isLoadingPuzzles = true;
    _puzzlesError = '';
    notifyListeners();
    
    try {
      _puzzles = await _learningService.getPuzzles(
        difficulty: difficulty,
        category: category,
      );
      _isLoadingPuzzles = false;
      notifyListeners();
    } catch (e) {
      _puzzlesError = 'Fehler beim Laden der Schachprobleme: $e';
      _isLoadingPuzzles = false;
      notifyListeners();
    }
  }
  
  // Einzelnes Schachproblem laden
  Future<Puzzle?> loadPuzzle(String puzzleId) async {
    _isLoadingPuzzles = true;
    _puzzlesError = '';
    notifyListeners();
    
    try {
      final puzzle = await _learningService.getPuzzle(puzzleId);
      _isLoadingPuzzles = false;
      notifyListeners();
      return puzzle;
    } catch (e) {
      _puzzlesError = 'Fehler beim Laden des Schachproblems: $e';
      _isLoadingPuzzles = false;
      notifyListeners();
      return null;
    }
  }
  
  // Zufälliges Schachproblem laden
  Future<Puzzle?> loadRandomPuzzle({String? difficulty, String? category}) async {
    _isLoadingPuzzles = true;
    _puzzlesError = '';
    notifyListeners();
    
    try {
      final puzzle = await _learningService.getRandomPuzzle(
        difficulty: difficulty,
        category: category,
      );
      _isLoadingPuzzles = false;
      notifyListeners();
      return puzzle;
    } catch (e) {
      _puzzlesError = 'Fehler beim Laden eines zufälligen Schachproblems: $e';
      _isLoadingPuzzles = false;
      notifyListeners();
      return null;
    }
  }
  
  // Eröffnungen laden
  Future<void> loadOpenings({String? category}) async {
    _isLoadingOpenings = true;
    _openingsError = '';
    notifyListeners();
    
    try {
      _openings = await _learningService.getOpenings(
        category: category,
      );
      _isLoadingOpenings = false;
      notifyListeners();
    } catch (e) {
      _openingsError = 'Fehler beim Laden der Eröffnungen: $e';
      _isLoadingOpenings = false;
      notifyListeners();
    }
  }
  
  // Einzelne Eröffnung laden
  Future<Opening?> loadOpening(String openingId) async {
    _isLoadingOpenings = true;
    _openingsError = '';
    notifyListeners();
    
    try {
      final opening = await _learningService.getOpening(openingId);
      _isLoadingOpenings = false;
      notifyListeners();
      return opening;
    } catch (e) {
      _openingsError = 'Fehler beim Laden der Eröffnung: $e';
      _isLoadingOpenings = false;
      notifyListeners();
      return null;
    }
  }
  
  // Benutzerfortschritt laden
  Future<void> loadUserProgress() async {
    _isLoadingProgress = true;
    _progressError = '';
    notifyListeners();
    
    try {
      _userProgress = await _learningService.getUserProgress();
      _isLoadingProgress = false;
      notifyListeners();
    } catch (e) {
      _progressError = 'Fehler beim Laden des Benutzerfortschritts: $e';
      _isLoadingProgress = false;
      notifyListeners();
    }
  }
  
  // Benutzerfortschritt aktualisieren
  Future<bool> updateUserProgress(UserProgress progress) async {
    _isLoadingProgress = true;
    _progressError = '';
    notifyListeners();
    
    try {
      final success = await _learningService.updateUserProgress(progress);
      
      if (success) {
        _userProgress = progress;
      }
      
      _isLoadingProgress = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _progressError = 'Fehler beim Aktualisieren des Benutzerfortschritts: $e';
      _isLoadingProgress = false;
      notifyListeners();
      return false;
    }
  }
  
  // Lektion abschließen
  Future<bool> completeLesson(String lessonId) async {
    try {
      final success = await _learningService.completeLesson(lessonId);
      
      if (success) {
        // Aktualisiere den lokalen Fortschritt
        await loadUserProgress();
        await loadLearningStats();
        await loadRecommendations();
      }
      
      return success;
    } catch (e) {
      _progressError = 'Fehler beim Abschließen der Lektion: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Schachproblem lösen
  Future<bool> solvePuzzle(String puzzleId) async {
    try {
      final success = await _learningService.solvePuzzle(puzzleId);
      
      if (success) {
        // Aktualisiere den lokalen Fortschritt
        await loadUserProgress();
        await loadLearningStats();
        await loadRecommendations();
      }
      
      return success;
    } catch (e) {
      _progressError = 'Fehler beim Lösen des Schachproblems: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Eröffnung studieren
  Future<bool> studyOpening(String openingId) async {
    try {
      final success = await _learningService.studyOpening(openingId);
      
      if (success) {
        // Aktualisiere den lokalen Fortschritt
        await loadUserProgress();
        await loadLearningStats();
        await loadRecommendations();
      }
      
      return success;
    } catch (e) {
      _progressError = 'Fehler beim Studieren der Eröffnung: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Empfehlungen laden
  Future<void> loadRecommendations() async {
    _isLoadingRecommendations = true;
    _recommendationsError = '';
    notifyListeners();
    
    try {
      _recommendations = await _learningService.getRecommendations();
      _isLoadingRecommendations = false;
      notifyListeners();
    } catch (e) {
      _recommendationsError = 'Fehler beim Laden der Empfehlungen: $e';
      _isLoadingRecommendations = false;
      notifyListeners();
    }
  }
  
  // Tägliche Herausforderungen laden
  Future<void> loadDailyChallenges() async {
    _isLoadingChallenges = true;
    _challengesError = '';
    notifyListeners();
    
    try {
      _dailyChallenges = await _learningService.getDailyChallenges();
      _isLoadingChallenges = false;
      notifyListeners();
    } catch (e) {
      _challengesError = 'Fehler beim Laden der täglichen Herausforderungen: $e';
      _isLoadingChallenges = false;
      notifyListeners();
    }
  }
  
  // Lernstatistiken laden
  Future<void> loadLearningStats() async {
    _isLoadingStats = true;
    _statsError = '';
    notifyListeners();
    
    try {
      _learningStats = await _learningService.getLearningStats();
      _isLoadingStats = false;
      notifyListeners();
    } catch (e) {
      _statsError = 'Fehler beim Laden der Lernstatistiken: $e';
      _isLoadingStats = false;
      notifyListeners();
    }
  }
}
