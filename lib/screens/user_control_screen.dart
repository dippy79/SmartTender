import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class UserControlScreen extends StatelessWidget {
  UserControlScreen({super.key});
  final _service = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin: User Control")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _service.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text("No users found."));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, i) {
              final user = users[i];
              final isBlocked = user['is_blocked'] ?? false;
              final role = user['role'] ?? 'User';
              final email = user['email'] ?? 'No Email';

              return Card(
                elevation: 0,
                color: Colors.transparent,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isBlocked ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      child: Icon(
                        isBlocked ? Icons.block : Icons.person,
                        color: isBlocked ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(email, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.cyan.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                            ),
                            child: Text(role.toString().toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Text("Active", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Switch(
                          value: !isBlocked,
                          activeColor: Colors.greenAccent,
                          inactiveThumbColor: Colors.redAccent,
                          onChanged: (val) async {
                            try {
                              await _service.toggleUserBlock(user['id'], !val);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(val ? "User Unblocked" : "User Blocked")),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Action failed"), backgroundColor: Colors.red),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
