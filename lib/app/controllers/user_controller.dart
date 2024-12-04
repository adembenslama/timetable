import 'package:get/get.dart';
import 'package:timetable/app/models/models.dart';
import 'package:timetable/app/data/repositories/user_repository.dart';

class UserController extends GetxController {
  final _users = <User>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = RxnString();
  
  final UserRepository _repository = Get.find<UserRepository>();

  // Getters
  List<User> get users => _users;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      final response = await _repository.getUsers();
      _users.value = response;
    } catch (e) {
      _errorMessage.value = 'Failed to fetch users: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> addUser(User user) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      await _repository.createUser(user);
      await fetchUsers();
    } catch (e) {
      _errorMessage.value = 'Failed to add user: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateUser(User user) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      await _repository.updateUser(user);
      await fetchUsers();
    } catch (e) {
      _errorMessage.value = 'Failed to update user: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      await _repository.deleteUser(userId);
      await fetchUsers();
    } catch (e) {
      _errorMessage.value = 'Failed to delete user: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }
} 