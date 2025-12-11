class EmotionalAnalysis {
  final int id;
  final String studentName;
  final String week;
  final String weekDisplay;
  final int? weekNumber;
  final int? year;
  final String emotion;
  final String emotionDisplay;
  final String riskLevel;
  final String riskLevelDisplay;
  final String? aiComment;
  final String? strengths;
  final String? concerns;
  final String? recommendations;
  final int totalAnswers;
  final int positiveAnswers;
  final int negativeAnswers;
  final bool expertReviewed;
  final String? expertNotes;
  final String? expertActionTaken;
  final bool parentNotified;

  EmotionalAnalysis({
    required this.id,
    required this.studentName,
    required this.week,
    required this.weekDisplay,
    this.weekNumber,
    this.year,
    required this.emotion,
    required this.emotionDisplay,
    required this.riskLevel,
    required this.riskLevelDisplay,
    this.aiComment,
    this.strengths,
    this.concerns,
    this.recommendations,
    required this.totalAnswers,
    required this.positiveAnswers,
    required this.negativeAnswers,
    required this.expertReviewed,
    this.expertNotes,
    this.expertActionTaken,
    required this.parentNotified,
  });

  factory EmotionalAnalysis.fromJson(Map<String, dynamic> json) {
    return EmotionalAnalysis(
      id: json['id'],
      studentName: json['student_name'],
      week: json['week'],
      weekDisplay: json['week_display'],
      weekNumber: json['week_number'],
      year: json['year'],
      emotion: json['emotion'],
      emotionDisplay: json['emotion_display'],
      riskLevel: json['risk_level'],
      riskLevelDisplay: json['risk_level_display'],
      aiComment: json['ai_comment'],
      strengths: json['strengths'],
      concerns: json['concerns'],
      recommendations: json['recommendations'],
      totalAnswers: json['total_answers'],
      positiveAnswers: json['positive_answers'],
      negativeAnswers: json['negative_answers'],
      expertReviewed: json['expert_reviewed'],
      expertNotes: json['expert_notes'],
      expertActionTaken: json['expert_action_taken'],
      parentNotified: json['parent_notified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'week': week,
      'week_display': weekDisplay,
      'week_number': weekNumber,
      'year': year,
      'emotion': emotion,
      'emotion_display': emotionDisplay,
      'risk_level': riskLevel,
      'risk_level_display': riskLevelDisplay,
      'ai_comment': aiComment,
      'strengths': strengths,
      'concerns': concerns,
      'recommendations': recommendations,
      'total_answers': totalAnswers,
      'positive_answers': positiveAnswers,
      'negative_answers': negativeAnswers,
      'expert_reviewed': expertReviewed,
      'expert_notes': expertNotes,
      'expert_action_taken': expertActionTaken,
      'parent_notified': parentNotified,
    };
  }
}
