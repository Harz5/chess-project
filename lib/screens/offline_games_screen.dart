import 'package:flutter/material.dart';
import '../services/offline_service.dart';
import '../models/chess_board.dart';
import '../widgets/enhanced_game_dashboard.dart';

/// Bildschirm zur Verwaltung von Offline-Spielen
class OfflineGamesScreen extends StatefulWidget {
  const OfflineGamesScreen({super.key});

  @override
  State<OfflineGamesScreen> createState() => _OfflineGamesScreenState();
}

class _OfflineGamesScreenState extends State<OfflineGamesScreen> {
  final OfflineService _offlineService = OfflineService();
  List<Map<String, dynamic>> _savedGames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedGames();
  }

  Future<void> _loadSavedGames() async {
    setState(() {
      _isLoading = true;
    });

    final games = await _offlineService.getSavedGames();

    setState(() {
      _savedGames = games;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline-Spiele'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSavedGames,
            tooltip: 'Aktualisieren',
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _synchronizeGames,
            tooltip: 'Synchronisieren',
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _importGame,
            tooltip: 'Spiel importieren',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedGames.isEmpty
              ? _buildEmptyState()
              : _buildGamesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewGame,
        tooltip: 'Neues Offline-Spiel',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.save_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Keine gespeicherten Spiele',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Speichere Spiele, um sie offline zu spielen',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewGame,
            icon: const Icon(Icons.add),
            label: const Text('Neues Spiel erstellen'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _importGame,
            icon: const Icon(Icons.file_upload),
            label: const Text('Spiel importieren'),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList() {
    return ListView.builder(
      itemCount: _savedGames.length,
      itemBuilder: (context, index) {
        final game = _savedGames[index];
        final gameName = game['name'] as String;
        final variant = game['variant'] as String;
        final date = DateTime.parse(game['date']);
        final isGameOver = game['gameOver'] as bool;
        final winner = game['winner'] as String?;

        // Bestimme den Status des Spiels
        String status;
        if (isGameOver) {
          if (winner == null) {
            status = 'Unentschieden';
          } else if (winner == 'white') {
            status = 'Weiß hat gewonnen';
          } else {
            status = 'Schwarz hat gewonnen';
          }
        } else {
          status =
              game['currentTurn'] == 'white' ? 'Weiß am Zug' : 'Schwarz am Zug';
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              gameName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Variante: $variant'),
                Text('Datum: ${_formatDate(date)}'),
                Text('Status: $status'),
              ],
            ),
            isThreeLine: true,
            leading: _getVariantIcon(variant),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Spiel laden',
                  onPressed: () => _loadGame(gameName),
                ),
                IconButton(
                  icon: const Icon(Icons.file_download),
                  tooltip: 'Exportieren',
                  onPressed: () => _exportGame(gameName),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Löschen',
                  onPressed: () => _deleteGame(gameName),
                ),
              ],
            ),
            onTap: () => _loadGame(gameName),
          ),
        );
      },
    );
  }

  Widget _getVariantIcon(String variant) {
    IconData iconData;
    Color iconColor;

    switch (variant.toLowerCase()) {
      case 'standard':
        iconData = Icons.grid_on;
        iconColor = Colors.blue;
        break;
      case 'chess960':
        iconData = Icons.shuffle;
        iconColor = Colors.purple;
        break;
      case 'crazyhouse':
        iconData = Icons.swap_horiz;
        iconColor = Colors.orange;
        break;
      case 'antichess':
        iconData = Icons.flip_to_back;
        iconColor = Colors.red;
        break;
      case 'threecheck':
        iconData = Icons.looks_3;
        iconColor = Colors.green;
        break;
      case 'kingofthehill':
        iconData = Icons.landscape;
        iconColor = Colors.brown;
        break;
      case 'racingkings':
        iconData = Icons.directions_run;
        iconColor = Colors.teal;
        break;
      default:
        iconData = Icons.chess;
        iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.2),
      child: Icon(
        iconData,
        color: iconColor,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _createNewGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neues Offline-Spiel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Spielname',
                hintText: 'Geben Sie einen Namen für das Spiel ein',
              ),
              onChanged: (value) {
                // Speichere den Spielnamen
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Schachvariante',
              ),
              items: const [
                DropdownMenuItem(value: 'standard', child: Text('Standard')),
                DropdownMenuItem(value: 'chess960', child: Text('Chess960')),
                DropdownMenuItem(
                    value: 'crazyhouse', child: Text('Crazyhouse')),
                DropdownMenuItem(value: 'antichess', child: Text('Antichess')),
                DropdownMenuItem(
                    value: 'threecheck', child: Text('Three-Check')),
                DropdownMenuItem(
                    value: 'kingofthehill', child: Text('King of the Hill')),
                DropdownMenuItem(
                    value: 'racingkings', child: Text('Racing Kings')),
              ],
              onChanged: (value) {
                // Speichere die ausgewählte Variante
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              // Erstelle ein neues Spiel und speichere es
              Navigator.of(context).pop();
              // Navigiere zum Spielbildschirm
            },
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );
  }

  void _loadGame(String gameName) async {
    // Lade das Spiel und navigiere zum Spielbildschirm
    final gameData = await _offlineService.loadGame(gameName);
    if (gameData != null) {
      // Hier würde man das Spiel rekonstruieren und zum Spielbildschirm navigieren
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Spiel "$gameName" wird geladen...'),
        ),
      );
    }
  }

  void _exportGame(String gameName) async {
    final pgnPath = await _offlineService.exportGameAsPGN(gameName);
    if (pgnPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Spiel wurde exportiert nach: $pgnPath'),
          action: SnackBarAction(
            label: 'Teilen',
            onPressed: () {
              // Hier würde man die Datei teilen
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fehler beim Exportieren des Spiels'),
        ),
      );
    }
  }

  void _deleteGame(String gameName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Spiel löschen'),
        content: Text('Möchten Sie das Spiel "$gameName" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await _offlineService.deleteGame(gameName);
              if (success) {
                _loadSavedGames();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Spiel "$gameName" wurde gelöscht'),
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fehler beim Löschen des Spiels'),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  void _importGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Spiel importieren'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Spielname',
                hintText: 'Geben Sie einen Namen für das importierte Spiel ein',
              ),
              onChanged: (value) {
                // Speichere den Spielnamen
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Fügen Sie den PGN-Text ein oder wählen Sie eine PGN-Datei aus:',
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'PGN-Text hier einfügen...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Speichere den PGN-Text
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // Öffne den Dateiauswahldialog
              },
              icon: const Icon(Icons.file_open),
              label: const Text('PGN-Datei auswählen'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              // Importiere das Spiel
              Navigator.of(context).pop();
              _loadSavedGames();
            },
            child: const Text('Importieren'),
          ),
        ],
      ),
    );
  }

  void _synchronizeGames() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Synchronisiere Spiele...'),
      ),
    );

    final success = await _offlineService.synchronizeGames();
    if (success) {
      _loadSavedGames();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Spiele wurden erfolgreich synchronisiert'),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler bei der Synchronisierung der Spiele'),
          ),
        );
      }
    }
  }
}
