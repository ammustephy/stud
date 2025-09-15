import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:stud/Screens/HomePage.dart';

class OnlineClass {
  final String id, subject, topic, teacher, time, date, status;
  final int participants;
  final String duration;

  OnlineClass({
    required this.id,
    required this.subject,
    required this.topic,
    required this.teacher,
    required this.time,
    required this.date,
    required this.status,
    required this.participants,
    required this.duration,
  });
}

final List<OnlineClass> mockClasses = [
  OnlineClass(
    id: '1',
    subject: 'Mathematics',
    topic: 'Quadratic Equations - Problem Solving',
    teacher: 'Mr. Smith',
    time: '10:00 AM - 11:00 AM',
    date: '2025-08-29',
    status: 'live',
    participants: 25,
    duration: '60 min',
  ),
  OnlineClass(
    id: '2',
    subject: 'English',
    topic: 'Literature Analysis - Macbeth',
    teacher: 'Ms. Johnson',
    time: '02:00 PM - 03:00 PM',
    date: '2025-08-29',
    status: 'upcoming',
    participants: 20,
    duration: '60 min',
  ),
  OnlineClass(
    id: '3',
    subject: 'Science',
    topic: 'Physics - Mechanics',
    teacher: 'Dr. Brown',
    time: '09:00 AM - 10:00 AM',
    date: '2025-08-28',
    status: 'completed',
    participants: 30,
    duration: '60 min',
  ),
];

abstract class ClassroomEvent extends Equatable {
  const ClassroomEvent();
  @override
  List<Object?> get props => [];
}

class LoadClasses extends ClassroomEvent {}

class JoinClass extends ClassroomEvent {
  final String id;
  const JoinClass(this.id);
  @override
  List<Object?> get props => [id];
}

abstract class ClassroomState extends Equatable {
  const ClassroomState();
  @override
  List<Object?> get props => [];
}

class ClassroomLoading extends ClassroomState {}

class ClassroomLoaded extends ClassroomState {
  final List<OnlineClass> classes;
  const ClassroomLoaded(this.classes);
  @override
  List<Object?> get props => [classes];
}

class ClassroomBloc extends Bloc<ClassroomEvent, ClassroomState> {
  ClassroomBloc(List<OnlineClass> initialClasses) : super(ClassroomLoading()) {
    on<LoadClasses>((_, emit) => emit(ClassroomLoaded(initialClasses)));
    on<JoinClass>((event, emit) {
      if (state is ClassroomLoaded) {
        emit(ClassroomLoaded((state as ClassroomLoaded).classes));
      }
    });
  }
}

class OnlineClassroomPage extends StatelessWidget {
  final Student? student;

  const OnlineClassroomPage({super.key, this.student});

  @override
  Widget build(BuildContext context) {
    final studentArg = student ?? ModalRoute.of(context)?.settings.arguments as Student? ??
        const Student(
          name: 'Default User',
          studentClass: 'Unknown',
          division: 'Unknown',
          userId: 0,
        );

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: BlocProvider(
        create: (_) => ClassroomBloc(mockClasses)..add(LoadClasses()),
        child: Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                // Icon(Icons.video_call),
                SizedBox(width: 8),
                Text('Online Classroom'),
              ],
            ),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: BlocBuilder<ClassroomBloc, ClassroomState>(
            builder: (context, state) {
              if (state is ClassroomLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ClassroomLoaded) {
                return _ClassList(classes: state.classes, student: studentArg);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _ClassList extends StatelessWidget {
  final List<OnlineClass> classes;
  final Student student;
  const _ClassList({required this.classes, required this.student});

  Color statusColor(String status) {
    switch (status) {
      case 'live':
        return Colors.red.shade100;
      case 'upcoming':
        return Colors.blue.shade100;
      case 'completed':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final live = classes.where((c) => c.status == 'live').toList();
    final upcoming = classes.where((c) => c.status == 'upcoming').toList();
    final completed = classes.where((c) => c.status == 'completed').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Class ${student.studentClass} - Division ${student.division}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                const Text('Academic Year 2024-25', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
        if (live.isNotEmpty) ...[
          const Text('Live Classes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...live.map((c) => _ClassCard(c, Colors.red)),
        ],
        if (upcoming.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Upcoming Classes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...upcoming.map((c) => _ClassCard(c, Colors.blue)),
        ],
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Recent Classes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...completed.map((c) => _ClassCard(c, Colors.green)),
        ],
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  final OnlineClass c;
  final Color color;
  const _ClassCard(this.c, this.color);

  DateTime? parseClassDateTime(String date, String time) {
    try {
      final timeParts = time.split(' - ')[0];
      final dateTimeString = '$date $timeParts';
      return DateTime.parse('$dateTimeString +05:30');
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(context) {
    return Card(
      color: c.status == 'live' ? Colors.red.shade50 : null,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              c.subject,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                backgroundColor: color.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 4),
            Text(c.topic, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text('Teacher: ${c.teacher}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 4),
                TimerBuilder.periodic(
                  const Duration(seconds: 1),
                  builder: (context) {
                    final classDateTime = parseClassDateTime(c.date, c.time);
                    if (classDateTime == null) {
                      return Text('${c.date}, ${c.time}');
                    }
                    final now = DateTime.now();
                    final difference = classDateTime.difference(now);
                    if (c.status == 'live') {
                      return Text(
                        'LIVE • Started ${difference.isNegative ? difference.abs().inMinutes : 0} min ago',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      );
                    } else if (c.status == 'upcoming' && difference > Duration.zero) {
                      final hours = difference.inHours;
                      final minutes = difference.inMinutes % 60;
                      return Text(
                        'Starts in ${hours}h ${minutes}m',
                        style: const TextStyle(color: Colors.blue),
                      );
                    }
                    return Text('${c.date}, ${c.time}');
                  },
                ),
                const Spacer(),
                const Icon(Icons.people, size: 16),
                const SizedBox(width: 4),
                Text('${c.participants} students'),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: c.status == 'live'
                  ? () {
                context.read<ClassroomBloc>().add(JoinClass(c.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Joining ${c.topic}...'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
                  : c.status == 'completed'
                  ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Viewing recording for ${c.topic}...'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
                  : null,
              icon: Icon(c.status == 'live' ? Icons.play_arrow : Icons.videocam),
              label: Text(
                c.status == 'live'
                    ? 'Join Live Class'
                    : c.status == 'completed'
                    ? 'View Recording'
                    : 'Starts Soon',
              ),
            ),
          ],
        ),
      ),
    );
  }
}