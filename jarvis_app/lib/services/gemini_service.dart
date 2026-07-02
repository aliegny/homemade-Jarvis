import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_message.dart';

class GeminiService {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  String? _apiKey;
  bool _initialized = false;

  static const String _systemInstruction = '''
Sen Jarvis isimli bir AI asistanısın. Kullanıcının kişisel asistanısın.
Kurallarin:
- Kisa ve öz cevaplar ver (1-3 cümle ideal)
- Türkçe'de akici ve dogal konuş
- Yardimci, nazik ve misafirperver ol
- Ses komutlariyla konuşulduğunu unutma - cevaplari kisa tut
- Teknik terimleri Türkçe'ye çevir
- Kullanicinin adini öğrenmeye çaliş
''';

  Future<void> initialize(String apiKey) async {
    if (_initialized && _apiKey == apiKey) return;

    _apiKey = apiKey;
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(_systemInstruction),
      generationConfig: GenerationConfig(
        temperature: 0.8,
        maxOutputTokens: 512,
      ),
    );

    _chatSession = _model!.startChat();
    _initialized = true;
  }

  Future<ChatMessage> sendMessage(String userMessage) async {
    if (!_initialized || _model == null || _chatSession == null) {
      throw Exception('Gemini API key ayarlanmadı. Ayarlar ekranından ekleyin.');
    }

    try {
      final response = await _chatSession!.sendMessage(
        Content.text(userMessage),
      );

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Gemini boş yanıt döndürdü');
      }

      return ChatMessage(
        text: text,
        isUser: false,
        source: 'gemini',
      );
    } on GenerativeAIException catch (e) {
      throw Exception('Gemini API hatası: ${e.message}');
    } catch (e) {
      throw Exception('Gemini bağlantı hatası: $e');
    }
  }

  void clearHistory() {
    if (_initialized && _model != null) {
      _chatSession = _model!.startChat();
    }
  }

  bool get isInitialized => _initialized;
  String? get apiKey => _apiKey;
}
