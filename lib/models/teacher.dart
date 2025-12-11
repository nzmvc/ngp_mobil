class Teacher {
  final int id;
  final String fullName;
  final String username;
  final String email;
  final String? profilePicUrl;
  final String? sube;

  Teacher({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.profilePicUrl,
    this.sube,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profilePicUrl: json['profile_pic_url'],
      sube: json['sube'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'email': email,
      'profile_pic_url': profilePicUrl,
      'sube': sube,
    };
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
