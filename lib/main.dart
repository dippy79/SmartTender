import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Supabase Init (Replace with your actual keys)
  await Supabase.initialize(
    url: 'https://your-project-url.supabase.co',
    anonKey: 'your-anon-key',
  );
  runApp(const SmartTenderApp());
}

class SmartTenderApp extends StatelessWidget {
  const SmartTenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Tender Futuristic',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617), // Deep Space Blue
        primarySwatch: Colors.cyan,
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}