import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timetable/app/controllers/auth_controller.dart';
import 'package:timetable/app/views/admin/sessions/sessions_view.dart';
import 'package:timetable/app/views/admin/rooms/rooms_view.dart';
import 'package:timetable/app/views/admin/subjects/subjects_view.dart';
import 'package:timetable/app/views/admin/users/users_view.dart';

class BaseLayout extends StatefulWidget {
  const BaseLayout({super.key});

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final List<({Widget view, String title, IconData icon})> _views = [
      (
        view: const SessionsView(),
        title: 'Sessions',
        icon: Icons.schedule,
      ),
      (
        view: const RoomsView(),
        title: 'Rooms',
        icon: Icons.room,
      ),
      (
        view: const SubjectsView(),
        title: 'Subjects',
        icon: Icons.subject,
      ),
      (
        view: const UsersView(),
        title: 'Users',
        icon: Icons.people,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_views[_selectedIndex].title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: _views[_selectedIndex].view,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _views
            .map((view) => NavigationDestination(
                  icon: Icon(view.icon),
                  label: view.title,
                ))
            .toList(),
      ),
    );
  }
} 