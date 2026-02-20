import 'package:flutter/material.dart';

class TenderToolScreen extends StatefulWidget {
  const TenderToolScreen({super.key});

  @override
  State<TenderToolScreen> createState() => _TenderToolScreenState();
}

class _TenderToolScreenState extends State<TenderToolScreen> {
  final List<Map<String, dynamic>> _items = [];
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();

  double _gstPercent = 18.0;
  double _profitPercent = 10.0;

  void _addItem() {
    final name = _nameController.text;
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;

    if (name.isNotEmpty && qty > 0 && rate > 0) {
      setState(() {
        _items.add({'name': name, 'qty': qty, 'rate': rate, 'total': qty * rate});
        _nameController.clear();
        _qtyController.clear();
        _rateController.clear();
      });
    }
  }

  Map<String, double> _calculate() {
    double base = _items.fold(0, (sum, item) => sum + item['total']);
    double profit = base * (_profitPercent / 100);
    double gst = (base + profit) * (_gstPercent / 100);
    return {'base': base, 'profit': profit, 'gst': gst, 'final': base + profit + gst};
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();
    return Scaffold(
      appBar: AppBar(title: const Text("Tender Estimation Tool")),
      body: Column(
        children: [
          _buildEntrySection(),
          Expanded(child: _buildItemList()),
          _buildCalculationSummary(results),
        ],
      ),
    );
  }

  Widget _buildEntrySection() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Item Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    decoration: const InputDecoration(labelText: "Qty", border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    decoration: const InputDecoration(labelText: "Rate", border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_circle, color: Colors.cyan, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList() {
    if (_items.isEmpty) {
      return const Center(child: Text("No items added yet."));
    }
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${item['qty']} x ₹${item['rate']}"),
          trailing: Text("₹${item['total'].toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
          onLongPress: () => setState(() => _items.removeAt(index)),
        );
      },
    );
  }

  Widget _buildCalculationSummary(Map<String, double> res) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sliderRow("Profit %", _profitPercent, (v) => setState(() => _profitPercent = v)),
          _sliderRow("GST %", _gstPercent, (v) => setState(() => _gstPercent = v), max: 28),
          const Divider(),
          _summaryRow("Base Amount", res['base']!),
          _summaryRow("Profit", res['profit']!),
          _summaryRow("GST", res['gst']!),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyanAccent),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Final Bid:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("₹${res['final']!.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliderRow(String label, double val, Function(double) onChg, {double max = 50}) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text("$label: ${val.toInt()}%")),
        Expanded(child: Slider(value: val, min: 0, max: max, divisions: max.toInt(), onChanged: onChg)),
      ],
    );
  }

  Widget _summaryRow(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text("₹${val.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _rateController.dispose();
    super.dispose();
  }
}
