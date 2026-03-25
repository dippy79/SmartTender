import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? '';

  static String get adminPin =>
      dotenv.env['ADMIN_PIN'] ?? '';

  static String get bypassCode =>
      dotenv.env['BYPASS_CODE'] ?? '';

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get isAiConfigured => geminiApiKey.isNotEmpty;

  static bool get isAdminConfigured => adminPin.isNotEmpty;
}

