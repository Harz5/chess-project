import 'package:flutter/material.dart';
import '../models/optimized_chess_board.dart';
import '../widgets/enhanced_game_dashboard.dart';
import '../services/accessibility_service.dart';

/// Ein verbesserter Spielbildschirm mit Barrierefreiheitsfunktionen
class AccessibleGameScreen extends StatefulWidget {
  final OptimizedChessBoard board;
  final String variantName;

  const AccessibleGameScreen({
    super.key,
    required this.board,
    required this.variantName,
  });

  @override
  State<AccessibleGameScreen> createState() => _AccessibleGameScreenState();
}

class _AccessibleGameScreenState extends State<AccessibleGameScreen> {
  // Einstellungen für Barrierefreiheit
  bool _highContrastMode = false;
  bool _largeTextMode = false;
  bool _colorBlindMode = false;

  @override
  void initState() {
    super.initState();
    _loadAccessibilitySettings();
  }

  Future<void> _loadAccessibilitySettings() async {
    final accessibilityService = AccessibilityService();
    final settings = await accessibilityService.getSettings();

    setState(() {
      _highContrastMode = settings.highContrastMode;
      _largeTextMode = settings.largeTextMode;
      _colorBlindMode = settings.colorBlindMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Anpassen des Themes basierend auf den Barrierefreiheitseinstellungen
      data: _getThemeData(context),
      child: EnhancedGameDashboard(
        board: widget.board,
        variantName: widget.variantName,
        customStatusWidget: _buildAccessibilityControls(),
      ),
    );
  }

  ThemeData _getThemeData(BuildContext context) {
    final baseTheme = Theme.of(context);

    if (_highContrastMode) {
      // Hochkontrastmodus
      return baseTheme.copyWith(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.black,
        textTheme: baseTheme.textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.yellow,
          onSecondary: Colors.black,
        ),
      );
    } else if (_colorBlindMode) {
      // Farbenblindheitsmodus (Deuteranopie-freundlich)
      return baseTheme.copyWith(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: Colors.orange,
        ),
      );
    } else if (_largeTextMode) {
      // Großer Text-Modus
      return baseTheme.copyWith(
        textTheme: baseTheme.textTheme.copyWith(
          bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(fontSize: 18),
          bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(fontSize: 16),
          bodySmall: baseTheme.textTheme.bodySmall?.copyWith(fontSize: 14),
          titleLarge: baseTheme.textTheme.titleLarge?.copyWith(fontSize: 24),
          titleMedium: baseTheme.textTheme.titleMedium?.copyWith(fontSize: 20),
          titleSmall: baseTheme.textTheme.titleSmall?.copyWith(fontSize: 18),
        ),
      );
    }

    // Standard-Theme
    return baseTheme;
  }

  Widget _buildAccessibilityControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.contrast,
              color: _highContrastMode ? Colors.yellow : Colors.grey,
            ),
            onPressed: _toggleHighContrastMode,
            tooltip: 'Hochkontrastmodus',
          ),
          IconButton(
            icon: Icon(
              Icons.text_fields,
              color: _largeTextMode ? Colors.blue : Colors.grey,
            ),
            onPressed: _toggleLargeTextMode,
            tooltip: 'Großer Text',
          ),
          IconButton(
            icon: Icon(
              Icons.color_lens,
              color: _colorBlindMode ? Colors.orange : Colors.grey,
            ),
            onPressed: _toggleColorBlindMode,
            tooltip: 'Farbenblindheitsmodus',
          ),
        ],
      ),
    );
  }

  void _toggleHighContrastMode() {
    setState(() {
      _highContrastMode = !_highContrastMode;
      // Deaktiviere andere Modi, wenn dieser aktiviert wird
      if (_highContrastMode) {
        _largeTextMode = false;
        _colorBlindMode = false;
      }
    });
    _saveAccessibilitySettings();
  }

  void _toggleLargeTextMode() {
    setState(() {
      _largeTextMode = !_largeTextMode;
      // Deaktiviere andere Modi, wenn dieser aktiviert wird
      if (_largeTextMode) {
        _highContrastMode = false;
        _colorBlindMode = false;
      }
    });
    _saveAccessibilitySettings();
  }

  void _toggleColorBlindMode() {
    setState(() {
      _colorBlindMode = !_colorBlindMode;
      // Deaktiviere andere Modi, wenn dieser aktiviert wird
      if (_colorBlindMode) {
        _highContrastMode = false;
        _largeTextMode = false;
      }
    });
    _saveAccessibilitySettings();
  }

  void _saveAccessibilitySettings() {
    final accessibilityService = AccessibilityService();
    accessibilityService.saveSettings(
      highContrastMode: _highContrastMode,
      largeTextMode: _largeTextMode,
      colorBlindMode: _colorBlindMode,
    );
  }
}
