import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/tender_model.dart';
import 'tender_tool_screen.dart';
import 'ai_assistant_screen.dart';
import 'user_control_screen.dart';
import 'tender_details_screen.dart';
import 'registration_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  final bool isAdmin;
  const DashboardScreen({super.key, required this.isAdmin});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = SupabaseService();
  String _selectedCategory = 'All';

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegistrationScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMART TENDER HUB"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: CustomScrollView(
          slivers: [
            // --- HEADER & TOOLS SECTION ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isAdmin ? "Administrator Portal" : "Tender Management Hub",
                      style: const TextStyle(fontSize: 14, color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    const SizedBox(height: 20),

                    // QUICK ACTIONS GRID
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.1,
                      children: [
                        _buildToolCard(Icons.calculate_outlined, "Tender Tool", const TenderToolScreen()),
                        _buildToolCard(Icons.psychology_outlined, "AI Advisor", const AIAssistantScreen()),
                        _buildToolCard(Icons.history_rounded, "History", null),
                        if (widget.isAdmin) ...[
                          _buildToolCard(Icons.manage_accounts_outlined, "User Control", UserControlScreen()),
                          _buildToolCard(Icons.add_business_outlined, "Add Tender", null),
                          _buildToolCard(Icons.analytics_outlined, "Analytics", null),
                        ],
                      ],
                    ),

                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("LIVE TENDER FEED", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        _buildCategoryFilter(),
                      ],
                    ),
                    const Divider(color: Colors.white10),
                  ],
                ),
              ),
            ),

            // --- LIVE TENDERS LIST ---
            StreamBuilder<List<Tender>>(
              stream: _service.getTenderStream(category: _selectedCategory, isAdmin: widget.isAdmin),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return SliverFillRemaining(child: Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent))));
                }
                final tenders = snapshot.data ?? [];
                if (tenders.isEmpty) {
                  return const SliverFillRemaining(child: Center(child: Text("No live tenders found.")));
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildTenderListItem(tenders[index]),
                    childCount: tenders.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(IconData icon, String label, Widget? screen) {
    return InkWell(
      onTap: screen != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          dropdownColor: const Color(0xFF151D24),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          items: ['All', 'Civil', 'IT', 'Mechanical', 'Electrical', 'Private']
              .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v!),
        ),
      ),
    );
  }

  Widget _buildTenderListItem(Tender tender) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: Colors.white.withOpacity(0.03),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(tender.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.business, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                Text(tender.department, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("₹${tender.value.toStringAsFixed(0)}", style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                Text("Deadline: ${tender.deadline.toLocal().toString().split(' ')[0]}", style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white.withOpacity(0.2)),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TenderDetailsScreen(tender: tender))),
      ),
    );
  }
}
