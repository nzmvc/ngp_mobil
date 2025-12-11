class AdminParent {
  final int id;
  final String fullName;
  final String username;
  final String email;
  final String? profilePicUrl;
  final int gender;
  final String? telephone;
  final String? job;
  final int totalChildren;

  AdminParent({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.profilePicUrl,
    required this.gender,
    this.telephone,
    this.job,
    required this.totalChildren,
  });

  factory AdminParent.fromJson(Map<String, dynamic> json) {
    return AdminParent(
      id: json['id'],
      fullName: json['full_name'],
      username: json['username'],
      email: json['email'],
      profilePicUrl: json['profile_pic_url'],
      gender: json['gender'],
      telephone: json['telephone'],
      job: json['job'],
      totalChildren: json['total_children'],
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
      'job': job,
      'total_children': totalChildren,
    };
  }

  String get genderDisplay {
    switch (gender) {
      case 0:
        return 'Kadın';
      case 1:
        return 'Erkek';
      default:
        return 'Belirtilmemiş';
    }
  }
}
