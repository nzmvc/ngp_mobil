class AssignmentGrade {
  final int score;
  final int maxScore;
  final double percentage;
  final DateTime? gradedDate;

  AssignmentGrade({
    required this.score,
    required this.maxScore,
    required this.percentage,
    this.gradedDate,
  });

  factory AssignmentGrade.fromJson(Map<String, dynamic> json) {
    return AssignmentGrade(
      score: json['score'] ?? 0,
      maxScore: json['max_score'] ?? 100,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      gradedDate: json['graded_date'] != null
          ? DateTime.parse(json['graded_date'])
          : null,
    );
  }
}

class Assignment {
  final int id;
  final String title;
  final String? description;
  final String? homeworkType; // assignment, project, research, practice, quiz, reading, presentation
  final String? difficulty; // easy, medium, hard
  final DateTime? dueDate;
  final String status; // pending, submitted, graded, late, missing
  final String? statusDisplay; // Turkish display name
  final bool isOverdue;
  final int? daysRemaining;
  final String? courseName;
  final String? lessonName;
  final DateTime? submissionDate;
  final bool hasSubmission;
  final AssignmentGrade? grade;
  final String? feedback;
  final DateTime? assignedDate;
  final bool isSeen;

  Assignment({
    required this.id,
    required this.title,
    this.description,
    this.homeworkType,
    this.difficulty,
    this.dueDate,
    required this.status,
    this.statusDisplay,
    required this.isOverdue,
    this.daysRemaining,
    this.courseName,
    this.lessonName,
    this.submissionDate,
    required this.hasSubmission,
    this.grade,
    this.feedback,
    this.assignedDate,
    required this.isSeen,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      homeworkType: json['homework_type'],
      difficulty: json['difficulty'],
      dueDate: json['due_date'] != null 
        ? DateTime.parse(json['due_date']) 
        : null,
      status: json['status'] ?? 'pending',
      statusDisplay: json['status_display'],
      isOverdue: json['is_overdue'] ?? false,
      daysRemaining: json['days_remaining'],
      courseName: json['course_name'],
      lessonName: json['lesson_name'],
      submissionDate: json['submission_date'] != null
          ? DateTime.parse(json['submission_date'])
          : null,
      hasSubmission: json['has_submission'] ?? false,
      grade: json['grade'] != null 
          ? AssignmentGrade.fromJson(json['grade']) 
          : null,
      feedback: json['feedback'],
      assignedDate: json['assigned_date'] != null
          ? DateTime.parse(json['assigned_date'])
          : null,
      isSeen: json['is_seen'] ?? true,
    );
  }

  bool get isDueSoon {
    if (daysRemaining == null) return false;
    return daysRemaining! <= 3 && daysRemaining! > 0 && status == 'pending';
  }

  String get homeworkTypeDisplay {
    switch (homeworkType) {
      case 'assignment':
        return 'Ödev';
      case 'project':
        return 'Proje';
      case 'research':
        return 'Araştırma';
      case 'practice':
        return 'Alıştırma';
      case 'quiz':
        return 'Quiz';
      case 'reading':
        return 'Okuma';
      case 'presentation':
        return 'Sunum';
      default:
        return 'Ödev';
    }
  }

  String get difficultyDisplay {
    switch (difficulty) {
      case 'easy':
        return 'Kolay';
      case 'medium':
        return 'Orta';
      case 'hard':
        return 'Zor';
      default:
        return 'Orta';
    }
  }
}
