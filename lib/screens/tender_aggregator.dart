import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TenderAggregatorPage extends StatefulWidget {
  const TenderAggregatorPage({super.key});

  @override
  State<TenderAggregatorPage> createState() => _TenderAggregatorPageState();
}

class _TenderAggregatorPageState extends State<TenderAggregatorPage> {
  final SupabaseClient _client = SupabaseClientService.client;

  late Future<List<Map<String, dynamic>>> _tendersFuture;

  @override
  void initState() {
    super.initState();
    _tendersFuture = fetchTenders();
  }

  Future<List<Map<String, dynamic>>> fetchTenders() async {
    try {
      final data = await _client
          .from('tenders')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Error fetching tenders: $e');
      return [];
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _tendersFuture = fetchTenders();
    });
  }

  Color _getTypeColor(bool isPrivate) {
    return isPrivate ? Colors.orange : Colors.green;
  }

  String _getTypeLabel(bool isPrivate) {
    return isPrivate ? "Private" : "Government";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Active Tenders"),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _tendersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const Center(
                child: Text("Error loading tenders"),
              );
            }

            final tenders = snapshot.data!;

            if (tenders.isEmpty) {
              return const Center(
                child: Text("No tenders available"),
              );
            }

            return ListView.builder(
              itemCount: tenders.length,
              itemBuilder: (context, index) {
                final tender = tenders[index];

                final title = tender['title'] ?? 'No Title';
                final value = tender['value'] ?? 'N/A';
                final department = tender['department'] ?? 'Unknown';
                final deadline = tender['deadline'] ?? '';
                final isPrivate = tender['is_private'] ?? false;
                final link = tender['link'] ?? '';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Department
                        Text(
                          "Department: $department",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Value
                        Text(
                          "Value: ₹$value",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Deadline
                        if (deadline.toString().isNotEmpty)
                          Text(
                            "Deadline: ${deadline.toString().split('T')[0]}",
                            style: const TextStyle(
                              color: Colors.redAccent,
                            ),
                          ),

                        const SizedBox(height: 10),

                        // Type Chip + Share Button Row
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [

                            Chip(
                              label: Text(
                                _getTypeLabel(isPrivate),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor:
                                  _getTypeColor(isPrivate),
                            ),

                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                Share.share(
                                  "Tender: $title\nDepartment: $department\nValue: ₹$value\n$link",
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
