import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../main.dart';
import 'home_screen.dart';

class RegistrationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: appThemeColor,
      builder: (context, p, _) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [p, p.withOpacity(0.7)], begin: Alignment.topLeft),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.business_center_rounded, size: 70, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text("SMART TENDER", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 50),
                  _field("Email ID", Icons.email_outlined),
                  _field("Password", Icons.lock_outline, isPass: true),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: p, fixedSize: const Size(200, 50)),
                    onPressed: () {}, child: const Text("REGISTER", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  // Invisible Admin Bypass (No hint code)
                  GestureDetector(
                    onTap: () => _adminLogin(context),
                    child: Text("System Login", style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 10)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _adminLogin(BuildContext context) {
    final code = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Master Key Required"),
      content: TextField(controller: code, obscureText: true, decoration: const InputDecoration(hintText: "••••")),
      actions: [TextButton(onPressed: () {
        // Use AppConfig.adminPin instead of hardcoded value
        // Set via environment variable ADMIN_PIN or local_config.dart
        if (code.text == AppConfig.adminPin && AppConfig.adminPin.isNotEmpty) {
          isSystemAdmin = true;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else if (AppConfig.adminPin.isEmpty) {
          // Admin PIN not configured - show message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin PIN not configured. Please set ADMIN_PIN in environment or local_config.dart')),
          );
        } else {
          // Wrong PIN - show error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid PIN')),
          );
        }
      }, child: const Text("Verify"))],
    ));
  }

  Widget _field(String h, IconData i, {bool isPass = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        obscureText: isPass,
        decoration: InputDecoration(
          prefixIcon: Icon(i, color: Colors.white70),
          hintText: h, hintStyle: const TextStyle(color: Colors.white60),
          filled: true, fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}