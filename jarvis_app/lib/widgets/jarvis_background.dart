import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Full-screen animated background for the Jarvis app.
/// Shows a dynamic radial glow and floating particle grid when [isActive].
class JarvisBackground extends StatefulWidget {
  final Widget child;
  final bool isActive;

  const JarvisBackground({
    super.key,
    required this.child,
    this.isActive = false,
  });

  @override
  State<JarvisBackground> createState() => _JarvisBackgroundState();
}

class _JarvisBackgroundState extends State<JarvisBackground>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _gridController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat(reverse: true);

    _gridController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF060A1A),
            Color(0xFF0A0E27),
            Color(0xFF0D1220),
            Color(0xFF060A1A),
          ],
          stops: [0.0, 0.35, 0.65, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Dot grid
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _gridController,
              builder: (_, __) => CustomPaint(
                painter: _GridPainter(progress: _gridController.value),
              ),
            ),
          ),

          // Radial glow (active state)
          if (widget.isActive)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (_, __) => CustomPaint(
                  painter: _GlowPainter(intensity: _glowAnimation.value),
                ),
              ),
            ),

          // Content
          widget.child,
        ],
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _gridController.dispose();
    super.dispose();
  }
}

/// Subtle animated dot grid
class _GridPainter extends CustomPainter {
  final double progress;
  _GridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 32.0;
    const dotRadius = 1.0;

    final paint = Paint()
      ..style = PaintingStyle.fill;

    final cols = (size.width / spacing).ceil() + 1;
    final rows = (size.height / spacing).ceil() + 1;

    for (int col = 0; col < cols; col++) {
      for (int row = 0; row < rows; row++) {
        final x = col * spacing;
        final y = row * spacing;

        // Wave effect: brightness follows sine wave
        final wave = (math.sin((col + row) * 0.4 + progress * 2 * math.pi) +
                1) /
            2;
        final opacity = 0.04 + wave * 0.08;

        paint.color = Colors.blue.shade200.withOpacity(opacity);
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.progress != progress;
}

/// Radial glow overlay when Jarvis is active
class _GlowPainter extends CustomPainter {
  final double intensity;
  _GlowPainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.4);
    final radius = size.height * 0.9;

    final gradient = RadialGradient(
      colors: [
        const Color(0xFF1565C0).withOpacity(0.12 + intensity * 0.08),
        const Color(0xFF42A5F5).withOpacity(0.04 + intensity * 0.04),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.intensity != intensity;
}
