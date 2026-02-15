/// Application Configuration
/// 
/// This file contains sensitive configuration values.
/// DO NOT commit actual values to GitHub!
/// 
/// For local development, you can:
/// 1. Set environment variables in your IDE or CI/CD pipeline
/// 2. Or create a local_config.dart file (already gitignored)
/// 
/// Example for local_config.dart:
/// Copy the content from local_config.dart.example and fill in your values
/// 
/// For CI/CD, you can set environment variables:
/// - SUPABASE_URL
/// - SUPABASE_ANON_KEY
/// - ADMIN_PIN
/// - GEMINI_API_KEY

import 'dart:io';

// Default LocalConfig with empty values - users can override by creating local_config.dart
class _DefaultLocalConfig {
  static const String supabaseUrl = '';
  static const String supabaseAnonKey = '';
  static const String adminPin = '';
  static const String geminiApiKey = '';
}

// Type alias for LocalConfig - will use _DefaultLocalConfig if local_config.dart doesn't exist
typedef LocalConfig = _DefaultLocalConfig;

// Helper to get environment variable
String _getEnv(String key) {
  return Platform.environment[key] ?? '';
}

class AppConfig {
  // ============================================
  // SUPABASE CONFIGURATION
  // ============================================
  
  /// Supabase Project URL
  /// Set via environment variable: SUPABASE_URL
  /// Or create local_config.dart with LocalConfig.supabaseUrl
  static String get supabaseUrl {
    // First try environment variable
    final envValue = _getEnv('SUPABASE_URL');
    if (envValue.isNotEmpty) return envValue;
    
    // Fallback to local_config
    return LocalConfig.supabaseUrl;
  }
  
  /// Supabase Anonymous Key
  /// Set via environment variable: SUPABASE_ANON_KEY
  /// Or create local_config.dart with LocalConfig.supabaseAnonKey
  static String get supabaseAnonKey {
    // First try environment variable
    final envValue = _getEnv('SUPABASE_ANON_KEY');
    if (envValue.isNotEmpty) return envValue;
    
    // Fallback to local_config
    return LocalConfig.supabaseAnonKey;
  }
  
  // ============================================
  // ADMIN PIN CONFIGURATION
  // ============================================
  
  /// Admin PIN - Only for owner's access
  /// Set via environment variable: ADMIN_PIN
  /// Or create local_config.dart with LocalConfig.adminPin
  static String get adminPin {
    // First try environment variable
    final envValue = _getEnv('ADMIN_PIN');
    if (envValue.isNotEmpty) return envValue;
    
    // Fallback to local_config
    return LocalConfig.adminPin;
  }
  
  // ============================================
  // GEMINI AI CONFIGURATION
  // ============================================
  
  /// Gemini API Key for AI features
  /// Set via environment variable: GEMINI_API_KEY
  /// Or create local_config.dart with LocalConfig.geminiApiKey
  static String get geminiApiKey {
    // First try environment variable
    final envValue = _getEnv('GEMINI_API_KEY');
    if (envValue.isNotEmpty) return envValue;
    
    // Fallback to local_config
    return LocalConfig.geminiApiKey;
  }
  
  // ============================================
  // CONFIGURATION CHECKS
  // ============================================
  
  /// Check if Supabase is properly configured
  static bool get isSupabaseConfigured {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
  
  /// Check if AI features are properly configured
  static bool get isAiConfigured {
    return geminiApiKey.isNotEmpty;
  }
  
  /// Check if admin access is configured
  static bool get isAdminConfigured {
    return adminPin.isNotEmpty;
  }
}
