import 'package:flutter/foundation.dart';
import '../models/chat_room.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/polling_service.dart';
import '../models/user.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final PollingService _pollingService = PollingService();

  List<ChatRoom> _chatRooms = [];
  List<Message> _messages = [];
  ChatRoom? _currentRoom;
  User? _currentUser;
  bool _isLoading = false;
  bool _isConnected = false;
  String? _error;

  List<ChatRoom> get chatRooms => _chatRooms;
  List<Message> get messages => _messages;
  ChatRoom? get currentRoom => _currentRoom;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String? get error => _error;

  void setCurrentUser(User user) {
    _currentUser = user;
    print('� CRITICAL: ChatProvider setCurrentUser called');
    print('🔥 CRITICAL: Using PollingService (NO WEBSOCKETS!)');
    print('�🔄 Setting current user: ${user.username}');
    print('🔄 Using PollingService for real-time messaging');
    _connectService();
    notifyListeners();
  }

  void _connectService() {
    if (_currentUser == null) return;

    print('🔥 CRITICAL: _connectService called - initializing POLLING SERVICE');

    _pollingService.onConnected = () {
      print('🔥 CRITICAL: PollingService connected successfully');
      _isConnected = true;
      _clearError();
      notifyListeners();
    };

    _pollingService.onDisconnected = () {
      print('🔥 CRITICAL: PollingService disconnected');
      _isConnected = false;
      notifyListeners();
    };

    _pollingService.onMessageReceived = (message) {
      print('🔥 CRITICAL: PollingService received message: ${message.content}');
      if (_currentRoom != null && message.roomId == _currentRoom!.id) {
        // Check for duplicate messages by ID first, then by content+sender+time
        final messageExists = _messages.any(
          (msg) =>
              msg.id == message.id ||
              (msg.content == message.content &&
                  msg.senderId == message.senderId &&
                  msg.timestamp.difference(message.timestamp).abs().inSeconds <
                      5),
        );
        if (!messageExists) {
          _messages.add(message);
          notifyListeners();
        }
      }
    };

    // Note: PollingService doesn't have user join/leave events
    // These would need to be implemented separately if needed

    print('🔥 CRITICAL: Calling pollingService.connect()');
    _pollingService.connect(_currentUser!);
  }

  Future<void> loadChatRooms() async {
    _setLoading(true);
    _clearError();

    try {
      _chatRooms = await _apiService.getChatRooms();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  Future<void> createRoom({
    required String name,
    required String description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final newRoom = await _apiService.createChatRoom(
        name: name,
        description: description,
      );

      _chatRooms.insert(0, newRoom);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  Future<void> joinRoom(ChatRoom room) async {
    if (_currentUser == null) return;

    print('🔄 ChatProvider: Joining room ${room.name} (${room.id})');
    _setLoading(true);
    _clearError();

    try {
      // Join room via API
      final success = await _apiService.joinRoom(room.id);
      if (!success) {
        throw Exception('Failed to join room');
      }

      // Leave current room if any
      if (_currentRoom != null) {
        _pollingService.leaveRoom(_currentRoom!.id);
      }

      // Set new current room
      _currentRoom = room;

      // Load messages for the room
      await _loadRoomMessages(room.id);

      // Join room via polling
      if (_isConnected) {
        print('🔄 ChatProvider: Starting polling for room ${room.id}');
        _pollingService.joinRoom(room.id);
      } else {
        print('❌ ChatProvider: Not connected, cannot start polling');
      }

      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  Future<void> _loadRoomMessages(String roomId) async {
    try {
      _messages = await _apiService.getRoomMessages(roomId);
      notifyListeners();
    } catch (e) {
      print('Failed to load messages: $e');
    }
  }

  void sendMessage(String content) {
    if (_currentRoom != null && _isConnected && _currentUser != null) {
      _pollingService.sendMessage(content);
    }
  }

  Future<void> leaveCurrentRoom() async {
    if (_currentRoom == null || _currentUser == null) return;

    try {
      // Leave room via API
      await _apiService.leaveRoom(_currentRoom!.id);

      // Leave room via polling
      if (_isConnected) {
        _pollingService.leaveRoom(_currentRoom!.id);
      }

      // Clear current room and messages
      _currentRoom = null;
      _messages.clear();
      notifyListeners();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingService.disconnect();
    super.dispose();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
