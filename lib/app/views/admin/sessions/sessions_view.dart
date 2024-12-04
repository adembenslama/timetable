import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timetable/app/controllers/session_controller.dart';
import 'package:timetable/app/controllers/auth_controller.dart';
import 'package:timetable/app/models/session_model.dart';
import 'package:timetable/app/views/layouts/base_layout.dart';
import 'package:timetable/app/views/admin/sessions/session_form_dialog.dart';
import 'package:timetable/app/data/services/api_service.dart';

class SessionsView extends StatelessWidget {
  const SessionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SessionController());
    final authController = Get.find<AuthController>();

    print('Sessions: ${controller.sessions}');

    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage != null) {
        return Center(child: Text(controller.errorMessage!));
      }

      if (controller.sessions.isEmpty) {
        return const Center(child: Text('No sessions found'));
      }

      return Stack(
        children: [
          Column(
            children: [
                
                      
                    
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.fetchSessions(),
                  child: ListView.builder(
                    itemCount: controller.sessions.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final session = controller.sessions[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: ExpansionTile(
                          title: Text(
                            'Class: ${session.classId}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${_formatDateTime(session.startTime)} - ${_formatDateTime(session.endTime)}',
                            style: const TextStyle(color: Colors.blue),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('Teacher ID', session.teacherId),
                                  const SizedBox(height: 8),
                                  _buildInfoRow('Room', session.roomId),
                                  const SizedBox(height: 8),
                                  _buildInfoRow('Recurrence', session.recurrenceRule ?? 'None'),
                                  const SizedBox(height: 8),
                                  _buildInfoRow('Status', session.isActive ? 'Active' : 'Inactive'),
                                  if (authController.isAdmin) ...[
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          icon: const Icon(Icons.edit),
                                          label: const Text('Edit'),
                                          onPressed: () => _editSession(context, session),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          label: const Text('Delete', 
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          onPressed: () => _deleteSession(context, session.id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (authController.isAdmin)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () => _addSession(context),
                child: const Icon(Icons.add),
              ),
            ),
        ],
      );
    });
  }

  void _addSession(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SessionFormDialog(isNew: true),
    );
  }

  void _editSession(BuildContext context, Session session) {
    showDialog(
      context: context,
      builder: (context) => SessionFormDialog(session: session, isNew: false),
    );
  }

  void _deleteSession(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text('Are you sure you want to delete this session?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.find<SessionController>().deleteSession(sessionId);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 