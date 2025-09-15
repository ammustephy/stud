// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:stud/Screens/BottomNav.dart';
// import 'package:stud/Screens/HomePage.dart';
// import 'package:stud/Screens/Notification.dart';
// import 'package:stud/Screens/Profile.dart';
// import 'package:stud/Screens/Settings.dart';
//
// class NavigationEvent {}
// class ChangeTab extends NavigationEvent {
//   final int index;
//   ChangeTab(this.index);
// }
//
// class NavigationState {
//   final int selectedIndex;
//   NavigationState(this.selectedIndex);
// }
//
// class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
//   NavigationBloc() : super(NavigationState(0)) {
//     on<ChangeTab>((event, emit) {
//       emit(NavigationState(event.index));
//     });
//   }
// }
//
// // class MainPage extends StatefulWidget {
// //   final Student student;
// //
// //   const MainPage({super.key, required this.student});
// //
// //   @override
// //   State<MainPage> createState() => _MainPageState();
// // }
// //
// // class _MainPageState extends State<MainPage> {
// //   late final List<Widget> _pages;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _pages = [
// //       HomePage(student: widget.student),
// //        NotificationsPage(),
// //       const SettingsPage(),
// //       BlocBuilder<ProfileBloc, ProfileState>(
// //         builder: (context, state) => ProfilePage(),
// //       ),
// //     ];
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return BlocBuilder<NavigationBloc, NavigationState>(
// //       builder: (context, state) {
// //         return Scaffold(
// //           body: IndexedStack(
// //             index: state.selectedIndex,
// //             children: _pages,
// //           ),
// //           bottomNavigationBar: BottomNavigationBar(
// //             currentIndex: state.selectedIndex,
// //             onTap: (index) {
// //               context.read<NavigationBloc>().add(ChangeTab(index));
// //             },
// //             selectedItemColor: Colors.blue,
// //             unselectedItemColor: Colors.grey,
// //             showUnselectedLabels: true,
// //             items: const [
// //               BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
// //               BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
// //               BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
// //               BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }