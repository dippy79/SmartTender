import 'package:supabase_flutter/supabase_flutter.dart';

/// Use this to access Supabase client anywhere in the app
/// Supabase is initialized ONCE in main.dart via AppConfig + .env
class SupabaseClientHelper {
  SupabaseClientHelper._();
  static SupabaseClient get client => Supabase.instance.client;
}
