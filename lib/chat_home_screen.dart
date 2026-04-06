import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_detail_screen.dart';
import 'account_center_screen.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({Key? key}) : super(key: key);

  @override
  _ChatHomeScreenState createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  String _loggedInUser = '';

  final List<Map<String, dynamic>> _accounts = [
    {'name': 'Mary Karoki', 'color': Colors.pinkAccent},
    {'name': 'Brenda Karoki', 'color': Colors.purpleAccent},
    {'name': 'Daisy Karoki', 'color': Colors.orangeAccent},
    {'name': 'Ken Karoki', 'color': Colors.blueAccent},
    {'name': 'Diana Karoki', 'color': Colors.tealAccent},
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedInUser = prefs.getString('loggedInUser') ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> otherMembers = _accounts.where((acc) => acc['name'] != _loggedInUser).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountCenterScreen()),
              );
            },
          ),
        ],
      ),
      body: _loggedInUser.isEmpty 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF38BDF8),
                    child: Icon(Icons.group, color: Colors.white),
                  ),
                  title: const Text('Family Group Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: const Text('Chat with everyone'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          currentUser: _loggedInUser,
                          chatPartner: 'GROUP',
                          isGroup: true,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.grey),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Direct Messages', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ...otherMembers.map((member) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: member['color'],
                    child: Text(member['name'][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(member['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          currentUser: _loggedInUser,
                          chatPartner: member['name'],
                          isGroup: false,
                        ),
                      ),
                    );
                  },
                )).toList(),
              ],
            ),
    );
  }
}
