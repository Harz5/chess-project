class Tournament {
  final String id;
  String name;
  String description;
  String format; // 'swiss', 'elimination', 'roundrobin'
  int maxParticipants;
  int participantCount;
  List<String> participants;
  DateTime startTime;
  DateTime endTime;
  String status; // 'scheduled', 'ongoing', 'completed', 'cancelled'
  bool registrationOpen;
  Map<String, dynamic> settings;
  String createdBy;
  DateTime createdAt;

  Tournament({
    required this.name,
    required this.description,
    required this.format,
    required this.maxParticipants,
    required this.startTime,
    required this.endTime,
    this.status = 'scheduled',
    this.registrationOpen = true,
    Map<String, dynamic>? settings,
    required this.createdBy,
    DateTime? createdAt,
    String? id,
    List<String>? participants,
    int? participantCount,
  })  : id = id ?? '',
        settings = settings ?? {},
        createdAt = createdAt ?? DateTime.now(),
        participants = participants ?? [],
        participantCount = participantCount ?? 0;

  factory Tournament.fromMap(Map<String, dynamic> map, String id) {
    return Tournament(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      format: map['format'] ?? 'swiss',
      maxParticipants: map['maxParticipants'] ?? 0,
      participantCount: map['participantCount'] ?? 0,
      participants: List<String>.from(map['participants'] ?? []),
      startTime: map['startTime'] != null
          ? (map['startTime'] as dynamic).toDate()
          : DateTime.now(),
      endTime: map['endTime'] != null
          ? (map['endTime'] as dynamic).toDate()
          : DateTime.now().add(const Duration(days: 1)),
      status: map['status'] ?? 'scheduled',
      registrationOpen: map['registrationOpen'] ?? true,
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'format': format,
      'maxParticipants': maxParticipants,
      'participantCount': participantCount,
      'participants': participants,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'registrationOpen': registrationOpen,
      'settings': settings,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  Tournament copyWith({
    String? name,
    String? description,
    String? format,
    int? maxParticipants,
    int? participantCount,
    List<String>? participants,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    bool? registrationOpen,
    Map<String, dynamic>? settings,
  }) {
    return Tournament(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      format: format ?? this.format,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantCount: participantCount ?? this.participantCount,
      participants: participants ?? List.from(this.participants),
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      registrationOpen: registrationOpen ?? this.registrationOpen,
      settings: settings ?? Map.from(this.settings),
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}
