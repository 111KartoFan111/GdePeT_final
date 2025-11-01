import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../models/message_model.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String receiverId;
  final String receiverName;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final senderId = context.read<AuthProvider>().user!.uid;

    final message = MessageModel(
      senderId: senderId,
      receiverId: widget.receiverId,
      text: _messageController.text.trim(),
      timestamp: Timestamp.now(),
    );

    _chatService.sendMessage(widget.chatId, message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final senderId = context.watch<AuthProvider>().user!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.receiverName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Произошла ошибка'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  reverse: true,
                  padding: const EdgeInsets.all(16.0),
                  children: snapshot.data!.docs.map((doc) {
                    final message = MessageModel.fromDocument(doc);
                    final isSender = message.senderId == senderId;
                    return ChatBubble(
                      isSender: isSender,
                      text: message.text,
                    );
                  }).toList(),
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          )
        ]
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration.collapsed(
                hintText: 'Введите сообщение...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.send,
              color: Color(0xFFEE8A9A),
              size: 28,
            ),
            onPressed: _sendMessage,
            padding: const EdgeInsets.all(8.0),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isSender;
  final String text;

  const ChatBubble({
    super.key,
    required this.isSender,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSender ? const Color(0xFFEE8A9A) : Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          text,
          style: TextStyle(color: isSender ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
