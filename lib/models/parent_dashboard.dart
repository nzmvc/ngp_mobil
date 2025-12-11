import 'child.dart';
import 'parent.dart';
import 'payment.dart';
import 'attendance.dart';
import 'teacher_comment.dart';

class ParentDashboard {
  final Parent parent;
  final List<Child> children;
  final DashboardStatistics statistics;
  final List<Payment> recentPayments;
  final List<Attendance> recentRollcalls;
  final List<TeacherComment> recentComments;

  ParentDashboard({
    required this.parent,
    required this.children,
    required this.statistics,
    required this.recentPayments,
    required this.recentRollcalls,
    required this.recentComments,
  });

  factory ParentDashboard.fromJson(Map<String, dynamic> json) {
    return ParentDashboard(
      parent: Parent.fromJson(json['parent']),
      children: (json['children'] as List?)
              ?.map((child) => Child.fromJson(child))
              .toList() ??
          [],
      statistics: DashboardStatistics.fromJson(json['statistics'] ?? {}),
      recentPayments: (json['recent_payments'] as List?)
              ?.map((payment) => Payment.fromJson(payment))
              .toList() ??
          [],
      recentRollcalls: (json['recent_rollcalls'] as List?)
              ?.map((rollcall) => Attendance.fromJson(rollcall))
              .toList() ??
          [],
      recentComments: (json['recent_comments'] as List?)
              ?.map((comment) => TeacherComment.fromJson(comment))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parent': parent.toJson(),
      'children': children.map((c) => c.toJson()).toList(),
      'statistics': statistics.toJson(),
      'recent_payments': recentPayments.map((p) => p.toJson()).toList(),
      'recent_rollcalls': recentRollcalls.map((r) => r.toJson()).toList(),
      'recent_comments': recentComments.map((c) => c.toJson()).toList(),
    };
  }
}

class DashboardStatistics {
  final int totalChildren;
  final double totalPayments;
  final int totalPendingAssignments;
  final int totalActiveSessions;

  DashboardStatistics({
    required this.totalChildren,
    required this.totalPayments,
    required this.totalPendingAssignments,
    required this.totalActiveSessions,
  });

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) {
    return DashboardStatistics(
      totalChildren: json['total_children'] ?? 0,
      totalPayments: (json['total_payments'] ?? 0).toDouble(),
      totalPendingAssignments: json['total_pending_assignments'] ?? 0,
      totalActiveSessions: json['total_active_sessions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_children': totalChildren,
      'total_payments': totalPayments,
      'total_pending_assignments': totalPendingAssignments,
      'total_active_sessions': totalActiveSessions,
    };
  }
}
