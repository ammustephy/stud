import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

///////////////////////////////ExamResultsPage//////////////////////////////////////////////////////////


class Subject {
  final String name;
  final int totalMarks;
  final int obtainedMarks;
  final String grade;

  Subject({required this.name, required this.totalMarks, required this.obtainedMarks, required this.grade});
}

class ExamResult {
  final String id, examType, examName, date, grade;
  final int totalMarks, obtainedMarks, percentage;
  final List<Subject> subjects;

  ExamResult({
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

final List<ExamResult> mockExamResults = [
  ExamResult(
    id: '1',
    examType: 'Class Test',
    examName: 'Mid-term Class Test',
    date: '2025-01-10',
    totalMarks: 400,
    obtainedMarks: 340,
    percentage: 85,
    grade: 'A',
    subjects: [
      Subject(name: 'Mathematics', totalMarks: 100, obtainedMarks: 85, grade: 'A'),
      Subject(name: 'English', totalMarks: 100, obtainedMarks: 90, grade: 'A+'),
      Subject(name: 'Science', totalMarks: 100, obtainedMarks: 80, grade: 'A'),
      Subject(name: 'Social Studies', totalMarks: 100, obtainedMarks: 85, grade: 'A'),
    ],
  ),
  ExamResult(
    id: '2',
    examType: 'Assignment',
    examName: 'Monthly Assignment Test',
    date: '2025-01-05',
    totalMarks: 200,
    obtainedMarks: 170,
    percentage: 85,
    grade: 'A',
    subjects: [
      Subject(name: 'Mathematics', totalMarks: 50, obtainedMarks: 42, grade: 'A'),
      Subject(name: 'English', totalMarks: 50, obtainedMarks: 45, grade: 'A+'),
      Subject(name: 'Science', totalMarks: 50, obtainedMarks: 40, grade: 'A'),
      Subject(name: 'Social Studies', totalMarks: 50, obtainedMarks: 43, grade: 'A'),
    ],
  ),
  ExamResult(
    id: '3',
    examType: 'Unit Test',
    examName: 'Unit Test - 1',
    date: '2024-12-20',
    totalMarks: 300,
    obtainedMarks: 255,
    percentage: 85,
    grade: 'A',
    subjects: [
      Subject(name: 'Mathematics', totalMarks: 75, obtainedMarks: 65, grade: 'A'),
      Subject(name: 'English', totalMarks: 75, obtainedMarks: 68, grade: 'A'),
      Subject(name: 'Science', totalMarks: 75, obtainedMarks: 60, grade: 'B+'),
      Subject(name: 'Social Studies', totalMarks: 75, obtainedMarks: 62, grade: 'A'),
    ],
  ),
];


// Define mockExamResults list similarly using these models


abstract class ExamEvent {}
class LoadExamResults extends ExamEvent {}
class SelectExamResult extends ExamEvent {
  final ExamResult result;
  SelectExamResult(this.result);
}




abstract class ExamState extends Equatable {
  @override List<Object?> get props => [];
}

class ExamsLoading extends ExamState {}
class ExamsLoaded extends ExamState {
  final List<ExamResult> results;
  final ExamResult? selected;
  ExamsLoaded(this.results, {this.selected});
  @override List<Object?> get props => [results, selected];
}




class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final List<ExamResult> mockData;

  ExamBloc(this.mockData) : super(ExamsLoading()) {
    on<LoadExamResults>((_, emit) => emit(ExamsLoaded(mockData)));
    on<SelectExamResult>((event, emit) {
      if (state is ExamsLoaded) {
        emit(ExamsLoaded((state as ExamsLoaded).results, selected: event.result));
      }
    });
  }
}




Color gradeColor(String grade) {
  switch (grade) {
    case 'A+': return Colors.green.shade100;
    case 'A': return Colors.blue.shade100;
    case 'B+': return Colors.yellow.shade100;
    case 'B': return Colors.orange.shade100;
    default: return Colors.grey.shade200;
  }
}

class ExamResultsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExamBloc(mockExamResults)..add(LoadExamResults()),
      child: Scaffold(
        appBar: AppBar(
            title: Text('Exam Results'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,),
        body: BlocBuilder<ExamBloc, ExamState>(
          builder: (context, state) {
            if (state is ExamsLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ExamsLoaded) {
              if (state.selected != null) {
                return _ResultDetail(result: state.selected!, onBack: () {
                  context.read<ExamBloc>().add(LoadExamResults());
                });
              } else {
                return _ResultsList(results: state.results);
              }
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final List<ExamResult> results;
  _ResultsList({required this.results});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final res = results[i];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(res.examName),
            subtitle: Text('${res.examType} • ${res.date}'),
            trailing: ElevatedButton(
              child: Text('View'),
              onPressed: () => context.read<ExamBloc>().add(SelectExamResult(res)),
            ),
          ),
        );
      },
    );
  }
}

class _ResultDetail extends StatelessWidget {
  final ExamResult result;
  final VoidCallback onBack;

  _ResultDetail({required this.result, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AppBar(leading: BackButton(onPressed: onBack), title: Text('Result Details')),
      Expanded(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(result.examName, style: TextStyle(fontSize: 18)),
                subtitle: Text('${result.examType} • ${result.date}'),
                trailing: Icon(Icons.emoji_events, color: Colors.amber),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(children: [
                  Text('Marks: ${result.obtainedMarks}/${result.totalMarks}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Percentage: ${result.percentage}%', style: TextStyle(fontSize: 16)),
                ]),
              ),
            ),
            ...result.subjects.map((subject) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(subject.name),
                  subtitle: Text('${subject.obtainedMarks}/${subject.totalMarks}'),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: gradeColor(subject.grade),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(subject.grade),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    ]);
  }
}