import 'package:timetable/app/models/user_model.dart';

class AuthResponse {
  final String token;
  final User user;
  final String message;

  AuthResponse({
    required this.token,
    required this.user,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'],
        user: User.fromJson(json['user']),
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'user': user.toJson(),
        'message': message,
      };
} 