import 'user.dart';
import 'hospital.dart';

class Doctor extends User {
  final String doctorId;
  final String specialization;
  final String qualification;
  final int experienceYears;
  final String licenseNumber;
  final Hospital hospital;
  final List<String> availableDays;
  final String consultationFee;

  Doctor({
    required this.doctorId,
    required super.userId,
    required super.email,
    required super.passwordHash,
    required super.fullName,
    required super.phoneNumber,
    required super.createdAt,
    required this.specialization,
    required this.qualification,
    required this.experienceYears,
    required this.licenseNumber,
    required this.hospital,
    required this.availableDays,
    required this.consultationFee,
    super.isActive,
  }) : super(role: UserRole.doctor);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'doctorId': doctorId,
      'specialization': specialization,
      'qualification': qualification,
      'experienceYears': experienceYears,
      'licenseNumber': licenseNumber,
      'hospital': hospital.toJson(),
      'availableDays': availableDays,
      'consultationFee': consultationFee,
    };
  }

  factory Doctor.fromJson(Map<dynamic, dynamic> json) {
    return Doctor(
      doctorId: json['doctorId'],
      userId: json['userId'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      specialization: json['specialization'],
      qualification: json['qualification'],
      experienceYears: json['experienceYears'],
      licenseNumber: json['licenseNumber'],
      hospital: Hospital.fromJson(json['hospital']),
      availableDays: List<String>.from(json['availableDays']),
      consultationFee: json['consultationFee'],
      isActive: json['isActive'] ?? true,
    );
  }
}