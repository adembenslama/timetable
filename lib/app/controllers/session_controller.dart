import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timetable/app/models/models.dart';
import 'package:timetable/app/data/repositories/session_repository.dart';

class SessionController extends GetxController {
  final _sessions = <Session>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = RxnString();
  
  final SessionRepository _repository = Get.find<SessionRepository>();

  // Getters
  List<Session> get sessions => _sessions;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      print('Fetching sessions...');
      final response = await _repository.getSessions();
      print('Sessions fetched: ${response.length}');
      response.forEach((session) {
        print('Session: ${session.id}');
        print('  Day: ${session.recurrenceRule}');
        print('  Time: ${session.startTime.hour}:00-${session.endTime.hour}:00');
        print('  Teacher: ${session.teacherId}');
        print('  Class: ${session.classId}');
      });
      _sessions.value = response;
    } catch (e) {
      print('Error fetching sessions: $e');
      _errorMessage.value = 'Failed to fetch sessions: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchSessionsForUser(User user) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      final response = await _repository.getSessionsForUser(user);
      _sessions.value = response;
    } catch (e) {
      print('Error fetching sessions: $e');
      _errorMessage.value = 'Failed to fetch sessions: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  // TODO: Implement filtering sessions by date range
  // TODO: Implement filtering sessions by teacher
  // TODO: Implement filtering sessions by room
  // TODO: Implement filtering sessions by class
  // TODO: Implement recurring session creation
  // TODO: Implement session conflict detection
  // TODO: Implement bulk session creation
  // TODO: Implement session template creation
  // TODO: Implement session copy functionality
  // TODO: Implement session export to calendar
  // TODO: Implement session notifications
  // TODO: Implement session attendance tracking
  // TODO: Implement session statistics

  Future<bool> addSession(Session session) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      print('Adding session:');
      print('Class ID: ${session.classId}');
      print('Teacher ID: ${session.teacherId}');
      print('Room ID: ${session.roomId}');
      print('Start Time: ${session.startTime}');
      print('End Time: ${session.endTime}');
      print('Day: ${session.recurrenceRule}');

      // Check all conflicts
      if (await isRoomOccupied(session.roomId, session.startTime, session.endTime, session.id)) {
        _errorMessage.value = 'Room is already occupied at this time';
        return false;
      }

      if (await isTeacherOccupied(session.teacherId, session.startTime, session.endTime, session.id)) {
        _errorMessage.value = 'Teacher is already scheduled at this time';
        return false;
      }

      if (await isClassOccupied(session.classId, session.startTime, session.endTime, session.id)) {
        _errorMessage.value = 'Class already has a session at this time';
        return false;
      }

      // If no conflicts, create session
      await _repository.createSession(session);
      await fetchSessions();
      return true;
    } catch (e) {
      print('Error adding session: $e');
      _errorMessage.value = 'Failed to add session: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateSession(Session session) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      // Check all conflicts
      if (await isRoomOccupied(session.roomId, session.startTime, session.endTime, session.id)) {
        _errorMessage.value = 'Room is already occupied at this time';
        return false;
      }

      if (await isTeacherOccupied(session.teacherId, session.startTime, session.endTime, session.id)) {
        _errorMessage.value = 'Teacher is already scheduled at this time';
        return false;
      }

      if (await isClassOccupied(session.classId, session.startTime, session.endTime, session.id)) {
        _errorMessage.value = 'Class already has a session at this time';
        return false;
      }

      // If no conflicts, update session
      await _repository.updateSession(session);
      await fetchSessions();
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to update session: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      await _repository.deleteSession(sessionId);
      await fetchSessions();
    } catch (e) {
      _errorMessage.value = 'Failed to delete session: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> isRoomOccupied(String roomId, DateTime start, DateTime end, [String? excludeSessionId]) async {
    try {
      print('\nChecking room conflicts:');
      print('Room: $roomId');
      print('New session: ${_getDayName(start)} ${TimeOfDay.fromDateTime(start).format(Get.context!)} - ${TimeOfDay.fromDateTime(end).format(Get.context!)}');
      
      final conflictingSessions = _sessions.where((s) {
        // Skip the session being edited
        if (excludeSessionId != null && s.id == excludeSessionId) {
          print('Skipping session ${s.id} (being edited)');
          return false;
        }

        // Check if it's the same room
        if (s.roomId != roomId) {
          print('Different room for session ${s.id}');
          return false;
        }

        // Check if it's the same day
        String sessionDay = s.recurrenceRule?.toLowerCase() ?? '';
        String newDay = _getDayName(start).toLowerCase();
        print('Comparing days: $sessionDay vs $newDay');
        if (sessionDay != newDay) {
          print('Different day: $sessionDay vs $newDay');
          return false;
        }

        // Check time overlap
        final sessionStart = TimeOfDay.fromDateTime(s.startTime);
        final sessionEnd = TimeOfDay.fromDateTime(s.endTime);
        final newStart = TimeOfDay.fromDateTime(start);
        final newEnd = TimeOfDay.fromDateTime(end);

        print('Checking time overlap for session ${s.id}:');
        bool conflicts = _timeOverlaps(sessionStart, sessionEnd, newStart, newEnd);
        if (conflicts) {
          print('Time conflict found with session ${s.id}');
        }
        return conflicts;
      }).toList();

      if (conflictingSessions.isNotEmpty) {
        print('Room conflicts found: ${conflictingSessions.length}');
        for (var session in conflictingSessions) {
          print('Conflict with session: ${session.id}');
          print('Day: ${session.recurrenceRule}');
          print('Time: ${TimeOfDay.fromDateTime(session.startTime).format(Get.context!)} - ${TimeOfDay.fromDateTime(session.endTime).format(Get.context!)}');
        }
        return true;
      }
      print('No room conflicts found');
      return false;
    } catch (e) {
      print('Error checking room availability: $e');
      return false;
    }
  }

  Future<bool> isTeacherOccupied(String teacherId, DateTime start, DateTime end, [String? excludeSessionId]) async {
    try {
      print('\nChecking teacher conflicts:');
      print('Teacher: $teacherId');
      print('New session: ${_getDayName(start)} ${TimeOfDay.fromDateTime(start).format(Get.context!)} - ${TimeOfDay.fromDateTime(end).format(Get.context!)}');
      
      final conflictingSessions = _sessions.where((s) {
        // Skip the session being edited
        if (excludeSessionId != null && s.id == excludeSessionId) {
          print('Skipping session ${s.id} (being edited)');
          return false;
        }

        // Check if it's the same teacher
        if (s.teacherId != teacherId) {
          print('Different teacher for session ${s.id}');
          return false;
        }

        // Check if it's the same day
        String sessionDay = s.recurrenceRule?.toLowerCase() ?? '';
        String newDay = _getDayName(start).toLowerCase();
        if (sessionDay != newDay) {
          print('Different day: $sessionDay vs $newDay');
          return false;
        }

        // Check time overlap
        final sessionStart = TimeOfDay.fromDateTime(s.startTime);
        final sessionEnd = TimeOfDay.fromDateTime(s.endTime);
        final newStart = TimeOfDay.fromDateTime(start);
        final newEnd = TimeOfDay.fromDateTime(end);

        print('Checking time overlap for session ${s.id}:');
        bool conflicts = _timeOverlaps(sessionStart, sessionEnd, newStart, newEnd);
        if (conflicts) {
          print('Time conflict found with session ${s.id}');
        }
        return conflicts;
      }).toList();

      if (conflictingSessions.isNotEmpty) {
        print('Teacher conflicts found: ${conflictingSessions.length}');
        for (var session in conflictingSessions) {
          print('Conflict with session: ${session.id}');
          print('Day: ${session.recurrenceRule}');
          print('Time: ${TimeOfDay.fromDateTime(session.startTime).format(Get.context!)} - ${TimeOfDay.fromDateTime(session.endTime).format(Get.context!)}');
        }
        return true;
      }
      print('No conflicts found');
      return false;
    } catch (e) {
      print('Error checking teacher availability: $e');
      return false;
    }
  }

  Future<bool> isClassOccupied(String classId, DateTime start, DateTime end, [String? excludeSessionId]) async {
    try {
      final conflictingSessions = _sessions.where((s) {
        // Skip the session being edited
        if (excludeSessionId != null && s.id == excludeSessionId) return false;

        // Check if it's the same class
        if (s.classId != classId) return false;

        // Check if it's the same day
        if (s.recurrenceRule?.toLowerCase() != _getDayName(start).toLowerCase()) return false;

        // Check time overlap
        final sessionStart = TimeOfDay.fromDateTime(s.startTime);
        final sessionEnd = TimeOfDay.fromDateTime(s.endTime);
        final newStart = TimeOfDay.fromDateTime(start);
        final newEnd = TimeOfDay.fromDateTime(end);

        return _timeOverlaps(sessionStart, sessionEnd, newStart, newEnd);
      }).toList();

      if (conflictingSessions.isNotEmpty) {
        print('Class conflicts found: ${conflictingSessions.length}');
        for (var session in conflictingSessions) {
          print('Conflict with session: ${session.id} at ${session.startTime} - ${session.endTime}');
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking class availability: $e');
      return false;
    }
  }

  String _getDayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      default:
        return '';
    }
  }

  bool _timeOverlaps(TimeOfDay aStart, TimeOfDay aEnd, TimeOfDay bStart, TimeOfDay bEnd) {
    final aStartMinutes = aStart.hour * 60 + aStart.minute;
    final aEndMinutes = aEnd.hour * 60 + aEnd.minute;
    final bStartMinutes = bStart.hour * 60 + bStart.minute;
    final bEndMinutes = bEnd.hour * 60 + bEnd.minute;

    print('Comparing times:');
    print('Session A: $aStartMinutes-$aEndMinutes');
    print('Session B: $bStartMinutes-$bEndMinutes');

    // Times overlap if one starts before the other ends
    bool overlaps = !(aEndMinutes <= bStartMinutes || bEndMinutes <= aStartMinutes);
    print('Overlaps: $overlaps');
    return overlaps;
  }

  // Add these methods to SessionController

  // Filter sessions by date range
  Future<List<Session>> getSessionsByDateRange(DateTime start, DateTime end) {
    return Future.value(_sessions.where((s) {
      return s.startTime.isAfter(start) && s.endTime.isBefore(end);
    }).toList());
  }

  // Filter sessions by teacher
  List<Session> getSessionsByTeacher(String teacherId) {
    return _sessions.where((s) => s.teacherId == teacherId).toList();
  }

  // Filter sessions by room
  List<Session> getSessionsByRoom(String roomId) {
    return _sessions.where((s) => s.roomId == roomId).toList();
  }

  // Filter sessions by class
  List<Session> getSessionsByClass(String classId) {
    return _sessions.where((s) => s.classId == classId).toList();
  }

  // Create recurring session
  Future<bool> createRecurringSession(Session session, {
    required int repeatCount,
    required int intervalDays,
  }) async {
    try {
      for (int i = 0; i < repeatCount; i++) {
        final newSession = Session(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          classId: session.classId,
          teacherId: session.teacherId,
          roomId: session.roomId,
          startTime: session.startTime.add(Duration(days: i * intervalDays)),
          endTime: session.endTime.add(Duration(days: i * intervalDays)),
          recurrenceRule: session.recurrenceRule,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await addSession(newSession);
      }
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to create recurring sessions: $e';
      return false;
    }
  }

  // Copy session to another time slot
  Future<bool> copySession(Session session, DateTime newStartTime, DateTime newEndTime) async {
    try {
      final newSession = Session(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        classId: session.classId,
        teacherId: session.teacherId,
        roomId: session.roomId,
        startTime: newStartTime,
        endTime: newEndTime,
        recurrenceRule: session.recurrenceRule,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return addSession(newSession);
    } catch (e) {
      _errorMessage.value = 'Failed to copy session: $e';
      return false;
    }
  }

  // Export sessions to calendar
  Future<String> exportToCalendar() async {
    // Implement calendar export logic
    // This is a placeholder - you'll need to implement actual calendar integration
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    
    for (final session in _sessions) {
      buffer.writeln('BEGIN:VEVENT');
      buffer.writeln('SUMMARY:${session.classId}');
      buffer.writeln('DTSTART:${session.startTime.toIso8601String()}');
      buffer.writeln('DTEND:${session.endTime.toIso8601String()}');
      buffer.writeln('LOCATION:Room ${session.roomId}');
      buffer.writeln('END:VEVENT');
    }
    
    buffer.writeln('END:VCALENDAR');
    return buffer.toString();
  }

  // Get session statistics
  Map<String, dynamic> getSessionStats() {
    return {
      'totalSessions': _sessions.length,
      'activeCount': _sessions.where((s) => s.isActive).length,
      'byTeacher': _sessions.fold<Map<String, int>>({}, (map, session) {
        map[session.teacherId] = (map[session.teacherId] ?? 0) + 1;
        return map;
      }),
      'byRoom': _sessions.fold<Map<String, int>>({}, (map, session) {
        map[session.roomId] = (map[session.roomId] ?? 0) + 1;
        return map;
      }),
      'byClass': _sessions.fold<Map<String, int>>({}, (map, session) {
        map[session.classId] = (map[session.classId] ?? 0) + 1;
        return map;
      }),
    };
  }
} 