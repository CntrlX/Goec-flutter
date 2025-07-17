import 'package:flutter/material.dart';
import 'dart:math' as math;

class ChargingProgress extends StatefulWidget {
  final double progress;
  const ChargingProgress({Key? key, required this.progress}) : super(key: key);

  @override
  State<ChargingProgress> createState() => _ChargingProgressState();
}

class _ChargingProgressState extends State<ChargingProgress> {
  double convertRange(double value, double minInput, double maxInput,
      double minOutput, double maxOutput) {
    if (value < minInput) {
      return minOutput;
    }
    if (value > maxInput) {
      return maxOutput;
    }
    return (value - minInput) /
            (maxInput - minInput) *
            (maxOutput - minOutput) +
        minOutput;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(189, 190),
            painter: RPSCustomPainter(
                progress: convertRange(widget.progress, 0.2, 1.0, 0.0, 1.0)),
          ),
          Positioned(
            top: -28,
            right: -44,
            child: CustomPaint(
              size: const Size(189, 190),
              painter: TiltedRectanglePainter(
                  progress: convertRange(widget.progress, 0.0, 0.2, 0.0, 1.0)),
            ),
          ),
        ],
      ),
    );
  }
}

class RPSCustomPainter extends CustomPainter {
  final double progress;

  RPSCustomPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.width / 2) - (32 / 2);
    final center = Offset(size.width / 2, size.height / 2);
    const startAngle = -math.pi / 4.5;
    final sweepAngle = 2 * math.pi * progress;

    // Path path_0 = Path();
    // path_0.moveTo(181.142, 58.4194);
    // path_0.lineTo(153.386, 77.1294);
    // path_0.cubicTo(161.082, 102.356, 151.872, 130.61, 128.867, 146.083);
    // path_0.cubicTo(100.69, 165.087, 62.4203, 157.645, 43.4112, 129.433);
    // path_0.cubicTo(24.4023, 101.263, 31.8881, 63.0023, 60.065, 43.9978);
    // path_0.cubicTo(80.5459, 30.2073, 106.326, 30.3334, 126.134, 42.2741);
    // path_0.lineTo(154.9, 22.8913);
    // path_0.cubicTo(123.568, -3.3446, 77.4761, -6.96047, 41.8971, 17.005);
    // path_0.cubicTo(-1.16737, 46.1001, -12.5643, 104.585, 16.4958, 147.639);
    // path_0.cubicTo(45.556, 190.735, 104.013, 202.087, 147.077, 173.076);
    // path_0.cubicTo(185.053, 147.47, 198.427, 99.0766, 181.142, 58.4194);
    // path_0.close();

    // Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    // paint0Fill.color = const Color(0xffF2F2F2).withOpacity(1.0);
    // canvas.drawPath(path_0, paint0Fill);

    final path = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xffF2F2F2).withOpacity(1.0),
          const Color(0xffF2F2F2).withOpacity(1.0)
        ],
        startAngle: 0,
        endAngle: math.pi * 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.square;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      6,
      false,
      path,
    );

    final foregroundPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xff3B66FF).withOpacity(1),
          const Color(0xff3B66FF).withOpacity(1),
          const Color(0xff45FFBC).withOpacity(1),
          const Color(0xff45FFBC).withOpacity(1),
          const Color(0xff3B66FF).withOpacity(1),
          const Color(0xff3B66FF).withOpacity(1),
        ],
        startAngle: 0,
        endAngle: math.pi * 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      foregroundPaint,
    );

    // Path path_2 = Path();
    // path_2.moveTo(153.386, 77.1294);
    // path_2.lineTo(108.008, 107.738);
    // path_2.cubicTo(100.648, 112.699, 90.6813, 110.723, 85.7188, 103.407);
    // path_2.cubicTo(80.7563, 96.0495, 82.6907, 86.0427, 90.0505, 81.0815);
    // path_2.lineTo(163.731, 31.3846);
    // path_2.cubicTo(166.927, 34.7902, 169.829, 38.4901, 172.521, 42.4843);
    // path_2.cubicTo(175.969, 47.6137, 178.829, 52.9535, 181.142, 58.4194);
    // path_2.lineTo(153.386, 77.1294);
    // path_2.close();

    // Paint paint2Fill = Paint()..style = PaintingStyle.fill;
    // paint2Fill.color = const Color(0xffF2F2F2).withOpacity(1.0);
    // canvas.drawPath(path_2, paint2Fill);

    Path path_3 = Path();
    path_3.moveTo(73.5164, 85.7327);
    path_3.lineTo(97.1544, 120.803);
    path_3.cubicTo(97.4487, 121.266, 98.0795, 121.35, 98.5002, 121.055);
    path_3.lineTo(117.511, 108.23);
    path_3.cubicTo(117.974, 107.935, 118.058, 107.305, 117.764, 106.884);
    path_3.lineTo(94.126, 71.8142);
    path_3.cubicTo(93.8317, 71.3515, 93.2006, 71.2674, 92.7801, 71.5617);
    path_3.lineTo(73.7687, 84.3871);
    path_3.cubicTo(73.3483, 84.6814, 73.2219, 85.2702, 73.5164, 85.7327);
    path_3.close();

    Paint paint3Fill = Paint()..style = PaintingStyle.fill;
    paint3Fill.color = const Color(0xff3B66FF).withOpacity(1.0);
    canvas.drawPath(path_3, paint3Fill);

    Path path_4 = Path();
    path_4.moveTo(63.6458, 104.016);
    path_4.cubicTo(64.4442, 105.193, 66.0831, 105.53, 67.2597, 104.731);
    path_4.lineTo(81.506, 95.0983);
    path_4.cubicTo(82.6827, 94.2993, 83.019, 92.6587, 82.2204, 91.481);
    path_4.cubicTo(81.422, 90.3032, 79.7831, 89.9668, 78.6062, 90.7661);
    path_4.lineTo(64.3602, 100.398);
    path_4.cubicTo(63.1835, 101.198, 62.8472, 102.796, 63.6458, 104.016);
    path_4.close();

    Paint paint4Fill = Paint()..style = PaintingStyle.fill;
    paint4Fill.color = const Color(0xff3B66FF).withOpacity(1.0);
    canvas.drawPath(path_4, paint4Fill);

    Path path_5 = Path();
    path_5.moveTo(77.1229, 108.624);
    path_5.cubicTo(77.921, 109.802, 79.559, 110.138, 80.735, 109.339);
    path_5.lineTo(94.9732, 99.7071);
    path_5.cubicTo(96.1492, 98.9079, 96.485, 97.2675, 95.6872, 96.0898);
    path_5.cubicTo(94.889, 94.912, 93.251, 94.5754, 92.0751, 95.3746);
    path_5.lineTo(77.837, 105.007);
    path_5.cubicTo(76.6189, 105.806, 76.325, 107.404, 77.1229, 108.624);
    path_5.close();

    Paint paint5Fill = Paint()..style = PaintingStyle.fill;
    paint5Fill.color = const Color(0xff3B66FF).withOpacity(1.0);
    canvas.drawPath(path_5, paint5Fill);

    Path path_6 = Path();
    path_6.moveTo(76.4701, 123.101);
    path_6.cubicTo(77.271, 124.279, 78.915, 124.615, 80.0953, 123.816);
    path_6.lineTo(94.3863, 114.184);
    path_6.cubicTo(95.5667, 113.385, 95.904, 111.744, 95.1029, 110.567);
    path_6.cubicTo(94.3021, 109.389, 92.658, 109.052, 91.4777, 109.851);
    path_6.lineTo(77.1867, 119.484);
    path_6.cubicTo(75.9642, 120.283, 75.669, 121.881, 76.4701, 123.101);
    path_6.close();

    Paint paint6Fill = Paint()..style = PaintingStyle.fill;
    paint6Fill.color = const Color(0xff3B66FF).withOpacity(1.0);
    canvas.drawPath(path_6, paint6Fill);

    Path path_7 = Path();
    path_7.moveTo(103.329, 88.0978);
    path_7.lineTo(93.2597, 92.4273);
    path_7.lineTo(95.2821, 95.6219);
    path_7.lineTo(85.9708, 99.4048);
    path_7.lineTo(100.759, 97.6815);
    path_7.lineTo(98.6526, 94.487);
    path_7.lineTo(106.784, 93.4781);
    path_7.lineTo(103.329, 88.0978);
    path_7.close();

    Paint paint7Fill = Paint()..style = PaintingStyle.fill;
    paint7Fill.color = Colors.white.withOpacity(1.0);
    canvas.drawPath(path_7, paint7Fill);

    Path path_8 = Path();
    path_8.moveTo(154.991, 22.2515);
    path_8.cubicTo(158.135, 24.8851, 161.103, 27.7203, 163.878, 30.7372);
    path_8.lineTo(135.608, 49.7802);
    path_8.cubicTo(132.509, 46.9315, 129.113, 44.4013, 125.471, 42.2415);
    path_8.lineTo(154.991, 22.2515);
    path_8.close();

    Paint paint8Fill = Paint()..style = PaintingStyle.fill;
    paint8Fill.color = Colors.white.withOpacity(1.0);
    canvas.drawPath(path_8, paint8Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class TiltedRectanglePainter extends CustomPainter {
  final double progress;

  TiltedRectanglePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBackground = Paint()
      ..color = const Color(0xffF2F2F2).withOpacity(1.0)
      ..style = PaintingStyle.fill;

    final paintForeground = Paint()
      ..color = const Color(0xff3B66FF).withOpacity(1)
      ..style = PaintingStyle.fill;

    // Rectangle dimensions
    double rectWidth = 80;
    double rectHeight = 32;
    double angle = math.pi / 0.551; // 45 degrees in radians

    // Center of the canvas
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    // Calculate the positions of the rectangle corners
    Offset topLeft = Offset(
      centerX -
          (rectWidth / 2) * math.cos(angle) -
          (rectHeight / 2) * math.sin(angle),
      centerY -
          (rectWidth / 2) * math.sin(angle) +
          (rectHeight / 2) * math.cos(angle),
    );

    Offset topRight = Offset(
      centerX +
          (rectWidth / 2) * math.cos(angle) -
          (rectHeight / 2) * math.sin(angle),
      centerY +
          (rectWidth / 2) * math.sin(angle) +
          (rectHeight / 2) * math.cos(angle),
    );

    Offset bottomRight = Offset(
      centerX +
          (rectWidth / 2) * math.cos(angle) +
          (rectHeight / 2) * math.sin(angle),
      centerY +
          (rectWidth / 2) * math.sin(angle) -
          (rectHeight / 2) * math.cos(angle),
    );

    Offset bottomLeft = Offset(
      centerX -
          (rectWidth / 2) * math.cos(angle) +
          (rectHeight / 2) * math.sin(angle),
      centerY -
          (rectWidth / 2) * math.sin(angle) -
          (rectHeight / 2) * math.cos(angle),
    );

    // Create a path for the full tilted rectangle background
    Path backgroundPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();

    // Draw the background path
    canvas.drawPath(backgroundPath, paintBackground);

    // Calculate the positions for the filled progress part
    Offset progressTopRight = Offset(
      topLeft.dx + (topRight.dx - topLeft.dx) * progress,
      topLeft.dy + (topRight.dy - topLeft.dy) * progress,
    );

    Offset progressBottomRight = Offset(
      bottomLeft.dx + (bottomRight.dx - bottomLeft.dx) * progress,
      bottomLeft.dy + (bottomRight.dy - bottomLeft.dy) * progress,
    );

    // Create a path for the progress
    Path progressPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(progressTopRight.dx, progressTopRight.dy)
      ..lineTo(progressBottomRight.dx, progressBottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();

    // Draw the progress path
    canvas.drawPath(progressPath, paintForeground);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
