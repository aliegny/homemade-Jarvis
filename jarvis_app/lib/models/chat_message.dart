class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? source; // 'gemini', 'local', 'error', 'system'

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.source,
  }) : timestamp = timestamp ?? DateTime.now();
}
