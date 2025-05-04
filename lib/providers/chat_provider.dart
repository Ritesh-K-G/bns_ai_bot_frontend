import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/api_services.dart';

class ChatProvider with ChangeNotifier {
  final Map<String, List<ChatMessage>> _conversations = {
    'default': []
  };

  String _currentChatId = 'default';
  bool _isLoading = false;

  List<ChatMessage> get messages => _conversations[_currentChatId] ?? [];
  List<String> get chatIds => _conversations.keys.toList();
  String get currentChatId => _currentChatId;
  bool get isLoading => _isLoading;

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
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.sendMessage(msg);

    _isLoading = false;
    _conversations[_currentChatId]?.add(response);
    notifyListeners();
  }
}
