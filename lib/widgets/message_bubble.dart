import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const MessageBubble({
    Key? key,
    required this.text,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Pure Dark Theme Colors ---
    // These colors aim for a darker aesthetic like the Gemini app

    // User message colors (Dark blue-grey)
    const userBubbleColor = Color(0xFF2E2E3A);
    // Bot message colors (Standard dark grey)
    const botBubbleColor = Color(0xFF202124);
    // Primary text color (Off-white for readability)
    const primaryTextColor = Color(0xFFE1E3E6);


    // --- Widget Structure ---

    return Container(
      // Add vertical margin between bubbles
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        // Align bubble to the right for user, left for bot
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end, // Align bottom of bubble/avatar if you add one
        children: [
          Container(
            // Constrain the maximum width of the bubble
            constraints: BoxConstraints(
              // Adjust max width based on screen size for better responsiveness
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            // Padding inside the bubble
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            // Decoration for the bubble (color and shape)
            decoration: BoxDecoration(
              // Apply the pure dark theme color based on who sent the message
              color: isUser ? userBubbleColor : botBubbleColor,
              // Apply rounded corners to the bubble
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18), // Slightly more rounded
                topRight: const Radius.circular(18), // Slightly more rounded
                // Make bottom corners different based on user/bot for a "tail" effect
                bottomLeft: Radius.circular(isUser ? 18 : 4), // Smoother transition for bot
                bottomRight: Radius.circular(isUser ? 4 : 18), // Smoother transition for user
              ),
              // Optional: A very subtle shadow for depth
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Slightly darker shadow
                  spreadRadius: 0, // No spread
                  blurRadius: 3, // Soft blur
                  offset: const Offset(0, 1), // Subtle downward shadow
                ),
              ],
            ),
            // The actual text content of the message
            child: Text(
              text,
              // Apply the pure dark theme text color
              style: const TextStyle(
                color: primaryTextColor,
                fontSize: 15,
                height: 1.3, // Improve line spacing for readability
              ),
            ),
          ),
        ],
      ),
    );
  }
}
