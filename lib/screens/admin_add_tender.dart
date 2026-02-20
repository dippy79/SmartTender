import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AdminAddTenderScreen extends StatefulWidget {
  const AdminAddTenderScreen({super.key});

  @override
  State<AdminAddTenderScreen> createState() => _AdminAddTenderScreenState();
}

class _AdminAddTenderScreenState extends State<AdminAddTenderScreen> {
  final _service = SupabaseService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  String _selectedCategory = 'Civil';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _saveTender() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final orgId = await _service.getOrganizationId();
      if (orgId == null) throw "Organization context missing. Please re-login.";

      // Corrected table name and multi-tenant logic
      await _service.instance.from('tenders').insert({
        'organization_id': orgId,
        'title': _titleController.text.trim(),
        'department': _deptController.text.trim(),
        'value': double.parse(_valueController.text),
        'category': _selectedCategory,
        'deadline': _selectedDate.toIso8601String(),
        'link': _linkController.text.trim(),
        'is_private': _selectedCategory == 'Private',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Tender Published Successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ADD NEW TENDER")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Publish Tender for your Organization",
                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              _buildInput("Tender Title", _titleController, Icons.title),
              const SizedBox(height: 15),
              _buildInput("Department / Company", _deptController, Icons.business),
              const SizedBox(height: 15),
              _buildInput("Estimated Value (₹)", _valueController, Icons.payments, isNumber: true),
              const SizedBox(height: 15),
              _buildInput("Application Link (URL)", _linkController, Icons.link),
              const SizedBox(height: 20),

              const Text("Select Category", style: TextStyle(fontSize: 12, color: Colors.grey)),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: const Color(0xFF151D24),
                decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10))),
                items: ["Civil", "IT", "Mechanical", "Private", "Electrical"]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              
              const SizedBox(height: 30),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Submission Deadline", style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(_selectedDate.toLocal().toString().split(' ')[0],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                trailing: const Icon(Icons.calendar_month, color: Colors.cyanAccent),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context, initialDate: _selectedDate,
                    firstDate: DateTime.now(), lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              
              const SizedBox(height: 50),
              _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                : ElevatedButton(
                    onPressed: _saveTender,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("PUBLISH TENDER", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.cyanAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v!.isEmpty ? "Required field" : null,
    );
  }
}
extension on SupabaseService {
  SupabaseClient get instance => Supabase.instance.client;
}
