import 'package:flutter/material.dart';

class GradientProgressIndicator extends StatelessWidget {
  final double progress; // بين 0.0 و 1.0
  final double size;
  final double strokeWidth;
  final List<Color> gradientColors;

  const GradientProgressIndicator({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 8,
    this.gradientColors = const [Color(0xFF006A6A), Color(0xFFFF7043)],
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: _GradientProgressPainter(
            progress: value,
            strokeWidth: strokeWidth,
            gradientColors: gradientColors,
          ),
        );
      },
    );
  }
}

class _GradientProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;

  _GradientProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // دائرة الخلفية
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, backgroundPaint);

    // قوس التقدم
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // تطبيق التدرج اللوني
    progressPaint.shader = SweepGradient(
      colors: gradientColors,
      startAngle: -0.5 * 3.14, // يبدأ من الأعلى
      endAngle: 2.5 * 3.14,
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5 * 3.14, // زاوية البداية
      2 * 3.14 * progress, // زاوية النهاية
      false,
      progressPaint,
    );

    // نص النسبة المئوية
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).toInt()}%',
        style: TextStyle(
          color: gradientColors.last,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _GradientProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.gradientColors != gradientColors;
  }
}