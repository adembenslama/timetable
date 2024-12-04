import 'package:get/get.dart';
import 'package:timetable/app/data/services/api_service.dart';
import 'package:timetable/app/models/models.dart';

class ClassRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<Class>> getClasses() async {
    try {
      final response = await _apiService.get('/classes');
      return (response.data as List)
          .map((json) => Class.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching classes: $e');
      rethrow;
    }
  }
} 