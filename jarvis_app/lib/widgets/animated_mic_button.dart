import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedMicButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isListening;
  final bool isProcessing;

  const AnimatedMicButton({
    super.key,
    required this.onPressed,
    required this.isListening,
    required this.isProcessing,
  });

  @override
  State<AnimatedMicButton> createState() => _AnimatedMicButtonState();
}

class _AnimatedMicButtonState extends State<AnimatedMicButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _pressController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    _pressScale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );

    if (widget.isProcessing) {
      _rotateController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isProcessing && !oldWidget.isProcessing) {
      _rotateController.repeat();
    } else if (!widget.isProcessing && oldWidget.isProcessing) {
      _rotateController.stop();
      _rotateController.reset();
    }

    if (!widget.isListening && !widget.isProcessing) {
      _pulseController.stop();
      _pulseController.repeat();
    }
  }

  void _handleTapDown(TapDownDetails _) => _pressController.forward();
  void _handleTapUp(TapUpDetails _) {
    _pressController.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Center(
        child: SizedBox(
          width: 220,
          height: 220,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _pulseAnimation,
              _rotateAnimation,
              _pressScale,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pressScale.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ── LISTENING: two expanding pulse rings ──────────────────
                    if (widget.isListening) ...[
                      _buildPulseRing(
                        baseRadius: 84,
                        maxExtra: 50,
                        phaseOffset: 0.0,
                        color: Colors.blue.shade300,
                      ),
                      _buildPulseRing(
                        baseRadius: 76,
                        maxExtra: 34,
                        phaseOffset: 0.33,
                        color: Colors.blue.shade200,
                      ),
                      _buildPulseRing(
                        baseRadius: 68,
                        maxExtra: 20,
                        phaseOffset: 0.66,
                        color: Colors.blue.shade100,
                      ),
                    ],

                    // ── PROCESSING: spinning dashed arc ───────────────────────
                    if (widget.isProcessing) ...[
                      Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: CustomPaint(
                          size: const Size(170, 170),
                          painter: _DashedCirclePainter(
                            color: Colors.blue.shade400,
                            strokeWidth: 3,
                            dashCount: 10,
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: -_rotateAnimation.value * 1.5,
                        child: CustomPaint(
                          size: const Size(148, 148),
                          painter: _DashedCirclePainter(
                            color: Colors.purple.shade300,
                            strokeWidth: 2,
                            dashCount: 6,
                          ),
                        ),
                      ),
                    ],

                    // ── IDLE: subtle glowing ring ─────────────────────────────
                    if (!widget.isListening && !widget.isProcessing)
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.shade700
                                .withOpacity(0.4 + 0.3 * _pulseAnimation.value),
                            width: 1.5,
                          ),
                        ),
                      ),

                    // ── Main button body ──────────────────────────────────────
                    _buildMainButton(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPulseRing({
    required double baseRadius,
    required double maxExtra,
    required double phaseOffset,
    required Color color,
  }) {
    final phase = (_pulseAnimation.value + phaseOffset) % 1.0;
    final radius = baseRadius + maxExtra * phase;
    final opacity = (1 - phase) * 0.5;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(opacity),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildMainButton() {
    Color topColor;
    Color bottomColor;
    IconData icon;
    String label;

    if (widget.isListening) {
      topColor = const Color(0xFF1976D2);
      bottomColor = const Color(0xFF42A5F5);
      icon = Icons.mic_rounded;
      label = 'Dinleniyor...';
    } else if (widget.isProcessing) {
      topColor = const Color(0xFF6A1B9A);
      bottomColor = const Color(0xFF1565C0);
      icon = Icons.auto_awesome;
      label = 'İşleniyor...';
    } else {
      topColor = const Color(0xFF0D47A1);
      bottomColor = const Color(0xFF1976D2);
      icon = Icons.mic_none_rounded;
      label = 'Konuşmak için tıkla';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [topColor, bottomColor],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(
                  widget.isListening ? 0.7 : (widget.isProcessing ? 0.5 : 0.4),
                ),
                blurRadius: widget.isListening ? 28 : 18,
                spreadRadius: widget.isListening ? 6 : 2,
              ),
            ],
          ),
          child: Center(
            child: widget.isProcessing
                ? SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(
                        Colors.white.withOpacity(0.9),
                      ),
                    ),
                  )
                : Icon(icon, size: 46, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            label,
            key: ValueKey(label),
            style: TextStyle(
              color: Colors.blue.shade300,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _pressController.dispose();
    super.dispose();
  }
}

/// Custom painter for the dashed spinning ring
class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  const _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final dashAngle = (2 * math.pi) / (dashCount * 2);

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * 2 * dashAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashCount != dashCount;
}
