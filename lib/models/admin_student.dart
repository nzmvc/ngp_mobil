class AdminStudent {
  final int id;
  final String fullName;
  final String username;
  final String email;
  final String? profilePicUrl;
  final int gender;
  final String? school;
  final String? birthday;
  final int age;
  final String? telephone;
  final int totalCourses;
  final int totalHomeworks;
  final double attendanceRate;

  AdminStudent({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.profilePicUrl,
    required this.gender,
    this.school,
    this.birthday,
    required this.age,
    this.telephone,
    required this.totalCourses,
    required this.totalHomeworks,
    required this.attendanceRate,
  });

  factory AdminStudent.fromJson(Map<String, dynamic> json) {
    return AdminStudent(
      id: json['id'],
      fullName: json['full_name'],
      username: json['username'],
      email: json['email'],
      profilePicUrl: json['profile_pic_url'],
      gender: json['gender'],
      school: json['school'],
      birthday: json['birthday'],
      age: json['age'],
      telephone: json['telephone'],
      totalCourses: json['total_courses'],
      totalHomeworks: json['total_homeworks'],
      attendanceRate: (json['attendance_rate'] ?? 0.0).toDouble(),
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
      'telephone': telephone,
      'total_courses': totalCourses,
      'total_homeworks': totalHomeworks,
      'attendance_rate': attendanceRate,
    };
  }

  String get genderDisplay {
    switch (gender) {
      case 1:
        return 'Erkek';
      case 2:
        return 'Kadın';
      default:
        return 'Belirtilmemiş';
    }
  }
}
