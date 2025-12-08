enum AppointmentStatus { scheduled, completed, cancelled, noShow }

class Appointment {
  final String appointmentId;
  final String patientId;
  final String doctorId;
  final DateTime appointmentDate;
  final String timeSlot;
  final String reason;
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;

  Appointment({
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.timeSlot,
    required this.reason,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'timeSlot': timeSlot,
      'reason': reason,
      'status': status.toString(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Appointment.fromJson(Map<dynamic, dynamic> json) {
    return Appointment(
      appointmentId: json['appointmentId'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      appointmentDate: DateTime.parse(json['appointmentDate']),
      timeSlot: json['timeSlot'],
      reason: json['reason'],
      status: AppointmentStatus.values.firstWhere((e) => e.toString() == json['status']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
