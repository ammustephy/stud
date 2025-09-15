import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stud/Screens/HomePage.dart';

class Profile extends Equatable {
  final String id;
  final String name;
  final String studentClass;
  final String division;
  final String email;
  final String phone;
  final String? photoPath;

  const Profile({
    required this.id,
    required this.name,
    required this.studentClass,
    required this.division,
    required this.email,
    required this.phone,
    this.photoPath,
  });

  Profile copyWith({
    String? name,
    String? studentClass,
    String? division,
    String? email,
    String? phone,
    String? photoPath,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      studentClass: studentClass ?? this.studentClass,
      division: division ?? this.division,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  @override
  List<Object?> get props => [id, name, studentClass, division, email, phone, photoPath];
}

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class EditProfile extends ProfileEvent {}
class CancelEdit extends ProfileEvent {}
class UpdateProfileField extends ProfileEvent {
  final String field, value;
  const UpdateProfileField(this.field, this.value);
  @override
  List<Object?> get props => [field, value];
}
class UpdateProfilePhoto extends ProfileEvent {
  final String photoPath;
  const UpdateProfilePhoto(this.photoPath);
  @override
  List<Object?> get props => [photoPath];
}
class SaveProfile extends ProfileEvent {
  final Profile updated;
  const SaveProfile(this.updated);
  @override
  List<Object?> get props => [updated];
}

enum ProfileStatus { viewing, editing, saved }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final Profile profile;

  const ProfileState({required this.status, required this.profile});

  ProfileState copyWith({ProfileStatus? status, Profile? profile}) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [status, profile];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(Profile initialProfile)
      : super(ProfileState(status: ProfileStatus.viewing, profile: initialProfile)) {
    on<EditProfile>((_, emit) {
      emit(state.copyWith(status: ProfileStatus.editing));
    });
    on<CancelEdit>((_, emit) {
      emit(state.copyWith(status: ProfileStatus.viewing));
    });
    on<UpdateProfileField>((event, emit) {
      final updated = _applyUpdate(state.profile, event.field, event.value);
      emit(state.copyWith(profile: updated));
    });
    on<UpdateProfilePhoto>((event, emit) {
      final updated = state.profile.copyWith(photoPath: event.photoPath);
      emit(state.copyWith(profile: updated));
    });
    on<SaveProfile>((event, emit) {
      emit(ProfileState(status: ProfileStatus.saved, profile: event.updated));
    });
  }

  Profile _applyUpdate(Profile profile, String field, String value) {
    switch (field) {
      case 'name':
        return profile.copyWith(name: value);
      case 'class':
        return profile.copyWith(studentClass: value);
      case 'division':
        return profile.copyWith(division: value);
      case 'email':
        return profile.copyWith(email: value);
      case 'phone':
        return profile.copyWith(phone: value);
      default:
        return profile;
    }
  }
}

class ProfilePage extends StatelessWidget {
  final Student? student;

  const ProfilePage({super.key, this.student});

