import 'admin_user.dart';

class AdminDashboard {
  final AdminUser adminUser;
  final AdminStatistics statistics;
  final FinancialSummary financialSummary;
  final List<SystemActivity> recentActivities;
  final SystemHealth systemHealth;
  final UserDistribution userDistribution;

  AdminDashboard({
    required this.adminUser,
    required this.statistics,
    required this.financialSummary,
    required this.recentActivities,
    required this.systemHealth,
    required this.userDistribution,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    return AdminDashboard(
      adminUser: AdminUser.fromJson(json['admin_user'] ?? {}),
      statistics: AdminStatistics.fromJson(json['statistics'] ?? {}),
      financialSummary: FinancialSummary.fromJson(json['financial_summary'] ?? {}),
      recentActivities: (json['recent_activities'] as List?)
              ?.map((e) => SystemActivity.fromJson(e))
              .toList() ??
          [],
      systemHealth: SystemHealth.fromJson(json['system_health'] ?? {}),
      userDistribution: UserDistribution.fromJson(json['user_distribution'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_user': adminUser.toJson(),
      'statistics': statistics.toJson(),
      'financial_summary': financialSummary.toJson(),
      'recent_activities': recentActivities.map((e) => e.toJson()).toList(),
      'system_health': systemHealth.toJson(),
      'user_distribution': userDistribution.toJson(),
    };
  }
}

class AdminStatistics {
  final int totalStudents;
  final int totalTeachers;
  final int totalParents;
  final int totalPdr;
  final int totalCourses;
  final int totalHomeworks;
  final int totalTasks;

  AdminStatistics({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalParents,
    required this.totalPdr,
    required this.totalCourses,
    required this.totalHomeworks,
    required this.totalTasks,
  });

  factory AdminStatistics.fromJson(Map<String, dynamic> json) {
    return AdminStatistics(
      totalStudents: json['total_students'] ?? 0,
      totalTeachers: json['total_teachers'] ?? 0,
      totalParents: json['total_parents'] ?? 0,
      totalPdr: json['total_pdr'] ?? 0,
      totalCourses: json['total_courses'] ?? 0,
      totalHomeworks: json['total_homeworks'] ?? 0,
      totalTasks: json['total_tasks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_students': totalStudents,
      'total_teachers': totalTeachers,
      'total_parents': totalParents,
      'total_pdr': totalPdr,
      'total_courses': totalCourses,
      'total_homeworks': totalHomeworks,
      'total_tasks': totalTasks,
    };
  }
}

class FinancialSummary {
  final double totalIncome;
  final double totalExpense;
  final double netProfit;
  final String period;

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
    required this.period,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      totalIncome: (json['total_income'] ?? 0.0).toDouble(),
      totalExpense: (json['total_expense'] ?? 0.0).toDouble(),
      netProfit: (json['net_profit'] ?? 0.0).toDouble(),
      period: json['period'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'net_profit': netProfit,
      'period': period,
    };
  }
}

class SystemActivity {
  final int id;
  final String userName;
  final String operation;
  final String date;

  SystemActivity({
    required this.id,
    required this.userName,
    required this.operation,
    required this.date,
  });

  factory SystemActivity.fromJson(Map<String, dynamic> json) {
    return SystemActivity(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? '',
      operation: json['operation'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'operation': operation,
      'date': date,
    };
  }
}

class SystemHealth {
  final int activeStudents;
  final int activeTeachers;
  final String databaseStatus;
  final String? lastBackup;

  SystemHealth({
    required this.activeStudents,
    required this.activeTeachers,
    required this.databaseStatus,
    this.lastBackup,
  });

  factory SystemHealth.fromJson(Map<String, dynamic> json) {
    return SystemHealth(
      activeStudents: json['active_students'] ?? 0,
      activeTeachers: json['active_teachers'] ?? 0,
      databaseStatus: json['database_status'] ?? 'unknown',
      lastBackup: json['last_backup'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_students': activeStudents,
      'active_teachers': activeTeachers,
      'database_status': databaseStatus,
      'last_backup': lastBackup,
    };
  }

  String get databaseStatusDisplay {
    switch (databaseStatus) {
      case 'healthy':
        return 'Sağlıklı';
      case 'warning':
        return 'Uyarı';
      case 'critical':
        return 'Kritik';
      default:
        return databaseStatus;
    }
  }
}

class UserDistribution {
  final int students;
  final int teachers;
  final int parents;
  final int pdr;

  UserDistribution({
    required this.students,
    required this.teachers,
    required this.parents,
    required this.pdr,
  });

  factory UserDistribution.fromJson(Map<String, dynamic> json) {
    return UserDistribution(
      students: json['students'] ?? 0,
      teachers: json['teachers'] ?? 0,
      parents: json['parents'] ?? 0,
      pdr: json['pdr'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'students': students,
      'teachers': teachers,
      'parents': parents,
      'pdr': pdr,
    };
  }

  int get total => students + teachers + parents + pdr;
}
