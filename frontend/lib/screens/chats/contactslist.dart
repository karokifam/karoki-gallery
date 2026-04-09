import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/screens/chats/chatpage.dart';

class Contactslist extends StatelessWidget {
  final String username;
  const Contactslist({required this.username, super.key});

  final List<List<dynamic>> contacts = const [
    /// 👥 GROUP CHAT
    ["Family Group", Color(0xFF22C55E), "avatars/group.svg", 'family_group'],
    ["Mary Karoki", Color(0xFFB310DB), "avatars/mary.svg", 'marykaroki'],
    ["Brenda Karoki", Color(0xFFF53B2D), "avatars/brenda.svg", 'brendakaroki'],
    ["Daisy Karoki", Color(0xFFECD60F), "avatars/daisy.svg", 'daisykaroki'],
    ["Ken Karoki", Color(0xFF2563EB), "avatars/ken.svg", 'kenkaroki'],
    ["Diana Karoki", Color(0xFFEA6C96), "avatars/diana.svg", 'dianakaroki'],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter out your own contact
    final filteredContacts = contacts.where((c) => c[3] != username).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Message your family...."),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: filteredContacts.length,
        itemBuilder: (context, index) {
          final name = filteredContacts[index][0];
          final color = filteredContacts[index][1];
          final svg = filteredContacts[index][2];
          final recipientId = filteredContacts[index][3];
          final displayName = filteredContacts[index][0];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Chatscreen(
                    recipient: recipientId,
                    sender: username,
                    displayname: displayName,
                  ),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: theme.cardColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: color.withOpacity(0.2), width: 1),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: color.withOpacity(0.15),
                      child: SvgPicture.asset(svg, width: 32, height: 32),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                subtitle: Text(
                  "Tap to start chatting...",
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 13,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.arrow_forward_ios, size: 14, color: color),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
