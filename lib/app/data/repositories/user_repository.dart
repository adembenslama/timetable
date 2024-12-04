import 'package:get/get.dart';
import 'package:timetable/app/data/services/api_service.dart';
import 'package:timetable/app/models/models.dart';

class UserRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<User>> getUsers() async {
    try {
      final response = await _apiService.get('/users');
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  Future<User> getUser(String id) async {
    final response = await _apiService.get('/users/$id');
    return User.fromJson(response.data);
  }

  Future<User> createUser(User user) async {
    final response = await _apiService.post('/users', user.toJson());
    return User.fromJson(response.data);
  }

  Future<User> updateUser(User user) async {
    final response = await _apiService.put(
      '/users/${user.id}',
      user.toJson(),
    );
    return User.fromJson(response.data);
  }

  Future<void> deleteUser(String id) async {
    await _apiService.delete('/users/$id');
  }

  Future<List<User>> getTeachers() async {
    try {
      final response = await _apiService.get('/users?role=teacher');
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching teachers: $e');
      rethrow;
    }
  }
} 