import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timetable/app/controllers/subject_controller.dart';
import 'package:timetable/app/controllers/auth_controller.dart';
import 'package:timetable/app/models/models.dart';
import 'package:timetable/app/views/admin/subjects/subject_form_dialog.dart';

class SubjectsView extends StatelessWidget {
  const SubjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubjectController());
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
            itemCount: controller.subjects.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final subject = controller.subjects[index];
              return Card(
                child: ListTile(
                  title: Text(subject.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${subject.code}'),
                      Text('Credits: ${subject.credits}'),
                      Text('Description: ${subject.description}'),
                      Text('Status: ${subject.isActive ? "Active" : "Inactive"}'),
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
                              _editSubject(context, subject);
                            } else if (value == 'delete') {
                              _deleteSubject(context, subject.id);
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
                onPressed: () => _addSubject(context),
                child: const Icon(Icons.add),
              ),
            ),
        ],
      );
    });
  }

  void _addSubject(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SubjectFormDialog(),
    );
  }

  void _editSubject(BuildContext context, Subject subject) {
    showDialog(
      context: context,
      builder: (context) => SubjectFormDialog(subject: subject),
    );
  }

  void _deleteSubject(BuildContext context, String subjectId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: const Text('Are you sure you want to delete this subject?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.find<SubjectController>().deleteSubject(subjectId);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 