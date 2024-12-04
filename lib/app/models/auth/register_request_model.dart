class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String role;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'role': role,
      };
} 