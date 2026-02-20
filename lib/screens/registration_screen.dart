import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/supabase_service.dart';
import 'dashboard_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool isLogin = true;
  bool isLoading = false;
  late final SupabaseService _service;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bypassController = TextEditingController();

  String _selectedBusinessType = 'Contractor';
  String _selectedCategory = 'Civil';

  final List<String> _businessTypes = ['Contractor', 'Supplier', 'Engineer', 'Architect', 'Civil Worker'];
  final List<String> _categories = ['Civil', 'IT', 'Mechanical', 'Electrical', 'Private'];

  @override
  void initState() {
    super.initState();
    _service = SupabaseService();
  }

  Future<void> _handleAuth() async {
    setState(() => isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      if (isLogin) {
        final response = await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (response.user != null) _goToDashboard(isAdmin: false);
      } else {
        final response = await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          data: {
            'full_name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'business_type': _selectedBusinessType,
            'preferred_category': _selectedCategory,
          },
        );

        if (response.user != null) {
          await _service.updatePreferences(
            response.user!.id,
            _selectedBusinessType,
            _selectedCategory
          );
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration Successful! Please Login.")));
          setState(() => isLogin = true);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.redAccent));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showBypassDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151D24),
        title: const Text("System Override", style: TextStyle(color: Colors.cyanAccent, fontSize: 16)),
        content: TextField(
          controller: _bypassController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter Secret Access Code",
            hintStyle: TextStyle(color: Colors.white24),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final secret = dotenv.env['ADMIN_BYPASS_CODE'] ?? '1202';
              if (_bypassController.text == secret) {
                Navigator.pop(context);
                _goToDashboard(isAdmin: true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Access Code")));
              }
              _bypassController.clear();
            },
            child: const Text("VERIFY", style: TextStyle(color: Colors.cyanAccent)),
          )
        ],
      ),
    );
  }

  void _goToDashboard({required bool isAdmin}) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen(isAdmin: isAdmin)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Secret Trigger: Double tap the shield icon to open bypass
                    GestureDetector(
                      onDoubleTap: _showBypassDialog,
                      child: const Icon(Icons.shield_outlined, color: Colors.cyanAccent, size: 48),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isLogin ? "IDENTITY VERIFICATION" : "SYSTEM REGISTRATION",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 3, color: Colors.cyanAccent)
                    ),
                    const SizedBox(height: 40),

                    if (!isLogin) _input("Full Name", Icons.person_outline, _nameController),
                    _input("Email ID", Icons.alternate_email, _emailController),
                    if (!isLogin) _input("Mobile Number", Icons.phone_android_outlined, _phoneController),

                    if (!isLogin) ...[
                      _label("Business Type"),
                      _dropdownField(_selectedBusinessType, _businessTypes, (v) => setState(() => _selectedBusinessType = v!)),
                      const SizedBox(height: 15),
                      _label("Preferred Tender Category"),
                      _dropdownField(_selectedCategory, _categories, (v) => setState(() => _selectedCategory = v!)),
                    ],

                    _input("Password", Icons.lock_outline, _passwordController, hide: true),

                    const SizedBox(height: 32),
                    isLoading ? const CircularProgressIndicator(color: Colors.cyanAccent) : _actionBtn(),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() => isLogin = !isLogin),
                      child: Text(
                        isLogin ? "New User? Create Account" : "Already Registered? Sign In",
                        style: const TextStyle(color: Colors.grey, fontSize: 12)
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
    );
  }

  Widget _input(String hint, IconData icon, TextEditingController controller, {bool hide = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: hide,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.cyanAccent, size: 18),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
          filled: true,
          fillColor: Colors.white.withOpacity(0.04),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.cyanAccent, width: 1)),
        ),
      ),
    );
  }

  Widget _dropdownField(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF0F172A),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.cyanAccent),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: items.map((String val) => DropdownMenuItem<String>(value: val, child: Text(val))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _actionBtn() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
        onPressed: _handleAuth,
        child: Text(isLogin ? "AUTHENTICATE" : "COMPLETE REGISTRATION", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13)),
      ),
    );
  }
}
