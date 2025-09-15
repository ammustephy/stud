import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stud/APIService.dart';
import 'package:stud/Model/AttendanceModel.dart';
import 'package:stud/Screens/HomePage.dart' hide ApiService;
import 'package:table_calendar/table_calendar.dart';


// home_page.dart

// attendance_state.dart
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class FetchAttendance extends AttendanceEvent {
  final DateTime date;

  const FetchAttendance(this.date);

  @override
  List<Object?> get props => [date];
}

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceSuccess extends AttendanceState {
  final AttendanceResponse response;

  const AttendanceSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class AttendanceFailure extends AttendanceState {
  final String error;

  const AttendanceFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final ApiService apiService;

  AttendanceBloc({required this.apiService}) : super(AttendanceInitial()) {
    on<FetchAttendance>(_onFetchAttendance);
  }

  Future<void> _onFetchAttendance(FetchAttendance event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      // Format date to YYYY-MM-DD for API consistency
      final formattedDate = DateFormat('yyyy-MM-dd').format(event.date);
      log('Fetching attendance for formatted date: $formattedDate', name: 'AttendanceBloc');
      final result = await apiService.fetchAttendance(event.date);
      log('FetchAttendance result: success=${result.success}, message=${result.message}, records=${result.data.attendanceRecords.length}, date=${result.data.date}', name: 'AttendanceBloc');
      if (result.success) {
        emit(AttendanceSuccess(result));
      } else {
        log('API Failure: ${result.message}', name: 'AttendanceBloc');
        emit(AttendanceFailure(result.message));
      }
    } catch (e) {
      log('Exception: $e', name: 'AttendanceBloc', error: e);
      emit(AttendanceFailure('Error: $e'));
    }
  }
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  void _showSummaryDialog(BuildContext context, AttendanceData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attendance Summary', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${data.date}', style: const TextStyle(fontSize: 14)),
            Text('Total Classes: ${data.summary.totalClasses}', style: const TextStyle(fontSize: 14)),
            Text('Present: ${data.summary.presentCount}', style: const TextStyle(fontSize: 14)),
            Text('Absent: ${data.summary.absentCount}', style: const TextStyle(fontSize: 14)),
            Text('Late: ${data.summary.lateCount}', style: const TextStyle(fontSize: 14)),
            Text('Excused: ${data.summary.excusedCount}', style: const TextStyle(fontSize: 14)),
            Text('Percentage: ${data.summary.attendancePercentage.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            log('Available constraints: height=${constraints.maxHeight}, width=${constraints.maxWidth}', name: 'AttendancePage');
            return Column(
              children: [
                // Calendar Widget
                Card(
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDay);
                      log('Selected date: $formattedDate', name: 'AttendancePage');
                      context.read<AttendanceBloc>().add(FetchAttendance(selectedDay));
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFF667eea),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFF667eea).withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      outsideDaysVisible: false,
                      weekendTextStyle: const TextStyle(color: Colors.red),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Attendance List
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.red, width: 2), // Debug border
                    ),
                    child: BlocBuilder<AttendanceBloc, AttendanceState>(
                      key: ValueKey('AttendanceBloc_${DateTime.now().millisecondsSinceEpoch}'),
                      builder: (context, state) {
                        log('Current state: ${state.runtimeType}, state: $state', name: 'AttendancePage');
                        if (state is AttendanceLoading) {
                          log('Rendering loading state', name: 'AttendancePage');
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is AttendanceSuccess) {
                          final data = state.response.data;
                          log('Rendering AttendanceSuccess with ${data.attendanceRecords.length} records, message: ${state.response.message}', name: 'AttendancePage');
                          if (data.attendanceRecords.isEmpty) {
                            log('Rendering empty state for date: ${data.date}, message: ${state.response.message}', name: 'AttendancePage');
                            return Center(
                              child: Text(
                                state.response.message,
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return CustomScrollView(
                            key: ValueKey('CustomScrollView_${data.attendanceRecords.length}'),
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                    log('SliverList builder called for index: $index, total items: ${data.attendanceRecords.length}', name: 'AttendancePage');
                                    final record = data.attendanceRecords[index];
                                    log('Rendering record $index: ${record.courseName}, code: ${record.courseCode}, status: ${record.attendanceStatus}', name: 'AttendancePage');
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                      child: ListTile(
                                        key: ValueKey('Record_${record.id}'),
                                        title: Text(
                                          record.courseName,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Code: ${record.courseCode}', style: const TextStyle(fontSize: 14)),
                                                  Text(
                                                    'Status: ${record.attendanceStatus}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: record.attendanceStatus == 'P'
                                                          ? Colors.green
                                                          : record.attendanceStatus == 'A'
                                                          ? Colors.red
                                                          : Colors.orange,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Time Slot: ${record.timeSlot}', style: const TextStyle(fontSize: 14)),
                                                  Text('Date: ${record.classdate}', style: const TextStyle(fontSize: 14)),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text('Teacher: ${record.teacherName}', style: const TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                        tileColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        onTap: () => _showSummaryDialog(context, data),
                                      ),
                                    );
                                  },
                                  childCount: data.attendanceRecords.length,
                                ),
                              ),
                            ],
                          );
                        } else if (state is AttendanceFailure) {
                          log('Rendering AttendanceFailure: ${state.error}', name: 'AttendancePage');
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(child: Text('Error: ${state.error}', style: const TextStyle(fontSize: 16, color: Colors.red))),
                          );
                        }
                        log('Rendering initial state', name: 'AttendancePage');
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: Text('Select a date to view attendance', style: TextStyle(fontSize: 16))),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


