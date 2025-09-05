import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api/auth';
  static const _storage = FlutterSecureStorage();

  // Register new user
  Future<User?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        await _storage.write(key: 'token', value: data['token']);
        return user.copyWith(token: data['token']);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Registration failed');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException') || e.toString().contains('SocketException')) {
        throw Exception('Server not available. Please check if the backend is running.');
      }
      throw Exception('Network error: $e');
    }
  }

  // Login user
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        await _storage.write(key: 'token', value: data['token']);
        return user.copyWith(token: data['token']);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException') || e.toString().contains('SocketException')) {
        throw Exception('Server not available. Please check if the backend is running.');
      }
      throw Exception('Network error: $e');
    }
  }

  // Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // Logout user
  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  // Verify token validity
  Future<User?> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']).copyWith(token: token);
      } else {
        await logout();
        return null;
      }
    } catch (e) {
      await logout();
      return null;
    }
  }

  // Update user profile
  Future<User?> updateProfile({
    required String username,
    required String email,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']).copyWith(token: token);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Profile update failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete user account
  Future<bool> deleteAccount({
    required String password,
    required bool deleteChats,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.delete(
        Uri.parse('$baseUrl/account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'password': password,
          'deleteChats': deleteChats,
        }),
      );

      if (response.statusCode == 200) {
        await logout(); // Clear stored token
        return true;
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Account deletion failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}