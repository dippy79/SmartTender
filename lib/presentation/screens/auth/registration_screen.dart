import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../config/app_config.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool isLoading = false;


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
  }

  Future<void> _handleSignup() async {
    setState(() => isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      // 1. Supabase Auth signup
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
        final userId = response.user!.id;

        // 2. Insert into profiles table
        await supabase.from('profiles').insert({
          'id': userId,
          'full_name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'business_type': _selectedBusinessType,
          'preferred_category': _selectedCategory,
          'updated_at': DateTime.now().toIso8601String(),
        });

        // 3. Insert into user_roles table (default role: 'user')
        await supabase.from('user_roles').insert({
          'user_id': userId,
          'role': 'user',
          'is_blocked': false,
        });

        // Success - show message and pop back to login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration Successful! Please check your email and login."),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: ${e.toString()}"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
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
              final secret = dotenv.env['ADMIN_BYPASS_CODE'] ?? AppConfig.adminPin;
              if (_bypassController.text == secret) {
                _bypassController.clear();
                Navigator.pop(context);
                Navigator.pop(context); // Back to auth gate
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Access Code")));
                _bypassController.clear();
              }
            },
            child: const Text("VERIFY", style: TextStyle(color: Colors.cyanAccent)),
          )
        ],
      ),
    );
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
   color: Colors.white.withValues(alpha: 0.05),
    borderRadius: BorderRadius.circular(24),
     border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                    const Text(
                      "SYSTEM REGISTRATION",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 3, color: Colors.cyanAccent)
                    ),
                    const SizedBox(height: 40),

                    _input("Full Name", Icons.person_outline, _nameController),
                    _input("Email ID", Icons.alternate_email, _emailController),
                    _input("Mobile Number", Icons.phone_android_outlined, _phoneController),

                    _label("Business Type"),
                    _dropdownField(_selectedBusinessType, _businessTypes, (v) => setState(() => _selectedBusinessType = v!)),
                    const SizedBox(height: 15),
                    _label("Preferred Tender Category"),
                    _dropdownField(_selectedCategory, _categories, (v) => setState(() => _selectedCategory = v!)),

                    _input("Password", Icons.lock_outline, _passwordController, hide: true),

                    const SizedBox(height: 32),
                    isLoading 
                      ? const CircularProgressIndicator(color: Colors.cyanAccent) 
                      : _actionBtn(),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Already Registered? Sign In",
                        style: TextStyle(color: Colors.grey, fontSize: 12)
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
fillColor: Colors.white.withValues(alpha: 0.04),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.cyanAccent, width: 1))
        ),
      ),
    );
  }

  Widget _dropdownField(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyanAccent, 
          foregroundColor: Colors.black, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
          elevation: 0
        ),
        onPressed: _handleSignup,
        child: const Text("COMPLETE REGISTRATION", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13)),
      ),
    );
  }
}

