import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stud/Screens/HomePage.dart';
import 'package:stud/Screens/Profile.dart';

enum ThemeEvent { toggleDark, toggleLight }

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  ThemeBloc({required bool initiallyDark})
      : super(initiallyDark ? ThemeMode.dark : ThemeMode.light) {
    on<ThemeEvent>((event, emit) {
      emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
    });
  }
}

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object> get props => [];
}

class ToggleDarkTheme extends SettingsEvent {}
class UpdatePassword extends SettingsEvent {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  const UpdatePassword({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });
  @override
  List<Object> get props => [oldPassword, newPassword, confirmPassword];
}
class Logout extends SettingsEvent {}

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {
  final bool isDarkTheme;
  const SettingsInitial({this.isDarkTheme = false});
  @override
  List<Object> get props => [isDarkTheme];
}

class SettingsUpdated extends SettingsState {
  final bool isDarkTheme;
  const SettingsUpdated({required this.isDarkTheme});
  @override
  List<Object> get props => [isDarkTheme];
}

class SettingsFailure extends SettingsState {
  final String error;
  const SettingsFailure(this.error);
  @override
  List<Object> get props => [error];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  SettingsBloc() : super(const SettingsInitial()) {
    on<ToggleDarkTheme>(_onToggleDarkTheme);
    on<UpdatePassword>(_onUpdatePassword);
    on<Logout>(_onLogout);
  }

  Future<void> _onToggleDarkTheme(ToggleDarkTheme event, Emitter<SettingsState> emit) async {
    final currentDarkTheme = state is SettingsInitial
        ? (state as SettingsInitial).isDarkTheme
        : (state as SettingsUpdated).isDarkTheme;
    emit(SettingsUpdated(isDarkTheme: !currentDarkTheme));
  }

  Future<void> _onUpdatePassword(UpdatePassword event, Emitter<SettingsState> emit) async {
    try {
      final currentDarkTheme = state is SettingsInitial
          ? (state as SettingsInitial).isDarkTheme
          : (state as SettingsUpdated).isDarkTheme;
      if (event.newPassword != event.confirmPassword) {
        throw Exception('New password and confirm password do not match');
      }
      if (event.newPassword.length < 6) {
        throw Exception('New password must be at least 6 characters long');
      }
      await _storage.write(key: 'password', value: event.newPassword);
      emit(SettingsUpdated(isDarkTheme: currentDarkTheme));
    } catch (e) {
      emit(SettingsFailure(e.toString()));
    }
  }

  Future<void> _onLogout(Logout event, Emitter<SettingsState> emit) async {
    try {
      // Delete stored credentials
      await _storage.delete(key: 'userToken');
      await _storage.delete(key: 'username');
      await _storage.delete(key: 'studentId');

      // Reset the ProfileBloc
      // Make sure ProfileBloc is available in context when invoking this, e.g. via BlocProvider up tree
      // We cannot get context here (in bloc) in a pure bloc handler easily for navigation
      // So we handle the profile reset & navigation in the UI (SettingsPage) when state changes

      // After logout, you might emit an updated state so UI can listen
      emit(const SettingsInitial(isDarkTheme: false));
    } catch (e) {
      emit(SettingsFailure(e.toString()));
    }
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
      child: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsUpdated) {
            // theme toggle logic
            context.read<ThemeBloc>().add(ThemeEvent.toggleDark);
          } else if (state is SettingsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            final isDarkTheme = state is SettingsInitial
                ? state.isDarkTheme
                : state is SettingsUpdated
                ? state.isDarkTheme
                : false;
            return Scaffold(
              appBar: AppBar(
                title: const Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: const Text('Profile/Account Settings'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context.read<NavigationBloc>().add(NavigateTo(3));
                      Navigator.pushReplacementNamed(context, '/profile', arguments: student);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock, color: Colors.blue),
                    title: const Text('Password Settings'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showUpdatePasswordDialog(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Trigger logout event
                      context.read<SettingsBloc>().add(Logout());

                      // Also reset ProfileBloc
                      context.read<ProfileBloc>().add(
                        SaveProfile(
                          Profile(
                            id: '0',
                            name: 'Default User',
                            studentClass: 'Unknown',
                            division: 'Unknown',
                            email: '',
                            phone: '',
                          ),
                        ),
                      );

                      // Navigate to login screen and clear all previous routes
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
              bottomNavigationBar: BlocBuilder<NavigationBloc, NavigationState>(
                buildWhen: (prev, curr) => prev != curr,
                builder: (context, state) {
                  final currentIndex = state is NavigationIndex ? state.index : 2;
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
          },
        ),
      ),
    );
  }

  void _showUpdatePasswordDialog(BuildContext context) {
    final _oldPasswordCtrl = TextEditingController();
    final _newPasswordCtrl = TextEditingController();
    final _confirmPasswordCtrl = TextEditingController();
    bool _oldPwdVisible = false;
    bool _newPwdVisible = false;
    bool _confirmPwdVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 8, right: 8, bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            _oldPasswordCtrl.dispose();
                            _newPasswordCtrl.dispose();
                            _confirmPasswordCtrl.dispose();
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: const Text(
                      'Update Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _passwordField(
                            controller: _oldPasswordCtrl,
                            labelText: 'Old Password',
                            obscureText: !_oldPwdVisible,
                            onVisibilityToggle: () {
                              setState(() => _oldPwdVisible = !_oldPwdVisible);
                            },
                            onClear: () {
                              _oldPasswordCtrl.clear();
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 16),
                          _passwordField(
                            controller: _newPasswordCtrl,
                            labelText: 'New Password',
                            obscureText: !_newPwdVisible,
                            onVisibilityToggle: () {
                              setState(() => _newPwdVisible = !_newPwdVisible);
                            },
                            onClear: () {
                              _newPasswordCtrl.clear();
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 16),
                          _passwordField(
                            controller: _confirmPasswordCtrl,
                            labelText: 'Confirm New Password',
                            obscureText: !_confirmPwdVisible,
                            onVisibilityToggle: () {
                              setState(() => _confirmPwdVisible = !_confirmPwdVisible);
                            },
                            onClear: () {
                              _confirmPasswordCtrl.clear();
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            _oldPasswordCtrl.dispose();
                            _newPasswordCtrl.dispose();
                            _confirmPasswordCtrl.dispose();
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            context.read<SettingsBloc>().add(
                              UpdatePassword(
                                oldPassword: _oldPasswordCtrl.text,
                                newPassword: _newPasswordCtrl.text,
                                confirmPassword: _confirmPasswordCtrl.text,
                              ),
                            );
                            Navigator.of(dialogContext).pop();
                            _oldPasswordCtrl.dispose();
                            _newPasswordCtrl.dispose();
                            _confirmPasswordCtrl.dispose();
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onVisibilityToggle,
    required VoidCallback onClear,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              ),
            IconButton(
              icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: onVisibilityToggle,
            ),
          ],
        ),
      ),
      onChanged: (_) {
        // Trigger rebuild for clear button
      },
    );
  }
}