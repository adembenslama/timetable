import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timetable/app/models/models.dart';
import 'package:timetable/app/data/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  Future<String?> getToken() async {
    return _storage.read<String>(tokenKey);
  }

  Future<User?> getUser() async {
    try {
      final userData = _storage.read<String>(userKey);
      if (userData != null) {
        return User.fromJson(json.decode(userData));
      }
      return null;
    } catch (e) {
      print('Error getting stored user: $e');
      return null;
    }
  }

  Future<void> _storeAuthData(AuthResponse response) async {
    try {
      await _storage.write(tokenKey, response.token);
      await _storage.write(userKey, json.encode(response.user.toJson()));
      print('Auth data stored successfully');
    } catch (e) {
      print('Error storing auth data: $e');
      rethrow;
    }
  }

  Future<void> clearAuthData() async {
    try {
      await _storage.remove(tokenKey);
      await _storage.remove(userKey);
      print('Auth data cleared successfully');
    } catch (e) {
      print('Error clearing auth data: $e');
      rethrow;
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      // Find user by email and password
      final usersResponse = await _apiService.get(
        '/users?email=${request.email}&password=${request.password}'
      );
      
      final users = (usersResponse.data as List);
      if (users.isEmpty) {
        throw Exception('Invalid credentials');
      }

      final user = User.fromJson(users.first);
      final token = 'dummy-token-${DateTime.now().millisecondsSinceEpoch}';

      final authResponse = AuthResponse(
        token: token,
        user: user,
        message: 'Login successful',
      );

      await _storeAuthData(authResponse);
      print('Login successful for user: ${user.email}');
      return authResponse;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      // Check if email already exists
      final checkEmail = await _apiService.get('/users?email=${request.email}');
      if ((checkEmail.data as List).isNotEmpty) {
        throw Exception('Email already exists');
      }

      // Create new user
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final newUser = {
        'id': userId,
        'name': request.name,
        'email': request.email,
        'password': request.password,
        'role': request.role,
        'isEmailVerified': false,
        'isActive': true,
        'lastLogin': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Add user to database
      final response = await _apiService.post('/users', newUser);
      final user = User.fromJson(response.data);

      // Generate token
      final token = 'dummy-token-${DateTime.now().millisecondsSinceEpoch}';

      final authResponse = AuthResponse(
        token: token,
        user: user,
        message: 'Registration successful',
      );

      await _storeAuthData(authResponse);
      print('Registration successful for user: ${user.email}');
      return authResponse;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      final user = await getUser();
      if (user == null) {
        print('No stored user found');
        return false;
      }

      // Check if user still exists in database
      final response = await _apiService.get('/users/${user.id}');
      if (response.data == null) {
        print('User not found in database');
        return false;
      }

      print('Token validated for user: ${user.email}');
      return true;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }
}