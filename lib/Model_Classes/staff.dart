import 'user.dart';
import 'hospital.dart';


enum StaffType { nurse, receptionist, technician, pharmacist, administrator }

class Staff extends User {
  final String staffId;
  final StaffType staffType;
  final String department;
  final Hospital hospital;
  final String shift;
  final DateTime joiningDate;

  Staff({
    required this.staffId,
    required super.userId,
    required super.email,
    required super.passwordHash,
    required super.fullName,
    required super.phoneNumber,
    required super.createdAt,
    required this.staffType,
    required this.department,
    required this.hospital,
    required this.shift,
    required this.joiningDate,
    super.isActive,
  }) : super(role: UserRole.staff);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'staffId': staffId,
      'staffType': staffType.toString(),
      'department': department,
      'hospital': hospital.toJson(),
      'shift': shift,
      'joiningDate': joiningDate.toIso8601String(),
    };
  }

  factory Staff.fromJson(Map<dynamic, dynamic> json) {
    return Staff(
      staffId: json['staffId'],
      userId: json['userId'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      staffType: StaffType.values.firstWhere((e) => e.toString() == json['staffType']),
      department: json['department'],
      hospital: Hospital.fromJson(json['hospital']),
      shift: json['shift'],
      joiningDate: DateTime.parse(json['joiningDate']),
      isActive: json['isActive'] ?? true,
    );
  }
}
