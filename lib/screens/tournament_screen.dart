import 'package:flutter/material.dart';
import '../services/tournament_service.dart';

class TournamentListScreen extends StatefulWidget {
  const TournamentListScreen({super.key});

  @override
  State<TournamentListScreen> createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends State<TournamentListScreen>
    with SingleTickerProviderStateMixin {
  final TournamentService _tournamentService = TournamentService();
  List<Map<String, dynamic>> _activeTournaments = [];
  List<Map<String, dynamic>> _userTournaments = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lade aktive Turniere und Turniere des Benutzers
      final activeTournaments = await _tournamentService.getActiveTournaments();
      final userTournaments = _tournamentService.getUserTournaments();

      setState(() {
        _activeTournaments = activeTournaments;
        _userTournaments = userTournaments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Turniere: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turniere'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aktive Turniere'),
            Tab(text: 'Meine Turniere'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Aktualisieren',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigiere zum Bildschirm zum Erstellen eines Turniers
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateTournamentScreen(),
                ),
              ).then((_) => _loadData());
            },
            tooltip: 'Neues Turnier erstellen',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Aktive Turniere
                _buildTournamentList(_activeTournaments),

                // Meine Turniere
                _buildTournamentList(_userTournaments),
              ],
            ),
    );
  }

  Widget _buildTournamentList(List<Map<String, dynamic>> tournaments) {
    if (tournaments.isEmpty) {
      return const Center(
        child: Text('Keine Turniere gefunden.'),
      );
    }

    return ListView.builder(
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        return _buildTournamentCard(tournament);
      },
    );
  }

  Widget _buildTournamentCard(Map<String, dynamic> tournament) {
    // Formatiere die Daten
    final startDate = (tournament['startDate'] as Timestamp).toDate();
    final endDate = (tournament['endDate'] as Timestamp).toDate();
    final formattedStartDate =
        '${startDate.day}.${startDate.month}.${startDate.year}';
    final formattedEndDate = '${endDate.day}.${endDate.month}.${endDate.year}';

    // Bestimme den Status-Text und die Farbe
    String statusText;
    Color statusColor;

    switch (tournament['status']) {
      case 'registration':
        statusText = 'Anmeldung';
        statusColor = Colors.blue;
        break;
      case 'active':
        statusText = 'Aktiv';
        statusColor = Colors.green;
        break;
      case 'completed':
        statusText = 'Beendet';
        statusColor = Colors.grey;
        break;
      default:
        statusText = tournament['status'];
        statusColor = Colors.grey;
    }

    // Bestimme den Turniertyp-Text
    String tournamentTypeText;

    switch (tournament['tournamentType']) {
      case 'knockout':
        tournamentTypeText = 'K.O.-System';
        break;
      case 'roundrobin':
        tournamentTypeText = 'Jeder gegen jeden';
        break;
      case 'swiss':
        tournamentTypeText = 'Schweizer System';
        break;
      default:
        tournamentTypeText = tournament['tournamentType'];
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          // Navigiere zum Turnierdetail-Bildschirm
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TournamentDetailScreen(
                tournamentId: tournament['id'],
              ),
            ),
          ).then((_) => _loadData());
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tournament['name'],
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
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
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
                tournament['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Typ: $tournamentTypeText',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Teilnehmer: ${tournament['currentParticipants']}/${tournament['maxParticipants']}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Zeitraum: $formattedStartDate - $formattedEndDate',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                  if (tournament['status'] == 'active')
                    Text(
                      'Runde: ${tournament['currentRound']}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final TournamentService _tournamentService = TournamentService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '8');
  final _minEloController = TextEditingController();
  final _maxEloController = TextEditingController();

  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 8));
  String _tournamentType = 'knockout';
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    _minEloController.dispose();
    _maxEloController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate ? DateTime.now() : _startDate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // Stelle sicher, dass das Enddatum nicht vor dem Startdatum liegt
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 7));
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _createTournament() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final maxParticipants = int.parse(_maxParticipantsController.text.trim());

      // Konvertiere leere Strings zu null
      final minEloText = _minEloController.text.trim();
      final maxEloText = _maxEloController.text.trim();

      final minElo = minEloText.isNotEmpty ? int.parse(minEloText) : null;
      final maxElo = maxEloText.isNotEmpty ? int.parse(maxEloText) : null;

      final tournamentId = await _tournamentService.createTournament(
        name: name,
        description: description,
        startDate: _startDate,
        endDate: _endDate,
        maxParticipants: maxParticipants,
        tournamentType: _tournamentType,
        minEloRating: minElo,
        maxEloRating: maxElo,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turnier erfolgreich erstellt')),
        );

        // Navigiere zurück zur Turnierliste
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Erstellen des Turniers: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neues Turnier erstellen'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Turniername',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte gib einen Turniernamen ein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte gib eine Beschreibung ein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _maxParticipantsController,
                      decoration: const InputDecoration(
                        labelText: 'Max. Teilnehmer',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Erforderlich';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 2) {
                          return 'Min. 2';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _tournamentType,
                      decoration: const InputDecoration(
                        labelText: 'Turniertyp',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'knockout',
                          child: Text('K.O.-System'),
                        ),
                        DropdownMenuItem(
                          value: 'roundrobin',
                          child: Text('Jeder gegen jeden'),
                        ),
                        DropdownMenuItem(
                          value: 'swiss',
                          child: Text('Schweizer System'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _tournamentType = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Startdatum',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_startDate.day}.${_startDate.month}.${_startDate.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Enddatum',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_endDate.day}.${_endDate.month}.${_endDate.year}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'ELO-Beschränkungen (optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minEloController,
                      decoration: const InputDecoration(
                        labelText: 'Min. ELO',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxEloController,
                      decoration: const InputDecoration(
                        labelText: 'Max. ELO',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createTournament,
                  child: _isCreating
                      ? const CircularProgressIndicator()
                      : const Text('Turnier erstellen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TournamentDetailScreen extends StatefulWidget {
  final String tournamentId;

  const TournamentDetailScreen({
    super.key,
    required this.tournamentId,
  });

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen>
    with SingleTickerProviderStateMixin {
  final TournamentService _tournamentService = TournamentService();
  Map<String, dynamic>? _tournament;
  List<Map<String, dynamic>> _participants = [];
  bool _isLoading = true;
  bool _isJoining = false;
  bool _isStarting = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lade Turnierdetails und Teilnehmer
      final tournament =
          await _tournamentService.getTournamentDetails(widget.tournamentId);
      final participants =
          _tournamentService.getTournamentParticipants(widget.tournamentId);

      setState(() {
        _tournament = tournament;
        _participants = participants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Turnierdaten: $e')),
        );
      }
    }
  }

  Future<void> _joinTournament() async {
    setState(() {
      _isJoining = true;
    });

    try {
      final success =
          await _tournamentService.joinTournament(widget.tournamentId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Erfolgreich dem Turnier beigetreten')),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konnte dem Turnier nicht beitreten')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Beitreten des Turniers: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  Future<void> _startTournament() async {
    setState(() {
      _isStarting = true;
    });

    try {
      final success =
          await _tournamentService.startTournament(widget.tournamentId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Turnier erfolgreich gestartet')),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konnte das Turnier nicht starten')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Starten des Turniers: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Turnierdetails'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_tournament == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Turnierdetails'),
        ),
        body: const Center(
          child: Text('Turnier nicht gefunden'),
        ),
      );
    }

    // Formatiere die Daten
    final startDate = (_tournament!['startDate'] as Timestamp).toDate();
    final endDate = (_tournament!['endDate'] as Timestamp).toDate();
    final formattedStartDate =
        '${startDate.day}.${startDate.month}.${startDate.year}';
    final formattedEndDate = '${endDate.day}.${endDate.month}.${endDate.year}';

    // Bestimme den Turniertyp-Text
    String tournamentTypeText;

    switch (_tournament!['tournamentType']) {
      case 'knockout':
        tournamentTypeText = 'K.O.-System';
        break;
      case 'roundrobin':
        tournamentTypeText = 'Jeder gegen jeden';
        break;
      case 'swiss':
        tournamentTypeText = 'Schweizer System';
        break;
      default:
        tournamentTypeText = _tournament!['tournamentType'];
    }

    // Überprüfe, ob der Benutzer der Ersteller des Turniers ist
    final isCreator =
        _tournament!['createdBy'] == FirebaseAuth.instance.currentUser?.uid;

    // Überprüfe, ob der Benutzer bereits teilnimmt
    final isParticipant = (_tournament!['participants'] as List<dynamic>)
        .contains(FirebaseAuth.instance.currentUser?.uid);

    // Überprüfe, ob das Turnier voll ist
    final isFull =
        _tournament!['currentParticipants'] >= _tournament!['maxParticipants'];

    // Bestimme, ob der Benutzer dem Turnier beitreten kann
    final canJoin =
        _tournament!['status'] == 'registration' && !isParticipant && !isFull;

    // Bestimme, ob der Ersteller das Turnier starten kann
    final canStart = isCreator &&
        _tournament!['status'] == 'registration' &&
        _tournament!['currentParticipants'] >= 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(_tournament!['name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Aktualisieren',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Übersicht'),
            Tab(text: 'Teilnehmer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Übersicht
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Turnierstatus
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_tournament!['status']),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    _getStatusText(_tournament!['status']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // Turnierbeschreibung
                const Text(
                  'Beschreibung',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(_tournament!['description']),
                const SizedBox(height: 16),

                // Turnierdetails
                const Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Typ', tournamentTypeText),
                _buildDetailRow(
                    'Zeitraum', '$formattedStartDate - $formattedEndDate'),
                _buildDetailRow('Teilnehmer',
                    '${_tournament!['currentParticipants']}/${_tournament!['maxParticipants']}'),
                if (_tournament!['minEloRating'] != null)
                  _buildDetailRow(
                      'Min. ELO', '${_tournament!['minEloRating']}'),
                if (_tournament!['maxEloRating'] != null)
                  _buildDetailRow(
                      'Max. ELO', '${_tournament!['maxEloRating']}'),
                if (_tournament!['status'] == 'active')
                  _buildDetailRow(
                      'Aktuelle Runde', '${_tournament!['currentRound']}'),
                const SizedBox(height: 16),

                // Aktionsbuttons
                if (canJoin)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isJoining ? null : _joinTournament,
                      child: _isJoining
                          ? const CircularProgressIndicator()
                          : const Text('Turnier beitreten'),
                    ),
                  ),
                if (canStart)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isStarting ? null : _startTournament,
                      child: _isStarting
                          ? const CircularProgressIndicator()
                          : const Text('Turnier starten'),
                    ),
                  ),

                // Turnierrunden
                if (_tournament!['status'] != 'registration' &&
                    _tournament!['rounds'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Runden',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._buildRoundsList(_tournament!['rounds']),
                    ],
                  ),
              ],
            ),
          ),

          // Teilnehmer
          _participants.isEmpty
              ? const Center(
                  child: Text('Keine Teilnehmer gefunden.'),
                )
              : ListView.builder(
                  itemCount: _participants.length,
                  itemBuilder: (context, index) {
                    final participant = _participants[index];
                    return _buildParticipantListItem(participant);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRoundsList(List<dynamic> rounds) {
    final widgets = <Widget>[];

    for (int i = 0; i < rounds.length; i++) {
      final round = rounds[i] as Map<String, dynamic>;
      final roundNumber = round['roundNumber'];
      final matches = round['matches'] as List<dynamic>;
      final isActive = round['status'] == 'active';

      widgets.add(
        ExpansionTile(
          title: Text('Runde $roundNumber'),
          subtitle: Text('${matches.length} Partien'),
          initiallyExpanded: isActive,
          children: matches.map<Widget>((match) {
            return _buildMatchListItem(match);
          }).toList(),
        ),
      );
    }

    return widgets;
  }

  Widget _buildMatchListItem(Map<String, dynamic> match) {
    final player1Id = match['player1'];
    final player2Id = match['player2'];
    final winnerId = match['winnerId'];
    final isDraw = match['isDraw'] ?? false;
    final status = match['status'];

    // Finde die Spielernamen
    String player1Name = 'Spieler 1';
    String player2Name = 'Spieler 2';

    for (final participant in _participants) {
      if (participant['userId'] == player1Id) {
        player1Name = participant['displayName'] ?? 'Spieler 1';
      }
      if (participant['userId'] == player2Id) {
        player2Name = participant['displayName'] ?? 'Spieler 2';
      }
    }

    // Bestimme die Statusfarbe
    Color statusColor;
    switch (status) {
      case 'pending':
        statusColor = Colors.grey;
        break;
      case 'active':
        statusColor = Colors.blue;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              player1Name,
              style: TextStyle(
                fontWeight:
                    winnerId == player1Id ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            'vs',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              player2Id != null ? player2Name : 'Freilos',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight:
                    winnerId == player2Id ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      subtitle: status == 'completed'
          ? Text(
              isDraw
                  ? 'Unentschieden'
                  : winnerId == player1Id
                      ? '$player1Name gewinnt'
                      : '$player2Name gewinnt',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            )
          : null,
      leading: CircleAvatar(
        backgroundColor: statusColor,
        radius: 6,
      ),
      onTap: () {
        // Hier könnte man zum Spieldetail navigieren
      },
    );
  }

  Widget _buildParticipantListItem(Map<String, dynamic> participant) {
    final userId = participant['userId'];
    final displayName = participant['displayName'] ?? 'Unbekannt';
    final points = participant['points'] ?? 0;
    final wins = participant['wins'] ?? 0;
    final losses = participant['losses'] ?? 0;
    final draws = participant['draws'] ?? 0;
    final status = participant['status'] ?? 'active';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.brown,
        child: Text(
          displayName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        displayName,
        style: TextStyle(
          fontWeight:
              status == 'eliminated' ? FontWeight.normal : FontWeight.bold,
          color: status == 'eliminated' ? Colors.grey : null,
        ),
      ),
      subtitle: Text(
        'W: $wins | N: $losses | U: $draws',
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.brown,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$points Pkt.',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () {
        // Hier könnte man zum Spielerprofil navigieren
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'registration':
        return Colors.blue;
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'registration':
        return 'Anmeldephase';
      case 'active':
        return 'Turnier läuft';
      case 'completed':
        return 'Turnier beendet';
      default:
        return status;
    }
  }
}
