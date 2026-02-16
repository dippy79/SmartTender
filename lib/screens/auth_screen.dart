import 'dart:ui';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _business = TextEditingController();

  void _handleAuth() {
    // Normal User Login
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen(isAdmin: false)));
  }

  void _adminBypass() {
    final code = TextEditingController();
    showDialog(
      context: context, 
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), 
          side: const BorderSide(color: Colors.cyanAccent, width: 1), // Sahi tareeka
        ),
          title: const Text("MASTER ACCESS", style: TextStyle(fontSize: 14, color: Colors.cyanAccent)),
          content: TextField(
            controller: code, 
            obscureText: true, 
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: "Enter Security Code", hintStyle: TextStyle(color: Colors.white24)),
          ),
          actions: [
            TextButton(onPressed: () {
              if (code.text == "1202") {
                Navigator.pop(ctx);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen(isAdmin: true)));
              }
            }, child: const Text("UNLOCK"))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(top: -100, right: -100, child: _glowCircle(Colors.cyan)),
          Positioned(bottom: -100, left: -100, child: _glowCircle(Colors.blueAccent)),
          
          Center(
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 350, padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(children: [
                      Text(isLogin ? "CORE LOGIN" : "SYSTEM REGISTER", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 3)),
                      const SizedBox(height: 30),
                      if (!isLogin) _input(_name, "Full Name", Icons.person_outline),
                      _input(_email, "Email Address", Icons.alternate_email),
                      if (!isLogin) _input(_business, "Business Type", Icons.business_center),
                      _input(TextEditingController(), "Password", Icons.lock_outline, hide: true),
                      const SizedBox(height: 30),
                      _actionBtn(),
                      TextButton(onPressed: () => setState(() => isLogin = !isLogin), child: Text(isLogin ? "Create Account" : "Back to Login", style: const TextStyle(color: Colors.cyan, fontSize: 12))),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          // HIDDEN BYPASS TRIGGER
          Positioned(
            bottom: 0, right: 0,
            child: GestureDetector(
              onDoubleTap: _adminBypass,
              child: Container(width: 50, height: 50, color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(Color color) {
    return Container(
      width: 300, height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 100, spreadRadius: 50)],
      ),
    );
  }

  Widget _input(TextEditingController c, String h, IconData i, {bool hide = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c, obscureText: hide,
        decoration: InputDecoration(
          prefixIcon: Icon(i, color: Colors.cyan, size: 18),
          hintText: h, hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
          filled: true, fillColor: Colors.white.withOpacity(0.03),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _actionBtn() {
    return Container(
      width: double.infinity, height: 50,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), gradient: const LinearGradient(colors: [Colors.cyan, Colors.blueAccent])),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
        onPressed: _handleAuth, child: const Text("INITIALIZE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}