class AiResponse {
  final String text;
  final String source; // 'gemini', 'local', 'error'
  final DateTime timestamp;
  final int? tokensUsed;

  const AiResponse({
    required this.text,
    required this.source,
    required this.timestamp,
    this.tokensUsed,
  });

  factory AiResponse.fromGemini(String text) {
    return AiResponse(
      text: text,
      source: 'gemini',
      timestamp: DateTime.now(),
    );
  }

  factory AiResponse.fromLocal(String text) {
    return AiResponse(
      text: text,
      source: 'local',
      timestamp: DateTime.now(),
    );
  }

  factory AiResponse.error(String message) {
    return AiResponse(
      text: message,
      source: 'error',
      timestamp: DateTime.now(),
    );
  }
}
