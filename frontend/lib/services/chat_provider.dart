import 'package:flutter/foundation.dart';
import '../models/chat_room.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../models/user.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();
  
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
    _connectSocket();
    notifyListeners();
  }

  void _connectSocket() {
    if (_currentUser == null) return;

    _socketService.onConnected = () {
      _isConnected = true;
      _clearError();
      notifyListeners();
    };

    _socketService.onDisconnected = () {
      _isConnected = false;
      notifyListeners();
    };

    _socketService.onMessageReceived = (message) {
      if (_currentRoom != null && message.roomId == _currentRoom!.id) {
        // Check for duplicate messages by ID first, then by content+sender+time
        final messageExists = _messages.any((msg) => 
          msg.id == message.id || 
          (msg.content == message.content && 
           msg.senderId == message.senderId && 
           msg.timestamp.difference(message.timestamp).abs().inSeconds < 5)
        );
        if (!messageExists) {
          _messages.add(message);
          notifyListeners();
        }
      }
    };

    _socketService.onUserJoined = (username) {
      // Could show notification or update UI
      print('$username joined the room');
    };

    _socketService.onUserLeft = (username) {
      // Could show notification or update UI
      print('$username left the room');
    };

    _socketService.connect(_currentUser!);
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
        _socketService.leaveRoom(_currentRoom!.id);
      }

      // Set new current room
      _currentRoom = room;
      
      // Load messages for the room
      await _loadRoomMessages(room.id);
      
      // Join room via socket
      if (_isConnected) {
        _socketService.joinRoom(room.id);
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
      _socketService.sendMessage(content);
    }
  }

  Future<void> leaveCurrentRoom() async {
    if (_currentRoom == null || _currentUser == null) return;

    try {
      // Leave room via API
      await _apiService.leaveRoom(_currentRoom!.id);
      
      // Leave room via socket
      if (_isConnected) {
        _socketService.leaveRoom(_currentRoom!.id);
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
    _socketService.dispose();
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