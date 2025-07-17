import 'package:flutter/material.dart';
import 'dart:math' as math;

class ChargingLoader extends StatefulWidget {
  const ChargingLoader({super.key});

  @override
  State<ChargingLoader> createState() => _ChargingLoaderState();
}

class _ChargingLoaderState extends State<ChargingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..addListener(() {
        setState(() {});
      });
    _animationController.repeat();
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(189, 190),
            painter: RPSCustomPainter(),
          ),
          RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: CustomPaint(
              size: const Size(189, 190),
              painter: RPSLoaderPainter(),
            ),
          ),
          CustomPaint(
            size: const Size(189, 190),
            painter: RPSOverlayPainter(),
          ),
        ],
      ),
    );
  }
}

class RPSOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
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

class RPSLoaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(188.692, 94.4088);
    path_0.cubicTo(188.692, 146.375, 146.565, 188.501, 94.5997, 188.501);
    path_0.cubicTo(59.9964, 188.501, 29.7559, 169.822, 13.4111, 141.997);
    path_0.cubicTo(15.609, 142.77, 17.9727, 143.19, 20.4346, 143.19);
    path_0.cubicTo(31.5528, 143.19, 40.6698, 134.621, 41.5425, 123.728);
    path_0.cubicTo(51.8746, 142.385, 71.762, 155.017, 94.5997, 155.017);
    path_0.cubicTo(128.072, 155.017, 155.208, 127.882, 155.208, 94.4088);
    path_0.cubicTo(155.208, 60.9359, 128.072, 33.8009, 94.5997, 33.8009);
    path_0.cubicTo(79.3199, 33.8009, 65.3607, 39.4552, 54.7005, 48.7856);
    path_0.cubicTo(55.0069, 47.3517, 55.1682, 45.864, 55.1682, 44.3386);
    path_0.cubicTo(55.1682, 32.6433, 45.6872, 23.1623, 33.9919, 23.1623);
    path_0.cubicTo(33.6987, 23.1623, 33.4069, 23.1683, 33.1167, 23.18);
    path_0.cubicTo(49.6071, 8.93318, 71.0971, 0.316284, 94.5997, 0.316284);
    path_0.cubicTo(146.565, 0.316284, 188.692, 42.4429, 188.692, 94.4088);
    path_0.close();

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = const Color(0xffF2F2F2).withOpacity(1.0);
    canvas.drawPath(path_0, paint0Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.width / 2) - (32 / 2);
    final center = Offset(size.width / 2, size.height / 2);
    const startAngle = -math.pi / 6;

    Path path_2 = Path();
    path_2.moveTo(153.386, 77.1294);
    path_2.lineTo(108.008, 107.738);
    path_2.cubicTo(100.648, 112.699, 90.6813, 110.723, 85.7188, 103.407);
    path_2.cubicTo(80.7563, 96.0495, 82.6907, 86.0427, 90.0505, 81.0815);
    path_2.lineTo(163.731, 31.3846);
    path_2.cubicTo(166.927, 34.7902, 169.829, 38.4901, 172.521, 42.4843);
    path_2.cubicTo(175.969, 47.6137, 178.829, 52.9535, 181.142, 58.4194);
    path_2.lineTo(153.386, 77.1294);
    path_2.close();

    Paint paint2Fill = Paint()..style = PaintingStyle.fill;
    paint2Fill.color = const Color(0xffF2F2F2).withOpacity(1.0);
    canvas.drawPath(path_2, paint2Fill);

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
      7,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
