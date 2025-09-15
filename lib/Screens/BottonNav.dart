// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:stud/Screens/HomePage.dart';
// import 'package:stud/Screens/Notification.dart';
// import 'package:stud/Screens/Settings.dart';
// import 'package:stud/Screens/Profile.dart';
//
// class BottomNav extends StatelessWidget {
//   const BottomNav({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Student>(
//       future: HomePage.getStudent(context),
//       builder: (context, snapshot) {
//         final student = snapshot.data ??
//             const Student(
//               name: 'Default User',
//               studentClass: 'Unknown',
//               division: 'Unknown',
//               userId: 0,
//             );
//
//         return BlocBuilder<NavigationBloc, NavigationState>(
//           builder: (context, state) {
//             final currentIndex = state is NavigationIndex ? state.index : 0;
//             return Scaffold(
//               body: IndexedStack(
//                 index: currentIndex,
//                 children: [
//                   HomePage(student: student),
//                   NotificationsPage(),
//                   SettingsPage(),
//                   ProfilePage(),
//                 ],
//               ),
//               bottomNavigationBar: BottomNavigationBar(
//                 currentIndex: currentIndex,
//                 onTap: (index) {
//                   if (index != currentIndex) {
//                     context.read<NavigationBloc>().add(NavigateTo(index));
//                   }
//                 },
//                 selectedItemColor: Colors.blue,
//                 unselectedItemColor: Colors.grey,
//                 type: BottomNavigationBarType.fixed,
//                 items: const [
//                   BottomNavigationBarItem(
//                       icon: Icon(Icons.home), label: 'Home'),
//                   BottomNavigationBarItem(
//                       icon: Icon(Icons.notifications), label: 'Notifications'),
//                   BottomNavigationBarItem(
//                       icon: Icon(Icons.settings), label: 'Settings'),
//                   BottomNavigationBarItem(
//                       icon: Icon(Icons.person), label: 'Profile'),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }