import 'package:get/get.dart';
import 'package:timetable/app/data/services/api_service.dart';
import 'package:timetable/app/models/models.dart';

class ClassRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<Class>> getClasses() async {
    try {
      print('Fetching classes...');
      final response = await _apiService.get('/classes');
      final classes = (response.data as List)
          .map((json) => Class.fromJson(json))
          .toList();
      print('Found ${classes.length} classes');
      return classes;
    } catch (e) {
      print('Error fetching classes: $e');
      rethrow;
    }
  }
} 