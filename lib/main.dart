import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stud/Screens/HomePage.dart';
import 'package:stud/Screens/Notification.dart';
import 'package:stud/Screens/Settings.dart';
import 'package:stud/Screens/Profile.dart';
import 'package:stud/Screens/LoginFile.dart';
import 'package:stud/Screens/StuAttendance.dart';
import 'package:stud/Screens/ExamResult.dart';
import 'package:stud/Screens/Marklist.dart';
import 'package:stud/Screens/Notes.dart';
import 'package:stud/Screens/OnlineClass.dart';
import 'package:stud/Screens/Payment.dart';
import 'package:stud/Screens/Syllabus.dart';
import 'package:stud/APIService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = const FlutterSecureStorage();

  final token = await storage.read(key: 'userToken');
  final studentId = await storage.read(key: 'studentId');
  final username = await storage.read(key: 'username');

  final bool hasToken = token != null && token.isNotEmpty;
  final String initToken = hasToken ? token! : '';
  final String initStudentId = (studentId != null && studentId.isNotEmpty) ? studentId! : '';
  final String initUsername = (username != null && username.isNotEmpty) ? username! : '';

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeBloc(initiallyDark: false)),
        BlocProvider(
          create: (_) {
            // initialize with stored data if available
            return ProfileBloc(
              Profile(
                id: initStudentId,
                name: initUsername,
                studentClass: '',
                division: '',
                email: '',
                phone: '',
              ),
            );
          },
        ),
        BlocProvider(create: (_) => SyllabusBloc()),
        BlocProvider(create: (_) => NavigationBloc()),
        BlocProvider(create: (_) => SettingsBloc()),
        BlocProvider(create: (_) => AttendanceBloc(apiService: ApiService())),
      ],
      child: StudentPortalApp(
        token: initToken,
        studentId: initStudentId,
        username: initUsername,
      ),
    ),
  );
}

class StudentPortalApp extends StatelessWidget {
  final String token;
  final String studentId;
  final String username;

  const StudentPortalApp({
    Key? key,
    required this.token,
    required this.studentId,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, themeMode) {
        final bool loggedIn = token.isNotEmpty;
        final student = Student(
          name: username,
          studentClass: '',
          division: '',
          userId: int.tryParse(studentId) ?? 0,
        );
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Student Portal',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          initialRoute: loggedIn ? '/home' : '/login',
          routes: {
            '/login': (_) => LoginPage(),
            // Fixed: Extract Student from arguments, fallback to initial
            '/home': (context) {
              final studentArg = ModalRoute.of(context)?.settings.arguments as Student?;
              return HomePage(student: studentArg ?? student);
            },
            '/bottom-nav': (_) => BottomNav(student: student),
            '/attendance': (_) => AttendancePage(),
            '/exam-results': (_) => ExamResultsPage(),
            '/marklist': (_) => MarklistPage(),
            '/notes': (_) => NotesPage(),
            // Fixed: Pass extracted Student (though NotificationsPage uses arguments internally)
            '/notifications': (context) {
              final studentArg = ModalRoute.of(context)?.settings.arguments as Student?;
              return NotificationsPage(); // Internal extraction handles it
            },
            '/online-classroom': (_) => OnlineClassroomPage(),
            '/payments': (_) => PaymentsPage(),
            // Fixed: Pass extracted Student as prop
            '/profile': (context) {
              final studentArg = ModalRoute.of(context)?.settings.arguments as Student?;
              return ProfilePage(student: studentArg);
            },
            // Fixed: Pass extracted Student (though SettingsPage uses arguments internally)
            '/settings': (context) {
              final studentArg = ModalRoute.of(context)?.settings.arguments as Student?;
              return SettingsPage(); // Internal extraction handles it
            },
            '/syllabus': (_) => const SyllabusPage(),
          },
        );
      },
    );
  }
}

class BottomNav extends StatelessWidget {
  final Student student;

  const BottomNav({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        final currentIndex = state is NavigationIndex ? state.index : 0;
        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: [
              HomePage(student: student),
              const NotificationsPage(),
              const SettingsPage(),
              ProfilePage(student: student),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              if (index != currentIndex) {
                context.read<NavigationBloc>().add(NavigateTo(index));
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
          ),
        );
      },
    );
  }
}