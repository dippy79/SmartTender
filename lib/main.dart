import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'screens/registration_screen.dart';

Future<void> main() async {
  // 1. Mandatory initialization
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint(">>> APP INITIALIZING <<<");

  // Default Fallback Values
  String supabaseUrl = 'https://crzfwshhxetnbkfxpssy.supabase.co';
  String supabaseKey = 'sb_publishable_sRMu7lj4qZwIHxiiXAHLlA_UctBrKQy';

  try {
    // 2. Load .env file
    try {
      await dotenv.load(fileName: ".env");
      debugPrint("Environment loaded successfully");

      // Update values if found in .env
      supabaseUrl = dotenv.maybeGet('SUPABASE_URL') ?? supabaseUrl;
      supabaseKey = dotenv.maybeGet('SUPABASE_ANON_KEY') ?? supabaseKey;
    } catch (e) {
      debugPrint("Environment file (.env) not found. Proceeding with default settings.");
    }

    // 3. Initialize Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    debugPrint("Supabase ready");

  } catch (e) {
    debugPrint("Initialization Warning: $e");
  }

  // 4. Start Application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Tender Hub',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Safety Error Widget
      builder: (context, widget) {
        ErrorWidget.builder = (details) => Scaffold(
          body: Center(
            child: Text("UI Render Error: ${details.exception}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent)
            ),
          ),
        );
        return widget!;
      },

      home: const RegistrationScreen(),
    );
  }
}
