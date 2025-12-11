import 'teacher.dart';
import 'teacher_student.dart';
import 'attendance.dart';

class TeacherDashboard {
  final Teacher teacher;
  final TeacherStatistics statistics;
  final List<Attendance> recentSessions;
  final int pendingHomeworks;
  final int todaySessions;

  TeacherDashboard({
    required this.teacher,
    required this.statistics,
    required this.recentSessions,
    required this.pendingHomeworks,
    required this.todaySessions,
  });

  factory TeacherDashboard.fromJson(Map<String, dynamic> json) {
    return TeacherDashboard(
      teacher: Teacher.fromJson(json['teacher']),
      statistics: TeacherStatistics.fromJson(json['statistics'] ?? {}),
      recentSessions: (json['recent_sessions'] as List?)
              ?.map((session) => Attendance.fromJson(session))
              .toList() ??
          [],
      pendingHomeworks: json['pending_homeworks'] ?? 0,
      todaySessions: json['today_sessions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher': teacher.toJson(),
      'statistics': statistics.toJson(),
      'recent_sessions': recentSessions.map((s) => s.toJson()).toList(),
      'pending_homeworks': pendingHomeworks,
      'today_sessions': todaySessions,
    };
  }
}

class TeacherStatistics {
  final int totalStudents;
  final int totalCourses;
  final int totalHomeworks;
  final int pendingGrading;
  final int todayRollcalls;

  TeacherStatistics({
    required this.totalStudents,
    required this.totalCourses,
    required this.totalHomeworks,
    required this.pendingGrading,
    required this.todayRollcalls,
  });

  factory TeacherStatistics.fromJson(Map<String, dynamic> json) {
    return TeacherStatistics(
      totalStudents: json['total_students'] ?? 0,
      totalCourses: json['total_courses'] ?? 0,
      totalHomeworks: json['total_homeworks'] ?? 0,
      pendingGrading: json['pending_grading'] ?? 0,
      todayRollcalls: json['today_rollcalls'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_students': totalStudents,
      'total_courses': totalCourses,
      'total_homeworks': totalHomeworks,
      'pending_grading': pendingGrading,
      'today_rollcalls': todayRollcalls,
    };
  }
}
