import 'package:get/get.dart';
import 'package:timetable/app/models/models.dart';
import 'package:timetable/app/data/repositories/auth_repository.dart';
import 'package:timetable/app/views/auth/login_view.dart';
import 'package:timetable/app/views/layouts/base_layout.dart';


class AuthController extends GetxController {
  // Observable variables
  final _user = Rxn<User>();
  final _token = RxnString();
  final _isLoading = false.obs;
  final _errorMessage = RxnString();
  final _isPasswordVisible = false.obs;

  // Getters
  User? get user => _user.value;
  String? get token => _token.value;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  bool get isLoggedIn => _token.value != null;
  bool get isPasswordVisible => _isPasswordVisible.value;
  
  // Auth state getters
  bool get isAdmin => user?.isAdmin ?? false;
  bool get isTeacher => user?.isTeacher ?? false;
  bool get isStudent => user?.isStudent ?? false;

  final _authRepository = Get.find<AuthRepository>();

  @override
  void onInit() {
    super.onInit();
    // Load saved auth state
    _loadAuthState();
  }

  // Load saved authentication state from storage
  Future<void> _loadAuthState() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final savedToken = await _authRepository.getToken();
      final savedUser = await _authRepository.getUser();

      print('Saved token: $savedToken');
      print('Saved user: $savedUser');

      if (savedToken != null && savedUser != null) {
        final isValid = await _authRepository.validateToken(savedToken);
        if (isValid) {
          _token.value = savedToken;
          _user.value = savedUser;
          print('Auth state loaded successfully');
          _navigateBasedOnRole();
        } else {
          print('Invalid token, clearing auth state');
          await _authRepository.clearAuthData();
        }
      } else {
        print('No saved auth state found');
      }
    } catch (e) {
      print('Error loading auth state: $e');
      _errorMessage.value = 'Failed to load authentication state';
    } finally {
      _isLoading.value = false;
    }
  }

  // Login method
  Future<void> login(String email, String password) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final loginRequest = LoginRequest(
        email: email,
        password: password,
      );

      final response = await _authRepository.login(loginRequest);
      _handleAuthResponse(response);
    } catch (e) {
      _errorMessage.value = 'Login failed: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  // Register method
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final registerRequest = RegisterRequest(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
      );

      final response = await _authRepository.register(registerRequest);
      _handleAuthResponse(response);
    } catch (e) {
      _errorMessage.value = 'Registration failed: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      _isLoading.value = true;
      await _authRepository.clearAuthData();
      _clearAuthState();
      Get.offAll(() => LoginView());
    } catch (e) {
      _errorMessage.value = 'Logout failed: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  // Handle authentication response
  void _handleAuthResponse(AuthResponse response) {
    _token.value = response.token;
    _user.value = response.user;
    
    // TODO: Save auth state to local storage
    // await storage.write(key: 'token', value: response.token);
    // await storage.write(key: 'user', value: jsonEncode(response.user.toJson()));
    
    // Navigate based on role
    _navigateBasedOnRole();
  }

  // Clear authentication state
  void _clearAuthState() {
    _token.value = null;
    _user.value = null;
    
    // TODO: Clear stored auth state
    // await storage.delete(key: 'token');
    // await storage.delete(key: 'user');
  }

  // Navigate based on user role
  void _navigateBasedOnRole() {
    // All users go to BaseLayout after authentication
    Get.offAll(() => const BaseLayout());
  }

  // Validate stored token
  Future<void> _validateToken(String token) async {
    try {
      // TODO: Implement token validation
      // final response = await _authRepository.validateToken(token);
      // _handleAuthResponse(response);
    } catch (e) {
      _clearAuthState();
      _errorMessage.value = 'Session expired. Please login again.';
    }
  }

  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }
} 