import 'package:get/get.dart';
import 'package:timetable/app/models/models.dart';

class ClassController extends GetxController {
  final _classes = <Class>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = RxnString();

  // Getters
  List<Class> get classes => _classes;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      // TODO: Implement API call
      // final response = await _classRepository.getClasses();
      // _classes.assignAll(response);
    } catch (e) {
      _errorMessage.value = 'Failed to fetch classes: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> addClass(Class classData) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      // TODO: Implement API call
      // await _classRepository.addClass(classData);
      await fetchClasses();
    } catch (e) {
      _errorMessage.value = 'Failed to add class: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateClass(Class classData) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      // TODO: Implement API call
      // await _classRepository.updateClass(classData);
      await fetchClasses();
    } catch (e) {
      _errorMessage.value = 'Failed to update class: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteClass(String classId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      // TODO: Implement API call
      // await _classRepository.deleteClass(classId);
      await fetchClasses();
    } catch (e) {
      _errorMessage.value = 'Failed to delete class: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }
} 