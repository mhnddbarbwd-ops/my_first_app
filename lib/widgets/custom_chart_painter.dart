import 'package:flutter/material.dart';

class CustomChartPainter extends StatelessWidget {
  final List<double> dataPoints; // نقاط البيانات
  final double maxValue; // أقصى قيمة للرسم
  final List<Color> gradientColors;

  const CustomChartPainter({
    super.key,
    required this.dataPoints,
    this.maxValue = 10000,
    this.gradientColors = const [Color(0xFF006A6A), Color(0xFFFF7043)],
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width - 40, 200),
      painter: _ChartPainter(dataPoints, maxValue, gradientColors),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final double maxValue;
  final List<Color> gradientColors;

  _ChartPainter(this.dataPoints, this.maxValue, this.gradientColors);

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // إنشاء التدرج اللوني
    paint.shader = LinearGradient(
      colors: gradientColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final stepX = size.width / (dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = size.height - (dataPoints[i] / maxValue) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // استخدام منحنيات بيزيه (Cubic Bezier) لتنعيم الخط
        final prevX = (i - 1) * stepX;
        final prevY = size.height - (dataPoints[i - 1] / maxValue) * size.height;
        final controlX = prevX + (x - prevX) / 2;
        path.cubicTo(controlX, prevY, controlX, y, x, y);
      }
    }

    canvas.drawPath(path, paint);

    // رسم النقاط (دوائر صغيرة) على كل عقدة
    final pointPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = gradientColors.last;
    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = size.height - (dataPoints[i] / maxValue) * size.height;
      canvas.drawCircle(Offset(x, y), 5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints || oldDelegate.maxValue != maxValue;
  }
}