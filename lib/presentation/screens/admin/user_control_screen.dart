import 'package:flutter/material.dart';
import '../../../services/supabase_client.dart';

class UserControlScreen extends StatefulWidget {
  const UserControlScreen({super.key});

  @override
  State<UserControlScreen> createState() => _UserControlScreenState();
}

class _UserControlScreenState extends State<UserControlScreen> {
  late final supabase = SupabaseClientHelper.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin: User Control")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('profiles')
            .stream(primaryKey: ['id'])
            .order('email'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: \${snapshot.error}"));
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
                      backgroundColor: isBlocked 
                          ? Colors.red.withAlpha(26) 
                          : Colors.green.withAlpha(26),
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
                          Text(
                            email, 
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, 
                              vertical: 2
                            ),
                            decoration: BoxDecoration(
                              color: Colors.cyan.withAlpha(26),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.cyan.withAlpha(128)
                              ),
                            ),
                            child: Text(
                              role.toString().toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.cyanAccent
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Text(
                          "Active", 
                          style: TextStyle(fontSize: 10, color: Colors.grey)
                        ),
                        Switch(
                          value: !isBlocked,
                          activeThumbColor: Colors.greenAccent,
                          inactiveThumbColor: Colors.redAccent,
                          onChanged: (val) async {
                            if (!context.mounted) return;
                            try {
                              await supabase
                                  .from('profiles')
                                  .update({'is_blocked': !val})
                                  .eq('id', user['id']);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(val ? "User Unblocked" : "User Blocked")),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Action failed"), 
                                  backgroundColor: Colors.red
                                ),
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

