import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();

  // Einstellungswerte
  ThemeMode _themeMode = ThemeMode.system;
  String _boardStyle = SettingsService.defaultBoardStyle;
  String _pieceStyle = SettingsService.defaultPieceStyle;
  bool _soundEnabled = SettingsService.defaultSoundEnabled;
  bool _vibrationEnabled = SettingsService.defaultVibrationEnabled;
  bool _moveHighlight = SettingsService.defaultMoveHighlight;
  bool _autoPromotion = SettingsService.defaultAutoPromotion;
  bool _showCoordinates = SettingsService.defaultShowCoordinates;
  double _animationSpeed = SettingsService.defaultAnimationSpeed;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final themeMode = await _settingsService.getThemeMode();
      final boardStyle = await _settingsService.getBoardStyle();
      final pieceStyle = await _settingsService.getPieceStyle();
      final soundEnabled = await _settingsService.getSoundEnabled();
      final vibrationEnabled = await _settingsService.getVibrationEnabled();
      final moveHighlight = await _settingsService.getMoveHighlight();
      final autoPromotion = await _settingsService.getAutoPromotion();
      final showCoordinates = await _settingsService.getShowCoordinates();
      final animationSpeed = await _settingsService.getAnimationSpeed();

      setState(() {
        _themeMode = themeMode;
        _boardStyle = boardStyle;
        _pieceStyle = pieceStyle;
        _soundEnabled = soundEnabled;
        _vibrationEnabled = vibrationEnabled;
        _moveHighlight = moveHighlight;
        _autoPromotion = autoPromotion;
        _showCoordinates = showCoordinates;
        _animationSpeed = animationSpeed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Einstellungen: $e')),
        );
      }
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Einstellungen zurücksetzen'),
        content: const Text(
            'Möchtest du wirklich alle Einstellungen auf die Standardwerte zurücksetzen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _settingsService.resetAllSettings();
      await _loadSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Einstellungen wurden zurückgesetzt')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetSettings,
            tooltip: 'Zurücksetzen',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSectionHeader('Erscheinungsbild'),
                _buildThemeModeSetting(),
                _buildBoardStyleSetting(),
                _buildPieceStyleSetting(),
                _buildSectionHeader('Spielverhalten'),
                _buildSwitchSetting(
                  title: 'Zughervorhebung',
                  subtitle: 'Mögliche Züge hervorheben',
                  value: _moveHighlight,
                  onChanged: (value) async {
                    await _settingsService.setMoveHighlight(value);
                    setState(() {
                      _moveHighlight = value;
                    });
                  },
                ),
                _buildSwitchSetting(
                  title: 'Automatische Bauernumwandlung',
                  subtitle: 'Bauern automatisch in Dame umwandeln',
                  value: _autoPromotion,
                  onChanged: (value) async {
                    await _settingsService.setAutoPromotion(value);
                    setState(() {
                      _autoPromotion = value;
                    });
                  },
                ),
                _buildSwitchSetting(
                  title: 'Koordinaten anzeigen',
                  subtitle: 'Schachbrettkoordinaten anzeigen',
                  value: _showCoordinates,
                  onChanged: (value) async {
                    await _settingsService.setShowCoordinates(value);
                    setState(() {
                      _showCoordinates = value;
                    });
                  },
                ),
                _buildAnimationSpeedSetting(),
                _buildSectionHeader('Sound und Haptik'),
                _buildSwitchSetting(
                  title: 'Sound',
                  subtitle: 'Soundeffekte aktivieren',
                  value: _soundEnabled,
                  onChanged: (value) async {
                    await _settingsService.setSoundEnabled(value);
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                ),
                _buildSwitchSetting(
                  title: 'Vibration',
                  subtitle: 'Haptisches Feedback aktivieren',
                  value: _vibrationEnabled,
                  onChanged: (value) async {
                    await _settingsService.setVibrationEnabled(value);
                    setState(() {
                      _vibrationEnabled = value;
                    });
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeModeSetting() {
    return ListTile(
      title: const Text('Erscheinungsmodus'),
      subtitle: Text(_getThemeModeText(_themeMode)),
      leading: const Icon(Icons.brightness_6),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Erscheinungsmodus'),
            children: [
              _buildThemeModeOption(ThemeMode.system, 'Systemeinstellung'),
              _buildThemeModeOption(ThemeMode.light, 'Hell'),
              _buildThemeModeOption(ThemeMode.dark, 'Dunkel'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeModeOption(ThemeMode mode, String text) {
    return RadioListTile<ThemeMode>(
      title: Text(text),
      value: mode,
      groupValue: _themeMode,
      onChanged: (value) async {
        if (value != null) {
          await _settingsService.setThemeMode(value);
          setState(() {
            _themeMode = value;
          });
          Navigator.pop(context);
        }
      },
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Systemeinstellung';
      case ThemeMode.light:
        return 'Hell';
      case ThemeMode.dark:
        return 'Dunkel';
    }
  }

  Widget _buildBoardStyleSetting() {
    return ListTile(
      title: const Text('Brettstil'),
      subtitle: Text(_getBoardStyleText(_boardStyle)),
      leading: const Icon(Icons.grid_on),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Brettstil'),
            children: _settingsService.availableBoardStyles.map((style) {
              return _buildStyleOption(
                value: style,
                text: _getBoardStyleText(style),
                groupValue: _boardStyle,
                onChanged: (value) async {
                  if (value != null) {
                    await _settingsService.setBoardStyle(value);
                    setState(() {
                      _boardStyle = value;
                    });
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getBoardStyleText(String style) {
    switch (style) {
      case 'classic':
        return 'Klassisch';
      case 'wooden':
        return 'Holz';
      case 'marble':
        return 'Marmor';
      case 'blue':
        return 'Blau';
      case 'green':
        return 'Grün';
      default:
        return style;
    }
  }

  Widget _buildPieceStyleSetting() {
    return ListTile(
      title: const Text('Figurenstil'),
      subtitle: Text(_getPieceStyleText(_pieceStyle)),
      leading: const Icon(Icons.emoji_objects),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Figurenstil'),
            children: _settingsService.availablePieceStyles.map((style) {
              return _buildStyleOption(
                value: style,
                text: _getPieceStyleText(style),
                groupValue: _pieceStyle,
                onChanged: (value) async {
                  if (value != null) {
                    await _settingsService.setPieceStyle(value);
                    setState(() {
                      _pieceStyle = value;
                    });
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getPieceStyleText(String style) {
    switch (style) {
      case 'standard':
        return 'Standard';
      case 'classic':
        return 'Klassisch';
      case 'modern':
        return 'Modern';
      case 'minimalist':
        return 'Minimalistisch';
      case '3d':
        return '3D';
      default:
        return style;
    }
  }

  Widget _buildStyleOption({
    required String value,
    required String text,
    required String groupValue,
    required void Function(String?) onChanged,
  }) {
    return RadioListTile<String>(
      title: Text(text),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }

  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildAnimationSpeedSetting() {
    return ListTile(
      title: const Text('Animationsgeschwindigkeit'),
      subtitle: Slider(
        value: _animationSpeed,
        min: 0.1,
        max: 1.0,
        divisions: 9,
        label: _getAnimationSpeedText(_animationSpeed),
        onChanged: (value) async {
          await _settingsService.setAnimationSpeed(value);
          setState(() {
            _animationSpeed = value;
          });
        },
      ),
    );
  }

  String _getAnimationSpeedText(double speed) {
    if (speed < 0.3) {
      return 'Schnell';
    } else if (speed < 0.7) {
      return 'Mittel';
    } else {
      return 'Langsam';
    }
  }
}
