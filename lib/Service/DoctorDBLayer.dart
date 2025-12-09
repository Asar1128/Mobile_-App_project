import 'package:supabase_flutter/supabase_flutter.dart';
import 'SupabaseService.dart';

class DoctorDBLayer {
  final SupabaseClient _client = SupabaseService.instance.client;

  Future<String?> getCurrentDoctorId() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('doctors')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();
    return row?['id'] as String?;
  }

  Future<List<Map<String, dynamic>>> listUpcomingAppointmentsForDoctor({
    int limit = 10,
  }) async {
    final did = await getCurrentDoctorId();
    if (did == null) return [];
    final rows =
        await _client
                .from('appointments')
                .select(
                  'id, scheduled_at, patient:patients(id, user:users(full_name))',
                )
                .eq('doctor_id', did)
                .gte('scheduled_at', DateTime.now().toIso8601String())
                .order('scheduled_at', ascending: true)
                .limit(limit)
            as List<dynamic>;
    return rows.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> listDoctorPatients() async {
    final did = await getCurrentDoctorId();
    if (did == null) return [];
    final rows =
        await _client
                .from('appointments')
                .select('patient:patients(id, user:users(full_name))')
                .eq('doctor_id', did)
            as List<dynamic>;
    final patients = <String, Map<String, dynamic>>{};
    for (final r in rows) {
      final p = r['patient'] as Map<String, dynamic>?;
      if (p == null) continue;
      patients[p['id'] as String] = p;
    }
    return patients.values.toList();
  }

  Future<Map<String, dynamic>?> ensureDoctorProfile(
    Map<String, dynamic> payload,
  ) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final existing = await _client
        .from('doctors')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();
    if (existing != null) return existing;
    final insert = {'user_id': user.id, ...payload};
    final res = await _client
        .from('doctors')
        .insert(insert)
        .select()
        .maybeSingle();
    return res;
  }

  Future<List<Map<String, dynamic>>> listMedicalRecordsForDoctor(
    String patientId,
  ) async {
    final did = await getCurrentDoctorId();
    if (did == null) return [];
    final rows =
        await _client
                .from('medical_records')
                .select('id, title, notes, created_at, patient_id')
                .eq('doctor_id', did)
                .eq('patient_id', patientId)
                .order('created_at', ascending: false)
            as List<dynamic>;
    return rows.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> upsertMedicalRecord({
    required String patientId,
    String? recordId,
    required String title,
    String? notes,
  }) async {
    final did = await getCurrentDoctorId();
    if (did == null) return null;
    if (recordId == null) {
      final res = await _client
          .from('medical_records')
          .insert({
            'doctor_id': did,
            'patient_id': patientId,
            'title': title,
            'notes': notes,
          })
          .select()
          .maybeSingle();
      return res;
    } else {
      final res = await _client
          .from('medical_records')
          .update({'title': title, 'notes': notes})
          .eq('id', recordId)
          .eq('doctor_id', did)
          .select()
          .maybeSingle();
      return res;
    }
  }

  Future<List<Map<String, dynamic>>> listPrescriptionsForDoctor(
    String patientId,
  ) async {
    final did = await getCurrentDoctorId();
    if (did == null) return [];
    final rows =
        await _client
                .from('prescriptions')
                .select(
                  'id, medicine_name, dosage, frequency, instructions, start_date, end_date, patient_id',
                )
                .eq('doctor_id', did)
                .eq('patient_id', patientId)
                .order('start_date', ascending: false)
            as List<dynamic>;
    return rows.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> upsertPrescription({
    required String patientId,
    String? prescriptionId,
    required Map<String, dynamic> data,
  }) async {
    final did = await getCurrentDoctorId();
    if (did == null) return null;
    final body = {'doctor_id': did, 'patient_id': patientId, ...data};
    if (prescriptionId == null) {
      return await _client
          .from('prescriptions')
          .insert(body)
          .select()
          .maybeSingle();
    } else {
      return await _client
          .from('prescriptions')
          .update(body)
          .eq('id', prescriptionId)
          .eq('doctor_id', did)
          .select()
          .maybeSingle();
    }
  }
}
