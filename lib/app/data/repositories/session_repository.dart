import 'package:get/get.dart';
import 'package:timetable/app/data/services/api_service.dart';
import 'package:timetable/app/models/models.dart';

class SessionRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<Session>> getSessions() async {
    try {
      final response = await _apiService.get('/sessions');
      return (response.data as List)
          .map((json) => Session.fromJson(json))
          .toList();
    } catch (e) {
      print('Error in getSessions: $e');
      rethrow;
    }
  }

  Future<Session> getSession(String id) async {
    final response = await _apiService.get('/sessions/$id');
    return Session.fromJson(response.data);
  }

  // Admin only
  Future<Session> createSession(Session session) async {
    try {
      final Map<String, dynamic> sessionData = {
        'id': session.id,
        'classId': session.classId,
        'teacherId': session.teacherId,
        'roomId': session.roomId,
        'startTime': session.startTime.toIso8601String(),
        'endTime': session.endTime.toIso8601String(),
        'recurrenceRule': session.recurrenceRule,
        'isActive': session.isActive,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final response = await _apiService.post('/sessions', sessionData);
      return Session.fromJson(response.data);
    } catch (e) {
      print('Error in createSession: $e');
      rethrow;
    }
  }

  // Admin only
  Future<Session> updateSession(Session session) async {
    try {
      final Map<String, dynamic> sessionData = {
        'id': session.id,
        'classId': session.classId,
        'teacherId': session.teacherId,
        'roomId': session.roomId,
        'startTime': session.startTime.toIso8601String(),
        'endTime': session.endTime.toIso8601String(),
        'recurrenceRule': session.recurrenceRule,
        'isActive': session.isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final response = await _apiService.put(
        '/sessions/${session.id}',
        sessionData,
      );
      return Session.fromJson(response.data);
    } catch (e) {
      print('Error in updateSession: $e');
      rethrow;
    }
  }

  // Admin only
  Future<void> deleteSession(String id) async {
    try {
      await _apiService.delete('/sessions/$id');
    } catch (e) {
      print('Error in deleteSession: $e');
      rethrow;
    }
  }

  // Get sessions by teacher
  Future<List<Session>> getTeacherSessions(String teacherId) async {
    final response = await _apiService.get('/sessions?teacherId=$teacherId');
    return (response.data as List)
        .map((json) => Session.fromJson(json))
        .toList();
  }

  // Get sessions by student (via class)
  Future<List<Session>> getStudentSessions(String studentId) async {
    // First get classes for student
    final classResponse = await _apiService.get(
      '/classes?studentIds_like=$studentId',
    );
    final classIds = (classResponse.data as List)
        .map((json) => json['id'] as String)
        .toList();

    // Then get sessions for these classes
    final sessions = <Session>[];
    for (final classId in classIds) {
      final response = await _apiService.get('/sessions?classId=$classId');
      sessions.addAll(
        (response.data as List).map((json) => Session.fromJson(json)),
      );
    }
    return sessions;
  }
} 