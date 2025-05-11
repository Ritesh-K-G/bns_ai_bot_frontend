import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import 'package:open_file/open_file.dart';

import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();

  void _launchFile(String path) async {
    final result = await OpenFile.open(path);
    if (result.type != ResultType.done) {
      debugPrint('Error opening file: ${result.message}');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final isLoading = chatProvider.isLoading;

    const scaffoldBackgroundColor = Color(0xFF121212);
    const appBarBackgroundColor = Color(0xFF1F1F1F);
    const drawerBackgroundColor = Color(0xFF181818);
    const drawerHeaderColor = Color(0xFF2E2E3A);
    const primaryTextColor = Color(0xFFE1E3E6);
    const secondaryTextColor = Color(0xFFB0B3B8);
    const accentColor = Color(0xFF8A81F8);
    const listTileSelectedColor = Color(0xFF2A2A2F);
    const iconColor = Color(0xFFB0B3B8);
    const fileBubbleColor = Color(0xFF202124);

    return SafeArea(
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'ChatBot',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: primaryTextColor,
            ),
          ),
          centerTitle: true,
          elevation: 2,
          backgroundColor: appBarBackgroundColor,
          iconTheme: const IconThemeData(color: primaryTextColor),
        ),
        drawer: Drawer(
          child: Container(
            color: const Color(0xFF202123),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, left: 16.0, bottom: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Chat History',
                      style: TextStyle(
                        fontSize: 18,
                        color: primaryTextColor.withOpacity(0.87),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: InkWell(
                    onTap: () {
                      final now = DateTime.now();
                      final formattedDate = DateFormat('dd_MMMM_yyyy_HH_mm_ss').format(now);
                      final newId =
                          "chat_${formattedDate}";
                      chatProvider.switchChat(newId);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: accentColor, size: 24),
                          const SizedBox(width: 16),
                          Text(
                            'New Chat',
                            style: TextStyle(
                              color: primaryTextColor.withOpacity(0.87),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: Color(0xFF303134), height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 8.0),
                    children: chatProvider.chatIds.map((id) {
                      bool isSelected = chatProvider.currentChatId == id;
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          chatProvider.switchChat(id);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 10.0),
                          child: Row(
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  color: iconColor.withOpacity(0.6)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  id.replaceFirst('chat_', ''),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isSelected
                                        ? primaryTextColor.withOpacity(0.87)
                                        : secondaryTextColor.withOpacity(0.6),
                                    fontWeight: isSelected
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(color: Color(0xFF303134), height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined,
                          color: iconColor.withOpacity(0.6)),
                      const SizedBox(width: 16),
                      Text(
                        'Settings',
                        style: TextStyle(
                            color: secondaryTextColor.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(child:
                Consumer<ChatProvider>(builder: (context, chatProvider, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  itemCount: chatProvider.messages.length +
                      (chatProvider.isLoading ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i < chatProvider.messages.length) {
                      final message = chatProvider.messages[i];
                      if (message.isUser ||
                          !message.message.startsWith("file:")) {
                        return MessageBubble(
                          text: message.message,
                          isUser: message.isUser,
                        );
                      } else {
                        final fileUrl = message.message.substring(5);
                        String fileName = fileUrl.split('/').last;
                        if (fileName.length > 20) {
                          fileName = '${fileName.substring(0, 20)}...';
                        }
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => _launchFile(fileUrl),
                            child: IntrinsicWidth(
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF303134),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                        color: const Color(0xFF4a4a50)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 0,
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.insert_drive_file,
                                        color: Color(0xFF64b5f6),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              fileName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Text(
                                              'Tap to open file',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    } else {
                      // Loading spinner
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 20),
                          child: TypingIndicator(),
                        ),
                      );
                    }
                  },
                ),
              );
            })),
            const Padding(
              padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
              child: MessageInput(),
            ),
          ],
        ),
      ),
    );
  }
}
