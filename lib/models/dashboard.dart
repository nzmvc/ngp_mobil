class DashboardStats {
  final int totalCourses;
  final int totalAssignments;
  final int pendingAssignments;
  final int completedAssignments;
  final int overdueAssignments;
  final int totalLessons;

  DashboardStats({
    required this.totalCourses,
    required this.totalAssignments,
    required this.pendingAssignments,
    required this.completedAssignments,
    required this.overdueAssignments,
    required this.totalLessons,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalCourses: json['total_courses'] ?? 0,
      totalAssignments: json['total_assignments'] ?? 0,
      pendingAssignments: json['pending_assignments'] ?? 0,
      completedAssignments: json['completed_assignments'] ?? 0,
      overdueAssignments: json['overdue_assignments'] ?? 0,
      totalLessons: json['total_lessons'] ?? 0,
    );
  }
}

class RecentAssignment {
  final int id;
  final String title;
  final String status;
  final String? dueDate;
  final bool isOverdue;

  RecentAssignment({
    required this.id,
    required this.title,
    required this.status,
    this.dueDate,
    required this.isOverdue,
  });

  factory RecentAssignment.fromJson(Map<String, dynamic> json) {
    return RecentAssignment(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      status: json['status'] ?? 'pending',
      dueDate: json['due_date'],
      isOverdue: json['is_overdue'] ?? false,
    );
  }
}

class RecentCourse {
  final int id;
  final String title;
  final int lessonCount;

  RecentCourse({
    required this.id,
    required this.title,
    required this.lessonCount,
  });

  factory RecentCourse.fromJson(Map<String, dynamic> json) {
    return RecentCourse(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      lessonCount: json['lesson_count'] ?? 0,
    );
  }
}

class StudentInfo {
  final int id;
  final String fullName;
  final String username;
  final String email;

  StudentInfo({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Dashboard {
  final StudentInfo student;
  final DashboardStats stats;
  final List<RecentAssignment> recentAssignments;
  final List<RecentCourse> recentCourses;

  Dashboard({
    required this.student,
    required this.stats,
    required this.recentAssignments,
    required this.recentCourses,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      student: StudentInfo.fromJson(json['student'] ?? {}),
      stats: DashboardStats.fromJson(json['stats'] ?? {}),
      recentAssignments: (json['recent_assignments'] as List<dynamic>?)
              ?.map((e) => RecentAssignment.fromJson(e))
              .toList() ??
          [],
      recentCourses: (json['recent_courses'] as List<dynamic>?)
              ?.map((e) => RecentCourse.fromJson(e))
              .toList() ??
          [],
    );
  }
}
