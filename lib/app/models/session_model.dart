class Session {
  final String id;
  final String classId;
  final String teacherId;
  final String roomId;
  final DateTime startTime;
  final DateTime endTime;
  final String? recurrenceRule;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Session({
    required this.id,
    required this.classId,
    required this.teacherId,
    required this.roomId,
    required this.startTime,
    required this.endTime,
    this.recurrenceRule,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    try {
      return Session(
        id: json['id'] as String,
        classId: json['classId'] as String,
        teacherId: json['teacherId'] as String,
        roomId: json['roomId'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        recurrenceRule: json['recurrenceRule'] as String?,
        isActive: json['isActive'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
    } catch (e) {
      print('Error parsing Session: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'classId': classId,
        'teacherId': teacherId,
        'roomId': roomId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'recurrenceRule': recurrenceRule,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  String toString() {
    return 'Session{id: $id, classId: $classId, teacherId: $teacherId, roomId: $roomId, '
        'startTime: $startTime, endTime: $endTime, recurrenceRule: $recurrenceRule, '
        'isActive: $isActive}';
  }
} 