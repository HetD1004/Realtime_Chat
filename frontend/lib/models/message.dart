class Message {
  final String id;
  final String content;
  final String senderId;
  final String senderUsername;
  final String roomId;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderUsername,
    required this.roomId,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    try {
      final message = Message(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        senderId: json['senderId']?.toString() ?? json['sender_id']?.toString() ?? '',
        senderUsername: json['senderUsername']?.toString() ?? json['sender_username']?.toString() ?? '',
        roomId: json['roomId']?.toString() ?? json['room_id']?.toString() ?? '',
        timestamp: json['timestamp'] != null 
            ? DateTime.parse(json['timestamp'].toString())
            : DateTime.now(),
      );
      return message;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'roomId': roomId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}