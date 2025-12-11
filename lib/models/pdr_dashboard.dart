import 'pdr_expert.dart';
import 'pdr_student.dart';
import 'emotional_analysis.dart';

class PdrDashboard {
  final PdrExpert pdrExpert;
  final PdrStatistics statistics;
  final List<PdrStudent> highRiskStudents;
  final List<EmotionalAnalysis> recentAnalyses;
  final int unreadMessages;

  PdrDashboard({
    required this.pdrExpert,
    required this.statistics,
    required this.highRiskStudents,
    required this.recentAnalyses,
    required this.unreadMessages,
  });

  factory PdrDashboard.fromJson(Map<String, dynamic> json) {
    return PdrDashboard(
      pdrExpert: PdrExpert.fromJson(json['pdr_expert']),
      statistics: PdrStatistics.fromJson(json['statistics']),
      highRiskStudents: (json['high_risk_students'] as List)
          .map((e) => PdrStudent.fromJson(e))
          .toList(),
      recentAnalyses: (json['recent_analyses'] as List)
          .map((e) => EmotionalAnalysis.fromJson(e))
          .toList(),
      unreadMessages: json['unread_messages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pdr_expert': pdrExpert.toJson(),
      'statistics': statistics.toJson(),
      'high_risk_students': highRiskStudents.map((e) => e.toJson()).toList(),
      'recent_analyses': recentAnalyses.map((e) => e.toJson()).toList(),
      'unread_messages': unreadMessages,
    };
  }
}

class PdrStatistics {
  final int totalStudents;
  final int totalQuestions;
  final int totalAnswers;
  final int totalAnalyses;
  final int highRiskCount;
  final int pendingReview;

  PdrStatistics({
    required this.totalStudents,
    required this.totalQuestions,
    required this.totalAnswers,
    required this.totalAnalyses,
    required this.highRiskCount,
    required this.pendingReview,
  });

  factory PdrStatistics.fromJson(Map<String, dynamic> json) {
    return PdrStatistics(
      totalStudents: json['total_students'],
      totalQuestions: json['total_questions'],
      totalAnswers: json['total_answers'],
      totalAnalyses: json['total_analyses'],
      highRiskCount: json['high_risk_count'],
      pendingReview: json['pending_review'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_students': totalStudents,
      'total_questions': totalQuestions,
      'total_answers': totalAnswers,
      'total_analyses': totalAnalyses,
      'high_risk_count': highRiskCount,
      'pending_review': pendingReview,
    };
  }
}
