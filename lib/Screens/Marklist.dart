import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stud/Screens/ExamResult.dart';
import 'package:stud/Screens/HomePage.dart';

class Marklist {
  final String id, examType, examName, date, grade;
  final int totalMarks, obtainedMarks, percentage;
  final List<Subject> subjects;

  Marklist({
    required this.id,
    required this.examType,
    required this.examName,
    required this.date,
    required this.totalMarks,
    required this.obtainedMarks,
    required this.percentage,
    required this.grade,
    required this.subjects,
  });
}

final List<Marklist> mockMarklists = [
  Marklist(
    id: '1',
    examType: 'Final Exam',
    examName: 'Annual Examination 2024',
    date: '2024-12-15',
    totalMarks: 500,
    obtainedMarks: 425,
    percentage: 85,
    grade: 'A',
    subjects: [
      Subject(name: 'Mathematics', totalMarks: 100, obtainedMarks: 85, grade: 'A'),
      Subject(name: 'English', totalMarks: 100, obtainedMarks: 90, grade: 'A+'),
      Subject(name: 'Science', totalMarks: 100, obtainedMarks: 80, grade: 'A'),
      Subject(name: 'Social Studies', totalMarks: 100, obtainedMarks: 85, grade: 'A'),
      Subject(name: 'Computer Science', totalMarks: 100, obtainedMarks: 85, grade: 'A'),
    ],
  ),
  Marklist(
    id: '2',
    examType: 'Half Yearly',
    examName: 'Half Yearly Examination 2024',
    date: '2024-09-20',
    totalMarks: 500,
    obtainedMarks: 410,
    percentage: 82,
    grade: 'A',
    subjects: [
      Subject(name: 'Mathematics', totalMarks: 100, obtainedMarks: 80, grade: 'A'),
      Subject(name: 'English', totalMarks: 100, obtainedMarks: 88, grade: 'A'),
      Subject(name: 'Science', totalMarks: 100, obtainedMarks: 78, grade: 'B+'),
      Subject(name: 'Social Studies', totalMarks: 100, obtainedMarks: 82, grade: 'A'),
      Subject(name: 'Computer Science', totalMarks: 100, obtainedMarks: 82, grade: 'A'),
    ],
  ),
];

abstract class MarklistEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMarklists extends MarklistEvent {}

class SelectMarklist extends MarklistEvent {
  final Marklist marklist;
  SelectMarklist(this.marklist);
  @override
  List<Object?> get props => [marklist];
}

abstract class MarklistState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MarklistsLoading extends MarklistState {}

class MarklistsLoaded extends MarklistState {
  final List<Marklist> lists;
  final Marklist? selected;

  MarklistsLoaded(this.lists, {this.selected});
  @override
  List<Object?> get props => [lists, selected];
}

class MarklistBloc extends Bloc<MarklistEvent, MarklistState> {
  final List<Marklist> mockData;

  MarklistBloc(this.mockData) : super(MarklistsLoading()) {
    on<LoadMarklists>((_, emit) => emit(MarklistsLoaded(mockData)));
    on<SelectMarklist>((event, emit) {
      if (state is MarklistsLoaded) {
        emit(MarklistsLoaded(
          (state as MarklistsLoaded).lists,
          selected: event.marklist,
        ));
      }
    });
  }
}

class MarklistPage extends StatelessWidget {
  final Student? student;
  const MarklistPage({Key? key, this.student}) : super(key: key);

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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: BlocProvider(
        create: (_) => MarklistBloc(mockMarklists)..add(LoadMarklists()),
        child: Scaffold(
          body: BlocBuilder<MarklistBloc, MarklistState>(
            builder: (context, state) {
              if (state is MarklistsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is MarklistsLoaded) {
                return Column(
                  children: [
                    Flexible(
                      flex: 2,
                      child: _ListView(lists: state.lists, student: studentArg),
                    ),
                    if (state.selected != null)
                      Flexible(
                        flex: 3,
                        child: _DetailView(marklist: state.selected!),
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  final List<Marklist> lists;
  final Student student;
  const _ListView({required this.lists, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            // Icon(Icons.assessment),
            SizedBox(width: 8),
            Text('Marklists'),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lists.length,
        itemBuilder: (_, idx) {
          final m = lists[idx];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(m.examName),
              subtitle: Text('${m.examType} • ${m.date}'),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    child: const Text('View'),
                    onPressed: () => context.read<MarklistBloc>().add(SelectMarklist(m)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  final Marklist marklist;
  const _DetailView({required this.marklist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.read<MarklistBloc>().add(LoadMarklists())),
        title: const Row(
          children: [
            // Icon(Icons.description),
            SizedBox(width: 8),
            Text('Marklist Details'),
          ],
        ),
        // backgroundColor: Colors.blue,
        // foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(title: Text(marklist.examName), subtitle: Text('${marklist.examType} • ${marklist.date}')),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(children: [Text('${marklist.obtainedMarks}', style: const TextStyle(fontSize: 20)), const Text('Obtained')]),
                      Column(children: [Text('${marklist.percentage}%', style: const TextStyle(fontSize: 20, color: Colors.green)), const Text('Percentage')]),
                      Column(children: [Container(padding: const EdgeInsets.all(6), color: gradeColor(marklist.grade), child: Text(marklist.grade)), const Text('Grade')]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Downloading ${marklist.examName}...')),
                              );
                            },
                            icon: const Icon(Icons.download, size: 16),
                            label: const Text(
                              'Download',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: const Size(0, 36),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final shareText = 'Marklist: ${marklist.examName}\nExam Type: ${marklist.examType}\nDate: ${marklist.date}\nObtained: ${marklist.obtainedMarks}/${marklist.totalMarks}\nPercentage: ${marklist.percentage}%\nGrade: ${marklist.grade}\n\nSubjects:\n${marklist.subjects.map((s) => '${s.name}: ${s.obtainedMarks}/${s.totalMarks} (${((s.obtainedMarks / s.totalMarks) * 100).round()}%, Grade: ${s.grade})').join('\n')}';
                              Share.share(shareText, subject: 'Marklist: ${marklist.examName}');
                            },
                            icon: const Icon(Icons.share, size: 16),
                            label: const Text(
                              'Share',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: const Size(0, 36),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ...marklist.subjects.map((s) => Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(s.name),
              subtitle: Text('Marks: ${s.obtainedMarks}/${s.totalMarks} — Percentage: ${((s.obtainedMarks / s.totalMarks) * 100).round()}%'),
              trailing: Container(padding: const EdgeInsets.all(6), color: gradeColor(s.grade), child: Text(s.grade)),
            ),
          )),
        ],
      ),
    );
  }
}