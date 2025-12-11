class SystemUser {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String userType;
  final bool isActive;
  final String dateJoined;

  SystemUser({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.userType,
    required this.isActive,
    required this.dateJoined,
  });

  factory SystemUser.fromJson(Map<String, dynamic> json) {
    return SystemUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: json['full_name'],
      userType: json['user_type'],
      isActive: json['is_active'],
      dateJoined: json['date_joined'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'user_type': userType,
      'is_active': isActive,
      'date_joined': dateJoined,
    };
  }

  String get userTypeDisplay {
    switch (userType) {
      case 'student':
        return 'Öğrenci';
      case 'teacher':
        return 'Öğretmen';
      case 'parent':
        return 'Veli';
      case 'pdr':
        return 'PDR Uzmanı';
      case 'admin':
        return 'Yönetici';
      default:
        return userType;
    }
  }
}
