enum UserRole { doctor, staff, patient, admin }

class User {
  final String userId;
  final String email;
  final String passwordHash;
  final String fullName;
  final String phoneNumber;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;

  User({
    required this.userId,
    required this.email,
    required this.passwordHash,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'passwordHash': passwordHash,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role.toString(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      userId: json['userId'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      role: UserRole.values.firstWhere((e) => e.toString() == json['role']),
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
    );
  }
}