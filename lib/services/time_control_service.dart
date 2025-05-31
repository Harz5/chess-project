import 'dart:async';
import '../models/chess_piece.dart';

/// Klasse für die Verwaltung der Spielzeit in verschiedenen Zeitkontrollmodi
class TimeControlService {
  // Singleton-Instanz
  static final TimeControlService _instance = TimeControlService._internal();

  factory TimeControlService() {
    return _instance;
  }

  TimeControlService._internal();

  // Verfügbare Zeitkontrollmodi
  static const Map<String, String> timeControlModes = {
    'none': 'Keine Zeitkontrolle',
    'blitz': 'Blitz (5 Minuten)',
    'rapid': 'Schnellschach (10 Minuten)',
    'classical': 'Klassisch (30 Minuten)',
    'custom': 'Benutzerdefiniert',
  };

  // Timer für die Spieler
  Timer? _whiteTimer;
  Timer? _blackTimer;

  // Verbleibende Zeit in Millisekunden
  int _whiteTimeMs = 0;
  int _blackTimeMs = 0;

  // Inkrement in Millisekunden (Zeit, die nach jedem Zug hinzugefügt wird)
  int _incrementMs = 0;

  // Aktueller Spieler am Zug
  PieceColor _currentTurn = PieceColor.white;

  // Spielstatus
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isGameOver = false;

  // Callback für Timer-Updates
  Function(int whiteTimeMs, int blackTimeMs)? _onTimerUpdate;

  // Callback für Zeitüberschreitung
  Function(PieceColor color)? _onTimeOut;

  /// Initialisiert die Zeitkontrolle für ein neues Spiel
  void initialize({
    required String timeControlMode,
    int? customTimeMinutes,
    int? customIncrementSeconds,
    Function(int whiteTimeMs, int blackTimeMs)? onTimerUpdate,
    Function(PieceColor color)? onTimeOut,
  }) {
    // Stoppe laufende Timer
    _stopTimers();

    // Setze Callbacks
    _onTimerUpdate = onTimerUpdate;
    _onTimeOut = onTimeOut;

    // Setze Spielstatus zurück
    _isRunning = false;
    _isPaused = false;
    _isGameOver = false;
    _currentTurn = PieceColor.white;

    // Setze die Zeit basierend auf dem gewählten Modus
    switch (timeControlMode) {
      case 'blitz':
        _whiteTimeMs = 5 * 60 * 1000; // 5 Minuten
        _blackTimeMs = 5 * 60 * 1000;
        _incrementMs = 0; // Kein Inkrement
        break;
      case 'rapid':
        _whiteTimeMs = 10 * 60 * 1000; // 10 Minuten
        _blackTimeMs = 10 * 60 * 1000;
        _incrementMs = 5 * 1000; // 5 Sekunden Inkrement
        break;
      case 'classical':
        _whiteTimeMs = 30 * 60 * 1000; // 30 Minuten
        _blackTimeMs = 30 * 60 * 1000;
        _incrementMs = 10 * 1000; // 10 Sekunden Inkrement
        break;
      case 'custom':
        if (customTimeMinutes != null) {
          _whiteTimeMs = customTimeMinutes * 60 * 1000;
          _blackTimeMs = customTimeMinutes * 60 * 1000;
        } else {
          _whiteTimeMs = 10 * 60 * 1000; // Standardmäßig 10 Minuten
          _blackTimeMs = 10 * 60 * 1000;
        }

        if (customIncrementSeconds != null) {
          _incrementMs = customIncrementSeconds * 1000;
        } else {
          _incrementMs = 0; // Standardmäßig kein Inkrement
        }
        break;
      case 'none':
      default:
        // Keine Zeitkontrolle
        _whiteTimeMs = 0;
        _blackTimeMs = 0;
        _incrementMs = 0;
        break;
    }

    // Benachrichtige über die initialen Zeiten
    if (_onTimerUpdate != null) {
      _onTimerUpdate!(_whiteTimeMs, _blackTimeMs);
    }
  }

  /// Startet die Zeitkontrolle
  void start() {
    if (_whiteTimeMs <= 0 && _blackTimeMs <= 0) {
      // Keine Zeitkontrolle aktiv
      return;
    }

    if (_isGameOver) {
      return;
    }

    _isRunning = true;
    _isPaused = false;

    // Starte den Timer für den aktuellen Spieler
    _startCurrentPlayerTimer();
  }

