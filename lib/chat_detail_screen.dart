import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'service/database_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String currentUser;
  final String chatPartner;
  final bool isGroup;

  const ChatDetailScreen({
    Key? key,
    required this.currentUser,
    required this.chatPartner,
    required this.isGroup,
  }) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _msgController = TextEditingController();

  Stream<List<Map<String, dynamic>>>? _messagesStream;

  @override
  void initState() {
    super.initState();
    _dbService.connect();
    
    if (widget.isGroup) {
      _messagesStream = _dbService.getGroupMessages();
    } else {
      _messagesStream = _dbService.getMessages(widget.currentUser, widget.chatPartner);
    }
  }

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;

    _dbService.sendMessage(
      sender: widget.currentUser,
      receiver: widget.isGroup ? 'GROUP' : widget.chatPartner,
      text: _msgController.text.trim(),
    );
    
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isGroup ? 'Family Group Chat' : widget.chatPartner),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                }
                
                final messages = snapshot.data ?? [];
                
                return ListView.builder(
                  reverse: true, // Show newest at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender'] == widget.currentUser;
                    
                    DateTime time = DateTime.tryParse(msg['timestamp'] ?? '') ?? DateTime.now();
                    String timeStr = DateFormat('hh:mm a').format(time.toLocal());
                    
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF38BDF8) : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isMe ? const Radius.circular(0) : null,
                            bottomLeft: !isMe ? const Radius.circular(0) : null,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.isGroup && !isMe)
                              Text(msg['sender'], style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text(msg['text'], style: const TextStyle(color: Colors.white, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(timeStr, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF0F172A),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF38BDF8),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
