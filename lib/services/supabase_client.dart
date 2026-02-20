import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  static final SupabaseClient client = SupabaseClient(
    'https://crzfwshhxetnbkfxpssy.supabase.co', // Replace with your Supabase URL
    'sb_publishable_sRMu7lj4qZwIHxiiXAHLlA_UctBrKQy', // Replace with your anon/public key
  );
}
