import 'package:supabase_flutter/supabase_flutter.dart';

class EmailService {
  final SupabaseClient client;
  EmailService(this.client);

  // Placeholder: Implement via Supabase Edge Functions or SMTP provider
  Future<void> sendEmail({
    required String to,
    required String subject,
    required String htmlBody,
  }) async {
    // For Supabase Edge Function, call via client.functions.invoke('send-email', ...)
    // await client.functions.invoke('send-email', body: {
    //   'to': to,
    //   'subject': subject,
    //   'html': htmlBody,
    // });
  }
}
