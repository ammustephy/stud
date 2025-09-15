import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stud/Screens/HomePage.dart';

class NotificationItem {
  final String id, title, message, type, date, priority;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.date,
    required this.priority,
    this.isRead = false,
  });
}

final List<NotificationItem> mockNotifications = [
  NotificationItem(
    id: '1',
    title: 'Assignment Due Tomorrow',
    message: 'Mathematics assignment on Quadratic Equations is due tomorrow at 11:59 PM.',
    type: 'reminder',
    date: '2025-01-19',
    isRead: false,
    priority: 'high',
  ),
];

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}
class MarkAsRead extends NotificationEvent {
  final String id;
  const MarkAsRead(this.id);
  @override
  List<Object?> get props => [id];
}
class MarkAllAsRead extends NotificationEvent {}

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationsLoading extends NotificationState {}
class NotificationsLoaded extends NotificationState {
  final List<NotificationItem> notifications;
  const NotificationsLoaded(this.notifications);
  @override
  List<Object?> get props => [notifications];
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(List<NotificationItem> initialData)
      : super(NotificationsLoading()) {
    on<LoadNotifications>((event, emit) async {
      await Future.delayed(const Duration(milliseconds: 100));
      emit(NotificationsLoaded(List.from(initialData)));
    });

    on<MarkAsRead>((event, emit) {
      if (state is NotificationsLoaded) {
        final updated = (state as NotificationsLoaded)
            .notifications
            .map((n) => n.id == event.id
            ? NotificationItem(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          date: n.date,
          priority: n.priority,
          isRead: true,
        )
            : n)
            .toList();
        emit(NotificationsLoaded(updated));
      }
    });

    on<MarkAllAsRead>((event, emit) {
      if (state is NotificationsLoaded) {
        final updated = (state as NotificationsLoaded)
            .notifications
            .map((n) => NotificationItem(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          date: n.date,
          priority: n.priority,
          isRead: true,
        ))
            .toList();
        emit(NotificationsLoaded(updated));
      }
    });
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final student = ModalRoute.of(context)?.settings.arguments as Student? ??
        const Student(
          name: 'Default User',
          studentClass: 'Unknown',
          division: 'Unknown',
          userId: 0,
        );

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home', arguments: student);
        return false;
      },
      child: BlocProvider(
        create: (_) => NotificationBloc(mockNotifications)..add(LoadNotifications()),
        child: Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.notifications),
                SizedBox(width: 8),
                Text('Notifications'),
              ],
            ),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is NotificationsLoaded) {
                final notes = state.notifications;
                if (notes.isEmpty) {
                  return const Center(child: Text('No notifications yet'));
                }
                return ListView.builder(
                  cacheExtent: 1000,
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final n = notes[index];
                    return Card(
                      elevation: 2,
                      color: n.isRead ? Colors.white : Colors.blue.shade50,
                      shape: Border(
                        left: BorderSide(
                          color: n.priority == 'high'
                              ? Colors.red
                              : n.priority == 'medium'
                              ? Colors.orange
                              : Colors.green,
                          width: 4,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Icon(
                          n.type == 'reminder'
                              ? Icons.calendar_today
                              : n.type == 'alert'
                              ? Icons.warning
                              : Icons.info,
                          color: n.type == 'reminder'
                              ? Colors.orange
                              : n.type == 'alert'
                              ? Colors.red
                              : Colors.blue,
                        ),
                        title: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          n.message,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () {
                          context.read<NotificationBloc>().add(MarkAsRead(n.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Marked "${n.title}" as read'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          bottomNavigationBar: BlocBuilder<NavigationBloc, NavigationState>(
            buildWhen: (prev, curr) => prev != curr,
            builder: (context, state) {
              final currentIndex = state is NavigationIndex ? state.index : 1;
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
        ),
      ),
    );
  }
}