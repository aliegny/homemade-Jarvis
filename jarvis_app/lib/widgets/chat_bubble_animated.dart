import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatBubbleAnimated extends StatefulWidget {
  final ChatMessage message;

  const ChatBubbleAnimated({super.key, required this.message});

  @override
  State<ChatBubbleAnimated> createState() => _ChatBubbleAnimatedState();
}

class _ChatBubbleAnimatedState extends State<ChatBubbleAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    final isUser = widget.message.isUser;

    _slideAnimation = Tween<Offset>(
      begin: Offset(isUser ? 0.3 : -0.3, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: widget.message.isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Align(
            alignment: widget.message.isUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: _buildBubble(),
          ),
        ),
      ),
    );
  }

  Widget _buildBubble() {
    final isUser = widget.message.isUser;
    final bgColor = _getBackgroundColor();

    return Container(
      margin: EdgeInsets.only(
        left: isUser ? 60 : 12,
        right: isUser ? 12 : 60,
        top: 5,
        bottom: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        gradient: isUser
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade700,
                  Colors.blue.shade500,
                ],
              )
            : null,
        color: isUser ? null : bgColor,
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: isUser
            ? null
            : Border.all(
                color: bgColor.withOpacity(0.5),
                width: 1,
              ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Source badge for AI messages
          if (!isUser && widget.message.source != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getSourceEmoji(),
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getSourceLabel(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getSourceColor(),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          // Message text
          Text(
            widget.message.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              height: 1.45,
            ),
          ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              _formatTime(widget.message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (widget.message.isUser) return Colors.blue.shade600;
    switch (widget.message.source) {
      case 'gemini':
        return const Color(0xFF1A1035);
      case 'local':
        return const Color(0xFF1A250D);
      case 'error':
        return const Color(0xFF2D0D0D);
      case 'system':
        return const Color(0xFF0F1629);
      default:
        return const Color(0xFF151A30);
    }
  }

  String _getSourceEmoji() {
    switch (widget.message.source) {
      case 'gemini':
        return '🌐';
      case 'local':
        return '🖥️';
      case 'error':
        return '⚠️';
      case 'system':
        return '🤖';
      default:
        return '';
    }
  }

  String _getSourceLabel() {
    switch (widget.message.source) {
      case 'gemini':
        return 'GEMINI';
      case 'local':
        return 'LOKAL MODEL';
      case 'error':
        return 'HATA';
      case 'system':
        return 'JARVIS';
      default:
        return '';
    }
  }

  Color _getSourceColor() {
    switch (widget.message.source) {
      case 'gemini':
        return Colors.blue.shade300;
      case 'local':
        return Colors.green.shade300;
      case 'error':
        return Colors.red.shade300;
      case 'system':
        return Colors.cyan.shade300;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
