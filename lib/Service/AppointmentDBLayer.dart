import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentDBLayer {
  final SupabaseClient client;
  AppointmentDBLayer(this.client);

  Future<List<Map<String, dynamic>>> getPatientAppointments(
    String patientId,
  ) async {
    final res = await client
        .from('appointments')
        .select()
        .eq('patient_id', patientId)
        .order('scheduled_at');
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<String> requestAppointment({
    required String patientId,
    required String doctorId,
    required String hospitalId,
    required DateTime scheduledAt,
    required String createdByUserId,
  }) async {
    final res = await client
        .from('appointments')
        .insert({
          'patient_id': patientId,
          'doctor_id': doctorId,
          'hospital_id': hospitalId,
          'scheduled_at': scheduledAt.toIso8601String(),
          'status': 'requested',
          'created_by': createdByUserId,
        })
        .select('id')
        .single();
    final id = res['id'] as String;
    await client.from('audit_logs').insert({
      'actor_user_id': createdByUserId,
      'action': 'request',
      'entity': 'appointment',
      'entity_id': id,
      'details': {
        'patient_id': patientId,
        'doctor_id': doctorId,
        'hospital_id': hospitalId,
        'scheduled_at': scheduledAt.toIso8601String(),
      },
    });
    return id;
  }

  Future<void> approveAppointment(
    String appointmentId, {
    String? actorUserId,
  }) async {
    await client
        .from('appointments')
        .update({
          'status': 'approved',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', appointmentId);
    if (actorUserId != null) {
      await client.from('audit_logs').insert({
        'actor_user_id': actorUserId,
        'action': 'approve',
        'entity': 'appointment',
        'entity_id': appointmentId,
      });
    }
  }

  Future<void> cancelAppointment(
    String appointmentId, {
    String? actorUserId,
  }) async {
    await client
        .from('appointments')
        .update({
          'status': 'cancelled',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', appointmentId);
    if (actorUserId != null) {
      await client.from('audit_logs').insert({
        'actor_user_id': actorUserId,
        'action': 'cancel',
        'entity': 'appointment',
        'entity_id': appointmentId,
      });
    }
  }

  Future<void> rescheduleByPatient({
    required String appointmentId,
    required DateTime newDate,
    required String actorUserId,
    required DateTime originalScheduledAt,
  }) async {
    // 24h policy enforced at UI + server function/RLS; here we just write.
    await client
        .from('appointments')
        .update({
          'scheduled_at': newDate.toIso8601String(),
          'status': 'rescheduled',
          'last_reschedule_by': actorUserId,
          'last_reschedule_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', appointmentId);
    await client.from('audit_logs').insert({
      'actor_user_id': actorUserId,
      'action': 'reschedule_patient',
      'entity': 'appointment',
      'entity_id': appointmentId,
      'details': {
        'new_date': newDate.toIso8601String(),
        'original_scheduled_at': originalScheduledAt.toIso8601String(),
      },
    });
  }

  Future<void> rescheduleByStaff({
    required String appointmentId,
    required DateTime newDate,
    required String actorUserId,
  }) async {
    await client
        .from('appointments')
        .update({
          'scheduled_at': newDate.toIso8601String(),
          'status': 'rescheduled',
          'last_reschedule_by': actorUserId,
          'last_reschedule_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', appointmentId);
    await client.from('audit_logs').insert({
      'actor_user_id': actorUserId,
      'action': 'reschedule_staff',
      'entity': 'appointment',
      'entity_id': appointmentId,
      'details': {'new_date': newDate.toIso8601String()},
    });
  }
}
