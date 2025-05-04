import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart'; // Assuming this path is correct
import '../widgets/message_bubble.dart'; // Uses pure dark theme internally now
import '../widgets/message_input.dart'; // Assuming this adapts or is styled for dark theme
import 'package:open_file/open_file.dart'; // For opening files

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  // Function to open a file using its path
  void _launchFile(String path) async {
    final result = await OpenFile.open(path);
    // Log if there was an issue opening the file
    if (result.type != ResultType.done) {
      // Use debugPrint for development logs
      debugPrint('Error opening file: ${result.message}');
      // Optionally, show a SnackBar to the user
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Could not open file: ${result.message}')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the ChatProvider using Provider
    final chatProvider = Provider.of<ChatProvider>(context);

    // --- Pure Dark Theme Colors ---
    const scaffoldBackgroundColor =
        Color(0xFF121212); // Very dark grey, near black
    const appBarBackgroundColor =
        Color(0xFF1F1F1F); // Slightly lighter dark grey
    const drawerBackgroundColor = Color(0xFF181818); // Dark grey for drawer
    const drawerHeaderColor =
        Color(0xFF2E2E3A); // Dark blue-grey like user bubble
    const primaryTextColor = Color(0xFFE1E3E6); // Off-white for text
    const secondaryTextColor =
        Color(0xFFB0B3B8); // Lighter grey for less emphasis
    const accentColor = Color(0xFF8A81F8); // A purple accent, adjust as needed
    const listTileSelectedColor =
        Color(0xFF2A2A2F); // Darker selection highlight
    const iconColor = Color(0xFFB0B3B8); // Grey for icons
    const fileBubbleColor = Color(0xFF202124); // Same as bot bubble

    return SafeArea(
        child: Scaffold(
      // Set the main background color
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'ChatBot',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: primaryTextColor, // Use primary text color
          ),
        ),
        centerTitle: true,
        elevation: 2, // Reduce elevation for a flatter dark look
        // Set AppBar background color
        backgroundColor: appBarBackgroundColor,
        // Ensure icons in AppBar are visible
        iconTheme: const IconThemeData(color: primaryTextColor),
      ),
      drawer: Drawer(
        // Match Gemini's dark background color more closely
        child: Container(
          color: const Color(0xFF202123), // A slightly lighter black
          child: Column(
            children: [
              // Header for the drawer - Gemini uses a more subtle approach, often just text
              Padding(
                padding:
                    const EdgeInsets.only(top: 20.0, left: 16.0, bottom: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Chat History',
                    style: TextStyle(
                      fontSize: 18,
                      color: primaryTextColor.withOpacity(
                          0.87), // Higher opacity for better readability
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // New Chat button - More prominent and styled like Gemini
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
                child: InkWell(
                  onTap: () {
                    final newId =
                        "chat_${DateTime.now().millisecondsSinceEpoch}";
                    chatProvider.switchChat(newId);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(24), // More rounded
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Icon(Icons.add,
                            color: accentColor, size: 24), // Accent color icon
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
              const SizedBox(height: 8), // Added some spacing
              // Divider - Subtler dark divider
              const Divider(color: Color(0xFF303134), height: 1),
              // List of previous chat sessions - More padding and visual density
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
                      // Subtle background highlight on tap/selection
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Row(
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                color: iconColor.withOpacity(
                                    0.6)), // Slightly less opaque icon
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
              // Optional: Settings or other actions at the bottom of the drawer
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
                      style:
                          TextStyle(color: secondaryTextColor.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Main content area (chat messages and input)
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.builder(
                reverse: false,
                padding: const EdgeInsets.only(top: 15, bottom: 10),
                itemCount: chatProvider.messages.length,
                itemBuilder: (ctx, i) {
                  final message = chatProvider.messages[i];
                  if (message.isUser || !message.message.startsWith("file:")) {
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
                        // Wrap with GestureDetector for inkwell
                        onTap: () => _launchFile(fileUrl),
                        child: IntrinsicWidth(
                          // Use IntrinsicWidth
                          child: Material(
                            // Use Material for inkwell effect and size constraints
                            color:
                                Colors.transparent, // Make Material transparent
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF303134),
                                // Darker, more consistent color
                                borderRadius: BorderRadius.circular(24),
                                // Fully rounded corners
                                border: Border.all(
                                  color:
                                      const Color(0xFF4a4a50), // Subtle border
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    // Even subtler shadow
                                    spreadRadius: 0,
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min, // Size row to content
                                children: [
                                  // File icon - more distinct
                                  const Icon(
                                    Icons.insert_drive_file,
                                    color: Color(0xFF64b5f6),
                                    // Blue accent for files
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    // Use Expanded to handle long file names
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fileName,
                                          // Use the processed file name
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight
                                                .w500, // Make filename bold
                                          ),
                                          overflow: TextOverflow
                                              .ellipsis, // Ensure no overflow
                                        ),
                                        Text(
                                          'Tap to open file',
                                          // Add a subtitle
                                          style: const TextStyle(
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
                },
              ),
            ),
          ),
          // Input field area (ensure MessageInput is also themed)
          const Padding(
            padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
            child: MessageInput(),
          ),
        ],
      ),
    ));
  }
}
