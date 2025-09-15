import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:stud/Screens/HomePage.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();
  @override
  List<Object?> get props => [];
}

class SubmitEmail extends ForgotPasswordEvent {
  final String email;
  const SubmitEmail(this.email);
  @override
  List<Object?> get props => [email];
}

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();
  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;
  const ForgotPasswordSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  const ForgotPasswordError(this.message);
  @override
  List<Object?> get props => [message];
}

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {
    on<SubmitEmail>((event, emit) async {
      emit(ForgotPasswordLoading());
      await Future.delayed(const Duration(seconds: 2));

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(event.email)) {
        emit(const ForgotPasswordError('Please enter a valid email address'));
        return;
      }

      emit(const ForgotPasswordSuccess('Password reset link sent to your email'));
    });
  }
}

class ForgotPasswordPage extends StatelessWidget {
  final Student? student;

  const ForgotPasswordPage({super.key, this.student});

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
        Navigator.pushReplacementNamed(context, '/login', arguments: studentArg);
        return false;
      },
      child: BlocProvider(
        create: (_) => ForgotPasswordBloc(),
        child: Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.lock_reset),
                SizedBox(width: 8),
                Text('Forgot Password'),
              ],
            ),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
            listener: (context, state) {
              if (state is ForgotPasswordSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    duration: const Duration(seconds: 3),
                    backgroundColor: Colors.green,
                  ),
                );
                Future.delayed(const Duration(seconds: 3), () {
                  Navigator.pushReplacementNamed(context, '/login', arguments: studentArg);
                });
              } else if (state is ForgotPasswordError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    duration: const Duration(seconds: 3),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reset Your Password',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your email address to receive a password reset link.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  _EmailForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailForm extends StatelessWidget {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.email),
                errorText: state is ForgotPasswordError ? state.message : null,
              ),
              enabled: state is! ForgotPasswordLoading,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: state is ForgotPasswordLoading
                  ? null
                  : () {
                context.read<ForgotPasswordBloc>().add(SubmitEmail(_emailController.text.trim()));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: state is ForgotPasswordLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white),
              )
                  : const Text('Send Reset Link', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}