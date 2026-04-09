import 'package:flutter/material.dart';
import 'package:frontend/apis/api_service.dart';

/// ---------------- MESSAGE MODEL ----------------
class Message {
  final String text;
  final String sender;
  final String receiver;
  final String? memory;
  final String? deleter;
  final String? pollId; // ✅ NEW

  Message({
    required this.text,
    required this.sender,
    required this.receiver,
    this.memory,
    this.deleter,
    this.pollId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['message'] ?? '',
      sender: json['sender'] ?? '',
      receiver: json['receiver'] ?? '',
      memory: json['memory'],
      deleter: json['deleter'],
      pollId: json['poll_id'], // ✅ MAP IT
    );
  }

  bool get isPoll => text == 'pole';
}

/// ---------------- CHAT SCREEN ----------------
class Chatscreen extends StatefulWidget {
  final String recipient;
  final String sender;
  final String displayname;

  const Chatscreen({
    required this.sender,
    required this.recipient,
    required this.displayname,
    super.key,
  });

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  List<Message> messages = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool isLoading = true;
  

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// ---------------- LOAD MESSAGES ----------------
  Future<void> loadMessages() async {
    try {
      final data = await ApiService.loadgroupMessages();
      setState(() {
        messages = (data).map((item) => Message.fromJson(item)).toList();
        isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error loading messages: $e");
    }
  }

  /// ---------------- SEND MESSAGE ----------------
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(
        Message(text: text, sender: widget.sender, receiver: widget.recipient),
      );
      messageController.clear();
    });

    _scrollToBottom();

    try {
      await ApiService.sendMessage(text, widget.sender, widget.recipient);
    } catch (e) {
      debugPrint("Send failed: $e");
    }
  }

  /// ---------------- POLL BUTTON PLACEHOLDER ----------------
  void onDeletePressed(Message msg, String? pollId) {
    if (pollId == null) return;
    ApiService().pollvoting(widget.sender, 'delete', pollId);
  }

  void onRemainPressed(Message msg, String? pollId) {
    if (pollId == null) return;
    ApiService().pollvoting(widget.sender, 'remain', pollId);
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.displayname), centerTitle: true),
      body: Column(
        children: [
          /// -------- MESSAGE LIST --------
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? const Center(child: Text("No messages yet"))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMine = msg.sender == widget.sender;
                      final isApp = msg.sender == 'app';

                      return Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : isApp
                            ? Alignment.center
                            : Alignment.centerLeft,
                        child: msg.isPoll
                            ? _buildPollCard(msg)
                            : _buildNormalMessage(msg, isMine),
                      );
                    },
                  ),
          ),

          /// -------- INPUT FIELD --------
          _buildInputArea(),
        ],
      ),
    );
  }

  /// ---------------- NORMAL MESSAGE ----------------
  Widget _buildNormalMessage(Message msg, bool isMine) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: isMine
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isMine ? 12 : 0),
          bottomRight: Radius.circular(isMine ? 0 : 12),
        ),
        border: isMine
            ? null
            : Border.all(color: Theme.of(context).dividerColor, width: 0.5),
      ),
      child: Text(
        msg.text,
        style: TextStyle(
          color: isMine
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 15,
        ),
      ),
    );
  }

  /// ---------------- POLL CARD ----------------
  Widget _buildPollCard(Message msg) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.85,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: const [
              Icon(Icons.how_to_vote, size: 18),
              SizedBox(width: 6),
              Text(
                "Deletion Poll",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// IMAGE
          if (msg.memory != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                msg.memory!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),

          const SizedBox(height: 10),

          /// TEXT
          Text(
            "${msg.deleter ?? 'Someone'} wants to delete this media",
            style: const TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 12),

          /// BUTTONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onDeletePressed(msg, msg.pollId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text("Delete"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onRemainPressed(msg, msg.pollId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Remain"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------------- INPUT AREA ----------------
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => sendMessage(),
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                filled: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: sendMessage, icon: const Icon(Icons.send)),
        ],
      ),
    );
  }
}
