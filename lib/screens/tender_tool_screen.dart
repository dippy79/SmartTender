import 'package:flutter/material.dart';

class TenderToolScreen extends StatefulWidget {
  const TenderToolScreen({super.key});
  @override
  State<TenderToolScreen> createState() => _TenderToolScreenState();
}

class _TenderToolScreenState extends State<TenderToolScreen> {
  double profitMargin = 10.0;
  String selectedGST = "18%";
  double baseAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TENDER CALCULATOR", style: TextStyle(fontSize: 14))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _calcCard("Base Quantity/Rate", Icons.edit, TextField(
            keyboardType: TextInputType.number,
            onChanged: (v) => setState(() => baseAmount = double.tryParse(v) ?? 0.0),
            decoration: const InputDecoration(hintText: "Enter Base Amount", border: InputBorder.none),
          )),
          const SizedBox(height: 20),
          _calcCard("Profit Margin Slider", Icons.trending_up, Column(children: [
            Slider(value: profitMargin, min: 0, max: 50, divisions: 50, label: "${profitMargin.round()}%", 
              onChanged: (v) => setState(() => profitMargin = v)),
            Text("Margin: ${profitMargin.round()}%", style: const TextStyle(color: Colors.cyan)),
          ])),
          const SizedBox(height: 20),
          _calcCard("GST Slab", Icons.pie_chart, DropdownButton<String>(
            value: selectedGST, isExpanded: true, underline: const SizedBox(),
            items: ["5%", "12%", "18%", "28%"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => selectedGST = v!),
          )),
          const SizedBox(height: 40),
          _resultPanel(),
          const SizedBox(height: 30),
          _bottomActions(),
        ]),
      ),
    );
  }

  Widget _calcCard(String t, IconData i, Widget child) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(i, size: 16, color: Colors.cyan), const SizedBox(width: 10), Text(t, style: const TextStyle(fontSize: 11, color: Colors.white54))]),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }

  Widget _resultPanel() {
    double gstVal = double.parse(selectedGST.replaceAll('%', '')) / 100;
    double total = baseAmount + (baseAmount * (profitMargin / 100));
    double finalTotal = total + (total * gstVal);

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.cyan.withOpacity(0.2), Colors.blueAccent.withOpacity(0.2)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.cyan.withOpacity(0.5))),
      child: Column(children: [
        const Text("ESTIMATED TENDER VALUE", style: TextStyle(fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 10),
        Text("₹ ${finalTotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
      ]),
    );
  }

  Widget _bottomActions() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _iconBtn(Icons.picture_as_pdf, "PDF"),
      _iconBtn(Icons.share, "SHARE"),
      _iconBtn(Icons.save, "SAVE"),
      _iconBtn(Icons.whatsapp, "W-APP"),
    ]);
  }

  Widget _iconBtn(IconData i, String l) {
    return Column(children: [
      IconButton(onPressed: () {}, icon: Icon(i, color: Colors.cyan)),
      Text(l, style: const TextStyle(fontSize: 9, color: Colors.white38)),
    ]);
  }
}