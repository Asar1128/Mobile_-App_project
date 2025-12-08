class Medicine {
  final String medicineName;
  final String dosage;
  final String frequency;
  final int durationDays;
  final String instructions;

  Medicine({
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.durationDays,
    required this.instructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicineName': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'durationDays': durationDays,
      'instructions': instructions,
    };
  }

  factory Medicine.fromJson(Map<dynamic, dynamic> json) {
    return Medicine(
      medicineName: json['medicineName'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      durationDays: json['durationDays'],
      instructions: json['instructions'],
    );
  }
}