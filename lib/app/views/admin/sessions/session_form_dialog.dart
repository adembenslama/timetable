import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timetable/app/controllers/session_controller.dart';
import 'package:timetable/app/data/repositories/user_repository.dart';
import 'package:timetable/app/data/repositories/class_repository.dart';
import 'package:timetable/app/data/repositories/room_repository.dart';
import 'package:timetable/app/data/repositories/subject_repository.dart';
import 'package:timetable/app/models/models.dart';

class SessionFormDialog extends StatefulWidget {
  final Session? session;
  final bool isNew;
  final String? prefilledTeacherId;
  final String? prefilledClassId;
  final String? prefilledTimeSlot;
  final String? prefilledDay;

  const SessionFormDialog({
    super.key,
    this.session,
    required this.isNew,
    this.prefilledTeacherId,
    this.prefilledClassId,
    this.prefilledTimeSlot,
    this.prefilledDay,
  });

  @override
  State<SessionFormDialog> createState() => _SessionFormDialogState();
}

class TimeSlot {
  final TimeOfDay start;
  final TimeOfDay end;
  final String label;

  const TimeSlot({
    required this.start,
    required this.end,
    required this.label,
  });
}

class _SessionFormDialogState extends State<SessionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClassId;
  String? _selectedTeacherId;
  String? _selectedRoomId;
  String? _selectedDay;
  String? _selectedTimeSlot;
  late DateTime _startTime;
  late DateTime _endTime;
  
  List<User> _teachers = [];
  List<Class> _classes = [];
  List<Room> _rooms = [];
  List<Subject> _subjects = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  // Define available time slots
  final List<TimeSlot> _timeSlots = [
    TimeSlot(
      start: const TimeOfDay(hour: 8, minute: 0),
      end: const TimeOfDay(hour: 10, minute: 0),
      label: '08:00 - 10:00',
    ),
    TimeSlot(
      start: const TimeOfDay(hour: 10, minute: 0),
      end: const TimeOfDay(hour: 12, minute: 0),
      label: '10:00 - 12:00',
    ),
    TimeSlot(
      start: const TimeOfDay(hour: 14, minute: 0),
      end: const TimeOfDay(hour: 16, minute: 0),
      label: '14:00 - 16:00',
    ),
    TimeSlot(
      start: const TimeOfDay(hour: 16, minute: 0),
      end: const TimeOfDay(hour: 18, minute: 0),
      label: '16:00 - 18:00',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final classRepo = Get.find<ClassRepository>();
      final userRepo = Get.find<UserRepository>();
      final roomRepo = Get.find<RoomRepository>();
      final subjectRepo = Get.find<SubjectRepository>();

      final futures = await Future.wait([
        classRepo.getClasses(),
        userRepo.getTeachers(),
        roomRepo.getRooms(),
        subjectRepo.getSubjects(),
      ]);

      setState(() {
        _classes = futures[0] as List<Class>;
        _teachers = futures[1] as List<User>;
        _rooms = futures[2] as List<Room>;
        _subjects = futures[3] as List<Subject>;

        // Initialize times
        _startTime = widget.session?.startTime ?? DateTime.now();
        _endTime = widget.session?.endTime ?? DateTime.now().add(const Duration(hours: 2));

        // Set initial values
        if (widget.session != null) {
          _selectedClassId = widget.session!.classId;
          _selectedTeacherId = widget.session!.teacherId;
          _selectedRoomId = widget.session!.roomId;
          _selectedDay = widget.session!.recurrenceRule?.toLowerCase();
        } else {
          // For new sessions, use prefilled values if available
          _selectedClassId = widget.prefilledClassId?.isNotEmpty == true ? widget.prefilledClassId : null;
          _selectedTeacherId = widget.prefilledTeacherId?.isNotEmpty == true ? widget.prefilledTeacherId : null;
          _selectedDay = widget.prefilledDay?.toLowerCase();
          _selectedTimeSlot = widget.prefilledTimeSlot;
        }

        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  Future<bool> _checkConflicts() async {
    try {
      final sessionController = Get.find<SessionController>();
      
      // Check room availability
      if (await sessionController.isRoomOccupied(
        _selectedRoomId!,
        _startTime,
        _endTime,
        widget.session?.id,
      )) {
        setState(() => _errorMessage = 'Room is not available at this time');
        return true;
      }

      // Check teacher availability
      if (await sessionController.isTeacherOccupied(
        _selectedTeacherId!,
        _startTime,
        _endTime,
        widget.session?.id,
      )) {
        setState(() => _errorMessage = 'Teacher is not available at this time');
        return true;
      }

      // Check class availability
      if (await sessionController.isClassOccupied(
        _selectedClassId!,
        _startTime,
        _endTime,
        widget.session?.id,
      )) {
        setState(() => _errorMessage = 'Class has another session at this time');
        return true;
      }

      return false;
    } catch (e) {
      setState(() => _errorMessage = 'Error checking conflicts: $e');
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isNew ? 'Add Session' : 'Edit Session'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                _buildClassDropdown(),
                DropdownButtonFormField<String>(
                  value: _selectedTeacherId,
                  decoration: const InputDecoration(
                    labelText: 'Teacher',
                    border: OutlineInputBorder(),
                  ),
                  items: _teachers.map((teacher) {
                    return DropdownMenuItem(
                      value: teacher.id,
                      child: Text(teacher.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedTeacherId = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a teacher';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedRoomId,
                  decoration: const InputDecoration(
                    labelText: 'Room',
                    border: OutlineInputBorder(),
                  ),
                  items: _rooms.map((room) {
                    return DropdownMenuItem(
                      value: room.id,
                      child: Text(room.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedRoomId = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a room';
                    }
                    return null;
                  },
                ),
                if (widget.prefilledDay == null)
                  DropdownButtonFormField<String>(
                    value: _selectedDay,
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      border: OutlineInputBorder(),
                    ),
                    items: _weekDays.map((day) {
                      return DropdownMenuItem(
                        value: day.toLowerCase(),
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedDay = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a day';
                      }
                      return null;
                    },
                  ),
                if (widget.prefilledTimeSlot == null)
                  _buildTimeSlotSelector(),
              ],
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
          onPressed: _isLoading ? null : _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedTimeSlot,
      decoration: const InputDecoration(
        labelText: 'Time Slot',
        border: OutlineInputBorder(),
      ),
      items: _timeSlots.map((slot) {
        return DropdownMenuItem(
          value: slot.label,
          child: Text(slot.label),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedTimeSlot = value;
          if (value != null) {
            final slot = _timeSlots.firstWhere((slot) => slot.label == value);
            final now = DateTime.now();
            _startTime = DateTime(
              now.year,
              now.month,
              now.day,
              slot.start.hour,
              slot.start.minute,
            );
            _endTime = DateTime(
              now.year,
              now.month,
              now.day,
              slot.end.hour,
              slot.end.minute,
            );
          }
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a time slot';
        }
        return null;
      },
    );
  }

  Widget _buildClassDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedClassId,
      decoration: const InputDecoration(
        labelText: 'Class',
        border: OutlineInputBorder(),
      ),
      items: [
        if (_selectedClassId == null)
          const DropdownMenuItem(
            value: '',
            child: Text('Select a class'),
          ),
        ..._classes.map((classItem) => DropdownMenuItem(
          value: classItem.id,
          child: Text('${classItem.name} (${_getSubjectName(classItem.subjectId)})'),
        )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedClassId = value?.isEmpty == true ? null : value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a class';
        }
        return null;
      },
    );
  }

  String _getSubjectName(String subjectId) {
    final subject = _subjects.firstWhereOrNull((s) => s.id == subjectId);
    return subject?.name ?? 'Unknown Subject';
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final session = Session(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        classId: _selectedClassId!,
        teacherId: _selectedTeacherId!,
        roomId: _selectedRoomId!,
        startTime: _startTime,
        endTime: _endTime,
        recurrenceRule: _selectedDay?.toLowerCase(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final controller = Get.find<SessionController>();
      bool success;
      
      try {
        if (widget.isNew) {
          success = await controller.addSession(session);
        } else {
          success = await controller.updateSession(session);
        }

        if (success) {
          Get.back();
        } else {
          setState(() {
            _errorMessage = controller.errorMessage;
          });
        }
      } catch (e) {
        print('Error submitting session: $e');
        setState(() {
          _errorMessage = 'Failed to save session: $e';
        });
      }
    }
  }
} 