import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart'; // Assuming this path is correct

class MessageInput extends StatefulWidget {
  const MessageInput({Key? key}) : super(key: key);

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  // Controller for the text input field
  final _controller = TextEditingController();
  final _focusNode = FocusNode(); // Add FocusNode
  bool _isDisposed = false;

  // Function to handle sending the message
  void _sendMessage() {
    // Get the trimmed text from the controller
    final msg = _controller.text.trim();
    // If the message is empty, do nothing
    if (msg.isEmpty) return;
    // Send the message using the ChatProvider
    Provider.of<ChatProvider>(context, listen: false).sendMessage(msg);
    // Clear the input field after sending
    _controller.clear();
    if (!_isDisposed) {
      // Check if the widget is disposed
      _focusNode.requestFocus(); // Keep focus in the input field
    }
  }

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to request focus after the build is complete.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _focusNode
            .requestFocus(); // Request focus when the widget is initialized
      }
    });
  }

  @override
  void dispose() {
    // Dispose the controller and focus node when the widget is removed from the widget tree
    _controller.dispose();
    _focusNode.dispose();
    _isDisposed = true; // Mark as disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define colors based on the theme mode
    const cardBackgroundColor = Color(0xFF2A2A2E); // Darker background
    const hintTextColor = Colors.grey; // Keep hint text the same
    const inputTextColor = Colors.white;
    const sendIconColor = Color(0xFF90CAF9); // Lighten send icon

    return Card(
      // Set the background color of the card based on the theme
      color: cardBackgroundColor,
      // Define the shape and border radius of the card
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25)), // More rounded corners
      // Set the elevation (shadow) of the card
      elevation: 3,
      // Add margin around the card
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        // Padding inside the card
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Row(
          // Align items vertically in the center
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Expanded TextField takes up available space
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode, // Attach the FocusNode
                // Style for the input text
                style: const TextStyle(color: inputTextColor),
                decoration: const InputDecoration(
                  // Remove the default underline border
                  border: InputBorder.none,
                  // Set the hint text that appears when the field is empty
                  hintText: 'Ask me anything...',
                  // Style for the hint text
                  hintStyle: TextStyle(color: hintTextColor),
                ),
                // Define the action when the user submits (e.g., presses Enter)
                onSubmitted: (_) => _sendMessage(),
                // Allow multiple lines and automatically adjust height
                keyboardType: TextInputType.multiline,
                maxLines: null, // Allows unlimited lines
                minLines: 1, // Starts with a single line
                textInputAction: TextInputAction
                    .send, // Show 'send' action button on keyboard
              ),
            ),
            // Add some spacing between text field and button
            const SizedBox(width: 8),
            // Send button
            IconButton(
              // Set the icon for the button
              icon: const Icon(Icons.send, color: sendIconColor),
              // Define the action when the button is pressed
              onPressed: _sendMessage,
              // Optional: Add tooltip for accessibility
              tooltip: 'Send message',
            )
          ],
        ),
      ),
    );
  }
}
