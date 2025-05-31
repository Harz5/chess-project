import 'package:flutter/material.dart';
import '../services/ranking_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final RankingService _rankingService = RankingService();
  List<Map<String, dynamic>> _topPlayers = [];
  bool _isLoading = true;
  Map<String, dynamic>? _currentPlayerProfile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lade die Top-Spieler
      final topPlayers = await _rankingService.getTopPlayers(limit: 50);

      // Lade das aktuelle Spielerprofil
      final currentProfile = await _rankingService.getCurrentPlayerProfile();

      setState(() {
        _topPlayers = topPlayers;
        _currentPlayerProfile = currentProfile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Rangliste: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rangliste'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Aktualisieren',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Aktueller Spieler
                if (_currentPlayerProfile != null) _buildCurrentPlayerCard(),

                // Top-Spieler
                Expanded(
                  child: _topPlayers.isEmpty
                      ? const Center(
                          child:
                              Text('Keine Spieler in der Rangliste gefunden.'),
                        )
                      : ListView.builder(
                          itemCount: _topPlayers.length,
                          itemBuilder: (context, index) {
                            final player = _topPlayers[index];
                            return _buildPlayerListItem(player, index + 1);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCurrentPlayerCard() {
    if (_currentPlayerProfile == null) return const SizedBox.shrink();

    // Finde die Position des aktuellen Spielers in der Rangliste
    int playerRank = -1;
    for (int i = 0; i < _topPlayers.length; i++) {
      if (_topPlayers[i]['userId'] == _currentPlayerProfile!['userId']) {
        playerRank = i + 1;
        break;
      }
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      color: Colors.brown.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.brown,
                  child: Text(
                    _currentPlayerProfile!['displayName']
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentPlayerProfile!['displayName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        playerRank > 0
                            ? 'Rang: $playerRank'
                            : 'Nicht in den Top 50',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'ELO: ${_currentPlayerProfile!['elo']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Siege', _currentPlayerProfile!['wins']),
                _buildStatItem('Niederlagen', _currentPlayerProfile!['losses']),
                _buildStatItem(
                    'Unentschieden', _currentPlayerProfile!['draws']),
                _buildStatItem('Spiele', _currentPlayerProfile!['gamesPlayed']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerListItem(Map<String, dynamic> player, int rank) {
    final isCurrentPlayer = _currentPlayerProfile != null &&
        player['userId'] == _currentPlayerProfile!['userId'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: isCurrentPlayer ? Colors.brown.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(rank),
          child: Text(
            rank.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          player['displayName'],
          style: TextStyle(
            fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          'Spiele: ${player['gamesPlayed']} | W: ${player['wins']} | N: ${player['losses']} | U: ${player['draws']}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.brown,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'ELO: ${player['elo']}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          // Hier könnte man zum Spielerprofil navigieren
        },
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber.shade700; // Gold
    if (rank == 2) return Colors.grey.shade400; // Silber
    if (rank == 3) return Colors.brown.shade300; // Bronze
    return Colors.brown;
  }
}
