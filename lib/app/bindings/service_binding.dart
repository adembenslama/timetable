import 'package:get/get.dart';
import 'package:timetable/app/data/services/api_service.dart';
import 'package:timetable/app/data/repositories/auth_repository.dart';
import 'package:timetable/app/data/repositories/session_repository.dart';
import 'package:timetable/app/data/repositories/room_repository.dart';
import 'package:timetable/app/data/repositories/subject_repository.dart';
import 'package:timetable/app/data/repositories/user_repository.dart';
import 'package:timetable/app/data/repositories/class_repository.dart';

class ServiceBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize API Service
    Get.put<ApiService>(ApiService(), permanent: true);
    
    // Initialize Repositories
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
    Get.put<SessionRepository>(SessionRepository(), permanent: true);
    Get.put<RoomRepository>(RoomRepository(), permanent: true);
    Get.put<SubjectRepository>(SubjectRepository(), permanent: true);
    Get.put<UserRepository>(UserRepository(), permanent: true);
    Get.put<ClassRepository>(ClassRepository(), permanent: true);
  }
} 