import 'package:supabase_flutter/supabase_flutter.dart';

class MedicalRecordDBLayer2 {
  final SupabaseClient client;
  MedicalRecordDBLayer2(this.client);

  Future<String> createRecord({
    required String patientId,
    required String doctorId,
    required String hospitalId,
    String? visitId,
    required String title,
    String? description,
    Map<String, dynamic>? attachments,
    String? actorUserId,
  }) async {
    final res = await client
        .from('medical_records')
        .insert({
          'patient_id': patientId,
          'doctor_id': doctorId,
          'hospital_id': hospitalId,
          'visit_id': visitId,
          'title': title,
          'description': description,
          'attachments': attachments,
          'status': 'pending',
        })
        .select('id')
        .single();
    final id = res['id'] as String;
    if (actorUserId != null) {
      await client.from('audit_logs').insert({
        'actor_user_id': actorUserId,
        'action': 'create',
        'entity': 'medical_record',
        'entity_id': id,
        'details': {
          'patient_id': patientId,
          'doctor_id': doctorId,
          'hospital_id': hospitalId,
          'visit_id': visitId,
          'title': title,
        },
      });
    }
    return id;
  }

  Future<void> verifyRecord({
    required String recordId,
    required String staffId,
    required bool approved,
  }) async {
    await client
        .from('medical_records')
        .update({
          'status': approved ? 'verified' : 'rejected',
          'verified_by': staffId,
          'verified_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', recordId);
    await client.from('audit_logs').insert({
      'actor_user_id': staffId,
      'action': approved ? 'verify' : 'reject',
      'entity': 'medical_record',
      'entity_id': recordId,
    });
  }

  Future<List<Map<String, dynamic>>> getPatientRecords(String patientId) async {
    final res = await client
        .from('medical_records')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false);
    return (res as List).cast<Map<String, dynamic>>();
  }
}
