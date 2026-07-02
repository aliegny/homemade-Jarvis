import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/chat_message.dart';

class LocalModelService {
  String _backendUrl = 'http://127.0.0.1:5000'; // Termux backend default
  bool _available = false;

  void setBackendUrl(String url) {
    _backendUrl = url;
  }

  String get backendUrl => _backendUrl;

  Future<bool> checkAvailability() async {
    try {
      final response = await http
          .get(Uri.parse('$_backendUrl/health'))
          .timeout(const Duration(seconds: 2));

      _available = response.statusCode == 200;
      return _available;
    } catch (e) {
      _available = false;
      return false;
    }
  }

  Future<ChatMessage> sendMessage(String userMessage) async {
    if (!_available) {
      throw Exception('Lokal model backend\'i çalışmıyor. '
          'Termux\'ta backend\'i başlattığınızdan emin olun.');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/chat'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({'message': userMessage}),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final responseText = data['response'] as String? ?? 'Yanıt alınamadı';
        return ChatMessage(
          text: responseText,
          isUser: false,
          source: 'local',
        );
      } else {
        throw Exception('Backend HTTP hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lokal model hatası: $e');
    }
  }

  Future<void> clearHistory() async {
    if (!_available) return;
    try {
      await http
          .post(Uri.parse('$_backendUrl/clear'))
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      // ignore: avoid_print
      print('Clear history error: $e');
    }
  }

  bool get isAvailable => _available;
}
