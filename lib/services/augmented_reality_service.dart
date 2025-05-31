import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../services/cross_platform_service.dart';

/// Service für den Augmented Reality Modus
class AugmentedRealityService {
  // Singleton-Instanz
  static final AugmentedRealityService _instance =
      AugmentedRealityService._internal();

  factory AugmentedRealityService() {
    return _instance;
  }

  // Methodenkanal für AR-Kommunikation
  static const MethodChannel _channel =
      MethodChannel('com.chessapp/ar_channel');

  // Ereigniskanal für AR-Ereignisse
  static const EventChannel _eventChannel =
      EventChannel('com.chessapp/ar_event_channel');

  // Stream für AR-Ereignisse
  StreamSubscription? _arEventSubscription;

  // Callback für AR-Ereignisse
  Function(Map<String, dynamic>)? _arEventCallback;

  // AR-Status
  bool _isARSessionActive = false;

  AugmentedRealityService._internal() {
    _initARChannels();
  }

  /// Initialisiert die AR-Kanäle
  void _initARChannels() {
    // Starte den AR-Ereignisstream
    _arEventSubscription = _eventChannel
        .receiveBroadcastStream()
        .map<Map<String, dynamic>>(
            (dynamic event) => Map<String, dynamic>.from(event as Map))
        .listen(_handleAREvent);
  }

  /// Behandelt eingehende AR-Ereignisse
  void _handleAREvent(Map<String, dynamic> event) {
    if (_arEventCallback != null) {
      _arEventCallback!(event);
    }
  }

  /// Setzt den Callback für AR-Ereignisse
  void setAREventCallback(Function(Map<String, dynamic>) callback) {
    _arEventCallback = callback;
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

  /// Startet eine AR-Sitzung
  Future<bool> startARSession() async {
    if (_isARSessionActive) {
      return true;
    }

    try {
      final result = await _channel.invokeMethod('startARSession') as bool;
      _isARSessionActive = result;
      return result;
    } catch (e) {
      print('Fehler beim Starten der AR-Sitzung: $e');
      return false;
    }
  }

  /// Stoppt die AR-Sitzung
  Future<bool> stopARSession() async {
    if (!_isARSessionActive) {
      return true;
    }

    try {
      final result = await _channel.invokeMethod('stopARSession') as bool;
      if (result) {
        _isARSessionActive = false;
      }
      return result;
    } catch (e) {
      print('Fehler beim Stoppen der AR-Sitzung: $e');
      return false;
    }
  }

  /// Platziert ein virtuelles Schachbrett auf einer erkannten Oberfläche
  Future<bool> placeChessBoard(Map<String, dynamic> position) async {
    if (!_isARSessionActive) {
      return false;
    }

    try {
      return await _channel.invokeMethod('placeChessBoard', position) as bool;
    } catch (e) {
      print('Fehler beim Platzieren des Schachbretts: $e');
      return false;
    }
  }

  /// Bewegt eine Schachfigur in AR
  Future<bool> moveChessPiece(String from, String to) async {
    if (!_isARSessionActive) {
      return false;
    }

    try {
      return await _channel.invokeMethod('moveChessPiece', {
        'from': from,
        'to': to,
      }) as bool;
    } catch (e) {
      print('Fehler beim Bewegen der Schachfigur: $e');
      return false;
    }
  }

  /// Erkennt physische Schachfiguren
  Future<Map<String, String>?> detectPhysicalChessPieces() async {
    if (!_isARSessionActive) {
      return null;
    }

    try {
      final result = await _channel.invokeMethod('detectPhysicalChessPieces');
      if (result != null) {
        return Map<String, String>.from(result as Map);
      }
      return null;
    } catch (e) {
      print('Fehler beim Erkennen physischer Schachfiguren: $e');
      return null;
    }
  }

  /// Projiziert einen gültigen Zug in AR
  Future<bool> projectValidMove(String from, List<String> validMoves) async {
    if (!_isARSessionActive) {
      return false;
    }

    try {
      return await _channel.invokeMethod('projectValidMove', {
        'from': from,
        'validMoves': validMoves,
      }) as bool;
    } catch (e) {
      print('Fehler beim Projizieren gültiger Züge: $e');
      return false;
    }
  }

  /// Zeigt eine Animation in AR an
  Future<bool> showAnimation(String type, String position) async {
    if (!_isARSessionActive) {
      return false;
    }

    try {
      return await _channel.invokeMethod('showAnimation', {
        'type': type,
        'position': position,
      }) as bool;
    } catch (e) {
      print('Fehler beim Anzeigen der Animation: $e');
      return false;
    }
  }

  /// Passt die Größe des AR-Schachbretts an
  Future<bool> resizeChessBoard(double scale) async {
    if (!_isARSessionActive) {
      return false;
    }

    try {
      return await _channel.invokeMethod('resizeChessBoard', {
        'scale': scale,
      }) as bool;
    } catch (e) {
      print('Fehler beim Anpassen der Brettgröße: $e');
      return false;
    }
  }

  /// Rotiert das AR-Schachbrett
  Future<bool> rotateChessBoard(double angle) async {
    if (!_isARSessionActive) {
      return false;
    }

    try {
      return await _channel.invokeMethod('rotateChessBoard', {
        'angle': angle,
      }) as bool;
    } catch (e) {
      print('Fehler beim Rotieren des Bretts: $e');
      return false;
    }
  }

  /// Wechselt das Thema des AR-Schachbretts
  Future<bool> changeChessBoardTheme(String theme) async {
    if (!_isARSessionActive) {
      return false;
    }

    try {
      return await _channel.invokeMethod('changeChessBoardTheme', {
        'theme': theme,
      }) as bool;
    } catch (e) {
      print('Fehler beim Wechseln des Brettthemas: $e');
      return false;
    }
  }

  /// Zeigt Informationen über eine Figur in AR an
  Future<bool> showPieceInfo(String position) async {
    if (!_isARSessionActive) {
      return false;
    }

    try {
      return await _channel.invokeMethod('showPieceInfo', {
        'position': position,
      }) as bool;
    } catch (e) {
      print('Fehler beim Anzeigen der Figureninformationen: $e');
      return false;
    }
  }

  /// Nimmt ein Foto der aktuellen AR-Szene auf
  Future<String?> takeScreenshot() async {
    if (!_isARSessionActive) {
      return null;
    }

    try {
      return await _channel.invokeMethod('takeScreenshot') as String?;
    } catch (e) {
      print('Fehler beim Aufnehmen des Screenshots: $e');
      return null;
    }
  }

  /// Gibt zurück, ob eine AR-Sitzung aktiv ist
  bool isARSessionActive() {
    return _isARSessionActive;
  }

  /// Bereinigt Ressourcen
  void dispose() {
    _arEventSubscription?.cancel();
    stopARSession();
  }
}

/// Widget für den AR-Modus
class ARModeScreen extends StatefulWidget {
  const ARModeScreen({super.key});

