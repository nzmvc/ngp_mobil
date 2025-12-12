class Child {
  final int id;
  final String fullName;
  final String username;
  final String? email;
  final String? profilePicUrl;
  final int? gender;  // Changed from String to int (API returns 0/1)
  final String? school;
  final String? birthday;
  final int? age;
  final ChildStats? stats;

  Child({
    required this.id,
    required this.fullName,
    required this.username,
    this.email,
    this.profilePicUrl,
    this.gender,
    this.school,
    this.birthday,
    this.age,
    this.stats,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      profilePicUrl: json['profile_pic_url'],
      gender: json['gender'] as int?,  // Cast to int
      school: json['school'],
      birthday: json['birthday'],
      age: json['age'] as int?,
      stats: json['stats'] != null ? ChildStats.fromJson(json['stats']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'email': email,
      'profile_pic_url': profilePicUrl,
      'gender': gender,
      'school': school,
      'birthday': birthday,
      'age': age,
      'stats': stats?.toJson(),
    };
  }

  String get genderDisplay {
    if (gender == 'male') return 'Erkek';
    if (gender == 'female') return 'Kız';
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
}

class ChildStats {
  final int totalSessions;
  final int totalRollcalls;
  final int totalAbsences;
  final int totalAssignments;
  final int pendingAssignments;
  final int completedAssignments;
  final int totalPayments;

  ChildStats({
    required this.totalSessions,
    required this.totalRollcalls,
    required this.totalAbsences,
    required this.totalAssignments,
    required this.pendingAssignments,
    required this.completedAssignments,
    required this.totalPayments,
  });

  factory ChildStats.fromJson(Map<String, dynamic> json) {
    return ChildStats(
      totalSessions: json['total_sessions'] ?? 0,
      totalRollcalls: json['total_rollcalls'] ?? 0,
      totalAbsences: json['total_absences'] ?? 0,
      totalAssignments: json['total_assignments'] ?? 0,
      pendingAssignments: json['pending_assignments'] ?? 0,
      completedAssignments: json['completed_assignments'] ?? 0,
      totalPayments: json['total_payments'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sessions': totalSessions,
      'total_rollcalls': totalRollcalls,
      'total_absences': totalAbsences,
      'total_assignments': totalAssignments,
      'pending_assignments': pendingAssignments,
      'completed_assignments': completedAssignments,
      'total_payments': totalPayments,
    };
  }

  double get attendanceRate {
    if (totalSessions == 0) return 0.0;
    return (totalRollcalls / totalSessions) * 100;
  }
}
