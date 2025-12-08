class Visit {
  final String visitId;
  final String patientId;
  final String doctorId;
  final DateTime visitDate;
  final String chiefComplaint;
  final String symptoms;
  final String diagnosis;
  final String treatmentGiven;
  final String vitalSigns;
  final double consultationFee;
  final bool isPaid;

  Visit({
    required this.visitId,
    required this.patientId,
    required this.doctorId,
    required this.visitDate,
    required this.chiefComplaint,
    required this.symptoms,
    required this.diagnosis,
    required this.treatmentGiven,
    required this.vitalSigns,
    required this.consultationFee,
    required this.isPaid,
  });

  Map<String, dynamic> toJson() {
    return {
      'visitId': visitId,
      'patientId': patientId,
      'doctorId': doctorId,
      'visitDate': visitDate.toIso8601String(),
      'chiefComplaint': chiefComplaint,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'treatmentGiven': treatmentGiven,
      'vitalSigns': vitalSigns,
      'consultationFee': consultationFee,
      'isPaid': isPaid,
    };
  }

  factory Visit.fromJson(Map<dynamic, dynamic> json) {
    return Visit(
      visitId: json['visitId'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      visitDate: DateTime.parse(json['visitDate']),
      chiefComplaint: json['chiefComplaint'],
      symptoms: json['symptoms'],
      diagnosis: json['diagnosis'],
      treatmentGiven: json['treatmentGiven'],
      vitalSigns: json['vitalSigns'],
      consultationFee: json['consultationFee'].toDouble(),
      isPaid: json['isPaid'],
    );
  }
}