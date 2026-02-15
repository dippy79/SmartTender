import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> categories = [
    {"n": "Civil", "i": Icons.engineering}, {"n": "Electric", "i": Icons.bolt},
    {"n": "Plumbing", "i": Icons.water_drop}, {"n": "Interior", "i": Icons.chair},
    {"n": "Paint", "i": Icons.format_paint}, {"n": "Security", "i": Icons.videocam},
    {"n": "Cleaning", "i": Icons.cleaning_services}, {"n": "HVAC", "i": Icons.ac_unit},
  ];

  void _userChoiceSettings() {
    final nCtrl = TextEditingController(text: appLuckyNumber.value);
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("Personalize App", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 15),
        TextField(controller: nCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Your Lucky Number", border: OutlineInputBorder())),
        const SizedBox(height: 20),
        const Text("Choose Your Theme Color:"),
        const SizedBox(height: 10),
        Wrap(spacing: 12, children: [Colors.indigo, Colors.teal, Colors.red, Colors.orange, Colors.black, Colors.purple].map((c) => GestureDetector(
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('app_color', c.value);
            await prefs.setString('app_number', nCtrl.text);
            appThemeColor.value = c;
            appLuckyNumber.value = nCtrl.text;
            Navigator.pop(ctx);
            setState(() {});
          },
          child: CircleAvatar(backgroundColor: c, radius: 20, child: appThemeColor.value == c ? const Icon(Icons.check, color: Colors.white, size: 15) : null),
        )).toList()),
        const SizedBox(height: 30),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    Color p = appThemeColor.value;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: p,
        elevation: 0,
        title: const Text("DASHBOARD", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
        actions: [
          // Lucky Number: Chota badge corner mein
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(15)),
            child: Center(child: Text("Lucky: ${appLuckyNumber.value}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
          ),
          IconButton(icon: const Icon(Icons.palette_outlined, color: Colors.white), onPressed: _userChoiceSettings),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [p.withOpacity(0.1), Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Column(
          children: [
            _adminBanner(p),
            const Padding(padding: EdgeInsets.all(15), child: Align(alignment: Alignment.centerLeft, child: Text("SELECT CATEGORY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)))),
            // Category Grid: 4 columns for micro-size
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 15, childAspectRatio: 0.85),
                itemCount: categories.length,
                itemBuilder: (ctx, i) => InkWell(
                  onTap: () => _openTenderLogic(categories[i]['n']),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: p.withOpacity(0.1), blurRadius: 4)]),
                      child: Icon(categories[i]['i'], color: p, size: 16), // Micro Icon Size
                    ),
                    const SizedBox(height: 5),
                    Text(categories[i]['n'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: p, onPressed: () {}, child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _adminBanner(Color p) {
    if (!isSystemAdmin) return const SizedBox();
    return Container(
      margin: const EdgeInsets.all(10), padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.amber.shade100, border: Border.all(color: Colors.amber), borderRadius: BorderRadius.circular(10)),
      child: const Row(children: [Icon(Icons.security, size: 14), SizedBox(width: 8), Text("ADMIN POWER MODE ACTIVE", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))]),
    );
  }

  void _openTenderLogic(String name) {
    // Basic Functionality Logic: Save / PDF Option link yahan hoga
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Opening $name Tender Logic..."), duration: const Duration(seconds: 1)));
  }
}