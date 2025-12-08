import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  SupabaseClient? _client;

  SupabaseService._internal();

  static SupabaseService get instance => _instance;

  SupabaseClient get client {
    if (_client == null) {
      throw StateError(
        'Supabase not initialized. Call SupabaseService.init() first.',
      );
    }
    return _client!;
  }

  /// Initialize Supabase. Call this once at app startup.
  static Future<void> init() async {
    if (_instance._client != null) return;
    await Supabase.initialize(
      url: SUPABASE_URL,
      anonKey: SUPABASE_ANON_KEY,
      // debug: true,
    );
    _instance._client = Supabase.instance.client;
  }

  /// Simple auth helpers
  Future<dynamic> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<dynamic> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
