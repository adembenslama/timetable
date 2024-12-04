import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timetable/app/controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  final authController = Get.find<AuthController>();

  @override
  RouteSettings? redirect(String? route) {
    // If not logged in, redirect to login page
    if (!authController.isLoggedIn) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}

class AdminMiddleware extends GetMiddleware {
  final authController = Get.find<AuthController>();

  @override
  RouteSettings? redirect(String? route) {
    // If not logged in or not admin, redirect appropriately
    if (!authController.isLoggedIn) {
      return const RouteSettings(name: '/login');
    }
    if (!authController.isAdmin) {
      return const RouteSettings(name: '/unauthorized');
    }
    return null;
  }
}

class TeacherMiddleware extends GetMiddleware {
  final authController = Get.find<AuthController>();

  @override
  RouteSettings? redirect(String? route) {
    // If not logged in or not teacher, redirect appropriately
    if (!authController.isLoggedIn) {
      return const RouteSettings(name: '/login');
    }
    if (!authController.isTeacher) {
      return const RouteSettings(name: '/unauthorized');
    }
    return null;
  }
}

class StudentMiddleware extends GetMiddleware {
  final authController = Get.find<AuthController>();

  @override
  RouteSettings? redirect(String? route) {
    // If not logged in or not student, redirect appropriately
    if (!authController.isLoggedIn) {
      return const RouteSettings(name: '/login');
    }
    if (!authController.isStudent) {
      return const RouteSettings(name: '/unauthorized');
    }
    return null;
  }
} 