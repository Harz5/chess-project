import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/lesson.dart';
import '../models/puzzle.dart';
import '../models/opening.dart';
import '../models/user_progress.dart';

/// Service für erweiterte Lernfunktionen
class LearningService {
  // Singleton-Instanz
  static final LearningService _instance = LearningService._internal();
  factory LearningService() => _instance;
  LearningService._internal();

  // Firebase-Instanzen
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lektionen
  Future<List<Lesson>> getLessons(
      {String? category, String? difficulty}) async {
    try {
      Query query = _firestore.collection('lessons');

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) =>
              Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Fehler beim Abrufen der Lektionen: $e');
      return [];
    }
  }

  Future<Lesson?> getLesson(String lessonId) async {
    try {
      final doc = await _firestore.collection('lessons').doc(lessonId).get();
      if (doc.exists) {
        return Lesson.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Fehler beim Abrufen der Lektion: $e');
      return null;
    }
  }

  // Schachprobleme
  Future<List<Puzzle>> getPuzzles(
      {String? difficulty, String? category}) async {
    try {
      Query query = _firestore.collection('puzzles');

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) =>
              Puzzle.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Fehler beim Abrufen der Schachprobleme: $e');
      return [];
    }
  }

  Future<Puzzle?> getPuzzle(String puzzleId) async {
    try {
      final doc = await _firestore.collection('puzzles').doc(puzzleId).get();
      if (doc.exists) {
        return Puzzle.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Fehler beim Abrufen des Schachproblems: $e');
      return null;
    }
  }

  Future<Puzzle?> getRandomPuzzle(
      {String? difficulty, String? category}) async {
    try {
      Query query = _firestore.collection('puzzles');

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      // Zufällige Sortierung und Limit 1
      query = query.orderBy(FieldPath.documentId).limit(1);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        return Puzzle.fromMap(
            snapshot.docs.first.data() as Map<String, dynamic>,
            snapshot.docs.first.id);
      }

      return null;
    } catch (e) {
      print('Fehler beim Abrufen eines zufälligen Schachproblems: $e');
      return null;
    }
  }

  // Eröffnungen
  Future<List<Opening>> getOpenings({String? category}) async {
    try {
      Query query = _firestore.collection('openings');

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) =>
              Opening.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Fehler beim Abrufen der Eröffnungen: $e');
      return [];
    }
  }

  Future<Opening?> getOpening(String openingId) async {
    try {
      final doc = await _firestore.collection('openings').doc(openingId).get();
      if (doc.exists) {
        return Opening.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Fehler beim Abrufen der Eröffnung: $e');
      return null;
    }
  }

  // Benutzerlernfortschritt
  Future<UserProgress?> getUserProgress() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('progress')
          .doc('learning')
          .get();

      if (doc.exists) {
        return UserProgress.fromMap(doc.data()!, currentUser.uid);
      } else {
        // Erstelle einen neuen Fortschritt, wenn keiner existiert
        final progress = UserProgress(
          userId: currentUser.uid,
          completedLessons: [],
          completedPuzzles: [],
          studiedOpenings: [],
          skillLevel: 'beginner',
          xp: 0,
          streak: 0,
          lastActivity: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('progress')
            .doc('learning')
            .set(progress.toMap());

        return progress;
      }
    } catch (e) {
      print('Fehler beim Abrufen des Benutzerfortschritts: $e');
      return null;
    }
  }

  Future<bool> updateUserProgress(UserProgress progress) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('progress')
          .doc('learning')
          .update(progress.toMap());

      return true;
    } catch (e) {
      print('Fehler beim Aktualisieren des Benutzerfortschritts: $e');
      return false;
    }
  }

  // Lektion abschließen
  Future<bool> completeLesson(String lessonId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      // Hole den aktuellen Fortschritt
      final progress = await getUserProgress();
      if (progress == null) return false;

      // Prüfe, ob die Lektion bereits abgeschlossen wurde
      if (progress.completedLessons.contains(lessonId)) {
        return true; // Bereits abgeschlossen
      }

      // Hole die Lektion, um XP zu bestimmen
      final lesson = await getLesson(lessonId);
      if (lesson == null) return false;

      // Aktualisiere den Fortschritt
      progress.completedLessons.add(lessonId);
      progress.xp += lesson.xpReward;
      progress.lastActivity = DateTime.now();

      // Aktualisiere den Streak
      final now = DateTime.now();
      final lastActivity = progress.lastActivity;
      final difference = now.difference(lastActivity).inHours;

      if (difference <= 36) {
        // Innerhalb von 36 Stunden (1,5 Tage)
        if (now.day != lastActivity.day) {
          // Neuer Tag, erhöhe Streak
          progress.streak++;
        }
      } else {
        // Mehr als 36 Stunden, Streak zurücksetzen
        progress.streak = 1;
      }

      // Aktualisiere das Fähigkeitsniveau basierend auf XP
      if (progress.xp >= 1000) {
        progress.skillLevel = 'expert';
      } else if (progress.xp >= 500) {
        progress.skillLevel = 'intermediate';
      } else {
        progress.skillLevel = 'beginner';
      }

      // Speichere den aktualisierten Fortschritt
      return await updateUserProgress(progress);
    } catch (e) {
      print('Fehler beim Abschließen der Lektion: $e');
      return false;
    }
  }

  // Schachproblem lösen
  Future<bool> solvePuzzle(String puzzleId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      // Hole den aktuellen Fortschritt
      final progress = await getUserProgress();
      if (progress == null) return false;

      // Prüfe, ob das Puzzle bereits gelöst wurde
      if (progress.completedPuzzles.contains(puzzleId)) {
        return true; // Bereits gelöst
      }

      // Hole das Puzzle, um XP zu bestimmen
      final puzzle = await getPuzzle(puzzleId);
      if (puzzle == null) return false;

      // Aktualisiere den Fortschritt
      progress.completedPuzzles.add(puzzleId);
      progress.xp += puzzle.xpReward;
      progress.lastActivity = DateTime.now();

      // Aktualisiere den Streak
      final now = DateTime.now();
      final lastActivity = progress.lastActivity;
      final difference = now.difference(lastActivity).inHours;

      if (difference <= 36) {
        // Innerhalb von 36 Stunden (1,5 Tage)
        if (now.day != lastActivity.day) {
          // Neuer Tag, erhöhe Streak
          progress.streak++;
        }
      } else {
        // Mehr als 36 Stunden, Streak zurücksetzen
        progress.streak = 1;
      }

      // Aktualisiere das Fähigkeitsniveau basierend auf XP
      if (progress.xp >= 1000) {
        progress.skillLevel = 'expert';
      } else if (progress.xp >= 500) {
        progress.skillLevel = 'intermediate';
      } else {
        progress.skillLevel = 'beginner';
      }

      // Speichere den aktualisierten Fortschritt
      return await updateUserProgress(progress);
    } catch (e) {
      print('Fehler beim Lösen des Schachproblems: $e');
      return false;
    }
  }

  // Eröffnung studieren
  Future<bool> studyOpening(String openingId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      // Hole den aktuellen Fortschritt
      final progress = await getUserProgress();
      if (progress == null) return false;

      // Prüfe, ob die Eröffnung bereits studiert wurde
      if (progress.studiedOpenings.contains(openingId)) {
        return true; // Bereits studiert
      }

      // Hole die Eröffnung, um XP zu bestimmen
      final opening = await getOpening(openingId);
      if (opening == null) return false;

      // Aktualisiere den Fortschritt
      progress.studiedOpenings.add(openingId);
      progress.xp += opening.xpReward;
      progress.lastActivity = DateTime.now();

      // Aktualisiere den Streak
      final now = DateTime.now();
      final lastActivity = progress.lastActivity;
      final difference = now.difference(lastActivity).inHours;

      if (difference <= 36) {
        // Innerhalb von 36 Stunden (1,5 Tage)
        if (now.day != lastActivity.day) {
          // Neuer Tag, erhöhe Streak
          progress.streak++;
        }
      } else {
        // Mehr als 36 Stunden, Streak zurücksetzen
        progress.streak = 1;
      }

      // Aktualisiere das Fähigkeitsniveau basierend auf XP
      if (progress.xp >= 1000) {
        progress.skillLevel = 'expert';
      } else if (progress.xp >= 500) {
        progress.skillLevel = 'intermediate';
      } else {
        progress.skillLevel = 'beginner';
      }

      // Speichere den aktualisierten Fortschritt
      return await updateUserProgress(progress);
    } catch (e) {
      print('Fehler beim Studieren der Eröffnung: $e');
      return false;
    }
  }

  // Empfehlungen
  Future<List<dynamic>> getRecommendations() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    try {
      // Hole den aktuellen Fortschritt
      final progress = await getUserProgress();
      if (progress == null) return [];

      final skillLevel = progress.skillLevel;
      final completedLessons = progress.completedLessons;
      final completedPuzzles = progress.completedPuzzles;
      final studiedOpenings = progress.studiedOpenings;

      // Empfehlungen basierend auf dem Fähigkeitsniveau
      List<dynamic> recommendations = [];

      // Empfohlene Lektionen
      final lessons = await getLessons(difficulty: skillLevel);
      for (final lesson in lessons) {
        if (!completedLessons.contains(lesson.id)) {
          recommendations.add({
            'type': 'lesson',
            'id': lesson.id,
            'title': lesson.title,
            'description': lesson.description,
            'difficulty': lesson.difficulty,
            'xpReward': lesson.xpReward,
          });

          if (recommendations.length >= 10) break;
        }
      }

      // Empfohlene Schachprobleme
      if (recommendations.length < 10) {
        final puzzles = await getPuzzles(difficulty: skillLevel);
        for (final puzzle in puzzles) {
          if (!completedPuzzles.contains(puzzle.id)) {
            recommendations.add({
              'type': 'puzzle',
              'id': puzzle.id,
              'title': puzzle.title,
              'description': puzzle.description,
              'difficulty': puzzle.difficulty,
              'xpReward': puzzle.xpReward,
            });

            if (recommendations.length >= 10) break;
          }
        }
      }

      // Empfohlene Eröffnungen
      if (recommendations.length < 10) {
        final openings = await getOpenings();
        for (final opening in openings) {
          if (!studiedOpenings.contains(opening.id)) {
            recommendations.add({
              'type': 'opening',
              'id': opening.id,
              'name': opening.name,
              'description': opening.description,
              'popularity': opening.popularity,
              'xpReward': opening.xpReward,
            });

            if (recommendations.length >= 10) break;
          }
        }
      }

      return recommendations;
    } catch (e) {
      print('Fehler beim Abrufen der Empfehlungen: $e');
      return [];
    }
  }

  // Tägliche Herausforderungen
  Future<List<dynamic>> getDailyChallenges() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    try {
      // Hole den aktuellen Fortschritt
      final progress = await getUserProgress();
      if (progress == null) return [];

      final skillLevel = progress.skillLevel;

      // Generiere tägliche Herausforderungen basierend auf dem aktuellen Datum
      final now = DateTime.now();
      final dateString = '${now.year}-${now.month}-${now.day}';

      // Verwende das Datum als Seed für die Auswahl
      final challengeDoc =
          await _firestore.collection('dailyChallenges').doc(dateString).get();

      if (challengeDoc.exists) {
        // Verwende vorhandene Herausforderungen
        return List<Map<String, dynamic>>.from(
            challengeDoc.data()?['challenges'] ?? []);
      } else {
        // Erstelle neue Herausforderungen
        List<dynamic> challenges = [];

        // Füge ein Puzzle hinzu
        final puzzle = await getRandomPuzzle(difficulty: skillLevel);
        if (puzzle != null) {
          challenges.add({
            'type': 'puzzle',
            'id': puzzle.id,
            'title': puzzle.title,
            'description': puzzle.description,
            'difficulty': puzzle.difficulty,
            'xpReward': puzzle.xpReward *
                2, // Doppelte XP für tägliche Herausforderungen
          });
        }

        // Füge eine Lektion hinzu
        final lessons = await getLessons(difficulty: skillLevel);
        if (lessons.isNotEmpty) {
          final lesson =
              lessons[now.day % lessons.length]; // Verwende Tag als Index
          challenges.add({
            'type': 'lesson',
            'id': lesson.id,
            'title': lesson.title,
            'description': lesson.description,
            'difficulty': lesson.difficulty,
            'xpReward': lesson.xpReward *
                2, // Doppelte XP für tägliche Herausforderungen
          });
        }

        // Speichere die Herausforderungen für den Tag
        await _firestore.collection('dailyChallenges').doc(dateString).set({
          'challenges': challenges,
          'date': now,
        });

        return challenges;
      }
    } catch (e) {
      print('Fehler beim Abrufen der täglichen Herausforderungen: $e');
      return [];
    }
  }

  // Lernstatistiken
  Future<Map<String, dynamic>> getLearningStats() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return {};

    try {
      // Hole den aktuellen Fortschritt
      final progress = await getUserProgress();
      if (progress == null) return {};

      // Berechne Statistiken
      final completedLessonsCount = progress.completedLessons.length;
      final completedPuzzlesCount = progress.completedPuzzles.length;
      final studiedOpeningsCount = progress.studiedOpenings.length;
      final totalXP = progress.xp;
      final streak = progress.streak;
      final skillLevel = progress.skillLevel;

      // Hole die Gesamtzahl der verfügbaren Lernmaterialien
      final totalLessonsCount = (await getLessons()).length;
      final totalPuzzlesCount = (await getPuzzles()).length;
      final totalOpeningsCount = (await getOpenings()).length;

      // Berechne Fortschrittsprozentwerte
      final lessonsProgress = totalLessonsCount > 0
          ? (completedLessonsCount / totalLessonsCount * 100).round()
          : 0;
      final puzzlesProgress = totalPuzzlesCount > 0
          ? (completedPuzzlesCount / totalPuzzlesCount * 100).round()
          : 0;
      final openingsProgress = totalOpeningsCount > 0
          ? (studiedOpeningsCount / totalOpeningsCount * 100).round()
          : 0;

      // Berechne Gesamtfortschritt
      final totalItems =
          totalLessonsCount + totalPuzzlesCount + totalOpeningsCount;
      final completedItems =
          completedLessonsCount + completedPuzzlesCount + studiedOpeningsCount;
      final totalProgress =
          totalItems > 0 ? (completedItems / totalItems * 100).round() : 0;

      return {
        'completedLessons': completedLessonsCount,
        'completedPuzzles': completedPuzzlesCount,
        'studiedOpenings': studiedOpeningsCount,
        'totalXP': totalXP,
        'streak': streak,
        'skillLevel': skillLevel,
        'lessonsProgress': lessonsProgress,
        'puzzlesProgress': puzzlesProgress,
        'openingsProgress': openingsProgress,
        'totalProgress': totalProgress,
      };
    } catch (e) {
      print('Fehler beim Abrufen der Lernstatistiken: $e');
      return {};
    }
  }
}
