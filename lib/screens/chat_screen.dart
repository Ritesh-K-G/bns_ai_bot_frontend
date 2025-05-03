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
        title: const Text('ChatBot', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 2,
      ),
      body: Row(
        children: [
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: const Border(right: BorderSide(color: Colors.grey)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Chats', style: Theme.of(context).textTheme.titleMedium),
                ),
                Expanded(
                  child: ListView(
                    children: chatProvider.chatIds.map((id) {
                      return ListTile(
                        title: Text(id, style: const TextStyle(fontSize: 14)),
                        selected: chatProvider.currentChatId == id,
                        selectedTileColor: Colors.indigo.shade100,
                        onTap: () => chatProvider.switchChat(id),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final newId = "chat_${DateTime.now().millisecondsSinceEpoch}";
          chatProvider.switchChat(newId);
        },
        icon: const Icon(Icons.add),
        label: const Text("New Chat"),
      ),
    );
  }
}
