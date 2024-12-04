import 'package:get/get.dart';
import 'package:timetable/app/data/services/api_service.dart';
import 'package:timetable/app/models/models.dart';

class SubjectRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<Subject>> getSubjects() async {
    final response = await _apiService.get('/subjects');
    return (response.data as List)
        .map((json) => Subject.fromJson(json))
        .toList();
  }

  Future<Subject> getSubject(String id) async {
    final response = await _apiService.get('/subjects/$id');
    return Subject.fromJson(response.data);
  }

  // Admin only
  Future<Subject> createSubject(Subject subject) async {
    final response = await _apiService.post('/subjects', subject.toJson());
    return Subject.fromJson(response.data);
  }

  // Admin only
  Future<Subject> updateSubject(Subject subject) async {
    final response = await _apiService.put(
      '/subjects/${subject.id}',
      subject.toJson(),
    );
    return Subject.fromJson(response.data);
  }

  // Admin only
  Future<void> deleteSubject(String id) async {
    await _apiService.delete('/subjects/$id');
  }
} 