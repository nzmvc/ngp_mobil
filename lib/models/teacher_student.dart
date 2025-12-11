class TeacherStudent {
  final int id;
  final String fullName;
  final String username;
  final String? profilePicUrl;
  final int? gender;
  final String? school;
  final String? birthday;
  final int? age;
  final int totalSessions;
  final double attendanceRate;
  final int pendingAssignments;

  TeacherStudent({
    required this.id,
    required this.fullName,
    required this.username,
    this.profilePicUrl,
    this.gender,
    this.school,
    this.birthday,
    this.age,
    required this.totalSessions,
    required this.attendanceRate,
    required this.pendingAssignments,
  });

  factory TeacherStudent.fromJson(Map<String, dynamic> json) {
    return TeacherStudent(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      profilePicUrl: json['profile_pic_url'],
      gender: json['gender'],
      school: json['school'],
      birthday: json['birthday'],
      age: json['age'],
      totalSessions: json['total_sessions'] ?? 0,
      attendanceRate: (json['attendance_rate'] ?? 0).toDouble(),
      pendingAssignments: json['pending_assignments'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'profile_pic_url': profilePicUrl,
      'gender': gender,
      'school': school,
      'birthday': birthday,
      'age': age,
      'total_sessions': totalSessions,
      'attendance_rate': attendanceRate,
      'pending_assignments': pendingAssignments,
    };
  }

  String get genderDisplay {
    if (gender == 1) return 'Erkek';
    if (gender == 0) return 'Kız';
    return 'Belirtilmemiş';
  }

  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return '?';
  }

  String get attendanceRateFormatted => '${attendanceRate.toStringAsFixed(1)}%';
}
