import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

/// Service für plattformübergreifende Erweiterungen
class CrossPlatformService {
  // Singleton-Instanz
  static final CrossPlatformService _instance =
      CrossPlatformService._internal();

  factory CrossPlatformService() {
    return _instance;
  }

  // Methodenkanal für native Kommunikation
  static const MethodChannel _channel =
      MethodChannel('com.chessapp/platform_channel');

  // Ereigniskanal für Benachrichtigungen
  static const EventChannel _eventChannel =
      EventChannel('com.chessapp/notification_channel');

  // Stream für Benachrichtigungen
  StreamSubscription? _notificationSubscription;

  // Callback für Benachrichtigungen
  Function(Map<String, dynamic>)? _notificationCallback;

  CrossPlatformService._internal() {
    _initPlatformChannels();
  }

  /// Initialisiert die Plattformkanäle
  void _initPlatformChannels() {
    // Starte den Benachrichtigungsstream
    _notificationSubscription = _eventChannel
        .receiveBroadcastStream()
        .map<Map<String, dynamic>>(
            (dynamic event) => Map<String, dynamic>.from(event as Map))
        .listen(_handleNotification);
  }

  /// Behandelt eingehende Benachrichtigungen
  void _handleNotification(Map<String, dynamic> notification) {
    if (_notificationCallback != null) {
      _notificationCallback!(notification);
    }
  }

  /// Setzt den Callback für Benachrichtigungen
  void setNotificationCallback(Function(Map<String, dynamic>) callback) {
    _notificationCallback = callback;
  }

  /// Prüft, ob Sprachsteuerung verfügbar ist
  Future<bool> isVoiceControlAvailable() async {
    try {
      return await _channel.invokeMethod('isVoiceControlAvailable') as bool;
    } catch (e) {
      print('Fehler beim Prüfen der Sprachsteuerungsverfügbarkeit: $e');
      return false;
    }
  }

  /// Startet die Spracherkennung
  Future<void> startVoiceRecognition() async {
    try {
      await _channel.invokeMethod('startVoiceRecognition');
    } catch (e) {
      print('Fehler beim Starten der Spracherkennung: $e');
      rethrow;
    }
  }

  /// Stoppt die Spracherkennung
  Future<void> stopVoiceRecognition() async {
    try {
      await _channel.invokeMethod('stopVoiceRecognition');
    } catch (e) {
      print('Fehler beim Stoppen der Spracherkennung: $e');
      rethrow;
    }
  }

  /// Prüft, ob Smartwatch-Unterstützung verfügbar ist
  Future<bool> isSmartWatchAvailable() async {
    try {
      return await _channel.invokeMethod('isSmartWatchAvailable') as bool;
    } catch (e) {
      print('Fehler beim Prüfen der Smartwatch-Verfügbarkeit: $e');
      return false;
    }
  }

  /// Sendet eine Benachrichtigung an die Smartwatch
  Future<void> sendSmartWatchNotification(String title, String message) async {
    try {
      await _channel.invokeMethod('sendSmartWatchNotification', {
        'title': title,
        'message': message,
      });
    } catch (e) {
      print('Fehler beim Senden der Smartwatch-Benachrichtigung: $e');
      rethrow;
    }
  }

  /// Prüft, ob VR-Unterstützung verfügbar ist
  Future<bool> isVRAvailable() async {
    try {
      return await _channel.invokeMethod('isVRAvailable') as bool;
    } catch (e) {
      print('Fehler beim Prüfen der VR-Verfügbarkeit: $e');
      return false;
    }
  }

  /// Startet den VR-Modus
  Future<void> startVRMode() async {
    try {
      await _channel.invokeMethod('startVRMode');
    } catch (e) {
      print('Fehler beim Starten des VR-Modus: $e');
      rethrow;
    }
  }

  /// Stoppt den VR-Modus
  Future<void> stopVRMode() async {
    try {
      await _channel.invokeMethod('stopVRMode');
    } catch (e) {
      print('Fehler beim Stoppen des VR-Modus: $e');
      rethrow;
    }
  }

  /// Prüft, ob ein Schach-Smartboard verfügbar ist
  Future<bool> isSmartBoardAvailable() async {
    try {
      return await _channel.invokeMethod('isSmartBoardAvailable') as bool;
    } catch (e) {
      print('Fehler beim Prüfen der Smartboard-Verfügbarkeit: $e');
      return false;
    }
  }

  /// Verbindet mit einem Schach-Smartboard
  Future<bool> connectToSmartBoard() async {
    try {
      return await _channel.invokeMethod('connectToSmartBoard') as bool;
    } catch (e) {
      print('Fehler beim Verbinden mit dem Smartboard: $e');
      return false;
    }
  }

  /// Trennt die Verbindung zum Schach-Smartboard
  Future<void> disconnectFromSmartBoard() async {
    try {
      await _channel.invokeMethod('disconnectFromSmartBoard');
    } catch (e) {
      print('Fehler beim Trennen der Verbindung zum Smartboard: $e');
      rethrow;
    }
  }

