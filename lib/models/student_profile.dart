class StudentProfile {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? profilePic;
  final int? gender; // 0: female, 1: male
  final String? school;
  final String? birthday;
  final int? age;
  final String? bio;
  final int achievementsCount;
  final int projectsCount;

  StudentProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.profilePic,
    this.gender,
    this.school,
    this.birthday,
    this.age,
    this.bio,
    required this.achievementsCount,
    required this.projectsCount,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return StudentProfile(
      id: json['id'] ?? 0,
      username: user['username'] ?? '',
      email: user['email'] ?? '',
      firstName: user['first_name'] ?? '',
      lastName: user['last_name'] ?? '',
      fullName: '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim(),
      profilePic: json['profile_pic'],
      gender: json['gender'] as int?,
      school: json['school'],
      birthday: json['birthday'],
      age: json['age'] as int?,
      bio: json['bio'],
      achievementsCount: json['achievements_count'] ?? 0,
      projectsCount: json['projects_count'] ?? 0,
    );
  }

  String get genderDisplay {
    if (gender == null) return 'Belirtilmemiş';
    return gender == 1 ? 'Erkek' : 'Kız';
  }

  String get formattedBirthday {
    if (birthday == null) return 'Belirtilmemiş';
    try {
      final date = DateTime.parse(birthday!);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return birthday!;
    }
  }
}
