import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({Key? key}) : super(key: key);

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isDisposed = false;

  void _sendMessage() {
    final msg = _controller.text.trim();

    if (msg.isEmpty) return;

    Provider.of<ChatProvider>(context, listen: false).sendMessage(msg);

    _controller.clear();
    if (!_isDisposed) {
      _focusNode.requestFocus();
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardBackgroundColor = Color(0xFF2A2A2E);
    const hintTextColor = Colors.grey;
    const inputTextColor = Colors.white;
    const sendIconColor = Color(0xFF90CAF9);

    return Card(
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(color: inputTextColor),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Ask me anything...',
                  hintStyle: TextStyle(color: hintTextColor),
                ),
                onSubmitted: (_) => _sendMessage(),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 1,
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: sendIconColor),
              onPressed: _sendMessage,
              tooltip: 'Send message',
            )
          ],
        ),
      ),
    );
  }
}