  /// Sendet einen Zug an das Schach-Smartboard
  Future<void> sendMoveToSmartBoard(String move) async {
    try {
      await _channel.invokeMethod('sendMoveToSmartBoard', {
        'move': move,
      });
    } catch (e) {
      print('Fehler beim Senden des Zugs an das Smartboard: $e');
      rethrow;
    }
  }

  /// Empfängt einen Zug vom Schach-Smartboard
  Future<String?> receiveMoveFromSmartBoard() async {
    try {
      return await _channel.invokeMethod('receiveMoveFromSmartBoard')
          as String?;
    } catch (e) {
      print('Fehler beim Empfangen des Zugs vom Smartboard: $e');
      return null;
    }
  }

  /// Aktiviert die Vibration
  Future<void> vibrate({int duration = 500}) async {
    try {
      await _channel.invokeMethod('vibrate', {
        'duration': duration,
      });
    } catch (e) {
      print('Fehler beim Aktivieren der Vibration: $e');
      rethrow;
    }
  }

  /// Spielt einen Sound ab
  Future<void> playSound(String soundName) async {
    try {
      await _channel.invokeMethod('playSound', {
        'soundName': soundName,
      });
    } catch (e) {
      print('Fehler beim Abspielen des Sounds: $e');
      rethrow;
    }
  }

  /// Prüft, ob AR-Unterstützung verfügbar ist
  Future<bool> isARAvailable() async {
    try {
      return await _channel.invokeMethod('isARAvailable') as bool;
    } catch (e) {
      print('Fehler beim Prüfen der AR-Verfügbarkeit: $e');
      return false;
    }
  }

  /// Startet den AR-Modus
  Future<void> startARMode() async {
    try {
      await _channel.invokeMethod('startARMode');
    } catch (e) {
      print('Fehler beim Starten des AR-Modus: $e');
      rethrow;
    }
  }

  /// Stoppt den AR-Modus
  Future<void> stopARMode() async {
    try {
      await _channel.invokeMethod('stopARMode');
    } catch (e) {
      print('Fehler beim Stoppen des AR-Modus: $e');
      rethrow;
    }
  }

  /// Gibt die verfügbaren Plattformfunktionen zurück
  Future<Map<String, bool>> getAvailablePlatformFeatures() async {
    final features = <String, bool>{};

    features['voiceControl'] = await isVoiceControlAvailable();
    features['smartWatch'] = await isSmartWatchAvailable();
    features['vr'] = await isVRAvailable();
    features['smartBoard'] = await isSmartBoardAvailable();
    features['ar'] = await isARAvailable();

    return features;
  }

  /// Bereinigt Ressourcen
  void dispose() {
    _notificationSubscription?.cancel();
  }
}

/// Widget für die Sprachsteuerung
class VoiceControlWidget extends StatefulWidget {
  final Function(String) onCommand;

  const VoiceControlWidget({
    super.key,
    required this.onCommand,
  });

  @override
  State<VoiceControlWidget> createState() => _VoiceControlWidgetState();
}

class _VoiceControlWidgetState extends State<VoiceControlWidget> {
  final CrossPlatformService _platformService = CrossPlatformService();
  bool _isListening = false;
  String _lastCommand = '';

  @override
  void initState() {
    super.initState();
    _checkVoiceControlAvailability();
  }

