import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_screen.dart';
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

  final supabase = Supabase.instance.client;

  bool _isLoading = false;

  // 🔐 Secure Admin PIN (stored hashed logic style)
  final String _secureAdminPin = "1202"; // You remember it

  // =========================
  // LOGIN FUNCTION
  // =========================
  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;

      if (user == null) throw "Login failed";

      // 🔎 Fetch role from DB
      final roleData = await supabase
          .from('user_roles')
          .select('role')
          .eq('id', user.id)
          .single();

      final role = roleData['role'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DashboardScreen(isAdmin: role == 'admin'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Error: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  // =========================
  // ADMIN PIN BYPASS
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
            onPressed: () async {
              if (_pinController.text == _secureAdminPin) {
                _pinController.clear();
                Navigator.pop(context);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const DashboardScreen(isAdmin: true),
                  ),
                );
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Incorrect PIN")),
                );
              }
            },
            child: const Text("Verify"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
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
                GestureDetector(
                  onDoubleTap: _showAdminPinDialog,
                  child: const Text(
                    "SMART TENDER",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent),
                  ),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
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
