import 'package:get/get.dart';
import 'package:timetable/app/data/services/api_service.dart';
import 'package:timetable/app/models/models.dart';

class SessionRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<Session>> getSessions() async {
    try {
      final response = await _apiService.get('/sessions');
      final sessions = (response.data as List)
          .map((json) => Session.fromJson(json))
          .toList();
      
      print('Fetched ${sessions.length} sessions from API');
      return sessions;
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

  // Get sessions for a specific user
  Future<List<Session>> getSessionsForUser(User user) async {
    try {
      print('Getting sessions for user: ${user.name} (${user.role})');
      
      if (user.isTeacher) {
        print('Fetching teacher sessions for ID: ${user.id}');
        final response = await _apiService.get('/sessions?teacherId=${user.id}');
        final sessions = (response.data as List).map((json) => Session.fromJson(json)).toList();
        print('Found ${sessions.length} sessions for teacher');
        return sessions;
      } 
      
      if (user.isStudent) {
        print('Fetching student sessions for class ID: 1');
        final response = await _apiService.get('/sessions?classId=1');
        final sessions = (response.data as List).map((json) => Session.fromJson(json)).toList();
        print('Found ${sessions.length} sessions for student');
        return sessions;
      }
      
      return [];
    } catch (e) {
      print('Error getting sessions for user: $e');
      rethrow;
    }
  }
} 