  @override
  State<ARModeScreen> createState() => _ARModeScreenState();
}

class _ARModeScreenState extends State<ARModeScreen> {
  final AugmentedRealityService _arService = AugmentedRealityService();
  final CrossPlatformService _platformService = CrossPlatformService();

  bool _isARAvailable = false;
  bool _isARSessionActive = false;
  bool _isBoardPlaced = false;
  String _statusMessage = 'Initialisiere AR...';

  // Steuerelemente
  double _boardScale = 1.0;
  double _boardRotation = 0.0;
  String _selectedTheme = 'Standard';

  @override
  void initState() {
    super.initState();
    _checkARAvailability();
    _setupAREventCallback();
  }

  @override
  void dispose() {
    _arService.dispose();
    super.dispose();
  }

  void _setupAREventCallback() {
    _arService.setAREventCallback((event) {
      final eventType = event['type'] as String?;

      switch (eventType) {
        case 'surfaceDetected':
          setState(() {
            _statusMessage =
                'Oberfläche erkannt. Tippe, um das Schachbrett zu platzieren.';
          });
          break;
        case 'boardPlaced':
          setState(() {
            _isBoardPlaced = true;
            _statusMessage = 'Schachbrett platziert. Du kannst jetzt spielen.';
          });
          break;
        case 'pieceDetected':
          final position = event['position'] as String?;
          final pieceType = event['pieceType'] as String?;
          if (position != null && pieceType != null) {
            setState(() {
              _statusMessage = '$pieceType auf $position erkannt.';
            });
          }
          break;
        case 'error':
          final errorMessage = event['message'] as String?;
          setState(() {
            _statusMessage = 'Fehler: ${errorMessage ?? 'Unbekannter Fehler'}';
          });
          break;
      }
    });
  }

  Future<void> _checkARAvailability() async {
    final isAvailable = await _arService.isARAvailable();

    setState(() {
      _isARAvailable = isAvailable;
      _statusMessage = isAvailable
          ? 'AR verfügbar. Starte eine Sitzung, um zu beginnen.'
          : 'AR ist auf diesem Gerät nicht verfügbar.';
    });
  }

