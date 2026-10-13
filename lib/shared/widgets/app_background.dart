import 'package:flutter/material.dart';

const appBackgroundGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF071A12),
    Color(0xFF0D251B),
    Color(0xFF141B12),
    Color(0xFF171008),
  ],
  stops: [0.0, 0.38, 0.72, 1.0],
);

class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: appBackgroundGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(painter: _AppBackgroundPainter()),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _AppBackgroundPainter extends CustomPainter {
  const _AppBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final topGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFD7A93C).withValues(alpha: 0.055),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.12, size.height * 0.12),
              radius: size.width * 0.68,
            ),
          );

    canvas.drawRect(Offset.zero & size, topGlow);

    final bottomGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF49A86B).withValues(alpha: 0.035),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.88, size.height * 0.84),
              radius: size.width * 0.64,
            ),
          );

    canvas.drawRect(Offset.zero & size, bottomGlow);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.8
      ..color = const Color(0xFFE7D9B1).withValues(alpha: 0.065);

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.08, size.height * 0.90),
        radius: size.width * 0.72,
      ),
      -0.80,
      1.50,
      false,
      line,
    );

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.96, size.height * 0.16),
        radius: size.width * 0.60,
      ),
      1.90,
      1.00,
      false,
      line,
    );

    line
      ..strokeWidth = 0.55
      ..color = Colors.white.withValues(alpha: 0.022);

    for (var i = 0; i < 6; i++) {
      final y = size.height * 0.76 + i * 16;
      canvas.drawLine(Offset(-20, y), Offset(size.width * 0.34, y - 52), line);
    }
  }

  @override
  bool shouldRepaint(covariant _AppBackgroundPainter oldDelegate) => false;
}
