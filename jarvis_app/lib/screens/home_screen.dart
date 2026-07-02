import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import '../services/local_model_service.dart';
import '../services/speech_service.dart';
import '../services/connectivity_service.dart';
import '../widgets/animated_mic_button.dart';
import '../widgets/jarvis_background.dart';
import '../widgets/chat_bubble_animated.dart';
import '../widgets/loading_indicator.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  final LocalModelService _localModelService = LocalModelService();
  final SpeechService _speechService = SpeechService();

  late GeminiService _geminiService;
  late ConnectivityService _connectivityService;

  bool _isProcessing = false;
  bool _isListening = false;
  bool _hasInternet = false;
  bool _geminiInitialized = false;

  // Status bar info
  String _statusText = 'Bağlanıyor...';
  Color _statusColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeAll());
  }

  Future<void> _initializeAll() async {
    _geminiService = context.read<GeminiService>();
    _connectivityService = context.read<ConnectivityService>();

    // Welcome message
    _addMessage(ChatMessage(
      text: 'Merhaba! Ben Jarvis, yapay zeka asistanınım. '
          'Size nasıl yardımcı olabilirim?',
      isUser: false,
      source: 'system',
    ));

    // Initialize speech
    await _speechService.initialize();

    // Check connectivity and Gemini
    await _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    _hasInternet = await _connectivityService.hasInternet();
    await _checkGeminiKey();
    await _localModelService.checkAvailability();
    _updateStatusBar();
  }

  Future<void> _checkGeminiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('gemini_api_key') ?? '';

    if (apiKey.isEmpty) {
      setState(() => _geminiInitialized = false);
      return;
    }

    try {
      await _geminiService.initialize(apiKey);
      setState(() => _geminiInitialized = true);
    } catch (e) {
      setState(() => _geminiInitialized = false);
    }
  }

  void _updateStatusBar() {
    String text;
    Color color;

    if (_hasInternet && _geminiInitialized) {
      text = '🌐 Gemini Aktif';
      color = Colors.blue.shade400;
    } else if (_localModelService.isAvailable) {
      text = '🖥️ Lokal Model Aktif';
      color = Colors.green.shade400;
    } else if (_hasInternet && !_geminiInitialized) {
      text = '⚙️ API Key Gerekli';
      color = Colors.orange.shade400;
    } else {
      text = '⚠️ Çevrimdışı - Lokal model bulunamadı';
      color = Colors.red.shade400;
    }

    setState(() {
      _statusText = text;
      _statusColor = color;
    });
  }

  void _addMessage(ChatMessage msg) {
    setState(() => _messages.add(msg));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String userText) async {
    final trimmed = userText.trim();
    if (trimmed.isEmpty) return;

    _textController.clear();
    _inputFocusNode.unfocus();

    _addMessage(ChatMessage(text: trimmed, isUser: true));
    setState(() => _isProcessing = true);

    try {
      ChatMessage aiResponse;

      // Refresh internet status before each call
      _hasInternet = await _connectivityService.hasInternet();

      if (_hasInternet && _geminiInitialized) {
        aiResponse = await _geminiService.sendMessage(trimmed);
      } else if (await _localModelService.checkAvailability()) {
        aiResponse = await _localModelService.sendMessage(trimmed);
      } else {
        aiResponse = ChatMessage(
          text: 'İnternet bağlantısı yok ve lokal model çalışmıyor. '
              'Lütfen bağlantınızı kontrol edin veya ayarlardan '
              'Gemini API key ekleyin.',
          isUser: false,
          source: 'error',
        );
      }

      _addMessage(aiResponse);

      // Speak the response (non-blocking)
      if (aiResponse.source != 'error') {
        _speechService.speak(aiResponse.text);
      }
    } catch (e) {
      _addMessage(ChatMessage(
        text: 'Hata oluştu: $e',
        isUser: false,
        source: 'error',
      ));
    } finally {
      setState(() => _isProcessing = false);
      _updateStatusBar();
    }
  }

  Future<void> _toggleVoiceInput() async {
    if (_isListening) {
      // Stop listening and send whatever was recognized
      await _speechService.stopListening();
      setState(() => _isListening = false);

      final words = _textController.text.trim();
      if (words.isNotEmpty) {
        await _sendMessage(words);
      }
    } else {
      // Stop TTS if speaking
      await _speechService.stopSpeaking();

      final started = await _speechService.startListening(
        onResult: (words, isFinal) {
          setState(() {
            _textController.text = words;
            _isListening = !isFinal;
          });

          if (isFinal && words.isNotEmpty) {
            _sendMessage(words);
          }
        },
        onListeningStarted: () => setState(() => _isListening = true),
      );

      if (!started) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Mikrofon kullanılamıyor. İzin verdiğinizden emin olun.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _clearChat() {
    setState(() => _messages.clear());
    _geminiService.clearHistory();
    _localModelService.clearHistory();
    _addMessage(ChatMessage(
      text: 'Sohbet temizlendi. Nasıl yardımcı olabilirim?',
      isUser: false,
      source: 'system',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060A1A),
      appBar: _buildAppBar(),
      body: JarvisBackground(
        isActive: _isListening || _isProcessing,
        child: Column(
          children: [
            // Status bar
            _buildStatusBar(),

            // Chat list
            Expanded(child: _buildChatList()),

            // Mic button area
            _buildMicArea(),

            // Text input
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF060A1A),
      elevation: 0,
      centerTitle: true,
      title: Text(
        'J A R V I S',
        style: GoogleFonts.orbitron(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.blue.shade300,
          letterSpacing: 6,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.grey),
          tooltip: 'Sohbeti Temizle',
          onPressed: _clearChat,
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.grey),
          tooltip: 'Ayarlar',
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
            _refreshStatus();
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildStatusBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: _statusColor.withOpacity(0.08),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _statusColor,
              boxShadow: [
                BoxShadow(color: _statusColor.withOpacity(0.6), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _statusText,
            style: TextStyle(
              fontSize: 11,
              color: _statusColor,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          if (_isProcessing)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: _statusColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _messages.length + (_isProcessing ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isProcessing && index == _messages.length) {
          return const LoadingIndicator();
        }
        return ChatBubbleAnimated(message: _messages[index]);
      },
    );
  }

  Widget _buildMicArea() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: AnimatedMicButton(
        onPressed: _isProcessing ? () {} : _toggleVoiceInput,
        isListening: _isListening,
        isProcessing: _isProcessing,
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1F),
        border: Border(
          top: BorderSide(
            color: Colors.blue.shade900.withOpacity(0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: const Color(0xFF151A35),
                border: Border.all(
                  color: Colors.blue.shade800.withOpacity(0.4),
                ),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _inputFocusNode,
                enabled: !_isProcessing,
                style: const TextStyle(color: Colors.white, fontSize: 14.5),
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (val) => _sendMessage(val),
                decoration: InputDecoration(
                  hintText: 'Mesajınızı yazın...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _isProcessing ? null : () => _sendMessage(_textController.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isProcessing
                      ? [Colors.grey.shade700, Colors.grey.shade600]
                      : [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: _isProcessing
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }
}
