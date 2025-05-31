import 'package:flutter/material.dart';
import '../models/tutorial.dart';
import '../services/tutorial_service.dart';
import '../widgets/chess_board_widget.dart';
import '../models/chess_board.dart';
import '../models/position.dart';

class TutorialListScreen extends StatefulWidget {
  const TutorialListScreen({super.key});

  @override
  State<TutorialListScreen> createState() => _TutorialListScreenState();
}

class _TutorialListScreenState extends State<TutorialListScreen> {
  final TutorialService _tutorialService = TutorialService();
  late List<Tutorial> _tutorials;

  @override
  void initState() {
    super.initState();
    _tutorials = _tutorialService.getAllTutorials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lernmodus'),
      ),
      body: ListView.builder(
        itemCount: _tutorials.length,
        itemBuilder: (context, index) {
          final tutorial = _tutorials[index];
          return _buildTutorialCard(tutorial);
        },
      ),
    );
  }

  Widget _buildTutorialCard(Tutorial tutorial) {
    // Bestimme die Schwierigkeitsfarbe
    Color difficultyColor;
    switch (tutorial.difficulty) {
      case 'Anfänger':
        difficultyColor = Colors.green;
        break;
      case 'Fortgeschritten':
        difficultyColor = Colors.orange;
        break;
      case 'Experte':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.blue;
    }

    // Berechne den Fortschritt
    final completedSteps =
        tutorial.steps.where((step) => step.isCompleted).length;
    final progress =
        tutorial.steps.isEmpty ? 0.0 : completedSteps / tutorial.steps.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TutorialScreen(tutorial: tutorial),
            ),
          ).then((_) {
            // Aktualisiere die Tutorials nach Rückkehr
            setState(() {
              _tutorials = _tutorialService.getAllTutorials();
            });
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tutorial.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: difficultyColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tutorial.difficulty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tutorial.description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        tutorial.isCompleted ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tutorial.isCompleted ? 'Abgeschlossen' : 'In Bearbeitung',
                style: TextStyle(
                  color: tutorial.isCompleted ? Colors.green : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TutorialScreen extends StatefulWidget {
  final Tutorial tutorial;

  const TutorialScreen({
    super.key,
    required this.tutorial,
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final TutorialService _tutorialService = TutorialService();
  late PageController _pageController;
  late List<TutorialStep> _steps;
  int _currentStepIndex = 0;
  late ChessBoard _board;
  bool _showHint = false;
  bool _moveCompleted = false;

  @override
  void initState() {
    super.initState();
    _steps = widget.tutorial.steps;
    _pageController = PageController();
    _loadCurrentStep();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadCurrentStep() {
    final step = _steps[_currentStepIndex];
    _board = ChessBoard.fromFen(step.boardFen);
    _showHint = false;
    _moveCompleted = step.isCompleted;
  }

  void _handleMove(Position from, Position to) {
    if (_moveCompleted) return;

    final step = _steps[_currentStepIndex];
    final moveString = '${from.toAlgebraic()}${to.toAlgebraic()}';

    // Überprüfe, ob der Zug gültig ist
    if (step.validMoves != null && !step.validMoves!.contains(moveString)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Dieser Zug ist nicht erlaubt. Versuche es noch einmal.')),
      );
      return;
    }

    // Führe den Zug aus
    final move = _board.getValidMovesForPiece(from).firstWhere(
          (m) => m.from == from && m.to == to,
          orElse: () => Move(from: from, to: to),
        );

    final success = _board.makeMove(move);

    if (success) {
      // Überprüfe, ob es der erwartete Zug war
      if (step.expectedMove == null || step.expectedMove == moveString) {
        // Markiere den Schritt als abgeschlossen
        _tutorialService.markTutorialStepAsCompleted(
            widget.tutorial.id, step.id);

        setState(() {
          _moveCompleted = true;
          _steps =
              _tutorialService.getTutorialById(widget.tutorial.id)?.steps ??
                  _steps;
        });

        // Zeige eine Erfolgsmeldung an
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sehr gut! Schritt abgeschlossen.')),
        );
      } else {
        // Der Zug war gültig, aber nicht der erwartete
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Dieser Zug ist gültig, aber nicht optimal. Versuche es noch einmal.')),
        );

        // Mache den Zug rückgängig
        setState(() {
          _loadCurrentStep();
        });
      }
    }
  }

  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _loadCurrentStep();
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Tutorial abgeschlossen
      Navigator.pop(context);
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _loadCurrentStep();
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleHint() {
    setState(() {
      _showHint = !_showHint;
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStepIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tutorial.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: _toggleHint,
            tooltip: 'Hinweis',
          ),
        ],
      ),
      body: Column(
        children: [
          // Fortschrittsanzeige
          LinearProgressIndicator(
            value: (_currentStepIndex + 1) / _steps.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),

          // Hauptinhalt
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return _buildStepContent(step);
              },
            ),
          ),

          // Navigationstasten
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentStepIndex > 0 ? _previousStep : null,
                  child: const Text('Zurück'),
                ),
                Text(
                  'Schritt ${_currentStepIndex + 1} von ${_steps.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: _moveCompleted ? _nextStep : null,
                  child: Text(_currentStepIndex < _steps.length - 1
                      ? 'Weiter'
                      : 'Abschließen'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(TutorialStep step) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return orientation == Orientation.portrait
            ? _buildPortraitLayout(step)
            : _buildLandscapeLayout(step);
      },
    );
  }

  Widget _buildPortraitLayout(TutorialStep step) {
    return Column(
      children: [
        // Titel und Beschreibung
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                step.description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              if (_showHint && step.expectedMove != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Hinweis: Versuche den Zug ${_formatMoveString(step.expectedMove!)}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Schachbrett
        Expanded(
          child: Center(
            child: ChessBoardWidget(
              board: _board,
              onMove: _handleMove,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(TutorialStep step) {
    return Row(
      children: [
        // Schachbrett
        Expanded(
          child: Center(
            child: ChessBoardWidget(
              board: _board,
              onMove: _handleMove,
            ),
          ),
        ),

        // Titel und Beschreibung
        SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      step.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                if (_showHint && step.expectedMove != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Hinweis: Versuche den Zug ${_formatMoveString(step.expectedMove!)}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatMoveString(String moveString) {
    if (moveString.length < 4) return moveString;

    final from = moveString.substring(0, 2);
    final to = moveString.substring(2, 4);

    return '$from → $to';
  }
}
