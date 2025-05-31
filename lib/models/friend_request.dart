class FriendRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  String status; // 'pending', 'accepted', 'declined'
  final DateTime timestamp;
  DateTime? respondedAt;

  FriendRequest({
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.timestamp,
    this.respondedAt,
    String? id,
  }) : id = id ?? '';

  factory FriendRequest.fromMap(Map<String, dynamic> map, String id) {
    return FriendRequest(
      id: id,
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      status: map['status'] ?? 'pending',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as dynamic).toDate()
          : DateTime.now(),
      respondedAt: map['respondedAt'] != null
          ? (map['respondedAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'status': status,
      'timestamp': timestamp,
      'respondedAt': respondedAt,
    };
  }
}
