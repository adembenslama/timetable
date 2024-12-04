import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timetable/app/controllers/room_controller.dart';
import 'package:timetable/app/models/models.dart';

class RoomFormDialog extends StatefulWidget {
  final Room? room;

  const RoomFormDialog({super.key, this.room});

  @override
  State<RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<RoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _buildingController;
  late TextEditingController _capacityController;
  bool _isActive = true;
  final List<String> _selectedFacilities = [];

  final List<String> _availableFacilities = [
    'projector',
    'whiteboard',
    'computer',
    'air_conditioning',
    'smart_board',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room?.name);
    _buildingController = TextEditingController(text: widget.room?.building);
    _capacityController = TextEditingController(
      text: widget.room?.capacity.toString(),
    );
    _isActive = widget.room?.isActive ?? true;
    if (widget.room?.facilities != null) {
      _selectedFacilities.addAll(widget.room!.facilities!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.room == null ? 'Add Room' : 'Edit Room'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter room name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _buildingController,
                decoration: const InputDecoration(
                  labelText: 'Building',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter building';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter capacity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Facilities:'),
              Wrap(
                spacing: 8,
                children: _availableFacilities.map((facility) {
                  return FilterChip(
                    label: Text(facility),
                    selected: _selectedFacilities.contains(facility),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFacilities.add(facility);
                        } else {
                          _selectedFacilities.remove(facility);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final room = Room(
        id: widget.room?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        building: _buildingController.text,
        capacity: int.parse(_capacityController.text),
        isActive: _isActive,
        facilities: _selectedFacilities,
        createdAt: widget.room?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final controller = Get.find<RoomController>();
      if (widget.room == null) {
        controller.addRoom(room);
      } else {
        controller.updateRoom(room);
      }

      Get.back();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _buildingController.dispose();
    _capacityController.dispose();
    super.dispose();
  }
} 