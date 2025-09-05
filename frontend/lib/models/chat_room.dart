class ChatRoom {
  final String id;
  final String name;
  final String description;
  final List<String> members;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.createdAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      members: _parseMembers(json['members']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  static List<String> _parseMembers(dynamic membersData) {
    if (membersData == null) return [];
    
    if (membersData is List) {
      return membersData.map((member) {
        if (member is String) {
          return member;
        } else if (member is Map) {
          // If member is an object, try to get the id or _id
          return member['_id']?.toString() ?? member['id']?.toString() ?? '';
        } else {
          return member.toString();
        }
      }).where((member) => member.isNotEmpty).toList();
    }
    
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'members': members,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}