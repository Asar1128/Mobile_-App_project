enum TestType { bloodTest, xray, mri, ctScan, ultrasound, ecg, other }

class MedicalRecord {
  final String recordId;
  final String patientId;
  final TestType testType;
  final DateTime sampleDate;
  final DateTime resultDate;
  final String testDetails;
  final String results;
  final String conductedBy;
  final List<String> attachmentUrls;
  final String notes;

  MedicalRecord({
    required this.recordId,
    required this.patientId,
    required this.testType,
    required this.sampleDate,
    required this.resultDate,
    required this.testDetails,
    required this.results,
    required this.conductedBy,
    required this.attachmentUrls,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'recordId': recordId,
      'patientId': patientId,
      'testType': testType.toString(),
      'sampleDate': sampleDate.toIso8601String(),
      'resultDate': resultDate.toIso8601String(),
      'testDetails': testDetails,
      'results': results,
      'conductedBy': conductedBy,
      'attachmentUrls': attachmentUrls,
      'notes': notes,
    };
  }

  factory MedicalRecord.fromJson(Map<dynamic, dynamic> json) {
    return MedicalRecord(
      recordId: json['recordId'],
      patientId: json['patientId'],
      testType: TestType.values.firstWhere((e) => e.toString() == json['testType']),
      sampleDate: DateTime.parse(json['sampleDate']),
      resultDate: DateTime.parse(json['resultDate']),
      testDetails: json['testDetails'],
      results: json['results'],
      conductedBy: json['conductedBy'],
      attachmentUrls: List<String>.from(json['attachmentUrls']),
      notes: json['notes'],
    );
  }
}