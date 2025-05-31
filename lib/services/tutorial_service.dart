import '../models/tutorial.dart';

class TutorialService {
  // Singleton-Instanz
  static final TutorialService _instance = TutorialService._internal();
  
  factory TutorialService() {
    return _instance;
  }
  
  TutorialService._internal();
  
  // Liste aller verfügbaren Tutorials
  List<Tutorial> _tutorials = [];
  
  // Initialisiert die Tutorials
  void initialize() {
    _tutorials = [
      _createBasicMovementTutorial(),
      _createSpecialMovesTutorial(),
      _createBasicTacticsTutorial(),
      _createCheckmateTutorial(),
      _createOpeningsTutorial(),
    ];
  }
  
  // Gibt alle verfügbaren Tutorials zurück
  List<Tutorial> getAllTutorials() {
    if (_tutorials.isEmpty) {
      initialize();
    }
    return _tutorials;
  }
  
  // Gibt ein Tutorial anhand seiner ID zurück
  Tutorial? getTutorialById(String id) {
    if (_tutorials.isEmpty) {
      initialize();
    }
    try {
      return _tutorials.firstWhere((tutorial) => tutorial.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Markiert ein Tutorial als abgeschlossen
  void markTutorialAsCompleted(String id) {
    final index = _tutorials.indexWhere((tutorial) => tutorial.id == id);
    if (index != -1) {
      _tutorials[index] = _tutorials[index].copyWith(isCompleted: true);
    }
  }
  
  // Markiert einen Tutorial-Schritt als abgeschlossen
  void markTutorialStepAsCompleted(String tutorialId, String stepId) {
    final tutorialIndex = _tutorials.indexWhere((tutorial) => tutorial.id == tutorialId);
    if (tutorialIndex != -1) {
      final steps = List<TutorialStep>.from(_tutorials[tutorialIndex].steps);
      final stepIndex = steps.indexWhere((step) => step.id == stepId);
      
      if (stepIndex != -1) {
        steps[stepIndex] = steps[stepIndex].copyWith(isCompleted: true);
        _tutorials[tutorialIndex] = _tutorials[tutorialIndex].copyWith(steps: steps);
        
        // Überprüfe, ob alle Schritte abgeschlossen sind
        final allStepsCompleted = steps.every((step) => step.isCompleted);
        if (allStepsCompleted) {
          _tutorials[tutorialIndex] = _tutorials[tutorialIndex].copyWith(isCompleted: true);
        }
      }
    }
  }
  
  // Erstellt das Tutorial für grundlegende Figurenbewegungen
  Tutorial _createBasicMovementTutorial() {
    return Tutorial(
      id: 'basic_movement',
      title: 'Grundlegende Figurenbewegungen',
      description: 'Lerne, wie sich die verschiedenen Schachfiguren bewegen.',
      difficulty: 'Anfänger',
      steps: [
        TutorialStep(
          id: 'basic_movement_1',
          title: 'Der Bauer',
          description: 'Bauern bewegen sich einen Schritt nach vorne. Bei ihrem ersten Zug können sie auch zwei Schritte vorwärts gehen. Sie schlagen diagonal.',
          boardFen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          validMoves: ['e2e3', 'e2e4'],
          expectedMove: 'e2e4',
        ),
        TutorialStep(
          id: 'basic_movement_2',
          title: 'Der Turm',
          description: 'Türme bewegen sich horizontal und vertikal über beliebig viele Felder.',
          boardFen: '8/8/8/8/8/8/8/R7 w - - 0 1',
          validMoves: ['a1a8', 'a1h1'],
          expectedMove: 'a1a8',
        ),
        TutorialStep(
          id: 'basic_movement_3',
          title: 'Der Läufer',
          description: 'Läufer bewegen sich diagonal über beliebig viele Felder.',
          boardFen: '8/8/8/8/8/8/8/B7 w - - 0 1',
          validMoves: ['a1h8'],
          expectedMove: 'a1h8',
        ),
        TutorialStep(
          id: 'basic_movement_4',
          title: 'Die Dame',
          description: 'Die Dame kann sich horizontal, vertikal und diagonal über beliebig viele Felder bewegen.',
          boardFen: '8/8/8/8/8/8/8/Q7 w - - 0 1',
          validMoves: ['a1a8', 'a1h1', 'a1h8'],
          expectedMove: 'a1h8',
        ),
        TutorialStep(
          id: 'basic_movement_5',
          title: 'Der Springer',
          description: 'Der Springer bewegt sich in L-Form: zwei Felder in eine Richtung und dann ein Feld im 90-Grad-Winkel. Er kann über andere Figuren springen.',
          boardFen: '8/8/8/8/8/8/8/N7 w - - 0 1',
          validMoves: ['a1b3', 'a1c2'],
          expectedMove: 'a1c2',
        ),
        TutorialStep(
          id: 'basic_movement_6',
          title: 'Der König',
          description: 'Der König kann sich in jede Richtung bewegen, aber nur um ein Feld.',
          boardFen: '8/8/8/8/8/8/8/K7 w - - 0 1',
          validMoves: ['a1a2', 'a1b1', 'a1b2'],
          expectedMove: 'a1b1',
        ),
      ],
    );
  }
  
  // Erstellt das Tutorial für Spezialzüge
  Tutorial _createSpecialMovesTutorial() {
    return Tutorial(
      id: 'special_moves',
      title: 'Spezialzüge',
      description: 'Lerne die besonderen Züge im Schach: Rochade, En Passant und Bauernumwandlung.',
      difficulty: 'Anfänger',
      steps: [
        TutorialStep(
          id: 'special_moves_1',
          title: 'Kleine Rochade',
          description: 'Die kleine Rochade ist ein Spezialzug, bei dem der König zwei Felder in Richtung Turm und der Turm über den König hinweg auf das angrenzende Feld zieht.',
          boardFen: 'r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1',
          validMoves: ['e1g1'],
          expectedMove: 'e1g1',
        ),
        TutorialStep(
          id: 'special_moves_2',
          title: 'Große Rochade',
          description: 'Die große Rochade ist ähnlich wie die kleine Rochade, aber der König bewegt sich zur Damenseite.',
          boardFen: 'r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1',
          validMoves: ['e1c1'],
          expectedMove: 'e1c1',
        ),
        TutorialStep(
          id: 'special_moves_3',
          title: 'En Passant',
          description: 'En Passant ist ein spezieller Bauernzug. Wenn ein gegnerischer Bauer zwei Felder vorrückt und dabei neben deinem Bauern landet, kannst du ihn im nächsten Zug "im Vorbeigehen" schlagen.',
          boardFen: '8/8/8/8/5p2/8/4P3/8 w - - 0 1',
          validMoves: ['e2e4'],
          expectedMove: 'e2e4',
        ),
        TutorialStep(
          id: 'special_moves_4',
          title: 'En Passant (Fortsetzung)',
          description: 'Jetzt kannst du den gegnerischen Bauern "en passant" schlagen.',
          boardFen: '8/8/8/8/4Pp2/8/8/8 b - e3 0 1',
          validMoves: ['f4e3'],
          expectedMove: 'f4e3',
        ),
        TutorialStep(
          id: 'special_moves_5',
          title: 'Bauernumwandlung',
          description: 'Wenn ein Bauer die gegnerische Grundlinie erreicht, kann er in eine Dame, einen Turm, einen Läufer oder einen Springer umgewandelt werden.',
          boardFen: '8/P7/8/8/8/8/8/8 w - - 0 1',
          validMoves: ['a7a8q', 'a7a8r', 'a7a8b', 'a7a8n'],
          expectedMove: 'a7a8q',
        ),
      ],
    );
  }
  
  // Erstellt das Tutorial für grundlegende Taktiken
  Tutorial _createBasicTacticsTutorial() {
    return Tutorial(
      id: 'basic_tactics',
      title: 'Grundlegende Taktiken',
      description: 'Lerne grundlegende taktische Motive im Schach.',
      difficulty: 'Fortgeschritten',
      steps: [
        TutorialStep(
          id: 'basic_tactics_1',
          title: 'Gabel',
          description: 'Eine Gabel ist ein Zug, der zwei oder mehr gegnerische Figuren gleichzeitig angreift.',
          boardFen: '8/8/8/4k3/8/2r5/8/4K3 w - - 0 1',
          validMoves: ['e1d2'],
          expectedMove: 'e1d2',
        ),
        TutorialStep(
          id: 'basic_tactics_2',
          title: 'Spieß',
          description: 'Ein Spieß ist ein Angriff auf eine wertvolle Figur, die gezwungen ist, sich zu bewegen, wodurch eine weniger wertvolle Figur dahinter gefangen wird.',
          boardFen: '8/8/8/8/8/5k2/4q3/R3K3 w - - 0 1',
          validMoves: ['a1a3'],
          expectedMove: 'a1a3',
        ),
        TutorialStep(
          id: 'basic_tactics_3',
          title: 'Fesselung',
          description: 'Eine Fesselung ist ein Zug, der eine gegnerische Figur daran hindert, sich zu bewegen, weil sonst eine wertvollere Figur dahinter gefangen würde.',
          boardFen: '8/8/8/8/8/5n2/4k3/R3K3 w - - 0 1',
          validMoves: ['a1a2'],
          expectedMove: 'a1a2',
        ),
        TutorialStep(
          id: 'basic_tactics_4',
          title: 'Abzugsschach',
          description: 'Ein Abzugsschach ist ein Schachgebot, das entsteht, wenn eine Figur bewegt wird und dadurch eine andere Figur den gegnerischen König angreift.',
          boardFen: '8/8/8/8/8/3bk3/8/R3K3 w - - 0 1',
          validMoves: ['e1f2'],
          expectedMove: 'e1f2',
        ),
        TutorialStep(
          id: 'basic_tactics_5',
          title: 'Doppelschach',
          description: 'Ein Doppelschach ist ein Schachgebot, bei dem der König von zwei Figuren gleichzeitig angegriffen wird.',
          boardFen: '8/8/8/8/8/4k3/3q4/R3K3 w - - 0 1',
          validMoves: ['e1f2'],
          expectedMove: 'e1f2',
        ),
      ],
    );
  }
  
  // Erstellt das Tutorial für Schachmatt-Muster
  Tutorial _createCheckmateTutorial() {
    return Tutorial(
      id: 'checkmate_patterns',
      title: 'Schachmatt-Muster',
      description: 'Lerne die häufigsten Schachmatt-Muster.',
      difficulty: 'Fortgeschritten',
      steps: [
        TutorialStep(
          id: 'checkmate_1',
          title: 'Ersticktes Matt',
          description: 'Das erstickte Matt ist ein Schachmatt, bei dem der König von seinen eigenen Figuren umgeben ist und durch einen Springerzug mattgesetzt wird.',
          boardFen: '5rrk/6pp/7N/8/8/8/8/7K w - - 0 1',
          validMoves: ['h6g8'],
          expectedMove: 'h6g8',
        ),
        TutorialStep(
          id: 'checkmate_2',
          title: 'Schäfermatt',
          description: 'Das Schäfermatt ist ein schnelles Schachmatt in nur vier Zügen.',
          boardFen: 'rnbqkbnr/ppp2ppp/3p4/4p3/2B1P3/5Q2/PPPP1PPP/RNB1K1NR w KQkq - 0 1',
          validMoves: ['f3f7'],
          expectedMove: 'f3f7',
        ),
        TutorialStep(
          id: 'checkmate_3',
          title: 'Damenmatt',
          description: 'Das Damenmatt ist ein häufiges Mattmuster, bei dem die Dame den gegnerischen König an den Rand drängt und mattsetzen kann.',
          boardFen: '7k/5ppp/8/8/8/8/8/6QK w - - 0 1',
          validMoves: ['g1g7'],
          expectedMove: 'g1g7',
        ),
        TutorialStep(
          id: 'checkmate_4',
          title: 'Turmmatt',
          description: 'Das Turmmatt ist ein Mattmuster, bei dem der Turm den gegnerischen König an den Rand drängt und mit Unterstützung des eigenen Königs mattsetzen kann.',
          boardFen: '7k/7p/8/8/8/8/8/5RK1 w - - 0 1',
          validMoves: ['f1f8'],
          expectedMove: 'f1f8',
        ),
        TutorialStep(
          id: 'checkmate_5',
          title: 'Epaulettenmatt',
          description: 'Das Epaulettenmatt ist ein Mattmuster, bei dem der König von seinen eigenen Figuren (meist Türmen) flankiert wird und frontal mattgesetzt wird.',
          boardFen: '3rkr2/8/8/8/8/8/8/3QK3 w - - 0 1',
          validMoves: ['d1d8'],
          expectedMove: 'd1d8',
        ),
      ],
    );
  }
  
  // Erstellt das Tutorial für Eröffnungen
  Tutorial _createOpeningsTutorial() {
    return Tutorial(
      id: 'openings',
      title: 'Schacheröffnungen',
      description: 'Lerne die grundlegenden Prinzipien und einige beliebte Schacheröffnungen.',
      difficulty: 'Experte',
      steps: [
        TutorialStep(
          id: 'openings_1',
          title: 'Eröffnungsprinzipien',
          description: 'In der Eröffnung solltest du: 1. Das Zentrum kontrollieren, 2. Leichtfiguren entwickeln, 3. Den König in Sicherheit bringen und 4. Die Türme verbinden.',
          boardFen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          validMoves: ['e2e4', 'd2d4'],
          expectedMove: 'e2e4',
        ),
        TutorialStep(
          id: 'openings_2',
          title: 'Italienische Eröffnung',
          description: 'Die Italienische Eröffnung beginnt mit 1.e4 e5 2.Nf3 Nc6 3.Bc4 und zielt auf schnelle Entwicklung und Kontrolle des Zentrums ab.',
          boardFen: 'r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 0 1',
          validMoves: ['f1c4'],
          expectedMove: 'f1c4',
        ),
        TutorialStep(
          id: 'openings_3',
          title: 'Spanische Eröffnung',
          description: 'Die Spanische Eröffnung (auch Ruy Lopez genannt) beginnt mit 1.e4 e5 2.Nf3 Nc6 3.Bb5 und ist eine der ältesten und solidesten Eröffnungen.',
          boardFen: 'r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 0 1',
          validMoves: ['f1b5'],
          expectedMove: 'f1b5',
        ),
        TutorialStep(
          id: 'openings_4',
          title: 'Sizilianische Verteidigung',
          description: 'Die Sizilianische Verteidigung beginnt mit 1.e4 c5 und ist eine aggressive Antwort auf 1.e4, die das Zentrum asymmetrisch bekämpft.',
          boardFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          validMoves: ['c7c5'],
          expectedMove: 'c7c5',
        ),
        TutorialStep(
          id: 'openings_5',
          title: 'Damengambit',
          description: 'Das Damengambit beginnt mit 1.d4 d5 2.c4 und ist eine solide Eröffnung, die das Zentrum kontrolliert und einen Bauern "opfert".',
          boardFen: 'rnbqkbnr/ppp1pppp/8/3p4/3P4/8/PPP1PPPP/RNBQKBNR w KQkq - 0 1',
          validMoves: ['c2c4'],
          expectedMove: 'c2c4',
        ),
      ],
    );
  }
}