  Future<void> _toggleARSession() async {
    if (_isARSessionActive) {
      final success = await _arService.stopARSession();
      if (success) {
        setState(() {
          _isARSessionActive = false;
          _isBoardPlaced = false;
          _statusMessage = 'AR-Sitzung beendet.';
        });
      } else {
        setState(() {
          _statusMessage = 'Fehler beim Beenden der AR-Sitzung.';
        });
      }
    } else {
      final success = await _arService.startARSession();
      if (success) {
        setState(() {
          _isARSessionActive = true;
          _statusMessage =
              'AR-Sitzung gestartet. Suche nach einer flachen Oberfläche...';
        });
      } else {
        setState(() {
          _statusMessage = 'Fehler beim Starten der AR-Sitzung.';
        });
      }
    }
  }

  Future<void> _placeChessBoard() async {
    if (!_isARSessionActive) {
      setState(() {
        _statusMessage = 'Starte zuerst eine AR-Sitzung.';
      });
      return;
    }

    // In einer realen Implementierung würden wir die Position aus der AR-Erkennung erhalten
    final position = {
      'x': 0.0,
      'y': 0.0,
      'z': -0.5,
    };

    final success = await _arService.placeChessBoard(position);
    if (success) {
      setState(() {
        _isBoardPlaced = true;
        _statusMessage = 'Schachbrett platziert. Du kannst jetzt spielen.';
      });
    } else {
      setState(() {
        _statusMessage = 'Fehler beim Platzieren des Schachbretts.';
      });
    }
  }

  Future<void> _moveChessPiece() async {
    if (!_isARSessionActive || !_isBoardPlaced) {
      setState(() {
        _statusMessage = 'Platziere zuerst das Schachbrett.';
      });
      return;
    }

    // Beispielzug
    const from = 'e2';
    const to = 'e4';

    final success = await _arService.moveChessPiece(from, to);
    if (success) {
      setState(() {
        _statusMessage = 'Figur von $from nach $to bewegt.';
      });
    } else {
      setState(() {
        _statusMessage = 'Fehler beim Bewegen der Figur.';
      });
    }
  }

  Future<void> _detectPhysicalPieces() async {
    if (!_isARSessionActive || !_isBoardPlaced) {
      setState(() {
        _statusMessage = 'Platziere zuerst das Schachbrett.';
      });
      return;
    }

    final pieces = await _arService.detectPhysicalChessPieces();
    if (pieces != null && pieces.isNotEmpty) {
      setState(() {
        _statusMessage = 'Erkannte Figuren: ${pieces.length}';
      });
    } else {
      setState(() {
        _statusMessage = 'Keine physischen Figuren erkannt.';
      });
    }
  }

  Future<void> _showValidMoves() async {
    if (!_isARSessionActive || !_isBoardPlaced) {
      setState(() {
        _statusMessage = 'Platziere zuerst das Schachbrett.';
      });
      return;
    }

    // Beispiel für gültige Züge
    const from = 'e2';
    const validMoves = ['e3', 'e4'];

    final success = await _arService.projectValidMove(from, validMoves);
    if (success) {
      setState(() {
        _statusMessage = 'Gültige Züge für $from angezeigt.';
      });
    } else {
      setState(() {
        _statusMessage = 'Fehler beim Anzeigen gültiger Züge.';
      });
    }
  }

  Future<void> _showAnimation() async {
    if (!_isARSessionActive || !_isBoardPlaced) {
      setState(() {
        _statusMessage = 'Platziere zuerst das Schachbrett.';
      });
      return;
    }

    // Beispielanimation
    const type = 'capture';
    const position = 'e4';

    final success = await _arService.showAnimation(type, position);
    if (success) {
      setState(() {
        _statusMessage = 'Animation auf $position angezeigt.';
      });
    } else {
      setState(() {
        _statusMessage = 'Fehler beim Anzeigen der Animation.';
      });
    }
  }

  Future<void> _updateBoardScale() async {
    if (!_isARSessionActive || !_isBoardPlaced) {
      setState(() {
        _statusMessage = 'Platziere zuerst das Schachbrett.';
      });
      return;
    }

    final success = await _arService.resizeChessBoard(_boardScale);
    if (success) {
      setState(() {
        _statusMessage = 'Brettgröße angepasst.';
      });
    } else {
      setState(() {
        _statusMessage = 'Fehler beim Anpassen der Brettgröße.';
      });
    }
  }

