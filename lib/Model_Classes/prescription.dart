import 'medicine.dart';

class Prescription {
  final String prescriptionId;
  final String patientId;
  final String doctorId;
  final DateTime prescriptionDate;
  final String diagnosis;
  final List<Medicine> medicines;
  final String additionalNotes;
  final DateTime? followUpDate;

  Prescription({
    required this.prescriptionId,
    required this.patientId,
    required this.doctorId,
    required this.prescriptionDate,
    required this.diagnosis,
    required this.medicines,
    required this.additionalNotes,
    this.followUpDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'prescriptionId': prescriptionId,
      'patientId': patientId,
      'doctorId': doctorId,
      'prescriptionDate': prescriptionDate.toIso8601String(),
      'diagnosis': diagnosis,
      'medicines': medicines.map((m) => m.toJson()).toList(),
      'additionalNotes': additionalNotes,
      'followUpDate': followUpDate?.toIso8601String(),
    };
  }

  factory Prescription.fromJson(Map<dynamic, dynamic> json) {
    return Prescription(
      prescriptionId: json['prescriptionId'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      prescriptionDate: DateTime.parse(json['prescriptionDate']),
      diagnosis: json['diagnosis'],
      medicines: (json['medicines'] as List<dynamic>)
          .map((m) => Medicine.fromJson(m))
          .toList(),
      additionalNotes: json['additionalNotes'],
      followUpDate: json['followUpDate'] != null 
          ? DateTime.parse(json['followUpDate']) 
          : null,
    );
  }
}