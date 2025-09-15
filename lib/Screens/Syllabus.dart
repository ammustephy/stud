import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stud/Screens/HomePage.dart';

abstract class SyllabusEvent extends Equatable {
  const SyllabusEvent();
  @override
  List<Object?> get props => [];
}

class LoadSyllabus extends SyllabusEvent {}

class ViewSubject extends SyllabusEvent {
  final String subjectId;
  const ViewSubject(this.subjectId);
  @override
  List<Object?> get props => [subjectId];
}

class DownloadSubject extends SyllabusEvent {
  final String subjectId;
  const DownloadSubject(this.subjectId);
  @override
  List<Object?> get props => [subjectId];
}

class ShareSubject extends SyllabusEvent {
  final String subjectId;
  const ShareSubject(this.subjectId);
  @override
  List<Object?> get props => [subjectId];
}

class SubjectProgress {
  final String id, subject;
  final List<String> chapters;
  final int completedChapters, totalChapters;

  SubjectProgress({
    required this.id,
    required this.subject,
    required this.chapters,
    required this.completedChapters,
    required this.totalChapters,
  });
}

class SyllabusState extends Equatable {
  final List<SubjectProgress> subjects;
  const SyllabusState(this.subjects);

  @override
  List<Object?> get props => [subjects];
}

class SyllabusBloc extends Bloc<SyllabusEvent, SyllabusState> {
  SyllabusBloc() : super(SyllabusState([
    SubjectProgress(
      id: '1',
      subject: 'Mathematics',
      chapters: ['Quadratic Equations', 'Linear Algebra', 'Geometry', 'Trigonometry', 'Calculus Basics'],
      completedChapters: 3,
      totalChapters: 5,
    ),
    SubjectProgress(
      id: '2',
      subject: 'English',
      chapters: ['Macbeth', 'Poetry Analysis', 'Grammar', 'Essay Writing'],
      completedChapters: 2,
      totalChapters: 4,
    ),
    SubjectProgress(
      id: '3',
      subject: 'Science',
      chapters: ['Mechanics', 'Thermodynamics', 'Electromagnetism', 'Optics', 'Chemistry Basics'],
      completedChapters: 1,
      totalChapters: 5,
    ),
  ])) {
    on<LoadSyllabus>((_, emit) => emit(SyllabusState(state.subjects)));
    on<ViewSubject>((event, emit) {
      emit(SyllabusState(state.subjects));
    });
    on<DownloadSubject>((event, emit) {
      emit(SyllabusState(state.subjects));
    });
    on<ShareSubject>((event, emit) {
      emit(SyllabusState(state.subjects));
    });
  }
}

class SyllabusPage extends StatelessWidget {
  final Student? student;

  const SyllabusPage({Key? key, this.student}) : super(key: key);

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
        create: (_) => SyllabusBloc()..add(LoadSyllabus()),
        child: Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                // Icon(Icons.book),
                SizedBox(width: 8),
                Text('Syllabus'),
              ],
            ),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: BlocBuilder<SyllabusBloc, SyllabusState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('Class ${studentArg.studentClass} - Division ${studentArg.division}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 4),
                          const Text('Academic Year 2024-25', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  ...state.subjects.map((subj) {
                    final progress = subj.completedChapters / subj.totalChapters;
                    final progressPercent = (progress * 100).round();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(subj.subject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Chip(label: Text('${subj.completedChapters}/${subj.totalChapters} Complete')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Progress', style: TextStyle(fontSize: 14)),
                                Text('$progressPercent%', style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade300,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 12),
                            const Text('Chapters:', style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            ...subj.chapters.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final chapter = entry.value;
                              final isDone = idx < subj.completedChapters;
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDone ? Colors.green.shade50 : Colors.grey.shade50,
                                  border: Border.all(color: isDone ? Colors.green.shade200 : Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isDone ? Colors.green : Colors.grey,
                                    radius: 12,
                                    child: Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                                  title: Text(
                                    chapter,
                                    style: TextStyle(
                                      color: isDone ? Colors.green.shade700 : Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.remove_red_eye, size: 14),
                                    label: const Text('View', style: TextStyle(fontSize: 13)),
                                    onPressed: () => _viewSubject(context, subj),
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
                                    onPressed: () => _downloadSubject(context, subj),
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
                                    onPressed: () => _shareSubject(context, subj),
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
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _viewSubject(BuildContext context, SubjectProgress subject) {
    context.read<SyllabusBloc>().add(ViewSubject(subject.id));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${subject.subject} Syllabus',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Progress: ${subject.completedChapters}/${subject.totalChapters} Chapters Complete'),
              Text('Progress Percentage: ${(subject.completedChapters / subject.totalChapters * 100).round()}%'),
              const SizedBox(height: 8),
              const Text('Chapters:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...subject.chapters.asMap().entries.map((entry) {
                final idx = entry.key;
                final chapter = entry.value;
                final isDone = idx < subject.completedChapters;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDone ? Colors.green : Colors.grey,
                    radius: 12,
                    child: Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  title: Text(
                    chapter,
                    style: TextStyle(
                      color: isDone ? Colors.green.shade700 : Colors.grey.shade600,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _downloadSubject(BuildContext context, SubjectProgress subject) {
    context.read<SyllabusBloc>().add(DownloadSubject(subject.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading syllabus for ${subject.subject}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareSubject(BuildContext context, SubjectProgress subject) {
    context.read<SyllabusBloc>().add(ShareSubject(subject.id));
    final shareText = '''
Syllabus: ${subject.subject}
Progress: ${subject.completedChapters}/${subject.totalChapters} Chapters Complete (${(subject.completedChapters / subject.totalChapters * 100).round()}%)
Chapters:
${subject.chapters.asMap().entries.map((e) => '${e.key + 1}. ${e.value}${e.key < subject.completedChapters ? ' (Completed)' : ''}').join('\n')}
''';
    Share.share(shareText, subject: 'Syllabus Progress: ${subject.subject}');
  }
}