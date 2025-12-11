class PdrExpert {
  final int id;
  final String fullName;
  final String username;
  final String email;
  final String? profilePicUrl;
  final String? specialization;

  PdrExpert({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.profilePicUrl,
    this.specialization,
  });

  factory PdrExpert.fromJson(Map<String, dynamic> json) {
    return PdrExpert(
      id: json['id'],
      fullName: json['full_name'],
      username: json['username'],
      email: json['email'],
      profilePicUrl: json['profile_pic_url'],
      specialization: json['specialization'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'email': email,
      'profile_pic_url': profilePicUrl,
      'specialization': specialization,
    };
  }

  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'P';
  }
}
