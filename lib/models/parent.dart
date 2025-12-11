class Parent {
  final int id;
  final String fullName;
  final String username;
  final String email;
  final String? telephone;
  final String? profilePicUrl;

  Parent({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.telephone,
    this.profilePicUrl,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'],
      profilePicUrl: json['profile_pic_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'email': email,
      'telephone': telephone,
      'profile_pic_url': profilePicUrl,
    };
  }
}
