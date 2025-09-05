import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/user.dart';
import '../config/config.dart';
import 'auth_service.dart';

class PollingService {
  static String get baseUrl => Config.baseUrl;
  final AuthService _authService = AuthService();

  Timer? _pollingTimer;
  String? _currentRoom;
  User? _currentUser;
  DateTime _lastMessageTime = DateTime.now().subtract(Duration(minutes: 1));

  // Callbacks
  Function(Message)? onMessageReceived;
  Function()? onConnected;
  Function()? onDisconnected;

  // Connect with polling instead of WebSocket
  void connect(User user) {
    _currentUser = user;
    print('🔄 Starting polling-based connection for ${user.username}');
    onConnected?.call();
  }

  // Join room and start polling for messages
  void joinRoom(String roomId) {
    _currentRoom = roomId;
    _lastMessageTime = DateTime.now().subtract(Duration(minutes: 1));

    // Stop existing polling
    _pollingTimer?.cancel();

    // Start polling for new messages
    _startPolling();

    print('📥 Started polling for room: $roomId');
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      if (_currentRoom != null) {
        await _pollForMessages();
      }
    });
  }

  Future<void> _pollForMessages() async {
    try {
      final token = await _authService.getToken();
      if (token == null || _currentRoom == null) return;

      // Get messages since last poll
      final response = await http
          .get(
            Uri.parse('$baseUrl/rooms/$_currentRoom/messages/since').replace(
              queryParameters: {
                'since': _lastMessageTime.toIso8601String(),
                'limit': '10',
              },
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final messages = data.map((json) => Message.fromJson(json)).toList();

        // Process new messages
        for (final message in messages) {
          if (message.timestamp.isAfter(_lastMessageTime)) {
            onMessageReceived?.call(message);
            _lastMessageTime = message.timestamp;
          }
        }
      }
    } catch (e) {
      print('⚠️ Polling error: $e');
      // Don't spam errors, just continue polling
    }
  }

  // Send message via REST API
  Future<void> sendMessage(String content) async {
    try {
      if (_currentRoom == null || _currentUser == null) return;

      final token = await _authService.getToken();
      if (token == null) return;

      await http.post(
        Uri.parse('$baseUrl/rooms/$_currentRoom/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'content': content,
          'userId': _currentUser!.id,
          'username': _currentUser!.username,
        }),
      );

      // Immediately poll for the new message
      await _pollForMessages();
    } catch (e) {
      print('❌ Send message error: $e');
    }
  }

  void leaveRoom(String roomId) {
    _pollingTimer?.cancel();
    _currentRoom = null;
    print('📤 Left room: $roomId');
  }

  void disconnect() {
    _pollingTimer?.cancel();
    _currentRoom = null;
    _currentUser = null;
    onDisconnected?.call();
    print('🔌 Disconnected polling service');
  }

  bool get isConnected => _currentUser != null;
}
