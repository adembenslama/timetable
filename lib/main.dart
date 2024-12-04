import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timetable/app/bindings/service_binding.dart';
import 'package:timetable/app/bindings/controller_binding.dart';
import 'package:timetable/app/views/admin/sessions/sessions_view.dart';
import 'package:timetable/app/views/auth/login_view.dart';
import 'package:timetable/app/views/layouts/base_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  
  // Initialize services and repositories
  ServiceBinding().dependencies();
  // Initialize controllers
  ControllerBinding().dependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timetable Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginView(),
    );
  }
}