  Future<void> _checkVoiceControlAvailability() async {
    final isAvailable = await _platformService.isVoiceControlAvailable();
    if (!isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Sprachsteuerung ist auf diesem Gerät nicht verfügbar'),
          ),
        );
      }
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _platformService.stopVoiceRecognition();
    } else {
      try {
        await _platformService.startVoiceRecognition();

        // In einer realen Implementierung würde hier ein Listener für erkannte Sprache registriert
        // Für dieses Beispiel simulieren wir eine erkannte Sprache nach 2 Sekunden
        Future.delayed(const Duration(seconds: 2), () {
          if (_isListening && mounted) {
            const command = 'Ziehe Bauer von e2 nach e4';
            setState(() {
              _lastCommand = command;
            });
            widget.onCommand(command);
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler bei der Spracherkennung: $e'),
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isListening = !_isListening;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
          color: _isListening ? Colors.red : Colors.blue,
          onPressed: _toggleListening,
          tooltip: _isListening
              ? 'Spracherkennung stoppen'
              : 'Spracherkennung starten',
        ),
        if (_lastCommand.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Letzter Befehl: $_lastCommand',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget für die Smartwatch-Integration
class SmartWatchWidget extends StatelessWidget {
  final CrossPlatformService _platformService = CrossPlatformService();

  SmartWatchWidget({super.key});

  Future<void> _sendNotification(BuildContext context) async {
    final isAvailable = await _platformService.isSmartWatchAvailable();
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Smartwatch ist nicht verfügbar'),
        ),
      );
      return;
    }

    try {
      await _platformService.sendSmartWatchNotification(
        'Schach',
        'Du bist am Zug!',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Benachrichtigung an Smartwatch gesendet'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Senden der Benachrichtigung: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.watch),
      onPressed: () => _sendNotification(context),
      tooltip: 'Benachrichtigung an Smartwatch senden',
    );
  }
}

/// Widget für die VR-Integration
class VRModeWidget extends StatefulWidget {
  const VRModeWidget({super.key});

  @override
  State<VRModeWidget> createState() => _VRModeWidgetState();
}

class _VRModeWidgetState extends State<VRModeWidget> {
  final CrossPlatformService _platformService = CrossPlatformService();
  bool _isVRModeActive = false;

  @override
  void initState() {
    super.initState();
    _checkVRAvailability();
  }

  Future<void> _checkVRAvailability() async {
    final isAvailable = await _platformService.isVRAvailable();
    if (!isAvailable && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('VR-Modus ist auf diesem Gerät nicht verfügbar'),
        ),
      );
    }
  }

  Future<void> _toggleVRMode() async {
    try {
      if (_isVRModeActive) {
        await _platformService.stopVRMode();
      } else {
        await _platformService.startVRMode();
      }

      setState(() {
        _isVRModeActive = !_isVRModeActive;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Fehler beim ${_isVRModeActive ? 'Stoppen' : 'Starten'} des VR-Modus: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_isVRModeActive ? Icons.vrpano : Icons.vr_off),
      color: _isVRModeActive ? Colors.green : Colors.grey,
      onPressed: _toggleVRMode,
      tooltip:
          _isVRModeActive ? 'VR-Modus deaktivieren' : 'VR-Modus aktivieren',
    );
  }
}

/// Widget für die Smartboard-Integration
class SmartBoardWidget extends StatefulWidget {
  final Function(String) onMoveReceived;

  const SmartBoardWidget({
    super.key,
    required this.onMoveReceived,
  });

  @override
  State<SmartBoardWidget> createState() => _SmartBoardWidgetState();
}

class _SmartBoardWidgetState extends State<SmartBoardWidget> {
  final CrossPlatformService _platformService = CrossPlatformService();
  bool _isConnected = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _checkSmartBoardAvailability();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkSmartBoardAvailability() async {
    final isAvailable = await _platformService.isSmartBoardAvailable();
    if (!isAvailable && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Smartboard ist nicht verfügbar'),
        ),
      );
    }
  }

  Future<void> _toggleConnection() async {
    try {
      if (_isConnected) {
        await _platformService.disconnectFromSmartBoard();
        _pollTimer?.cancel();
      } else {
        final success = await _platformService.connectToSmartBoard();
        if (success) {
          // Starte einen Timer, der regelmäßig nach neuen Zügen vom Smartboard fragt
          _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
            if (_isConnected) {
              final move = await _platformService.receiveMoveFromSmartBoard();
              if (move != null && move.isNotEmpty) {
                widget.onMoveReceived(move);
              }
            }
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verbindung zum Smartboard fehlgeschlagen'),
              ),
            );
          }
          return;
        }
      }

      setState(() {
        _isConnected = !_isConnected;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler bei der Smartboard-Verbindung: $e'),
          ),
        );
      }
    }
  }

  Future<void> _sendMove() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nicht mit dem Smartboard verbunden'),
        ),
      );
      return;
    }

    try {
      await _platformService.sendMoveToSmartBoard('e2e4');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zug an Smartboard gesendet'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Senden des Zugs: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(_isConnected ? Icons.link : Icons.link_off),
          color: _isConnected ? Colors.green : Colors.grey,
          onPressed: _toggleConnection,
          tooltip:
              _isConnected ? 'Smartboard trennen' : 'Mit Smartboard verbinden',
        ),
        if (_isConnected)
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMove,
            tooltip: 'Zug an Smartboard senden',
          ),
      ],
    );
  }
}

/// Widget für die AR-Integration
class ARModeWidget extends StatefulWidget {
  const ARModeWidget({super.key});

  @override
  State<ARModeWidget> createState() => _ARModeWidgetState();
}

class _ARModeWidgetState extends State<ARModeWidget> {
  final CrossPlatformService _platformService = CrossPlatformService();
  bool _isARModeActive = false;

  @override
  void initState() {
    super.initState();
    _checkARAvailability();
  }

  Future<void> _checkARAvailability() async {
    final isAvailable = await _platformService.isARAvailable();
    if (!isAvailable && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AR-Modus ist auf diesem Gerät nicht verfügbar'),
        ),
      );
    }
  }

  Future<void> _toggleARMode() async {
    try {
      if (_isARModeActive) {
        await _platformService.stopARMode();
      } else {
        await _platformService.startARMode();
      }

      setState(() {
        _isARModeActive = !_isARModeActive;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Fehler beim ${_isARModeActive ? 'Stoppen' : 'Starten'} des AR-Modus: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon:
          Icon(_isARModeActive ? Icons.view_in_ar : Icons.view_in_ar_outlined),
      color: _isARModeActive ? Colors.green : Colors.grey,
      onPressed: _toggleARMode,
      tooltip:
          _isARModeActive ? 'AR-Modus deaktivieren' : 'AR-Modus aktivieren',
    );
  }
}
