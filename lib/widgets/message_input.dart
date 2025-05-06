import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  bool _isListening = false;
  bool _speechEnabled = false;
  stt.SpeechToText? _speech;

  @override
  void initState() {
    super.initState();
    _initSpeech();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _focusNode.requestFocus();
      }
    });
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechEnabled = await _speech!.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (_speechEnabled && _speech != null) {
      setState(() {
        _isListening = true;
      });
      await _speech!.listen(onResult: (result) {
          setState(() {
            if (result.finalResult) {
              _controller.text = '${_controller.text}${result.recognizedWords} ';
              _isListening = false;
            }
          });
        },
        pauseFor: const Duration(seconds: 2),
      );
    }
  }

  void _stopListening() async {
    if (_speech != null) {
      await _speech!.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

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
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _isDisposed = true;
    if (_speech != null) {
      _speech!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardBackgroundColor = Color(0xFF2A2A2E);
    const hintTextColor = Colors.grey;
    const inputTextColor = Colors.white;
    const sendIconColor = Color(0xFF90CAF9);
    const micIconColor = Color(0xFF4CAF50);

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
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
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
                  maxLines: 5,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  // expands: true,
                ),
              ),
            ),
            Row(
              children: [
                if (_speechEnabled && _speech != null)
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic_off : Icons.mic,
                      color: micIconColor,
                    ),
                    onPressed: _isListening ? _stopListening : _startListening,
                    tooltip: _isListening ? 'Stop listening' : 'Start listening',
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: sendIconColor),
                  onPressed: _sendMessage,
                  tooltip: 'Send message',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
