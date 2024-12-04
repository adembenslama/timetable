import 'package:get/get.dart';
import 'package:timetable/app/models/models.dart';
import 'package:timetable/app/data/repositories/subject_repository.dart';

class SubjectController extends GetxController {
  final _subjects = <Subject>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = RxnString();
  
  final SubjectRepository _repository = Get.find<SubjectRepository>();

  // Getters
  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      final response = await _repository.getSubjects();
      _subjects.value = response;
    } catch (e) {
      _errorMessage.value = 'Failed to fetch subjects: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> addSubject(Subject subject) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      await _repository.createSubject(subject);
      await fetchSubjects();
    } catch (e) {
      _errorMessage.value = 'Failed to add subject: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateSubject(Subject subject) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      await _repository.updateSubject(subject);
      await fetchSubjects();
    } catch (e) {
      _errorMessage.value = 'Failed to update subject: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      await _repository.deleteSubject(subjectId);
      await fetchSubjects();
    } catch (e) {
      _errorMessage.value = 'Failed to delete subject: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }
} 