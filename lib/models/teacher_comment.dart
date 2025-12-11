class TeacherComment {
  final int id;
  final String studentName;
  final String lessonSubject;
  final String sessionDate;
  final String date;
  final bool rollcall;
  final String rollcallDisplay;
  final String? descToStudent;
  final bool hasComment;

  TeacherComment({
    required this.id,
    required this.studentName,
    required this.lessonSubject,
    required this.sessionDate,
    required this.date,
    required this.rollcall,
    required this.rollcallDisplay,
    this.descToStudent,
    required this.hasComment,
  });

  factory TeacherComment.fromJson(Map<String, dynamic> json) {
    return TeacherComment(
      id: json['id'],
      studentName: json['student_name'] ?? '',
      lessonSubject: json['lesson_subject'] ?? '',
      sessionDate: json['session_date'] ?? '',
      date: json['date'] ?? '',
      rollcall: json['rollcall'] ?? false,
      rollcallDisplay: json['rollcall_display'] ?? '',
      descToStudent: json['desc_to_student'],
      hasComment: json['has_comment'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'lesson_subject': lessonSubject,
      'session_date': sessionDate,
      'date': date,
      'rollcall': rollcall,
      'rollcall_display': rollcallDisplay,
      'desc_to_student': descToStudent,
      'has_comment': hasComment,
    };
  }

  String get comment => descToStudent ?? '';
}
