import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timetable/app/controllers/auth_controller.dart';
import 'package:timetable/app/controllers/session_controller.dart';
import 'package:timetable/app/models/models.dart';
import 'package:timetable/app/views/admin/sessions/session_form_dialog.dart';

class UserTimetableView extends StatefulWidget {
  final User user;

  const UserTimetableView({super.key, required this.user});

  @override
  State<UserTimetableView> createState() => _UserTimetableViewState();
}

class _UserTimetableViewState extends State<UserTimetableView> {
  final ScrollController _horizontalController = ScrollController();
  
  final List<String> timeSlots = [
    '08:00-10:00',
    '10:00-12:00',
    '14:00-16:00',
    '16:00-18:00',
  ];
  
  final List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Fetch sessions for this specific user
    Get.find<SessionController>().fetchSessionsForUser(widget.user);
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SessionController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.name}\'s Schedule'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 100 + (150.0 * timeSlots.length),
              child: Column(
                children: [
                  // Time slots header
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        const SizedBox(width: 100),
                        ...timeSlots.map((slot) => SizedBox(
                          width: 150,
                          child: Center(
                            child: Text(
                              slot,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  // Timetable grid
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 130,
                    child: Row(
                      children: [
                        // Days column
                        SizedBox(
                          width: 100,
                          child: ListView.builder(
                            itemCount: weekDays.length,
                            itemBuilder: (context, dayIndex) => SizedBox(
                              height: 100,
                              child: Center(
                                child: Text(
                                  weekDays[dayIndex],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Sessions grid
                        SizedBox(
                          width: 150.0 * timeSlots.length,
                          child: ListView.builder(
                            itemCount: weekDays.length,
                            itemBuilder: (context, dayIndex) => SizedBox(
                              height: 100,
                              child: Row(
                                children: List.generate(
                                  timeSlots.length,
                                  (timeIndex) => Obx(() {
                                    final session = _findSession(
                                      controller.sessions,
                                      weekDays[dayIndex].toLowerCase(),
                                      timeSlots[timeIndex],
                                      widget.user,
                                    );

                                    return SizedBox(
                                      width: 150,
                                      child: InkWell(
                                        onTap: () {
                                          print('Tapped: Day=${weekDays[dayIndex]}, Time=${timeSlots[timeIndex]}');
                                          if (!authController.isAdmin) return;
                                          
                                          if (session == null) {
                                            _handleEmptySlotTap(
                                              context,
                                              weekDays[dayIndex],
                                              timeSlots[timeIndex],
                                            );
                                          } else {
                                            _showSessionActions(context, session);
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: session != null
                                                ? Colors.blue.withOpacity(0.2)
                                                : Colors.grey.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.grey.withOpacity(0.2),
                                            ),
                                          ),
                                          child: session != null
                                              ? Padding(
                                                  padding: const EdgeInsets.all(4),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        'Class: ${session.classId}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Room: ${session.roomId}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : const Center(
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: authController.isAdmin ? FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Time Slots:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ...timeSlots.map((slot) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('• $slot'),
                  )),
                  const SizedBox(height: 8),
                  Text(
                    'Instructions:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Text('• Tap on an empty slot to add a session'),
                  const Text('• Tap on an existing session to edit/delete'),
                  const Text('• Grey slots are empty, blue slots are occupied'),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.info_outline),
      ) : null,
    );
  }

  Session? _findSession(List<Session> sessions, String day, String timeSlot, User user) {
    print('Finding session for:');
    print('Day: $day');
    print('Time slot: $timeSlot');
    print('Available sessions: ${sessions.length}');

    final startHour = int.parse(timeSlot.split('-')[0].split(':')[0]);
    
    return sessions.firstWhereOrNull((s) {
      // Debug print session details
      print('Checking session:');
      print('Session day: ${s.recurrenceRule}');
      print('Session hour: ${s.startTime.hour}');
      print('Session teacher: ${s.teacherId}');
      print('Session class: ${s.classId}');

      // Check day match
      if (s.recurrenceRule?.toLowerCase() != day.toLowerCase()) {
        print('Day mismatch');
        return false;
      }

      // Check hour match
      if (s.startTime.hour != startHour) {
        print('Hour mismatch');
        return false;
      }

      // For teachers, show their sessions
      if (user.isTeacher && s.teacherId == user.id) {
        print('Teacher session match');
        return true;
      }
      
      // For students, show their class sessions
      if (user.isStudent && s.classId == "1") { // Using class ID 1 for now
        print('Student session match');
        return true;
      }

      return false;
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _handleEmptySlotTap(BuildContext context, String day, String timeSlot) {
    if (!authController.isAdmin) return;

    final startTime = timeSlot.split('-')[0].split(':');
    final endTime = timeSlot.split('-')[1].split(':');

    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(startTime[0]),
      int.parse(startTime[1]),
    );
    final end = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(endTime[0]),
      int.parse(endTime[1]),
    );

    // Pass prefilled data based on context
    showDialog(
      context: context,
      builder: (context) => SessionFormDialog(
        session: null,
        isNew: true,
        prefilledTeacherId: widget.user.isTeacher ? widget.user.id : '',  // Empty string instead of null
        prefilledClassId: widget.user.isStudent ? widget.user.id : '',    // Empty string instead of null
        prefilledTimeSlot: timeSlot,
        prefilledDay: day,
      ),
    );
  }

  void _showSessionActions(BuildContext context, Session session) {
    if (!authController.isAdmin) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Session'),
            onTap: () {
              Get.back();
              showDialog(
                context: context,
                builder: (context) => SessionFormDialog(
                  session: session,
                  isNew: false,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Session', 
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Get.back();
              Get.find<SessionController>().deleteSession(session.id);
            },
          ),
        ],
      ),
    );
  }
} 
