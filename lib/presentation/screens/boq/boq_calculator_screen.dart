import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/boq_item.dart';
import '../../../models/tender.dart';
import '../../../presentation/widgets/app_sidebar.dart';
import '../../../presentation/widgets/ai_guide_widget.dart';
import '../../../presentation/widgets/import_step_indicator.dart';

class BoqCalculatorScreen extends StatefulWidget {
  const BoqCalculatorScreen({super.key});

  @override
  State<BoqCalculatorScreen> createState() => _BoqCalculatorScreenState();
}

class _BoqCalculatorScreenState extends State<BoqCalculatorScreen> {
  int _step = 0; 
  Tender? _tender;
  String _projectName = '';
  String _location = '';
  final String _category = 'Civil';
  
  final List<BoqItem> _items = [];
  
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _qtyControllers = [];
  final List<TextEditingController> _rateControllers = [];
  final List<TextEditingController> _gstControllers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tender == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Tender) {
          _tender = args;
          _projectName = _tender!.title;
        }
    }
  }

  @override
  void dispose() {
    for (var c in _nameControllers) {
      c.dispose();
    }
    for (var c in _qtyControllers) {
      c.dispose();
    }
    for (var c in _rateControllers) {
      c.dispose();
    }
    for (var c in _gstControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      final newItem = BoqItem(
        name: '',
        category: _category,
        quantity: 1.0,
        unit: 'm²',
        baseRate: 0.0,
      );
      _items.add(newItem);
      _nameControllers.add(TextEditingController());
      _qtyControllers.add(TextEditingController(text: '1.0'));
      _rateControllers.add(TextEditingController(text: '0.00'));
      _gstControllers.add(TextEditingController(text: '18.0'));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _nameControllers[index].dispose();
      _qtyControllers[index].dispose();
      _rateControllers[index].dispose();
      _gstControllers[index].dispose();
      
      _items.removeAt(index);
      _nameControllers.removeAt(index);
      _qtyControllers.removeAt(index);
      _rateControllers.removeAt(index);
      _gstControllers.removeAt(index);
    });
  }

  void _updateItemField(int index, String field, dynamic value) {
    setState(() {
      final item = _items[index];
      _items[index] = item.copyWith(
        name: field == 'name' ? value as String : item.name,
        quantity: field == 'quantity' ? (value as double) : item.quantity,
        unit: field == 'unit' ? value as String : item.unit,
        baseRate: field == 'rate' ? (value as double) : item.baseRate,
        gstPercent: field == 'gst' ? (value as double) : item.gstPercent,
      );
    });
  }

  double _calculateSubtotal() => _items.fold(0.0, (sum, item) => sum + item.amount);
  double _calculateGstTotal() => _items.fold(0.0, (sum, item) => sum + item.gstAmount);
  double _calculateGrandTotal() => _calculateSubtotal() + _calculateGstTotal();

  Widget _buildStepIndicator() => ImportStepIndicator(currentStep: _step);

  Widget _buildTextField(String label, String value, ValueChanged<String?> onChanged) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppTheme.surfaceDark,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildActionButtons({String? leftLabel, String? rightLabel, VoidCallback? onLeft, VoidCallback? onRight}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          OutlinedButton(onPressed: onLeft, child: Text(leftLabel ?? 'Back')),
          const Spacer(),
          ElevatedButton(onPressed: onRight, child: Text(rightLabel ?? 'Next')),
        ],
      ),
    );
  }

  Widget _buildStep0Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepIndicator(),
        const SizedBox(height: 32),
        Text('Project Details', style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 24),
        _buildTextField('Project Name', _projectName, (v) => _projectName = v ?? ''),
        const SizedBox(height: 16),
        _buildTextField('Location', _location, (v) => _location = v ?? ''),
        _buildActionButtons(
          leftLabel: 'Cancel',
          onLeft: () => Navigator.pop(context),
          onRight: () => setState(() => _step = 1),
        ),
      ],
    );
  }

  Widget _buildStep1Items() {
    return Column(
      children: [
        _buildStepIndicator(),
        const SizedBox(height: 24),
        ..._items.asMap().entries.map((entry) {
          int idx = entry.key;
          return Card(
            color: AppTheme.surfaceDark,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _nameControllers[idx],
                    decoration: const InputDecoration(labelText: 'Item Name'),
                    onChanged: (v) => _updateItemField(idx, 'name', v),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _qtyControllers[idx],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Qty'),
                          onChanged: (v) => _updateItemField(idx, 'quantity', double.tryParse(v) ?? 1.0),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _rateControllers[idx],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Rate ₹'),
                          onChanged: (v) => _updateItemField(idx, 'rate', double.tryParse(v) ?? 0.0),
                        ),
                      ),
                      IconButton(onPressed: () => _removeItem(idx), icon: const Icon(Icons.delete, color: Colors.red)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: const Text('Add Item')),
        _buildActionButtons(onLeft: () => setState(() => _step = 0), onRight: () => setState(() => _step = 2)),
      ],
    );
  }

  Widget _buildStep2Review() {
    return Column(
      children: [
        _buildStepIndicator(),
        const SizedBox(height: 32),
        Text('Review BOQ', style: GoogleFonts.playfairDisplay(fontSize: 24, color: AppTheme.textPrimary)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              _buildSummaryRow('Subtotal', _calculateSubtotal()),
              _buildSummaryRow('GST Total', _calculateGstTotal()),
              const Divider(),
              _buildSummaryRow('Grand Total', _calculateGrandTotal(), isBold: true),
            ],
          ),
        ),
        _buildActionButtons(onLeft: () => setState(() => _step = 1), onRight: () => setState(() => _step = 3)),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: AppTheme.textSecondary)),
          Text('₹${value.toStringAsFixed(2)}', style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: AppTheme.goldPrimary)),
        ],
      ),
    );
  }

  Widget _buildStep3Results() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
          const SizedBox(height: 20),
          Text('BOQ Saved Successfully!', style: GoogleFonts.dmSans(fontSize: 20)),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Dashboard')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: Row(
        children: [
          const AppSidebar(currentRoute: '/boq'),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: _buildCurrentStep(),
                ),
                const Positioned.fill(child: AiGuideWidget(screenContext: '/boq')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0: return _buildStep0Details();
      case 1: return _buildStep1Items();
      case 2: return _buildStep2Review();
      case 3: return _buildStep3Results();
      default: return _buildStep0Details();
    }
  }
}