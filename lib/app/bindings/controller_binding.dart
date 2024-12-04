import 'package:get/get.dart';
import 'package:timetable/app/controllers/auth_controller.dart';
import 'package:timetable/app/controllers/class_controller.dart';
import 'package:timetable/app/controllers/session_controller.dart';
import 'package:timetable/app/controllers/room_controller.dart';
import 'package:timetable/app/controllers/subject_controller.dart';

class ControllerBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.lazyPut<ClassController>(() => ClassController());
    Get.lazyPut<SessionController>(() => SessionController());
    Get.lazyPut<RoomController>(() => RoomController());
    Get.lazyPut<SubjectController>(() => SubjectController());
  }
} 