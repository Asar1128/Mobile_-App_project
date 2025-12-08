import 'SupabaseService.dart';

class MedicalRecordDBLayer {
  // Minimal stub - implement specific methods when tables/fields are known
  final _db = SupabaseService.instance.client;

  Future<List<Map<String, dynamic>>> fetchRecordsForPatient(
    String patientId,
  ) async {
    final res = await _db
        .from('medical_records')
        .select()
        .eq('patientId', patientId)
        .execute();
    if (res.data == null) throw Exception('Failed to fetch records');
    return List<Map<String, dynamic>>.from(res.data as List<dynamic>);
  }
}
