import 'dart:ui';
import 'package:flutter/material.dart';
import 'tender_details_screen.dart';
import 'tender_stats_screen.dart';
import 'user_control_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool isAdmin;
  const DashboardScreen({super.key, this.isAdmin = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // sequence-wise category list as per your requirement
  final List<Map<String, dynamic>> tenderCategories = [
    {
      "main": "Civil & Infrastructure",
      "icon": Icons.engineering,
      "color": Colors.cyan,
      "subs": ["Road Work", "Building Construction", "Smart City", "Irrigation", "Metro/Railway Civil"]
    },
    {
      "main": "Electrical & Power",
      "icon": Icons.bolt,
      "color": Colors.yellow,
      "subs": ["Wiring & Installation", "Solar Panel", "Substations", "Smart Meters"]
    },
    {
      "main": "IT & Digital Services",
      "icon": Icons.computer,
      "color": Colors.indigoAccent,
      "subs": ["Web/App Development", "Cyber Security", "CCTV Surveillance", "AI Projects"]
    },
    {
      "main": "Service & Manpower",
      "icon": Icons.groups_outlined,
      "color": Colors.orange,
      "subs": ["Housekeeping", "Security Guards", "Data Entry", "Consultancy"]
    },
    {
      "main": "Supply/Procurement",
      "icon": Icons.shopping_basket_outlined,
      "color": Colors.green,
      "subs": ["Furniture", "Medical Supply", "Stationery", "Lab Equipment"]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.isAdmin ? "ADMIN CONTROL" : "BUSINESS CONSOLE", 
             style: const TextStyle(fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          _backgroundGlow(),
          SafeArea(
            child: widget.isAdmin ? _buildAdminSplitView() : _buildOwnerGrid(),
          ),
        ],
      ),
    );
  }

  Widget _backgroundGlow() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF020617)),
      child: Stack(children: [
        Positioned(top: 100, right: -50, child: CircleAvatar(radius: 100, backgroundColor: Colors.cyan.withOpacity(0.05))),
      ]),
    );
  }

  // --- 1. ADMIN SPLIT VIEW (With 3 Features) ---
  Widget _buildAdminSplitView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(children: [
        _adminPanel("USER CONTROLS", Icons.manage_accounts, Colors.orangeAccent, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const UserControlScreen()));
        }),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 40), child: Divider(color: Colors.white10)),
        _adminPanel("APP STATISTICS", Icons.analytics, Colors.cyanAccent, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TenderStatsScreen()));
        }),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 40), child: Divider(color: Colors.white10)),
        // NEW FEATURE: APP WORKFLOW TESTER
        _adminPanel("APP WORKFLOW TESTER", Icons.play_circle_fill_outlined, Colors.greenAccent, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen(isAdmin: false)));
        }),
      ]),
    );
  }

  // --- 2. OWNER GRID (With Categories & Sub-menus) ---
  Widget _buildOwnerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tenderCategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15),
      itemBuilder: (ctx, i) => _categoryCard(tenderCategories[i]),
    );
  }

  Widget _categoryCard(Map<String, dynamic> cat) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: InkWell(
          onTap: () => _showSubCategories(cat), // Show Sub-category Bottom Sheet
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(cat['icon'], color: cat['color'], size: 30),
              const SizedBox(height: 12),
              Text(cat['main'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      ),
    );
  }

  // Sub-category Selector Logic
  void _showSubCategories(Map<String, dynamic> cat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Text(cat['main'], style: TextStyle(color: cat['color'], fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cat['subs'].length,
                itemBuilder: (c, i) => ListTile(
                  title: Text(cat['subs'][i], style: const TextStyle(fontSize: 14, color: Colors.white70)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white24),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TenderDetailsScreen(categoryName: cat['subs'][i])));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminPanel(String t, IconData i, Color c, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03), 
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: c.withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(i, color: c, size: 35),
          const SizedBox(height: 10),
          Text(t, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
      ),
    );
  }
}