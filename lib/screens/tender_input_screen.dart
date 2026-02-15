import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import '../models/boq_item.dart';
import '../main.dart'; 

class TenderInputScreen extends StatefulWidget {
  final String businessType;
  const TenderInputScreen({super.key, required this.businessType});

  @override
  State<TenderInputScreen> createState() => _TenderInputScreenState();
}

class _TenderInputScreenState extends State<TenderInputScreen> {
  final List<BOQItem> _items = [];
  final _clientNameController = TextEditingController();
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();
  final _marginController = TextEditingController(text: "10");
  final _freightController = TextEditingController(text: "0");
  final _labourController = TextEditingController(text: "0");
  final _termsController = TextEditingController(text: "1. 50% Advance.\n2. Valid for 7 days.");

  DateTime _validUntil = DateTime.now().add(const Duration(days: 7));
  bool _includeGST = false;

  void _addItem() {
    if (_nameController.text.isNotEmpty && _qtyController.text.isNotEmpty) {
      setState(() {
        _items.add(BOQItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          quantity: double.parse(_qtyController.text),
          baseRate: double.parse(_rateController.text),
        ));
        _nameController.clear(); _qtyController.clear(); _rateController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primary = appThemeColor.value;
    double base = _items.fold(0, (s, item) => s + (item.quantity * item.baseRate));
    double withExtras = base + (double.tryParse(_freightController.text) ?? 0) + (double.tryParse(_labourController.text) ?? 0);
    double subTotal = withExtras + (withExtras * (double.parse(_marginController.text) / 100));
    double gst = _includeGST ? subTotal * 0.18 : 0;
    double grandTotal = subTotal + gst;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.businessType),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text("Lucky: ${appLuckyNumber.value}", style: const TextStyle(fontWeight: FontWeight.bold))),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: _buildInput(_clientNameController, "Client Name", Icons.person)),
              const SizedBox(width: 10),
              _datePicker(),
            ]),
            const SizedBox(height: 15),
            _itemInputCard(primary),
            _buildItemsList(),
            const Divider(),
            _chargesRow(),
            SwitchListTile(title: const Text("GST (18%)"), value: _includeGST, activeColor: primary, onChanged: (v) => setState(() => _includeGST = v)),
            _buildInput(_termsController, "Terms", Icons.note, maxLines: 2),
            const SizedBox(height: 20),
            _totalCard(primary, subTotal, gst, grandTotal),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
                onPressed: () => PdfService.generateAndSharePdf(
                  businessType: widget.businessType,
                  clientName: _clientNameController.text,
                  items: _items,
                  subTotal: subTotal,
                  gstAmount: gst,
                  grandTotal: grandTotal,
                  terms: _termsController.text,
                ),
                icon: const Icon(Icons.share),
                label: const Text("GENERATE & SHARE PDF"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePicker() {
    return InkWell(
      onTap: () async {
        DateTime? p = await showDatePicker(context: context, initialDate: _validUntil, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
        if (p != null) setState(() => _validUntil = p);
      },
      child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)), child: Text("${_validUntil.day}/${_validUntil.month}")),
    );
  }

  Widget _itemInputCard(Color p) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: p.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: p.withOpacity(0.1))),
      child: Column(children: [
        _buildInput(_nameController, "Item Name", Icons.shopping_cart),
        Row(children: [
          Expanded(child: _buildInput(_qtyController, "Qty", Icons.numbers, isNum: true)),
          Expanded(child: _buildInput(_rateController, "Rate", Icons.currency_rupee, isNum: true)),
          IconButton(onPressed: _addItem, icon: Icon(Icons.add_circle, color: p, size: 35)),
        ])
      ]),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      itemBuilder: (c, i) => ListTile(title: Text(_items[i].name), trailing: Text("₹${(_items[i].quantity * _items[i].baseRate).toStringAsFixed(0)}")),
    );
  }

  Widget _chargesRow() {
    return Row(children: [
      Expanded(child: _buildInput(_freightController, "Freight", Icons.local_shipping, isNum: true)),
      Expanded(child: _buildInput(_labourController, "Labour", Icons.engineering, isNum: true)),
      Expanded(child: _buildInput(_marginController, "Margin%", Icons.trending_up, isNum: true)),
    ]);
  }

  Widget _totalCard(Color p, double s, double g, double t) {
    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: p, borderRadius: BorderRadius.circular(15)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Grand Total", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), Text("₹${t.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))]),
      ]),
    );
  }

  Widget _buildInput(TextEditingController c, String h, IconData i, {bool isNum = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextField(controller: c, keyboardType: isNum ? TextInputType.number : TextInputType.text, maxLines: maxLines, decoration: InputDecoration(prefixIcon: Icon(i, size: 18), hintText: h, border: const OutlineInputBorder(), isDense: true)),
    );
  }
}