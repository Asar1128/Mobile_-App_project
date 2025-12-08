import 'package:supabase_flutter/supabase_flutter.dart';
import 'SupabaseService.dart';
import '../Model_Classes/doctor.dart';

class DoctorDBLayer {
  final SupabaseClient _db = SupabaseService.instance.client;

  Future<List<Doctor>> fetchAllDoctors() async {
    final res = await _db.from('doctors').select().execute();
    if (res.data == null) throw Exception('Failed to fetch doctors');
    final data = res.data as List<dynamic>;
    return data.map((e) => Doctor.fromJson(e as Map)).toList();
  }

  Future<void> createDoctor(Map<String, dynamic> doctor) async {
    final res = await _db.from('doctors').insert(doctor).execute();
    if (res.data == null) throw Exception('Failed to create doctor');
  }
}