  @override
  Widget build(BuildContext context) {
    final studentArg = student ??
        ModalRoute.of(context)?.settings.arguments as Student? ??
        const Student(
          name: 'Default User',
          studentClass: 'Unknown',
          division: 'Unknown',
          userId: 0,
        );

    final profile = Profile(
      id: studentArg.userId.toString(),
      name: studentArg.name,
      studentClass: studentArg.studentClass,
      division: studentArg.division,
      email: '',
      phone: '',
      photoPath: null,
    );

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home', arguments: studentArg);
        return false;
      },
      child: BlocProvider(
        create: (_) => ProfileBloc(profile),
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (prev, curr) => curr.status == ProfileStatus.saved,
          listener: (_, __) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          },
          builder: (context, state) {
            final isEditing = state.status == ProfileStatus.editing;
            final profile = state.profile;

            return Scaffold(
              appBar: AppBar(
                title: const Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                // flexibleSpace: Container(
                //   decoration: const BoxDecoration(
                //     gradient: LinearGradient(
                //       colors: [Colors.blue, Colors.indigo],
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //     ),
                //   ),
                // ),
                actions: [
                  if (!isEditing)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        context.read<ProfileBloc>().add(EditProfile());
                      },
                      tooltip: 'Edit Profile',
                    ),
                ],
                elevation: 4,
              ),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade100, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.blue.shade100,
                                  backgroundImage: profile.photoPath != null
                                      ? FileImage(File(profile.photoPath!))
                                      : null,
                                  child: profile.photoPath == null
                                      ? const Icon(Icons.person, size: 60, color: Colors.blue)
                                      : null,
                                ),
                                if (isEditing)
                                  GestureDetector(
                                    onTap: () async {
                                      final source = await showDialog<ImageSource>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Select Image Source'),
                                          content: const Text('Choose to pick an image from gallery or take a new photo.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, ImageSource.gallery),
                                              child: const Text('Gallery'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, ImageSource.camera),
                                              child: const Text('Camera'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (source != null) {
                                        final ImagePicker picker = ImagePicker();
                                        final XFile? image = await picker.pickImage(source: source);
                                        if (image != null) {
                                          context.read<ProfileBloc>().add(UpdateProfilePhoto(image.path));
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              profile.name.isNotEmpty ? profile.name : studentArg.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Student ID: ${profile.id}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildEditableField(context, 'Full Name', 'name', profile.name, isEditing),
                    Row(
                      children: [
                        Expanded(
                          child: _buildEditableField(
                            context,
                            'Class',
                            'class',
                            profile.studentClass,
                            isEditing,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildEditableField(
                            context,
                            'Division',
                            'division',
                            profile.division,
                            isEditing,
                          ),
                        ),
                      ],
                    ),
                    _buildEditableField(context, 'Email', 'email', profile.email, isEditing),
                    _buildEditableField(context, 'Phone', 'phone', profile.phone, isEditing),
                    if (isEditing)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                context.read<ProfileBloc>().add(SaveProfile(profile));
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(140, 48),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.save, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Save Changes',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () {
                                context.read<ProfileBloc>().add(CancelEdit());
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(140, 48),
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cancel, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Cancel',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              bottomNavigationBar: BlocBuilder<NavigationBloc, NavigationState>(
                buildWhen: (prev, curr) => prev != curr,
                builder: (context, state) {
                  final currentIndex = state is NavigationIndex ? state.index : 3;
                  return BottomNavigationBar(
                    currentIndex: currentIndex,
                    onTap: (index) {
                      if (index != currentIndex) {
                        context.read<NavigationBloc>().add(NavigateTo(index));
                        switch (index) {
                          case 0:
                            Navigator.pushReplacementNamed(context, '/home', arguments: studentArg);
                            break;
                          case 1:
                            Navigator.pushReplacementNamed(context, '/notifications', arguments: studentArg);
                            break;
                          case 2:
                            Navigator.pushReplacementNamed(context, '/settings', arguments: studentArg);
                            break;
                          case 3:
                            break;
                        }
                      }
                    },
                    selectedItemColor: Colors.blue,
                    unselectedItemColor: Colors.grey.shade600,
                    backgroundColor: Colors.white,
                    elevation: 8,
                    type: BottomNavigationBarType.fixed,
                    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildEditableField(
      BuildContext context, String label, String keyField, String value, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.indigo.shade700,
            ),
          ),
          const SizedBox(height: 4),
          isEditing
              ? TextFormField(
            initialValue: value,
            onChanged: (v) => context.read<ProfileBloc>().add(UpdateProfileField(keyField, v)),
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: label == 'Full Name'
                  ? 'Enter your name'
                  : label == 'Email'
                  ? 'Enter your email'
                  : label == 'Phone'
                  ? 'Enter your phone number'
                  : label == 'Class'
                  ? 'Enter your class'
                  : label == 'Division'
                  ? 'Enter your division'
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          )
              : Text(
            value.isEmpty ? 'Add ${label == 'Full Name' ? 'Name' : label}' : value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}