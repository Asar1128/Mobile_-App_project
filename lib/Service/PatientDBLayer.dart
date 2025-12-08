import 'package:supabase_flutter/supabase_flutter.dart';
import 'SupabaseService.dart';
import '../Model_Classes/patient.dart';

class PatientDBLayer {
  final SupabaseClient _db = SupabaseService.instance.client;

  Future<List<Patient>> fetchAllPatients() async {
    final res = await _db.from('patients').select().execute();
    if (res.data == null) throw Exception('Failed to fetch patients');
    final data = res.data as List<dynamic>;
    return data.map((e) => Patient.fromJson(e as Map)).toList();
  }

  Future<void> createPatient(Map<String, dynamic> patient) async {
    final res = await _db.from('patients').insert(patient).execute();
    if (res.data == null) throw Exception('Failed to create patient');
  }

  Future<void> updatePatient(String id, Map<String, dynamic> patch) async {
    final res = await _db
        .from('patients')
        .update(patch)
        .eq('patientId', id)
        .execute();
    if (res.data == null) throw Exception('Failed to update patient');
  }

  Future<void> deletePatient(String id) async {
    final res = await _db
        .from('patients')
        .delete()
        .eq('patientId', id)
        .execute();
    if (res.data == null) throw Exception('Failed to delete patient');
  }
}
