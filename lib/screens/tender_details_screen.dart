import 'dart:ui';
import 'package:flutter/material.dart';

class TenderDetailsScreen extends StatefulWidget {
  final String categoryName;
  const TenderDetailsScreen({super.key, required this.categoryName});

  @override
  State<TenderDetailsScreen> createState() => _TenderDetailsScreenState();
}

class _TenderDetailsScreenState extends State<TenderDetailsScreen> {
  // Logic Variables
  double profitMargin = 15.0;
  final TextEditingController _freightCtrl = TextEditingController(text: "0");
  final TextEditingController _laborCtrl = TextEditingController(text: "0");

  // Items List (Name, Qty, Rate) - Fixed Structure
  List<Map<String, dynamic>> items = [
    {"name": "Resource 1", "qty": 1, "rate": 0.0},
  ];

  // Logic Calculations
  double get subTotal {
    double itemSum = items.fold(0, (sum, item) => sum + (item['qty'] * item['rate']));
    double freight = double.tryParse(_freightCtrl.text) ?? 0;
    double labor = double.tryParse(_laborCtrl.text) ?? 0;
    return itemSum + freight + labor;
  }

  double get finalTotal {
    double profit = subTotal * (profitMargin / 100);
    return subTotal + profit;
  }

  // --- FUNCTION: ADD NEW ITEM ---
  void _addItem() {
    setState(() {
      items.add({"name": "New Resource", "qty": 1, "rate": 0.0});
    });
  }

  // --- FUNCTION: AI CHAT (Logic based on inputs) ---
  void _openAIChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("AI TENDER ANALYST", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
              child: Text(
                "I see you have ${items.length} items for ${widget.categoryName}. Total estimate is ₹${finalTotal.toStringAsFixed(2)}. Pro Tip: In current market, freight is high, ensure ₹${_freightCtrl.text} covers all logistics.",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Ask AI about rates...",
                hintStyle: const TextStyle(color: Colors.white24),
                suffixIcon: const Icon(Icons.send, color: Colors.cyanAccent),
                filled: true, fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- FUNCTION: SHARE & SAVE (Database + Native Share Menu) ---
  void _handleShare() {
    String tenderSummary = "Tender: ${widget.categoryName}\nTotal: ₹${finalTotal.toStringAsFixed(2)}\nProfit: ${profitMargin.round()}%";
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("EXPORT & SHARE QUOTATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _shareOption(Icons.message, "WhatsApp", Colors.green, () {
                  print("Sharing to WhatsApp: $tenderSummary");
                  Navigator.pop(ctx);
                }),
                _shareOption(Icons.picture_as_pdf, "Save PDF", Colors.redAccent, () {
                  print("Saving PDF to Device...");
                  Navigator.pop(ctx);
                }),
                _shareOption(Icons.cloud_upload, "Cloud Sync", Colors.blue, () {
                  print("Saving to Supabase Database...");
                  Navigator.pop(ctx);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(widget.categoryName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.share, color: Colors.cyanAccent), onPressed: _handleShare),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Total Quote Header
            _glassContainer(
              child: Column(children: [
                const Text("ESTIMATED QUOTATION TOTAL", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2)),
                const SizedBox(height: 10),
                Text("₹ ${finalTotal.toStringAsFixed(2)}", 
                  style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
              ]),
            ),
            const SizedBox(height: 25),

            // Item Table (Name / Qty / Rate) - MISSING FEATURE ADDED
            _glassContainer(
              title: "RESOURCE DETAILS",
              child: Column(
                children: [
                  ...items.asMap().entries.map((entry) => _buildResourceRow(entry.key)).toList(),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add_circle, color: Colors.cyanAccent),
                    label: const Text("ADD NEW ITEM", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Freight & Labour
            Row(children: [
              Expanded(child: _miniInput(_freightCtrl, "Freight", Icons.local_shipping)),
              const SizedBox(width: 15),
              Expanded(child: _miniInput(_laborCtrl, "Labour", Icons.engineering)),
            ]),
            const SizedBox(height: 25),

            // Profit Slider with real-time %
            _glassContainer(
              title: "PROFIT MARGIN: ${profitMargin.round()}%",
              child: Slider(
                value: profitMargin, min: 0, max: 100,
                activeColor: Colors.cyanAccent,
                onChanged: (v) => setState(() => profitMargin = v),
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _circleAction(Icons.auto_awesome, "AI HELP", Colors.purpleAccent, _openAIChat),
              _circleAction(Icons.save_outlined, "SAVE DATA", Colors.greenAccent, _handleShare),
            ])
          ],
        ),
      ),
    );
  }

  Widget _buildResourceRow(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Name field ko thoda zyada space (flex: 4)
          Expanded(flex: 4, child: _tableField("Name", (v) => items[index]['name'] = v)),
          const SizedBox(width: 6),
          
          // Qty field - Iska flex aur padding balance kiya hai
          Expanded(flex: 2, child: _tableField("Qty", (v) => setState(() => items[index]['qty'] = int.tryParse(v) ?? 0), isNum: true)),
          const SizedBox(width: 6),
          
          // Rate field
          Expanded(flex: 3, child: _tableField("Rate", (v) => setState(() => items[index]['rate'] = double.tryParse(v) ?? 0.0), isNum: true)),
          
          // Delete Button
          IconButton(
            constraints: const BoxConstraints(), // Padding hatane ke liye
            padding: const EdgeInsets.only(left: 4),
            icon: const Icon(Icons.close, color: Colors.redAccent, size: 18), 
            onPressed: () => setState(() => items.removeAt(index))
          ),
        ],
      ),
    );
  }

  Widget _tableField(String hint, Function(String) onC, {bool isNum = false}) {
    return TextField(
      onChanged: onC,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
        filled: true,
        fillColor: Colors.white10,
        // YAHAN CHANGE HAI: Content padding kam ki hai taaki text dikhe
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _miniInput(TextEditingController c, String label, IconData icon) {
    return TextField(
      controller: c, keyboardType: TextInputType.number,
      onChanged: (v) => setState(() {}),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(prefixIcon: Icon(icon, color: Colors.cyanAccent, size: 18), labelText: label, labelStyle: const TextStyle(color: Colors.white38, fontSize: 12), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    );
  }

  Widget _glassContainer({required Widget child, String? title}) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null) ...[Text(title, style: const TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 2)), const SizedBox(height: 15)],
        child,
      ]),
    );
  }

  Widget _circleAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(children: [
      GestureDetector(onTap: onTap, child: CircleAvatar(radius: 28, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 28))),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _shareOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ]),
    );
  }
}