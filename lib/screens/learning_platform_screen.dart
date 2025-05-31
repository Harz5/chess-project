import 'package:flutter/material.dart';
import '../services/machine_learning_service.dart';
import '../models/chess_board.dart';

/// Bildschirm für die erweiterte Lernplattform
class LearningPlatformScreen extends StatefulWidget {
  final String playerName;

  const LearningPlatformScreen({
    super.key,
    required this.playerName,
  });

  @override
  State<LearningPlatformScreen> createState() => _LearningPlatformScreenState();
}

class _LearningPlatformScreenState extends State<LearningPlatformScreen>
    with SingleTickerProviderStateMixin {
  final MachineLearningService _mlService = MachineLearningService();
  late TabController _tabController;

  List<Map<String, dynamic>>? _learningPath;
  List<Map<String, dynamic>>? _trainingExercises;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLearningData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLearningData() async {
    setState(() {
      _isLoading = true;
    });

    // Lade die Lernpfad- und Übungsdaten
    await Future.wait([
      Future(() {
        _learningPath =
            _mlService.generatePersonalizedLearningPath(widget.playerName);
      }),
      Future(() {
        _trainingExercises =
            _mlService.generateTrainingExercises(widget.playerName);
      }),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lernplattform: ${widget.playerName}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Lernpfad'),
            Tab(text: 'Übungen'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLearningPathTab(),
                _buildExercisesTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadLearningData,
        tooltip: 'Aktualisieren',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildLearningPathTab() {
    if (_learningPath == null || _learningPath!.isEmpty) {
      return const Center(child: Text('Keine Lernpfaddaten verfügbar'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dein personalisierter Lernpfad',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Basierend auf deiner Spielhistorie haben wir einen personalisierten Lernpfad für dich erstellt.',
          ),
          const SizedBox(height: 24),

          // Fortschrittsanzeige
          const Text(
            'Dein Fortschritt',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.3, // Beispielwert
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 10,
          ),
          const SizedBox(height: 4),
          const Text('30% abgeschlossen'),
          const SizedBox(height: 24),

          // Lernpfad-Elemente
          ..._learningPath!.asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              _getLessonTypeColor(lesson['type'] as String),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson['title'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildDifficultyChip(
                                      lesson['difficulty'] as String),
                                  const SizedBox(width: 8),
                                  _buildTypeChip(lesson['type'] as String),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.play_circle_filled),
                          color: Colors.blue,
                          onPressed: () {
                            // Starte die Lektion
                            _startLesson(lesson);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(lesson['description'] as String),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExercisesTab() {
    if (_trainingExercises == null || _trainingExercises!.isEmpty) {
      return const Center(child: Text('Keine Übungsdaten verfügbar'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trainingsübungen',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Diese Übungen wurden speziell für dich ausgewählt, um deine Schachfähigkeiten zu verbessern.',
          ),
          const SizedBox(height: 24),

          // Filter-Optionen
          Wrap(
            spacing: 8.0,
            children: [
              FilterChip(
                label: const Text('Alle'),
                selected: true,
                onSelected: (bool selected) {
                  // Filter anwenden
                },
              ),
              FilterChip(
                label: const Text('Taktik'),
                selected: false,
                onSelected: (bool selected) {
                  // Filter anwenden
                },
              ),
              FilterChip(
                label: const Text('Strategie'),
                selected: false,
                onSelected: (bool selected) {
                  // Filter anwenden
                },
              ),
              FilterChip(
                label: const Text('Endspiel'),
                selected: false,
                onSelected: (bool selected) {
                  // Filter anwenden
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Übungselemente
          ..._trainingExercises!.map((exercise) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getExerciseTypeColor(
                                exercise['type'] as String),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Icon(
                              _getExerciseTypeIcon(exercise['type'] as String),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise['title'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildDifficultyChip(
                                      exercise['difficulty'] as String),
                                  const SizedBox(width: 8),
                                  _buildTypeChip(exercise['type'] as String),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Starte die Übung
                            _startExercise(exercise);
                          },
                          child: const Text('Üben'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(exercise['description'] as String),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color color;

    switch (difficulty.toLowerCase()) {
      case 'anfänger':
        color = Colors.green;
        break;
      case 'mittel':
        color = Colors.orange;
        break;
      case 'fortgeschritten':
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }

    return Chip(
      label: Text(
        difficulty,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }

  Widget _buildTypeChip(String type) {
    return Chip(
      label: Text(
        type,
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
      backgroundColor: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }

  Color _getLessonTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'taktik':
        return Colors.blue;
      case 'strategie':
        return Colors.green;
      case 'eröffnung':
        return Colors.orange;
      case 'endspiel':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getExerciseTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'taktik':
        return Colors.blue;
      case 'strategie':
        return Colors.green;
      case 'endspiel':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getExerciseTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'taktik':
        return Icons.flash_on;
      case 'strategie':
        return Icons.psychology;
      case 'endspiel':
        return Icons.flag;
      default:
        return Icons.chess;
    }
  }

  void _startLesson(Map<String, dynamic> lesson) {
    // Hier würde die Lektion gestartet werden
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lesson['title'] as String),
        content: const Text('Lektion wird geladen...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  void _startExercise(Map<String, dynamic> exercise) {
    // Hier würde die Übung gestartet werden
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise['title'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise['description'] as String),
            const SizedBox(height: 16),
            const Text(
              'FEN-Notation:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(exercise['fen'] as String),
            const SizedBox(height: 16),
            const Text(
              'Lösung:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(exercise['solution'] as String),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Schließen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Hier würde die Übung auf dem Brett angezeigt werden
            },
            child: const Text('Auf Brett anzeigen'),
          ),
        ],
      ),
    );
  }
}
