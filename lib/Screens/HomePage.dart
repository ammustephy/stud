import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String name;
  final String studentClass;
  final String division;
  final int userId;

  const Student({
    required this.name,
    required this.studentClass,
    required this.division,
    required this.userId,
  });

  @override
  List<Object?> get props => [name, studentClass, division, userId];
}

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();
  @override
  List<Object?> get props => [];
}

class NavigateTo extends NavigationEvent {
  final int index;
  const NavigateTo(this.index);
  @override
  List<Object?> get props => [index];
}

abstract class NavigationState extends Equatable {
  const NavigationState();
  @override
  List<Object?> get props => [];
}

class NavigationIndex extends NavigationState {
  final int index;
  const NavigationIndex(this.index);
  @override
  List<Object?> get props => [index];
}

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationIndex(0)) {
    on<NavigateTo>((event, emit) {
      emit(NavigationIndex(event.index));
    });
  }
}

class HomePage extends StatelessWidget {
  final Student student;

  HomePage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome back,",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                Text(student.name,
                    style: const TextStyle(fontSize: 20, color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: dashboardItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final item = dashboardItems[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/${item["id"]}', arguments: student);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: (item["color"] as Color).withOpacity(0.2),
                            child: Icon(
                              item["icon"] as IconData,
                              color: item["color"] as Color,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(item["title"] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(item["description"] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<NavigationBloc, NavigationState>(
        buildWhen: (prev, curr) => prev != curr,
        builder: (context, state) {
          final currentIndex = state is NavigationIndex ? state.index : 0;
          return BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              if (index != currentIndex) {
                context.read<NavigationBloc>().add(NavigateTo(index));
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, '/home', arguments: student);
                    break;
                  case 1:
                    Navigator.pushReplacementNamed(context, '/notifications', arguments: student);
                    break;
                  case 2:
                    Navigator.pushReplacementNamed(context, '/settings', arguments: student);
                    break;
                  case 3:
                    Navigator.pushReplacementNamed(context, '/profile', arguments: student);
                    break;
                }
              }
            },
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          );
        },
      ),
    );
  }

  final dashboardItems = [
    {
      "id": "attendance",
      "title": "Attendance",
      "description": "View your monthly attendance",
      "icon": Icons.calendar_today,
      "color": Colors.blue,
    },
    {
      "id": "exam-results",
      "title": "Exam Results",
      "description": "Check your test results",
      "icon": Icons.assignment,
      "color": Colors.green,
    },
    {
      "id": "marklist",
      "title": "Marklist",
      "description": "View your marks",
      "icon": Icons.school,
      "color": Colors.purple,
    },
    {
      "id": "syllabus",
      "title": "Syllabus",
      "description": "Access course syllabus",
      "icon": Icons.menu_book,
      "color": Colors.orange,
    },
    {
      "id": "notes",
      "title": "Notes",
      "description": "Study materials and notes",
      "icon": Icons.note,
      "color": Colors.amber,
    },
    {
      "id": "online-classroom",
      "title": "Online Classroom",
      "description": "Join live classes",
      "icon": Icons.video_call,
      "color": Colors.red,
    },
    {
      "id": "payments",
      "title": "Payments",
      "description": "Fee payment details",
      "icon": Icons.payment,
      "color": Colors.pink,
    },
  ];
}