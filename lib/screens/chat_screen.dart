import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.deepPurple.shade50,
          child: Column(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.deepPurple),
                child: Center(
                  child: Text(
                    'Chat History',
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    final newId = "chat_${DateTime.now().millisecondsSinceEpoch}";
                    chatProvider.switchChat(newId);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("New Chat"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size.fromHeight(40),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: chatProvider.chatIds.map((id) {
                    return ListTile(
                      leading: const Icon(Icons.chat_bubble_outline, color: Colors.deepPurple),
                      title: Text(id, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      tileColor: chatProvider.currentChatId == id
                          ? Colors.deepPurple.shade100
                          : Colors.transparent,
                      onTap: () {
                        Navigator.pop(context);
                        chatProvider.switchChat(id);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                itemCount: chatProvider.messages.length,
                itemBuilder: (ctx, i) {
                  return MessageBubble(
                    text: chatProvider.messages[i].message,
                    isUser: chatProvider.messages[i].isUser,
                  );
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: MessageInput(),
          ),
        ],
      ),
    );
  }
}