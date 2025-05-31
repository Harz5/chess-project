import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/position.dart';
import '../services/analysis_service.dart';

/// Bildschirm für die erweiterte Spielanalyse
class GameAnalysisScreen extends StatefulWidget {
  final ChessBoard board;
  final String gameName;
  
  const GameAnalysisScreen({
    super.key,
    required this.board,
    required this.gameName,
  });

  @override
  State<GameAnalysisScreen> createState() => _GameAnalysisScreenState();
}

class _GameAnalysisScreenState extends State<GameAnalysisScreen> with SingleTickerProviderStateMixin {
  final AnalysisService _analysisService = AnalysisService();
  late TabController _tabController;
  
  Map<String, dynamic>? _gameAnalysis;
  Map<String, dynamic>? _movementHeatmap;
  Map<String, dynamic>? _controlHeatmap;
  List<Map<String, dynamic>>? _bestMoves;
  Map<String, dynamic>? _masterGameComparison;
  List<Map<String, dynamic>>? _improvementSuggestions;
  
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _analyzeGame();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _analyzeGame() async {
    setState(() {
      _isLoading = true;
    });
    
    // Führe die Analysen parallel aus
    await Future.wait([
      Future(() {
        _gameAnalysis = _analysisService.analyzeGame(widget.board, widget.board.moveHistory);
      }),
      Future(() {
        _movementHeatmap = _analysisService.generateMovementHeatmap(widget.board.moveHistory);
      }),
      Future(() {
        _controlHeatmap = _analysisService.generateControlHeatmap(widget.board);
      }),
      Future(() {
        _bestMoves = _analysisService.findBestMoves(widget.board);
      }),
      Future(() {
        _masterGameComparison = _analysisService.compareWithMasterGame(widget.board.moveHistory);
      }),
      Future(() {
        _improvementSuggestions = _analysisService.generateImprovementSuggestions(widget.board.moveHistory);
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
        title: Text('Analyse: ${widget.gameName}'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Übersicht'),
            Tab(text: 'Heatmaps'),
            Tab(text: 'Beste Züge'),
            Tab(text: 'Eröffnung'),
            Tab(text: 'Vergleich'),
            Tab(text: 'Verbesserungen'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildHeatmapsTab(),
                _buildBestMovesTab(),
                _buildOpeningTab(),
                _buildComparisonTab(),
                _buildImprovementsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _analyzeGame,
        tooltip: 'Analyse aktualisieren',
        child: const Icon(Icons.refresh),
      ),
    );
  }
  
  Widget _buildOverviewTab() {
    if (_gameAnalysis == null) {
      return const Center(child: Text('Keine Analysedaten verfügbar'));
    }
    
    final evaluation = _gameAnalysis!['evaluation'] as double;
    final moveQuality = _gameAnalysis!['moveQuality'] as Map<String, dynamic>;
    final tacticalPatterns = _gameAnalysis!['tacticalPatterns'] as List<Map<String, dynamic>>;
    final endgameAnalysis = _gameAnalysis!['endgameAnalysis'] as Map<String, dynamic>;
    final mistakesAnalysis = _gameAnalysis!['mistakesAnalysis'] as Map<String, dynamic>;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stellungsbewertung',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _normalizeEvaluation(evaluation),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            evaluation > 0 ? Colors.blue : Colors.red,
                          ),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        evaluation > 0
                            ? '+${evaluation.toStringAsFixed(1)}'
                            : evaluation.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: evaluation > 0 ? Colors.blue : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    evaluation > 0
                        ? 'Weiß hat einen Vorteil'
                        : evaluation < 0
                            ? 'Schwarz hat einen Vorteil'
                            : 'Die Stellung ist ausgeglichen',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Zugqualität',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQualityChart(moveQuality),
                  const SizedBox(height: 16),
                  Text(
                    'Genauigkeit: ${(moveQuality['accuracy'] as double * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Taktische Muster',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  tacticalPatterns.isEmpty
                      ? const Text('Keine taktischen Muster gefunden')
                      : Column(
                          children: tacticalPatterns.map((pattern) {
                            return ListTile(
                              leading: _getTacticalPatternIcon(pattern['type'] as String),
                              title: Text(pattern['type'] as String),
                              subtitle: Text(pattern['description'] as String),
                              trailing: Text('Zug ${pattern['moveIndex'] + 1}'),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),
          if (endgameAnalysis['isEndgame'] as bool) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Endspielanalyse',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Typ: ${endgameAnalysis['type'] as String}'),
                    Text('Vorteil: ${endgameAnalysis['advantage'] as String}'),
                    const SizedBox(height: 8),
                    Text('Weiße Figuren: ${endgameAnalysis['whitePieces']}'),
                    Text('Schwarze Figuren: ${endgameAnalysis['blackPieces']}'),
                    Text('Weiße Bauern: ${endgameAnalysis['whitePawns']}'),
                    Text('Schwarze Bauern: ${endgameAnalysis['blackPawns']}'),
                    const SizedBox(height: 8),
                    Text('Tipp: ${endgameAnalysis['advice'] as String}'),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fehleranalyse',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Kritische Fehler: ${mistakesAnalysis['mistakeCount']}'),
                  const SizedBox(height: 8),
                  (mistakesAnalysis['criticalMistakes'] as List<Map<String, dynamic>>).isEmpty
                      ? const Text('Keine kritischen Fehler gefunden')
                      : Column(
                          children: (mistakesAnalysis['criticalMistakes'] as List<Map<String, dynamic>>).map((mistake) {
                            return ListTile(
                              leading: const Icon(Icons.error, color: Colors.red),
                              title: Text('Zug ${mistake['moveIndex'] + 1}'),
                              subtitle: Text(mistake['description'] as String),
                              trailing: Text(
                                mistake['evaluation'].toString(),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeatmapsTab() {
    if (_movementHeatmap == null || _controlHeatmap == null) {
      return const Center(child: Text('Keine Heatmap-Daten verfügbar'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bewegungsheatmap',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Diese Heatmap zeigt, wie oft Figuren auf bestimmten Feldern gelandet sind.',
          ),
          const SizedBox(height: 16),
          _buildHeatmap(_movementHeatmap!['white'] as List<List<int>>, Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Weiße Figurenbewegungen',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          _buildHeatmap(_movementHeatmap!['black'] as List<List<int>>, Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Schwarze Figurenbewegungen',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Kontrollheatmap',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Diese Heatmap zeigt, wie viele Figuren jedes Feld kontrollieren.',
          ),
          const SizedBox(height: 16),
          _buildHeatmap(_controlHeatmap!['white'] as List<List<int>>, Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Weiße Feldkontrolle',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          _buildHeatmap(_controlHeatmap!['black'] as List<List<int>>, Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Schwarze Feldkontrolle',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBestMovesTab() {
    if (_bestMoves == null || _bestMoves!.isEmpty) {
      return const Center(child: Text('Keine Daten zu besten Zügen verfügbar'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Beste Züge in der aktuellen Position',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._bestMoves!.asMap().entries.map((entry) {
            final index = entry.key;
            final moveData = entry.value;
            final move = moveData['move'];
            final evaluation = moveData['evaluation'] as double;
            
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
                          backgroundColor: Colors.blue,
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
                                _formatMove(move),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bewertung: ${evaluation > 0 ? '+' : ''}${evaluation.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: evaluation > 0 ? Colors.blue : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Hier würde man den Zug auf dem Brett anzeigen
                          },
                          child: const Text('Anzeigen'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildOpeningTab() {
    if (_gameAnalysis == null) {
      return const Center(child: Text('Keine Analysedaten verfügbar'));
    }
    
    final openingAnalysis = _gameAnalysis!['openingAnalysis'] as Map<String, dynamic>;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Eröffnungsanalyse',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erkannte Eröffnung: ${openingAnalysis['name']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if ((openingAnalysis['variation'] as String).isNotEmpty)
                    Text('Variante: ${openingAnalysis['variation']}'),
                  const SizedBox(height: 8),
                  Text('Genauigkeit: ${openingAnalysis['accuracy']}%'),
                  const SizedBox(height: 16),
                  const Text(
                    'Eröffnungstheorie:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(openingAnalysis['theory'] as String),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Eröffnungsprinzipien',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildOpeningPrinciple(
            'Kontrolle des Zentrums',
            'Versuche, das Zentrum mit Bauern und Figuren zu kontrollieren.',
            Icons.grid_on,
          ),
          _buildOpeningPrinciple(
            'Figurenentwicklung',
            'Entwickle deine Figuren schnell und effizient.',
            Icons.directions_run,
          ),
          _buildOpeningPrinciple(
            'Königssicherheit',
            'Bringe deinen König durch Rochade in Sicherheit.',
            Icons.security,
          ),
          _buildOpeningPrinciple(
            'Verbindung der Türme',
            'Verbinde deine Türme, um ihre Kraft zu maximieren.',
            Icons.link,
          ),
        ],
      ),
    );
  }
  
  Widget _buildComparisonTab() {
    if (_masterGameComparison == null) {
      return const Center(child: Text('Keine Vergleichsdaten verfügbar'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vergleich mit Meisterpartien',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ähnlichkeit: ${(_masterGameComparison!['similarityScore'] as double * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Passende Eröffnung: ${_masterGameComparison!['matchingOpeningName']}'),
                  Text('Übereinstimmende Züge: ${_masterGameComparison!['matchingOpeningMoves']}'),
                  Text('Abweichung bei Zug: ${_masterGameComparison!['deviationMove']}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ähnliche Meisterpartien',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...(_masterGameComparison!['similarMasterGames'] as List<Map<String, dynamic>>).map((game) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                title: Text('${game['white']} vs. ${game['black']}'),
                subtitle: Text(game['event'] as String),
                trailing: Text(
                  '${(game['similarity'] as double * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  // Hier würde man die Meisterpartie anzeigen
                },
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildImprovementsTab() {
    if (_improvementSuggestions == null || _improvementSuggestions!.isEmpty) {
      return const Center(child: Text('Keine Verbesserungsvorschläge verfügbar'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verbesserungsvorschläge',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._improvementSuggestions!.map((suggestion) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.lightbulb,
                          color: Colors.amber,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Zug ${suggestion['moveIndex'] + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Hier würde man zum entsprechenden Zug springen
                          },
                          child: const Text('Anzeigen'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(suggestion['suggestion'] as String),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.school,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Lernpunkt: ${suggestion['improvement']}',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildQualityChart(Map<String, dynamic> moveQuality) {
    final excellentMoves = moveQuality['excellentMoves'] as int;
    final goodMoves = moveQuality['goodMoves'] as int;
    final inaccuracies = moveQuality['inaccuracies'] as int;
    final mistakes = moveQuality['mistakes'] as int;
    final blunders = moveQuality['blunders'] as int;
    
    final total = excellentMoves + goodMoves + inaccuracies + mistakes + blunders;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: excellentMoves,
              child: Container(
                height: 20,
                color: Colors.green,
              ),
            ),
            Expanded(
              flex: goodMoves,
              child: Container(
                height: 20,
                color: Colors.lightGreen,
              ),
            ),
            Expanded(
              flex: inaccuracies,
              child: Container(
                height: 20,
                color: Colors.yellow,
              ),
            ),
            Expanded(
              flex: mistakes,
              child: Container(
                height: 20,
                color: Colors.orange,
              ),
            ),
            Expanded(
              flex: blunders,
              child: Container(
                height: 20,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQualityLegend('Exzellent', excellentMoves, total, Colors.green),
            _buildQualityLegend('Gut', goodMoves, total, Colors.lightGreen),
            _buildQualityLegend('Ungenau', inaccuracies, total, Colors.yellow),
            _buildQualityLegend('Fehler', mistakes, total, Colors.orange),
            _buildQualityLegend('Patzer', blunders, total, Colors.red),
          ],
        ),
      ],
    );
  }
  
  Widget _buildQualityLegend(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
    
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
        Text(
          '$count ($percentage%)',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildHeatmap(List<List<int>> heatmap, Color color) {
    // Finde den maximalen Wert in der Heatmap
    int maxValue = 0;
    for (var row in heatmap) {
      for (var value in row) {
        if (value > maxValue) {
          maxValue = value;
        }
      }
    }
    
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          children: List.generate(8, (row) {
            return Expanded(
              child: Row(
                children: List.generate(8, (col) {
                  final isLightSquare = (row + col) % 2 == 0;
                  final value = heatmap[row][col];
                  final opacity = maxValue > 0 ? value / maxValue : 0.0;
                  
                  return Expanded(
                    child: Container(
                      color: isLightSquare ? Colors.white : Colors.grey[300],
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: color.withOpacity(opacity * 0.7),
                          child: Center(
                            child: value > 0
                                ? Text(
                                    value.toString(),
                                    style: TextStyle(
                                      color: opacity > 0.5 ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
  
  Widget _buildOpeningPrinciple(String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.blue,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Icon _getTacticalPatternIcon(String patternType) {
    switch (patternType.toLowerCase()) {
      case 'fork':
        return const Icon(Icons.call_split, color: Colors.orange);
      case 'pin':
        return const Icon(Icons.push_pin, color: Colors.red);
      case 'discovery':
        return const Icon(Icons.visibility, color: Colors.purple);
      case 'skewer':
        return const Icon(Icons.linear_scale, color: Colors.green);
      case 'double attack':
        return const Icon(Icons.flash_on, color: Colors.amber);
      default:
        return const Icon(Icons.stars, color: Colors.blue);
    }
  }
  
  double _normalizeEvaluation(double evaluation) {
    // Normalisiere die Bewertung für die Fortschrittsanzeige
    // Werte zwischen -5 und +5 werden auf 0.0 bis 1.0 abgebildet
    const double maxEval = 5.0;
    
    if (evaluation > 0) {
      return 0.5 + (evaluation / maxEval) * 0.5;
    } else {
      return 0.5 - (evaluation.abs() / maxEval) * 0.5;
    }
  }
  
  String _formatMove(dynamic move) {
    // Formatiere einen Zug in algebraischer Notation
    final from = String.fromCharCode('a'.codeUnitAt(0) + move.from.col) + (8 - move.from.row).toString();
    final to = String.fromCharCode('a'.codeUnitAt(0) + move.to.col) + (8 - move.to.row).toString();
    
    return '$from-$to';
  }
}
