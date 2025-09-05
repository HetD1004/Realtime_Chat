import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_room.dart';
import '../models/message.dart';
import '../config/config.dart';
import 'auth_service.dart';

class ApiService {
  static String get baseUrl => Config.baseUrl;
  final AuthService _authService = AuthService();

  // Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get all chat rooms
  Future<List<ChatRoom>> getChatRooms() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/rooms'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => ChatRoom.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chat rooms');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Create new chat room
  Future<ChatRoom> createChatRoom({
    required String name,
    required String description,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/rooms'),
        headers: headers,
        body: jsonEncode({'name': name, 'description': description}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ChatRoom.fromJson(data);
      } else {
        throw Exception(
          jsonDecode(response.body)['message'] ?? 'Failed to create room',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get messages for a specific room
  Future<List<Message>> getRoomMessages(String roomId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/rooms/$roomId/messages'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Join a chat room
  Future<bool> joinRoom(String roomId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/rooms/$roomId/join'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Leave a chat room
  Future<bool> leaveRoom(String roomId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/rooms/$roomId/leave'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
