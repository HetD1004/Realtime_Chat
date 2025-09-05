import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message.dart';
import '../models/user.dart';
import '../config/config.dart';

class SocketService {
  static String get serverUrl => Config.socketUrl;
  IO.Socket? _socket;
  User? _currentUser;
  String? _currentRoom;

  // Callbacks
  Function(Message)? onMessageReceived;
  Function(String)? onUserJoined;
  Function(String)? onUserLeft;
  Function()? onConnected;
  Function()? onDisconnected;

  // Initialize socket connection
  void connect(User user) {
    _currentUser = user;

    print('Connecting to socket server at $serverUrl');
    print(
      'User: ${user.username}, Token: ${user.token != null ? 'Present' : 'NULL'}',
    );

    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': user.token},
    });

    _socket!.connect();

    // Set up event listeners
    _socket!.on('connect', (_) {
      print('Connected to server');
      onConnected?.call();
    });

    _socket!.on('disconnect', (_) {
      print('Disconnected from server');
      onDisconnected?.call();
    });

    _socket!.on('receive_message', (data) {
      final message = Message.fromJson(data);
      onMessageReceived?.call(message);
    });

    _socket!.on('user_joined', (data) {
      final username = data['username'] as String;
      onUserJoined?.call(username);
    });

    _socket!.on('user_left', (data) {
      final username = data['username'] as String;
      onUserLeft?.call(username);
    });

    _socket!.on('connect_error', (error) {
      print('Connection error: $error');
    });
  }

  // Join a chat room
  void joinRoom(String roomId) {
    if (_socket != null && _socket!.connected) {
      // Leave current room if any
      if (_currentRoom != null) {
        leaveRoom(_currentRoom!);
      }

      _currentRoom = roomId;
      _socket!.emit('join_room', {
        'roomId': roomId,
        'userId': _currentUser?.id,
        'username': _currentUser?.username,
      });
    }
  }

  // Leave current chat room
  void leaveRoom(String roomId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('leave_room', {
        'roomId': roomId,
        'userId': _currentUser?.id,
        'username': _currentUser?.username,
      });

      if (_currentRoom == roomId) {
        _currentRoom = null;
      }
    }
  }

  // Send message to current room
  void sendMessage(String content) {
    if (_socket != null && _socket!.connected && _currentRoom != null) {
      _socket!.emit('send_message', {
        'content': content,
        'roomId': _currentRoom,
        'senderId': _currentUser?.id,
        'senderUsername': _currentUser?.username,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Get current connection status
  bool get isConnected => _socket?.connected ?? false;

  // Get current room
  String? get currentRoom => _currentRoom;

  // Disconnect from server
  void disconnect() {
    if (_currentRoom != null) {
      leaveRoom(_currentRoom!);
    }
    _socket?.disconnect();
    _socket = null;
    _currentUser = null;
    _currentRoom = null;
  }

  // Clean up
  void dispose() {
    disconnect();
    onMessageReceived = null;
    onUserJoined = null;
    onUserLeft = null;
    onConnected = null;
    onDisconnected = null;
  }
}
