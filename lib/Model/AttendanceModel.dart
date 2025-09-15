import 'package:equatable/equatable.dart';
import 'dart:convert';

class AttendanceResponse extends Equatable {
  final bool success;
  final String message;
  final AttendanceData data;

  const AttendanceResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: AttendanceData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data.toJson(),
  };

  @override
  List<Object?> get props => [success, message, data];
}

class AttendanceData extends Equatable {
  final String date;
  final List<AttendanceRecord> attendanceRecords;
  final Summary summary;

  const AttendanceData({
    required this.date,
    required this.attendanceRecords,
    required this.summary,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      date: json['date'] as String,
      attendanceRecords: (json['attendance_records'] as List<dynamic>)
          .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: Summary.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'attendance_records': attendanceRecords.map((e) => e.toJson()).toList(),
    'summary': summary.toJson(),
  };

  @override
  List<Object?> get props => [date, attendanceRecords, summary];
}

class AttendanceRecord extends Equatable {
  final int id;
  final String courseName;
  final String courseCode;
  final String attendanceStatus;
  final int timeSlot;
  final String teacherName;
  final String classdate;

  const AttendanceRecord({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.attendanceStatus,
    required this.timeSlot,
    required this.teacherName,
    required this.classdate,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as int,
      courseName: json['course_name'] as String,
      courseCode: json['course_code'] as String,
      attendanceStatus: json['attendance_status'] as String,
      timeSlot: json['time_slot'] as int,
      teacherName: json['teacher_name'] as String,
      classdate: json['classdate'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'course_name': courseName,
    'course_code': courseCode,
    'attendance_status': attendanceStatus,
    'time_slot': timeSlot,
    'teacher_name': teacherName,
    'classdate': classdate,
  };

  @override
  List<Object?> get props => [
    id,
    courseName,
    courseCode,
    attendanceStatus,
    timeSlot,
    teacherName,
    classdate,
  ];
}

class Summary extends Equatable {
  final int totalClasses;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final double attendancePercentage;

  const Summary({
    required this.totalClasses,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.excusedCount,
    required this.attendancePercentage,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalClasses: json['total_classes'] as int,
      presentCount: json['present_count'] as int,
      absentCount: json['absent_count'] as int,
      lateCount: json['late_count'] as int,
      excusedCount: json['excused_count'] as int,
      attendancePercentage: (json['attendance_percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_classes': totalClasses,
    'present_count': presentCount,
    'absent_count': absentCount,
    'late_count': lateCount,
    'excused_count': excusedCount,
    'attendance_percentage': attendancePercentage,
  };

  @override
  List<Object?> get props => [
    totalClasses,
    presentCount,
    absentCount,
    lateCount,
    excusedCount,
    attendancePercentage,
  ];
}