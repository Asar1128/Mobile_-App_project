import 'user.dart';
import 'hospital.dart';
import 'medical_record.dart';

enum BloodGroup { APositive, ANegative, BPositive, BNegative, OPositive, ONegative, ABPositive, ABNegative }

class Patient extends User {
  final String patientId;
  final DateTime dateOfBirth;
  final String gender;
  final BloodGroup bloodGroup;
  final String address;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final Hospital hospital;
  final String assignedDoctorId; // Reference to doctor
  final List<MedicalRecord> medicalRecords;
  final DateTime registrationDate;
  final String? insuranceNumber;
  final String? allergies; // Important for medical safety
  final String? chronicDiseases;

  Patient({
    required this.patientId,
    required super.userId,
    required super.email,
    required super.passwordHash,
    required super.fullName,
    required super.phoneNumber,
    required super.createdAt,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.address,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.hospital,
    required this.assignedDoctorId,
    required this.medicalRecords,
    required this.registrationDate,
    this.insuranceNumber,
    this.allergies,
    this.chronicDiseases,
    super.isActive,
  }) : super(role: UserRole.patient);

  // Generate QR code data - just the patientId!
  String get qrData => patientId;

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'patientId': patientId,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'bloodGroup': bloodGroup.toString(),
      'address': address,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'hospital': hospital.toJson(),
      'assignedDoctorId': assignedDoctorId,
      'medicalRecords': medicalRecords.map((r) => r.toJson()).toList(),
      'registrationDate': registrationDate.toIso8601String(),
      'insuranceNumber': insuranceNumber,
      'allergies': allergies,
      'chronicDiseases': chronicDiseases,
    };
  }

  factory Patient.fromJson(Map<dynamic, dynamic> json) {
    return Patient(
      patientId: json['patientId'],
      userId: json['userId'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      bloodGroup: BloodGroup.values.firstWhere((e) => e.toString() == json['bloodGroup']),
      address: json['address'],
      emergencyContactName: json['emergencyContactName'],
      emergencyContactPhone: json['emergencyContactPhone'],
      hospital: Hospital.fromJson(json['hospital']),
      assignedDoctorId: json['assignedDoctorId'],
      medicalRecords: (json['medicalRecords'] as List<dynamic>)
          .map((r) => MedicalRecord.fromJson(r))
          .toList(),
      registrationDate: DateTime.parse(json['registrationDate']),
      insuranceNumber: json['insuranceNumber'],
      allergies: json['allergies'],
      chronicDiseases: json['chronicDiseases'],
      isActive: json['isActive'] ?? true,
    );
  }
}
