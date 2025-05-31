class Message {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String content;
  final DateTime timestamp;
  bool read;
  
  Message({
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    required this.timestamp,
    this.read = false,
    String? id,
  }) : this.id = id ?? '';
  
  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null 
          ? (map['timestamp'] as dynamic).toDate() 
          : DateTime.now(),
      read: map['read'] ?? false,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'content': content,
      'timestamp': timestamp,
      'read': read,
    };
  }
}
