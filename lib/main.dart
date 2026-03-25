import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/auth_screen.dart';
import 'presentation/screens/auth/registration_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/admin/admin_panel_screen.dart';
import 'presentation/screens/ai/ai_advisor_screen.dart';
import 'presentation/screens/boq/boq_calculator_screen.dart';
import 'presentation/screens/history/history_screen.dart';
import 'presentation/screens/import/tender_import_screen.dart';
import 'presentation/screens/tenders/tender_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env loaded");
  } catch (_) {
    debugPrint("⚠️ .env not found — add SUPABASE_URL etc.");
  }

  if (!AppConfig.isSupabaseConfigured) {
    debugPrint("❌ Supabase not configured!");
    runApp(const _ConfigErrorApp());
    return;
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  debugPrint("✅ Supabase ready");

  runApp(const SmartTenderApp());
}

class SmartTenderApp extends StatelessWidget {
  const SmartTenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SmartTender Hub',
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const _AuthGate(),
        routes: {
          '/dashboard': (_) => const DashboardScreen(),
          '/tenders':   (_) => const TenderListScreen(),
          '/boq':       (_) => const BoqCalculatorScreen(),
          '/history':   (_) => const HistoryScreen(),
          '/import':    (_) => const TenderImportScreen(),
          '/ai':        (_) => const AiAdvisorScreen(),
          '/admin':     (_) => const AdminPanelScreen(),
          '/auth':      (_) => const AuthScreen(),
          '/register':  (_) => const RegistrationScreen(),
        },
      ),
    );
  }
}

/// Routes user based on auth state
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.unknown:
        // Still loading role from Supabase
        return const Scaffold(
          backgroundColor: Color(0xFF14202E),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFC4A054)),
          ),
        );

      case AuthStatus.authenticated:
        if (auth.isSuperAdmin) {
          return const AdminPanelScreen();
        }
        return const DashboardScreen();

      case AuthStatus.unauthenticated:
        return const AuthScreen();
    }
  }
}

/// Shown when .env / Supabase config is missing
class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppTheme.backgroundDeep,
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 64),
                SizedBox(height: 16),
                Text('Missing Configuration',
                  style: TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text(
                  'Create a .env file with:\n\n'
                  'SUPABASE_URL=...\nSUPABASE_ANON_KEY=...\n'
                  'GEMINI_API_KEY=...\nADMIN_PIN=...',
                  style: TextStyle(color: Colors.white60, fontFamily: 'monospace'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
