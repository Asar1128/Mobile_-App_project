import 'SupabaseService.dart';

class VisitDBLayer {
  final _db = SupabaseService.instance.client;

  Future<List<Map<String, dynamic>>> fetchVisitsForPatient(
    String patientId,
  ) async {
    final res = await _db
        .from('visits')
        .select()
        .eq('patientId', patientId)
        .execute();
    if (res.data == null) throw Exception('Failed to fetch visits');
    return List<Map<String, dynamic>>.from(res.data as List<dynamic>);
  }
}
