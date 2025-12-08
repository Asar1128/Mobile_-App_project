import 'package:supabase_flutter/supabase_flutter.dart';

class AuditDBLayer {
  final SupabaseClient client;
  AuditDBLayer(this.client);

  Future<void> log({
    required String actorUserId,
    required String action,
    required String entity,
    String? entityId,
    Map<String, dynamic>? details,
  }) async {
    await client.from('audit_logs').insert({
      'actor_user_id': actorUserId,
      'action': action,
      'entity': entity,
      'entity_id': entityId,
      'details': details,
    });
  }
}
