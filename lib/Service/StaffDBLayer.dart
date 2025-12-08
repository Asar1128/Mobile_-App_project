import 'SupabaseService.dart';

class StaffDBLayer {
  final _db = SupabaseService.instance.client;

  Future<List<Map<String, dynamic>>> fetchAllStaff() async {
    final res = await _db.from('staff').select().execute();
    if (res.data == null) throw Exception('Failed to fetch staff');
    return List<Map<String, dynamic>>.from(res.data as List<dynamic>);
  }
}