  Future<void> _updateBoardRotation() async {
    if (!_isARSessionActive || !_isBoardPlaced) {
      setState(() {
        _statusMessage = 'Platziere zuerst das Schachbrett.';
      });
      return;
    }

    final success = await _arService.rotateChessBoard(_boardRotation);
    if (success) {
      setState(() {
        _statusMessage = 'Brett rotiert.';
      });
    } else {
      setState(() {
        _statusMessage = 'Fehler beim Rotieren des Bretts.';
      });
    }
  }

  Future<void> _changeTheme() async {
    if (!_isARSessionActive || !_isBoardPlaced) {
      setState(() {
        _statusMessage = 'Platziere zuerst das Schachbrett.';
      });
      return;
    }

    final success = await _arService.changeChessBoardTheme(_selectedTheme);
    if (success) {
      setState(() {
        _statusMessage = 'Thema zu $_selectedTheme gewechselt.';
      });
    } else {
      setState(() {
        _statusMessage = 'Fehler beim Wechseln des Themas.';
      });
    }
  }

  Future<void> _takeScreenshot() async {
    if (!_isARSessionActive || !_isBoardPlaced) {
      setState(() {
        _statusMessage = 'Platziere zuerst das Schachbrett.';
      });
      return;
    }

    final imagePath = await _arService.takeScreenshot();
    if (imagePath != null) {
      setState(() {
        _statusMessage = 'Screenshot gespeichert unter: $imagePath';
      });
    } else {
      setState(() {
        _statusMessage = 'Fehler beim Aufnehmen des Screenshots.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Augmented Reality Schach'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed:
                _isARSessionActive && _isBoardPlaced ? _takeScreenshot : null,
            tooltip: 'Screenshot',
          ),
        ],
      ),
      body: Column(
        children: [
          // AR-Vorschau (in einer realen Implementierung würde hier die Kameraansicht angezeigt)
          Expanded(
            child: Container(
              color: Colors.black,
              child: Center(
                child: _isARAvailable
                    ? _isARSessionActive
                        ? const Text(
                            'AR-Kameraansicht',
                            style: TextStyle(color: Colors.white),
                          )
                        : const Text(
                            'AR-Sitzung starten, um die Kameraansicht zu sehen',
                            style: TextStyle(color: Colors.white),
                          )
                    : const Text(
                        'AR ist auf diesem Gerät nicht verfügbar',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ),

          // Statusanzeige
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[200],
            width: double.infinity,
            child: Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // Steuerelemente
          if (_isARAvailable)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // AR-Sitzung starten/stoppen
                  ElevatedButton(
                    onPressed: _toggleARSession,
                    child: Text(_isARSessionActive
                        ? 'AR-Sitzung beenden'
                        : 'AR-Sitzung starten'),
                  ),

                  const SizedBox(height: 8),

                  // Schachbrett platzieren
                  ElevatedButton(
                    onPressed: _isARSessionActive && !_isBoardPlaced
                        ? _placeChessBoard
                        : null,
                    child: const Text('Schachbrett platzieren'),
                  ),

                  if (_isARSessionActive && _isBoardPlaced) ...[
                    const SizedBox(height: 16),

                    // Aktionsbuttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _moveChessPiece,
                          child: const Text('Zug'),
                        ),
                        ElevatedButton(
                          onPressed: _detectPhysicalPieces,
                          child: const Text('Erkennen'),
                        ),
                        ElevatedButton(
                          onPressed: _showValidMoves,
                          child: const Text('Züge'),
                        ),
                        ElevatedButton(
                          onPressed: _showAnimation,
                          child: const Text('Animation'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Größenanpassung
                    Row(
                      children: [
                        const Text('Größe:'),
                        Expanded(
                          child: Slider(
                            value: _boardScale,
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                            label: _boardScale.toStringAsFixed(1),
                            onChanged: (value) {
                              setState(() {
                                _boardScale = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _updateBoardScale();
                            },
                          ),
                        ),
                      ],
                    ),

                    // Rotation
                    Row(
                      children: [
                        const Text('Rotation:'),
                        Expanded(
                          child: Slider(
                            value: _boardRotation,
                            min: 0,
                            max: 360,
                            divisions: 36,
                            label: '${_boardRotation.toInt()}°',
                            onChanged: (value) {
                              setState(() {
                                _boardRotation = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _updateBoardRotation();
                            },
                          ),
                        ),
                      ],
                    ),

                    // Themenauswahl
                    Row(
                      children: [
                        const Text('Thema:'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedTheme,
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedTheme = newValue;
                                });
                                _changeTheme();
                              }
                            },
                            items: <String>[
                              'Standard',
                              'Holz',
                              'Marmor',
                              'Modern',
                              'Klassisch',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
