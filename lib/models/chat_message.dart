class ChatMessage {
  final String message;
  final bool isUser;
  final String content;

  ChatMessage({required this.message, required this.isUser, required this.content});



  Map<String, dynamic> toJson() => {
    'message': message,
    'isUser': isUser,
    'content': content
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    message: json['message'] as String,
    isUser: json['isUser'] as bool,
    content: json['content'] as String
  );

}