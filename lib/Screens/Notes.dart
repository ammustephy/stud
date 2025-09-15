import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stud/Screens/HomePage.dart';

class Note {
  final String id, subject, title, type, uploadDate, size;
  final int pages;

  Note({
    required this.id,
    required this.subject,
    required this.title,
    required this.type,
    required this.uploadDate,
    required this.size,
    required this.pages,
  });
}

final List<Note> mockNotes = [
  Note(
    id: '1',
    subject: 'Mathematics',
    title: 'Quadratic Equations - Complete Notes',
    type: 'Chapter Notes',
    uploadDate: '2025-01-10',
    size: '2.5 MB',
    pages: 15,
  ),
  Note(
    id: '2',
    subject: 'English',
    title: 'Literature Analysis - Complete Notes',
    type: 'Literature Notes',
    uploadDate: '2025-01-12',
    size: '1.8 MB',
    pages: 10,
  ),
  Note(
    id: '3',
    subject: 'Science',
    title: 'Physics - Practice Set',
    type: 'Practice Set',
    uploadDate: '2025-01-15',
    size: '3.2 MB',
    pages: 20,
  ),
];

abstract class NoteEvent extends Equatable {
  const NoteEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotes extends NoteEvent {}

class ViewNote extends NoteEvent {
  final Note note;
  const ViewNote(this.note);
  @override
  List<Object?> get props => [note];
}

abstract class NoteState extends Equatable {
  const NoteState();
  @override
  List<Object?> get props => [];
}

class NotesLoading extends NoteState {}

class NotesLoaded extends NoteState {
  final List<Note> notes;
  final Note? selected;
  const NotesLoaded(this.notes, {this.selected});
  @override
  List<Object?> get props => [notes, selected];
}

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final List<Note> mockData;
  NoteBloc(this.mockData) : super(NotesLoading()) {
    on<LoadNotes>((_, emit) => emit(NotesLoaded(mockData)));
    on<ViewNote>((event, emit) {
      final state = this.state;
      if (state is NotesLoaded) {
        emit(NotesLoaded(state.notes, selected: event.note));
      }
    });
  }
}

class NotesPage extends StatelessWidget {
  final Student? student;

  const NotesPage({Key? key, this.student}) : super(key: key);

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
        create: (_) => NoteBloc(mockNotes)..add(LoadNotes()),
        child: BlocBuilder<NoteBloc, NoteState>(
          builder: (context, state) {
            if (state is NotesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotesLoaded) {
              return state.selected != null
                  ? _DetailViews(note: state.selected!)
                  : _ListViews(notes: state.notes, student: studentArg);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ListViews extends StatelessWidget {
  final List<Note> notes;
  final Student student;
  const _ListViews({required this.notes, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            // Icon(Icons.note),
            SizedBox(width: 8),
            Text('Study Notes'),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Center(child: Text('Class ${student.studentClass} Study Materials')),
              subtitle: Center(child: Text('${notes.length} Notes Available')),
            ),
          ),
          const SizedBox(height: 12),
          ...notes.map((note) => Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Uploaded on ${note.uploadDate}'),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: [
                    // Placeholder for chips if needed in the future
                  ]),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.remove_red_eye, size: 14),
                          label: const Text('View', style: TextStyle(fontSize: 13)),
                          onPressed: () {
                            context.read<NoteBloc>().add(ViewNote(note));
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(36),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.download, size: 14),
                          label: const Text('Download', style: TextStyle(fontSize: 13)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Downloading ${note.title}...'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(36),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.share, size: 14),
                          label: const Text('Share', style: TextStyle(fontSize: 13)),
                          onPressed: () {
                            final shareText = 'Note: ${note.title}\nSubject: ${note.subject}\nType: ${note.type}\nPages: ${note.pages}\nSize: ${note.size}\nUploaded: ${note.uploadDate}';
                            Share.share(shareText, subject: 'Note: ${note.title}');
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(36),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _DetailViews extends StatelessWidget {
  final Note note;
  const _DetailViews({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          context.read<NoteBloc>().add(LoadNotes());
        }),
        title: const Row(
          children: [
            Icon(Icons.description),
            SizedBox(width: 8),
            Text('Note Details'),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Subject: ${note.subject}'),
              Text('Type: ${note.type}'),
              Text('Pages: ${note.pages}'),
              Text('Size: ${note.size}'),
              Text('Uploaded: ${note.uploadDate}'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Download', style: TextStyle(fontSize: 15)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloading ${note.title}...'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text('Share', style: TextStyle(fontSize: 15)),
                      onPressed: () {
                        final shareText = 'Note: ${note.title}\nSubject: ${note.subject}\nType: ${note.type}\nPages: ${note.pages}\nSize: ${note.size}\nUploaded: ${note.uploadDate}';
                        Share.share(shareText, subject: 'Note: ${note.title}');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}