import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'widgets/responsive_layout.dart';
import 'providers/game_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/analysis_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
      ],
      child: MaterialApp(
        title: 'Schachspiel',
        theme: ThemeData(
          primarySwatch: Colors.brown,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.brown,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        themeMode: ThemeMode.system,
        home: const ResponsiveLayout(
          child: HomeScreen(),
        ),
        routes: {
          '/game': (context) => const ResponsiveLayout(
                child: GameScreen(),
              ),
        },
      ),
    );
  }
}
