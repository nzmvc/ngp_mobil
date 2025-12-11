class AdminTeacher {
  final int id;
  final String fullName;
  final String username;
  final String email;
  final String? profilePicUrl;
  final int gender;
  final String? telephone;
  final String? sube;
  final int totalCourses;
  final int totalStudents;

  AdminTeacher({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.profilePicUrl,
    required this.gender,
    this.telephone,
    this.sube,
    required this.totalCourses,
    required this.totalStudents,
  });

  factory AdminTeacher.fromJson(Map<String, dynamic> json) {
    return AdminTeacher(
      id: json['id'],
      fullName: json['full_name'],
      username: json['username'],
      email: json['email'],
      profilePicUrl: json['profile_pic_url'],
      gender: json['gender'],
      telephone: json['telephone'],
      sube: json['sube'],
      totalCourses: json['total_courses'],
      totalStudents: json['total_students'],
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
      'telephone': telephone,
      'sube': sube,
      'total_courses': totalCourses,
      'total_students': totalStudents,
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
