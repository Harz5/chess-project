import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'online_lobby_screen.dart';
import 'ai_game_screen.dart';
import 'tournament_screen.dart';
import 'leaderboard_screen.dart';
import 'tutorial_screen.dart';
import 'settings_screen.dart';
import 'game_mode_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.brown, Colors.black],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Schachspiel',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              _buildMenuButton(
                context,
                'Lokales Spiel',
                Icons.people,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameModeSelectionScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildMenuButton(
                context,
                'Gegen KI spielen',
                Icons.smart_toy,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AIGameScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildMenuButton(
                context,
                'Online Spiel',
                Icons.wifi,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnlineLobbyScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildMenuButton(
                context,
                'Turniere',
                Icons.emoji_events,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TournamentListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildMenuButton(
                context,
                'Rangliste',
                Icons.leaderboard,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LeaderboardScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildMenuButton(
                context,
                'Lernmodus',
                Icons.school,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TutorialListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildMenuButton(
                context,
                'Einstellungen',
                Icons.settings,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.white,
          foregroundColor: Colors.brown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
