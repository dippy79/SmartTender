import 'dart:ui';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Glows
          Positioned(top: -100, right: -50, child: _glow(Colors.blue.withOpacity(0.2))),
          Positioned(bottom: -100, left: -50, child: _glow(Colors.cyan.withOpacity(0.2))),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isLogin ? "IDENTITY VERIFICATION" : "SYSTEM REGISTRATION",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        const SizedBox(height: 30),
                        
                        if (!isLogin) _input("Full Name", Icons.person_outline),
                        _input("Email ID", Icons.alternate_email),
                        if (!isLogin) _input("Mobile Number", Icons.phone_android_outlined),
                        if (!isLogin) _input("Business Type (e.g. Civil)", Icons.business_center_outlined),
                        _input("Password", Icons.lock_outline, hide: true),

                        const SizedBox(height: 30),
                        _actionBtn(),
                        
                        TextButton(
                          onPressed: () => setState(() => isLogin = !isLogin),
                          child: Text(isLogin ? "New User? Register System" : "Already Registered? Login",
                              style: const TextStyle(color: Colors.cyanAccent, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(String hint, IconData icon, {bool hide = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        obscureText: hide,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.cyanAccent, size: 18),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _actionBtn() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyanAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen())),
        child: Text(isLogin ? "AUTHENTICATE" : "REGISTER", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _glow(Color c) => Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: c, blurRadius: 100));
}