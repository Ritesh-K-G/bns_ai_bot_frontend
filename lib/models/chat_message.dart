class ChatMessage {
  final String message;
  final bool isUser;

  ChatMessage({required this.message, required this.isUser});



  Map<String, dynamic> toJson() => {
    'message': message,
    'isUser': isUser,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    message: json['message'] as String,
    isUser: json['isUser'] as bool,
  );

}