class Room {
  final String id;
  final String name;
  final String building;
  final int capacity;
  final bool isActive;
  final List<String>? facilities;
  final DateTime createdAt;
  final DateTime updatedAt;

  Room({
    required this.id,
    required this.name,
    required this.building,
    required this.capacity,
    required this.isActive,
    this.facilities,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: json['id'],
        name: json['name'],
        building: json['building'],
        capacity: json['capacity'],
        isActive: json['isActive'],
        facilities: json['facilities'] != null
            ? List<String>.from(json['facilities'])
            : null,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'building': building,
        'capacity': capacity,
        'isActive': isActive,
        'facilities': facilities,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
} 