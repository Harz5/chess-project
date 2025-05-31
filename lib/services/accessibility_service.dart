import 'package:shared_preferences/shared_preferences.dart';

/// Einstellungen für die Barrierefreiheit
class AccessibilitySettings {
  final bool highContrastMode;
  final bool largeTextMode;
  final bool colorBlindMode;
  final bool screenReaderSupport;
  
  AccessibilitySettings({
    this.highContrastMode = false,
    this.largeTextMode = false,
    this.colorBlindMode = false,
    this.screenReaderSupport = false,
  });
}

/// Service zur Verwaltung der Barrierefreiheitseinstellungen
class AccessibilityService {
  // Schlüssel für SharedPreferences
  static const String _keyHighContrast = 'accessibility_high_contrast';
  static const String _keyLargeText = 'accessibility_large_text';
  static const String _keyColorBlind = 'accessibility_color_blind';
  static const String _keyScreenReader = 'accessibility_screen_reader';
  
  // Singleton-Instanz
  static final AccessibilityService _instance = AccessibilityService._internal();
  
  factory AccessibilityService() {
    return _instance;
  }
  
  AccessibilityService._internal();
  
  /// Lädt die Barrierefreiheitseinstellungen
  Future<AccessibilitySettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    return AccessibilitySettings(
      highContrastMode: prefs.getBool(_keyHighContrast) ?? false,
      largeTextMode: prefs.getBool(_keyLargeText) ?? false,
      colorBlindMode: prefs.getBool(_keyColorBlind) ?? false,
      screenReaderSupport: prefs.getBool(_keyScreenReader) ?? false,
    );
  }
  
  /// Speichert die Barrierefreiheitseinstellungen
  Future<void> saveSettings({
    bool highContrastMode = false,
    bool largeTextMode = false,
    bool colorBlindMode = false,
    bool screenReaderSupport = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_keyHighContrast, highContrastMode);
    await prefs.setBool(_keyLargeText, largeTextMode);
    await prefs.setBool(_keyColorBlind, colorBlindMode);
    await prefs.setBool(_keyScreenReader, screenReaderSupport);
  }
  
  /// Generiert semantische Beschreibungen für Schachfiguren
  String getPieceDescription(String pieceType, String pieceColor) {
    final color = pieceColor == 'white' ? 'weiße' : 'schwarze';
    
    switch (pieceType) {
      case 'pawn':
        return '$color Bauer';
      case 'knight':
        return '$color Springer';
      case 'bishop':
        return '$color Läufer';
      case 'rook':
        return '$color Turm';
      case 'queen':
        return '$color Dame';
      case 'king':
        return '$color König';
      default:
        return 'Unbekannte Figur';
    }
  }
  
  /// Generiert semantische Beschreibungen für Schachfelder
  String getSquareDescription(int row, int col) {
    final files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    final ranks = ['8', '7', '6', '5', '4', '3', '2', '1'];
    
    return '${files[col]}${ranks[row]}';
  }
  
  /// Generiert semantische Beschreibungen für Züge
  String getMoveDescription(String from, String to, String? capturedPiece, String? promotion) {
    String description = 'Zug von $from nach $to';
    
    if (capturedPiece != null) {
      description += ', schlägt $capturedPiece';
    }
    
    if (promotion != null) {
      description += ', Bauernumwandlung zu $promotion';
    }
    
    return description;
  }
}
