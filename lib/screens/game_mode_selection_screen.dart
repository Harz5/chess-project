import 'package:flutter/material.dart';
import '../services/time_control_service.dart';
import '../screens/chess960_game_screen.dart';
import '../screens/crazyhouse_game_screen.dart';
import '../screens/antichess_game_screen.dart';
import '../screens/three_check_game_screen.dart';
import '../screens/king_of_the_hill_game_screen.dart';
import '../screens/racing_kings_game_screen.dart';
import '../models/chess_board.dart';

class GameModeSelectionScreen extends StatefulWidget {
  const GameModeSelectionScreen({super.key});

  @override
  State<GameModeSelectionScreen> createState() =>
      _GameModeSelectionScreenState();
}

class _GameModeSelectionScreenState extends State<GameModeSelectionScreen> {
  // Zeitkontrolle
  String _selectedTimeControl = 'none';
  int _customTimeMinutes = 10;
  int _customIncrementSeconds = 0;
  bool _showCustomTimeControls = false;

  // Schachvarianten
  String _selectedVariant = 'standard';
  static const Map<String, String> chessVariants = {
    'standard': 'Standard Schach',
    'chess960': 'Chess960 (Fischer Random)',
    'crazyhouse': 'Crazyhouse',
    'antichess': 'Antichess',
    'kingofthehill': 'King of the Hill',
    'threecheck': 'Three-Check',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spielmodus auswählen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Zeitkontrolle
          _buildSectionHeader('Zeitkontrolle'),
          ...TimeControlService.timeControlModes.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _selectedTimeControl,
              onChanged: (value) {
                setState(() {
                  _selectedTimeControl = value!;
                  _showCustomTimeControls = value == 'custom';
                });
              },
            );
          }),

          // Benutzerdefinierte Zeitkontrolle
          if (_showCustomTimeControls) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('Zeit pro Spieler:'),
                  Expanded(
                    child: Slider(
                      value: _customTimeMinutes.toDouble(),
                      min: 1,
                      max: 60,
                      divisions: 59,
                      label: '$_customTimeMinutes Minuten',
                      onChanged: (value) {
                        setState(() {
                          _customTimeMinutes = value.round();
                        });
                      },
                    ),
                  ),
                  Text('$_customTimeMinutes min'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('Inkrement:'),
                  Expanded(
                    child: Slider(
                      value: _customIncrementSeconds.toDouble(),
                      min: 0,
                      max: 60,
                      divisions: 12,
                      label: '$_customIncrementSeconds Sekunden',
                      onChanged: (value) {
                        setState(() {
                          _customIncrementSeconds = value.round();
                        });
                      },
                    ),
                  ),
                  Text('$_customIncrementSeconds s'),
                ],
              ),
            ),
          ],

          const Divider(height: 32),

          // Schachvarianten
          _buildSectionHeader('Schachvariante'),
          ...chessVariants.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _selectedVariant,
              onChanged: (value) {
                setState(() {
                  _selectedVariant = value!;
                });
              },
            );
          }),

          const SizedBox(height: 32),

          // Spielen-Button
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Spielen',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  void _startGame() {
    // Hier wird je nach ausgewähltem Modus der entsprechende Bildschirm geöffnet
    if (_selectedVariant == 'standard') {
      // Standard-Schach mit Zeitkontrolle
      Navigator.pushNamed(
        context,
        '/time_control_game',
        arguments: {
          'timeControlMode': _selectedTimeControl,
          'customTimeMinutes': _customTimeMinutes,
          'customIncrementSeconds': _customIncrementSeconds,
        },
      );
    } else if (_selectedVariant == 'chess960') {
      // Chess960 (Fischer Random Chess)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Chess960GameScreen(),
        ),
      );
    } else if (_selectedVariant == 'crazyhouse') {
      // Crazyhouse
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CrazyhouseGameScreen(),
        ),
      );
    } else if (_selectedVariant == 'antichess') {
      // Antichess (Räuberschach)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AntichessGameScreen(),
        ),
      );
    } else if (_selectedVariant == 'threecheck') {
      // Three-Check
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ThreeCheckGameScreen(),
        ),
      );
    } else if (_selectedVariant == 'kingofthehill') {
      // King of the Hill
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KingOfTheHillGameScreen(),
        ),
      );
    } else if (_selectedVariant == 'racingkings') {
      // Racing Kings
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RacingKingsGameScreen(),
        ),
      );
    } else {
      // Andere Schachvarianten (noch zu implementieren)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${chessVariants[_selectedVariant]} wird bald verfügbar sein!'),
        ),
      );
    }
  }
}
