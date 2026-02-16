import 'package:flutter/material.dart';

class UserControlScreen extends StatefulWidget {
  const UserControlScreen({super.key});
  @override
  State<UserControlScreen> createState() => _UserControlScreenState();
}

class _UserControlScreenState extends State<UserControlScreen> {
  List<Map<String, dynamic>> users = [
    {"name": "Rahul Infrastructure", "status": "Active"},
    {"name": "Vertex Electricals", "status": "Blocked"},
  ];

  void _addNewUser() {
    setState(() {
      users.add({"name": "New Contractor Pvt Ltd", "status": "Active"});
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("New User Added Successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(title: const Text("ADMIN CONTROL PANEL", style: TextStyle(fontSize: 14))),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewUser,
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.person_add_alt_1, color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: users.length,
        itemBuilder: (ctx, i) {
          bool isActive = users[i]['status'] == "Active";
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              title: Text(users[i]['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(users[i]['status'], style: TextStyle(color: isActive ? Colors.greenAccent : Colors.redAccent, fontSize: 12)),
              trailing: ElevatedButton(
                onPressed: () => setState(() => users[i]['status'] = isActive ? "Blocked" : "Active"),
                style: ElevatedButton.styleFrom(backgroundColor: isActive ? Colors.redAccent.withOpacity(0.2) : Colors.greenAccent.withOpacity(0.2)),
                child: Text(isActive ? "BLOCK" : "UNBLOCK"),
              ),
            ),
          );
        },
      ),
    );
  }
}