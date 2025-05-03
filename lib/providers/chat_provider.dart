import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatProvider with ChangeNotifier {
  final Map<String, List<ChatMessage>> _conversations = {
    'default': []
  };

  String _currentChatId = 'default';

  List<ChatMessage> get messages => _conversations[_currentChatId] ?? [];
  List<String> get chatIds => _conversations.keys.toList();
  String get currentChatId => _currentChatId;

  void switchChat(String chatId) {
    _currentChatId = chatId;
    _conversations.putIfAbsent(chatId, () => []);
    notifyListeners();
  }

  void addMessage(String msg, bool isUser) {
    _conversations[_currentChatId]?.add(ChatMessage(message: msg, isUser: isUser));
    notifyListeners();
  }

  Future<void> sendMessage(String msg) async {
    addMessage(msg, true);
    await Future.delayed(const Duration(milliseconds: 500));
    addMessage("Hi! This is a simulated response.", false);
  }
}
