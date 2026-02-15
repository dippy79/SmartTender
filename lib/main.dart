import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';

// Global Variables jo memory mein user choice save rakhenge
ValueNotifier<Color> appThemeColor = ValueNotifier(const Color(0xFF1A237E));
ValueNotifier<String> appLuckyNumber = ValueNotifier("7");
bool isSystemAdmin = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase with credentials from AppConfig
  // Set via environment variables or local_config.dart
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Storage se User Choice load karna
  final prefs = await SharedPreferences.getInstance();
  int? savedColor = prefs.getInt('app_color');
  if (savedColor != null) appThemeColor.value = Color(savedColor);
  appLuckyNumber.value = prefs.getString('app_number') ?? "7";

  runApp(const SmartTenderApp());
}

class SmartTenderApp extends StatelessWidget {
  const SmartTenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: appThemeColor,
      builder: (context, themeColor, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: themeColor,
            colorScheme: ColorScheme.fromSeed(seedColor: themeColor, brightness: Brightness.light),
            useMaterial3: true,
          ),
          home: (Supabase.instance.client.auth.currentUser == null && !isSystemAdmin)
              ? RegistrationScreen() : const HomeScreen(),
        );
      },
    );
  }
}