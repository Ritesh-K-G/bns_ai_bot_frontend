import 'dart:convert'; // Required for jsonEncode and jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../services/api_services.dart';

class ChatProvider with ChangeNotifier {
  // Keys for SharedPreferences
  static const String _chatIdsListKey = 'all_chat_id_list_test';
  static const String _chatSessionPrefix = 'chat_session_';

  Map<String, List<ChatMessage>> _conversations = {};
  String _currentChatId = 'default';
  bool _isLoading = false;
  SharedPreferences? _prefsInstance;

  ChatProvider() {
    _initProvider();
  }

  Future<void> _initProvider() async {
    _prefsInstance = await SharedPreferences.getInstance();
    await _loadAllConversations();

    if (_conversations.isEmpty) {
      _conversations['default'] = [];
      _currentChatId = 'default';
      await _saveChatSession(_currentChatId);
      await _updateChatIdsListInPrefs();
    } else if (!_conversations.containsKey(_currentChatId)) {
      _currentChatId = _conversations.keys.first;
    }
    // A final fallback if _currentChatId is still somehow not in _conversations
    if (!_conversations.containsKey(_currentChatId)) {
      _conversations['default'] = [];
      _currentChatId = 'default';
      if (_prefsInstance?.getStringList(_chatIdsListKey)?.contains(_currentChatId) != true) {
        await _saveChatSession(_currentChatId);
        await _updateChatIdsListInPrefs();
      }
    }
    notifyListeners();
  }

  Future<void> _loadAllConversations() async {
    if (_prefsInstance == null) return;

    final List<String>? chatIds = _prefsInstance!.getStringList(_chatIdsListKey);
    final Map<String, List<ChatMessage>> loadedConversations = {};

    if (chatIds != null && chatIds.isNotEmpty) {
      for (String chatId in chatIds) {
        final String? messagesJson = _prefsInstance!.getString(_chatSessionPrefix + chatId);
        if (messagesJson != null && messagesJson.isNotEmpty) {
          try {
            final List<dynamic> decodedList = jsonDecode(messagesJson);
            loadedConversations[chatId] = decodedList
                .map((jsonMsg) => ChatMessage.fromJson(jsonMsg as Map<String, dynamic>))
                .toList();
          } catch (e) {
            debugPrint("Error decoding messages for chat $chatId: $e. Will remove corrupted data.");
            // Clean up corrupted data
            await _prefsInstance!.remove(_chatSessionPrefix + chatId);
            // This chat ID will be removed from the list in the next _updateChatIdsListInPrefs call
            // if we make sure to call it after any modification.
          }
        }
      }
    }

    _conversations = loadedConversations; // Assign loaded or empty if nothing valid was found

    // Adjust currentChatId if the previous one is no longer valid
    if (_conversations.isNotEmpty && !_conversations.containsKey(_currentChatId)) {
      _currentChatId = _conversations.keys.first;
    } else if (_conversations.isEmpty) {
      _currentChatId = 'default'; // Will be handled by _initProvider's logic to create a default
    }
  }

  Future<void> _saveChatSession(String chatId) async {
    if (_prefsInstance == null || !_conversations.containsKey(chatId)) return;

    final List<Map<String, dynamic>> messagesAsJsonList =
    _conversations[chatId]!.map((msg) => msg.toJson()).toList();
    final String encodedMessages = jsonEncode(messagesAsJsonList);
    await _prefsInstance!.setString(_chatSessionPrefix + chatId, encodedMessages);
  }

  Future<void> _updateChatIdsListInPrefs() async {
    if (_prefsInstance == null) return;
    final List<String> allChatIds = _conversations.keys.toList();
    await _prefsInstance!.setStringList(_chatIdsListKey, allChatIds);
  }

  List<ChatMessage> get messages => _conversations[_currentChatId] ?? [];
  List<String> get chatIds => _conversations.keys.toList();
  String get currentChatId => _currentChatId;
  bool get isLoading => _isLoading;

  void switchChat(String chatId) {
    _currentChatId = chatId;
    bool isNewChat = false;
    _conversations.putIfAbsent(chatId, () {
      isNewChat = true;
      return <ChatMessage>[];
    });

    if (isNewChat) {
      // Save the new (empty) chat session and update the overall list of chat IDs
      _saveChatSession(chatId).then((_) => _updateChatIdsListInPrefs());
    }
    notifyListeners();
  }

  void _addMessageToMemory(ChatMessage message) {
    _conversations.putIfAbsent(_currentChatId, () => <ChatMessage>[]);
    _conversations[_currentChatId]!.add(message);
  }

  Future<void> sendMessage(String msg) async {
    final userMessage = ChatMessage(message: msg, isUser: true, content: '');
    _addMessageToMemory(userMessage);

    _isLoading = true;
    notifyListeners();
    await _saveChatSession(_currentChatId);
    List<Map<String, dynamic>> history = [];
    for (int i = 0; i < _conversations[_currentChatId]!.length; i++) {
      ChatMessage chatMessage = _conversations[_currentChatId]![i];
      history.add({
        "role": "model",
        "parts": [
          {
            "text": chatMessage.content
          }
        ]
      });
      if (i % 2 == 0) {
        history.last['role'] = "user";
      }
    }

    try {
      final responseMessage = await ApiService.sendMessage(msg);
      _addMessageToMemory(responseMessage);
    } catch (e) {
      final errorMessage = ChatMessage(message: "Error sending message: $e", isUser: false, content: '');
      _addMessageToMemory(errorMessage);
      debugPrint("ApiService Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
      await _saveChatSession(_currentChatId); // Persist changes again after bot response/error
    }
  }

  Future<void> deleteChat(String chatIdToDelete) async {
    if (_prefsInstance == null || !_conversations.containsKey(chatIdToDelete)) return;

    _conversations.remove(chatIdToDelete); // Remove from memory
    await _prefsInstance!.remove(_chatSessionPrefix + chatIdToDelete); // Remove chat's messages from prefs
    await _updateChatIdsListInPrefs(); // Update the list of chat IDs in prefs

    if (_currentChatId == chatIdToDelete) {
      // If the active chat was deleted, switch to 'default' or the first available chat
      _currentChatId = _conversations.keys.firstOrNull ?? 'default';
      if (!_conversations.containsKey(_currentChatId)) {
        // If all chats are deleted, (re)create a default one
        _conversations['default'] = [];
        _currentChatId = 'default';
        await _saveChatSession(_currentChatId);
        await _updateChatIdsListInPrefs();
      }
    }
    notifyListeners();
  }
}

