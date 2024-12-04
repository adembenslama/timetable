import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timetable/app/controllers/auth_controller.dart';
import 'package:timetable/app/controllers/room_controller.dart';
import 'package:timetable/app/models/models.dart';
import 'package:timetable/app/views/admin/rooms/room_form_dialog.dart';

class RoomsView extends StatelessWidget {
  const RoomsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RoomController());
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
            itemCount: controller.rooms.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final room = controller.rooms[index];
              return Card(
                child: ListTile(
                  title: Text(room.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Building: ${room.building}'),
                      Text('Capacity: ${room.capacity}'),
                      if (room.facilities != null && room.facilities!.isNotEmpty)
                        Text('Facilities: ${room.facilities!.join(", ")}'),
                      Text('Status: ${room.isActive ? "Active" : "Inactive"}'),
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
                              _editRoom(context, room);
                            } else if (value == 'delete') {
                              _deleteRoom(context, room.id);
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
                onPressed: () => _addRoom(context),
                child: const Icon(Icons.add),
              ),
            ),
        ],
      );
    });
  }

  void _addRoom(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const RoomFormDialog(),
    );
  }

  void _editRoom(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (context) => RoomFormDialog(room: room),
    );
  }

  void _deleteRoom(BuildContext context, String roomId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room'),
        content: const Text('Are you sure you want to delete this room?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.find<RoomController>().deleteRoom(roomId);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 