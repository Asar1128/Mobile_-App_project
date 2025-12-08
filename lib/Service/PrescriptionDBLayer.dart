import 'package:supabase_flutter/supabase_flutter.dart';

class PrescriptionDBLayer {
  final SupabaseClient client;
  PrescriptionDBLayer(this.client);

  Future<List<Map<String, dynamic>>> getPatientPrescriptions(
    String patientId,
  ) async {
    final res = await client
        .from('prescriptions')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false);
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<String> createPrescription({
    required String patientId,
    required String doctorId,
    required String hospitalId,
    String? visitId,
    required List<Map<String, dynamic>> items,
    String? actorUserId,
  }) async {
    final res = await client
        .from('prescriptions')
        .insert({
          'patient_id': patientId,
          'doctor_id': doctorId,
          'hospital_id': hospitalId,
          'visit_id': visitId,
          'items': items,
          'status': 'issued',
        })
        .select('id')
        .single();
    final id = res['id'] as String;
    if (actorUserId != null) {
      // audit log
      await client.from('audit_logs').insert({
        'actor_user_id': actorUserId,
        'action': 'create',
        'entity': 'prescription',
        'entity_id': id,
        'details': {
          'patient_id': patientId,
          'doctor_id': doctorId,
          'hospital_id': hospitalId,
          'visit_id': visitId,
          'items_count': items.length,
        },
      });
      // optional email hook placeholder
      // You can trigger an email via Edge Function here.
    }
    return id;
  }

  Future<void> updatePrescriptionItems({
    required String prescriptionId,
    required List<Map<String, dynamic>> items,
    String? actorUserId,
  }) async {
    await client
        .from('prescriptions')
        .update({
          'items': items,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', prescriptionId);
    if (actorUserId != null) {
      await client.from('audit_logs').insert({
        'actor_user_id': actorUserId,
        'action': 'update',
        'entity': 'prescription',
        'entity_id': prescriptionId,
        'details': {'items_count': items.length},
      });
    }
  }

  Future<void> markDispensed(
    String prescriptionId, {
    String? actorUserId,
  }) async {
    await client
        .from('prescriptions')
        .update({
          'status': 'dispensed',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', prescriptionId);
    if (actorUserId != null) {
      await client.from('audit_logs').insert({
        'actor_user_id': actorUserId,
        'action': 'dispense',
        'entity': 'prescription',
        'entity_id': prescriptionId,
      });
    }
  }
}
