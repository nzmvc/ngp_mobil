class PdrAnswer {
  final int id;
  final String studentName;
  final String questionText;
  final String questionCategory;
  final String? answerText;
  final String? emojiAnswer;
  final int? scaleAnswer;
  final bool aiAnalyzed;
  final String? sentiment;
  final String? sentimentDisplay;
  final String? riskLevel;
  final String? riskLevelDisplay;
  final String? aiComment;
  final bool isReviewed;
  final String? reviewedBy;
  final String? expertNotes;
  final String answeredDate;

  PdrAnswer({
    required this.id,
    required this.studentName,
    required this.questionText,
    required this.questionCategory,
    this.answerText,
    this.emojiAnswer,
    this.scaleAnswer,
    required this.aiAnalyzed,
    this.sentiment,
    this.sentimentDisplay,
    this.riskLevel,
    this.riskLevelDisplay,
    this.aiComment,
    required this.isReviewed,
    this.reviewedBy,
    this.expertNotes,
    required this.answeredDate,
  });

  factory PdrAnswer.fromJson(Map<String, dynamic> json) {
    return PdrAnswer(
      id: json['id'],
      studentName: json['student_name'],
      questionText: json['question_text'],
      questionCategory: json['question_category'],
      answerText: json['answer_text'],
      emojiAnswer: json['emoji_answer'],
      scaleAnswer: json['scale_answer'],
      aiAnalyzed: json['ai_analyzed'],
      sentiment: json['sentiment'],
      sentimentDisplay: json['sentiment_display'],
      riskLevel: json['risk_level'],
      riskLevelDisplay: json['risk_level_display'],
      aiComment: json['ai_comment'],
      isReviewed: json['is_reviewed'],
      reviewedBy: json['reviewed_by'],
      expertNotes: json['expert_notes'],
      answeredDate: json['answered_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'question_text': questionText,
      'question_category': questionCategory,
      'answer_text': answerText,
      'emoji_answer': emojiAnswer,
      'scale_answer': scaleAnswer,
      'ai_analyzed': aiAnalyzed,
      'sentiment': sentiment,
      'sentiment_display': sentimentDisplay,
      'risk_level': riskLevel,
      'risk_level_display': riskLevelDisplay,
      'ai_comment': aiComment,
      'is_reviewed': isReviewed,
      'reviewed_by': reviewedBy,
      'expert_notes': expertNotes,
      'answered_date': answeredDate,
    };
  }
}
