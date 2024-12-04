class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin', 'teacher', 'student'
  final String? profileImage;
  final bool isEmailVerified;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    required this.isEmailVerified,
    required this.isActive,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt, String? password,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
        profileImage: json['profileImage'],
        isEmailVerified: json['isEmailVerified'] ?? false,
        isActive: json['isActive'] ?? true,
        lastLogin: json['lastLogin'] != null 
            ? DateTime.parse(json['lastLogin'])
            : null,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'profileImage': profileImage,
        'isEmailVerified': isEmailVerified,
        'isActive': isActive,
        'lastLogin': lastLogin?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  // Helper method to check if user has specific role
  bool hasRole(String roleToCheck) => role == roleToCheck;

  // Helper method to check if user is admin
  bool get isAdmin => role == 'admin';

  // Helper method to check if user is teacher
  bool get isTeacher => role == 'teacher';

  // Helper method to check if user is student
  bool get isStudent => role == 'student';
} 