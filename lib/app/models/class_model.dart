class Class {
  final String id;
  final String name;
  final String subjectId;
  final List<String> studentIds;
  final int capacity;
  final DateTime createdAt;
  final DateTime updatedAt;

  Class({
    required this.id,
    required this.name,
    required this.subjectId,
    required this.studentIds,
    required this.capacity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Class.fromJson(Map<String, dynamic> json) => Class(
        id: json['id'],
        name: json['name'],
        subjectId: json['subjectId'],
        studentIds: List<String>.from(json['studentIds']),
        capacity: json['capacity'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subjectId': subjectId,
        'studentIds': studentIds,
        'capacity': capacity,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
} 