  /// Pausiert die Zeitkontrolle
  void pause() {
    if (_isRunning && !_isPaused) {
      _isPaused = true;
      _stopTimers();
    }
  }

  /// Setzt die Zeitkontrolle fort
  void resume() {
    if (_isRunning && _isPaused) {
      _isPaused = false;
      _startCurrentPlayerTimer();
    }
  }

  /// Stoppt die Zeitkontrolle
  void stop() {
    _isRunning = false;
    _isPaused = false;
    _stopTimers();
  }

  /// Wird aufgerufen, wenn ein Spieler einen Zug macht
  void onMoveMade(PieceColor color) {
    if (!_isRunning || _isPaused || _isGameOver) {
      return;
    }

    // Stoppe den aktuellen Timer
    _stopTimers();

    // Füge das Inkrement hinzu
    if (color == PieceColor.white) {
      _whiteTimeMs += _incrementMs;
    } else {
      _blackTimeMs += _incrementMs;
    }

    // Wechsle den Spieler
    _currentTurn =
        color == PieceColor.white ? PieceColor.black : PieceColor.white;

    // Starte den Timer für den nächsten Spieler
    _startCurrentPlayerTimer();

    // Benachrichtige über die aktualisierten Zeiten
    if (_onTimerUpdate != null) {
      _onTimerUpdate!(_whiteTimeMs, _blackTimeMs);
    }
  }

  /// Startet den Timer für den aktuellen Spieler
  void _startCurrentPlayerTimer() {
    if (_isGameOver) {
      return;
    }

    if (_currentTurn == PieceColor.white) {
      // Starte den Timer für Weiß
      _whiteTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_whiteTimeMs <= 0) {
          // Zeit abgelaufen für Weiß
          _handleTimeOut(PieceColor.white);
        } else {
          _whiteTimeMs -= 100;

          // Benachrichtige über die aktualisierte Zeit
          if (_onTimerUpdate != null) {
            _onTimerUpdate!(_whiteTimeMs, _blackTimeMs);
          }
        }
      });
    } else {
      // Starte den Timer für Schwarz
      _blackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_blackTimeMs <= 0) {
          // Zeit abgelaufen für Schwarz
          _handleTimeOut(PieceColor.black);
        } else {
          _blackTimeMs -= 100;

          // Benachrichtige über die aktualisierte Zeit
          if (_onTimerUpdate != null) {
            _onTimerUpdate!(_blackTimeMs, _whiteTimeMs);
          }
        }
      });
    }
  }

  /// Stoppt alle laufenden Timer
  void _stopTimers() {
    _whiteTimer?.cancel();
    _blackTimer?.cancel();
    _whiteTimer = null;
    _blackTimer = null;
  }

  /// Behandelt eine Zeitüberschreitung
  void _handleTimeOut(PieceColor color) {
    _stopTimers();
    _isGameOver = true;

    // Benachrichtige über die Zeitüberschreitung
    if (_onTimeOut != null) {
      _onTimeOut!(color);
    }
  }

  /// Gibt die verbleibende Zeit für Weiß in Millisekunden zurück
  int getWhiteTimeMs() {
    return _whiteTimeMs;
  }

  /// Gibt die verbleibende Zeit für Schwarz in Millisekunden zurück
  int getBlackTimeMs() {
    return _blackTimeMs;
  }

  /// Gibt zurück, ob die Zeitkontrolle aktiv ist
  bool isRunning() {
    return _isRunning;
  }

  /// Gibt zurück, ob die Zeitkontrolle pausiert ist
  bool isPaused() {
    return _isPaused;
  }

  /// Gibt zurück, ob das Spiel aufgrund einer Zeitüberschreitung beendet ist
  bool isGameOver() {
    return _isGameOver;
  }

  /// Formatiert die Zeit in Millisekunden als String (mm:ss)
  static String formatTime(int timeMs) {
    if (timeMs <= 0) {
      return '00:00';
    }

    final minutes = (timeMs / (60 * 1000)).floor();
    final seconds = ((timeMs % (60 * 1000)) / 1000).floor();

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Bereinigt Ressourcen
  void dispose() {
    _stopTimers();
    _onTimerUpdate = null;
    _onTimeOut = null;
  }
}
