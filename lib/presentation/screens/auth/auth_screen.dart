import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../config/app_config.dart';
import 'registration_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();

  bool _isLoading = false;

  // Admin PIN from .env via AppConfig
  final String adminPin = AppConfig.adminPin;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // =========================
  // LOGIN FUNCTION - USING PROVIDER
  // =========================
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Secret admin trigger: email='admin' + password='dippy79'
    if (email == 'admin' && password == 'dippy79') {
      _showBypassDialog();
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.login(email, password);

    if (!success) {
      if (authProvider.errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.errorMessage!)),
          );
        }
      }
    }

    setState(() => _isLoading = false);
  }

  // Two-step admin bypass
  void _showBypassDialog() {
    final bypassController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Bypass Code"),
        content: TextField(
          controller: bypassController,
          obscureText: true,
          autocorrect: false,
          decoration: const InputDecoration(hintText: "Secret code"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (bypassController.text == AppConfig.bypassCode) {
                Navigator.pop(context);
                _showAdminPinDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Wrong bypass code")),
                );
              }
            },
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  // =========================
  // ADMIN PIN BYPASS DIALOG
  // =========================
  void _showAdminPinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Admin PIN"),
        content: TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          autocorrect: false,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _pinController.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_pinController.text == adminPin) {
                Navigator.pop(context);
                context.read<AuthProvider>().bypassAsSuperAdmin();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Incorrect PIN")),
                );
                _pinController.clear();
              }
            },
            child: const Text("Verify"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "SMART TENDER",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                ),
                const SizedBox(height: 30),

                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text("Login"),
                      ),

                const SizedBox(height: 15),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const RegistrationScreen(),
                      ),
                    );
                  },
                  child: const Text("New User? Register Here"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

