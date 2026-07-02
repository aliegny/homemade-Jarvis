import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _speechAvailable = false;
  String _lastWords = '';

  Future<void> initialize() async {
    // Initialize Speech-to-Text
    try {
      _speechAvailable = await _speechToText.initialize(
        onError: (error) {
          // ignore: avoid_print
          print('STT error: ${error.errorMsg}');
          _isListening = false;
        },
        onStatus: (status) {
          // ignore: avoid_print
          print('STT status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('STT init error: $e');
      _speechAvailable = false;
    }

    // Initialize Text-to-Speech
    try {
      await _tts.setLanguage('tr-TR');
      await _tts.setSpeechRate(0.85);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
    } catch (e) {
      // ignore: avoid_print
      print('TTS init error: $e');
    }
  }

  Future<bool> startListening({
    required Function(String words, bool isFinal) onResult,
    Function()? onListeningStarted,
  }) async {
    if (_isListening) return false;
    if (!_speechAvailable) {
      _speechAvailable = await _speechToText.initialize();
      if (!_speechAvailable) return false;
    }

    _lastWords = '';

    try {
      await _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          onResult(_lastWords, result.finalResult);
          if (result.finalResult) {
            _isListening = false;
          }
        },
        localeId: 'tr_TR',
        listenMode: stt.ListenMode.confirmation,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 30),
      );
      _isListening = true;
      onListeningStarted?.call();
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Listen error: $e');
      _isListening = false;
      return false;
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    try {
      // Stop any ongoing TTS before speaking
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      // ignore: avoid_print
      print('TTS speak error: $e');
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (e) {
      // ignore: avoid_print
      print('TTS stop error: $e');
    }
  }

  bool get isListening => _isListening;
  bool get speechAvailable => _speechAvailable;
  String get lastWords => _lastWords;
}
