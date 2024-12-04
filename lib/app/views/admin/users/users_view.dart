import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timetable/app/controllers/auth_controller.dart';
import 'package:timetable/app/controllers/user_controller.dart';
import 'package:timetable/app/models/models.dart';
import 'package:timetable/app/views/admin/users/user_form_dialog.dart';
import 'package:timetable/app/views/timetable/user_timetable_view.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    final authController = Get.find<AuthController>();

    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage != null) {
        return Center(child: Text(controller.errorMessage!));
      }

      return Stack(
        children: [
          ListView.builder(
            itemCount: controller.users.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final user = controller.users[index];
              return user.isAdmin ? const SizedBox.shrink() : Card(
                child: ListTile(
                  onTap: () => Get.to(() => UserTimetableView(user: user)),
                  leading: CircleAvatar(
                    child: Text(user.name[0].toUpperCase()),
                  ),
                  title: Text(user.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${user.email}'),
                      Text('Role: ${user.role.capitalizeFirst}'),
                      Text('Status: ${user.isActive ? "Active" : "Inactive"}'),
                    ],
                  ),
                  trailing: authController.isAdmin 
                      ? PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editUser(context, user);
                            } else if (value == 'delete') {
                              _deleteUser(context, user.id);
                            }
                          },
                        )
                      : null,
                ),
              );
            },
          ),
          if (authController.isAdmin)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () => _addUser(context),
                child: const Icon(Icons.add),
              ),
            ),
        ],
      );
    });
  }

  void _addUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const UserFormDialog(),
    );
  }

  void _editUser(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(user: user),
    );
  }

  void _deleteUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.find<UserController>().deleteUser(userId);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 