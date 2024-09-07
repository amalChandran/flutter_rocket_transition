import 'dart:math' as math;
import 'package:flutter/material.dart';

class SteepEndCurve extends Curve {
  final double steepness;

  const SteepEndCurve({this.steepness = 15.0});

  @override
  double transformInternal(double t) {
    if (t >= 0.95) {
      // Steep increase in the last 10% of the animation
      return math.pow((t - 0.9) * 10, steepness).toDouble();
    } else {
      // Flat for the first 90% of the animation
      return 0.0;
    }
  }
}

class RocketExhaustPainter extends CustomPainter {
  final double amplitude = 10;
  final double wavelength = 200;
  final double outerPhaseShift;
  final double innerPhaseShift;
  final double launchProgress1;
  final double bottomWidthProgress;

  RocketExhaustPainter({
    required this.outerPhaseShift,
    required this.innerPhaseShift,
    required this.bottomWidthProgress,
    required this.launchProgress1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final canvasBgPaint = Paint()
      ..color = Color.fromARGB(255, 116, 4, 208)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), canvasBgPaint);

    final paintFill = Paint()
      ..color = Color.fromARGB(255, 144, 8, 251)
      ..style = PaintingStyle.fill;

    final paint1Fill = Paint()
      ..color = Color.fromARGB(255, 168, 70, 253)
      ..style = PaintingStyle.fill;

    final completeWavePath = getCompleteWave(size, 20, outerPhaseShift);
    canvas.drawPath(completeWavePath, paintFill);

    final completeWavePath1 = getCompleteWave(size, 0, innerPhaseShift);
    canvas.drawPath(completeWavePath1, paint1Fill);
  }

  Path getCompleteWave(Size size, double shiftX, double phaseShift) {
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    final path = Path();
    final startY = height - launchProgress1; //(height * launchProgress);

    // Calculate the bottom width based on the animation progress
    final maxBottomWidth = width * 2; // Adjust this value as needed
    final currentBottomWidth = maxBottomWidth * bottomWidthProgress;

    final leftBottomX = centerX - (currentBottomWidth / 2);
    final rightBottomX = centerX + (currentBottomWidth / 2);

    {
      final startX = centerX - shiftX;
      final endX = leftBottomX - shiftX; //-shiftX;
      const direction = -1;

      path.moveTo(startX, startY);

      for (double t = 0; t <= 1; t += 0.01) {
        final x = startX + direction * (startX - endX) * t;
        final baseY = startY + (height - startY) * t;

        final distance =
            math.sqrt(math.pow(x - startX, 2) + math.pow(baseY - startY, 2));
        final waveOffset = amplitude *
            math.sin(2 * math.pi * distance / wavelength + phaseShift);

        final angle = math.atan2(height - startY - 0, endX - startX);
        final perpendicularAngle = angle + (-math.pi / 2);

        final offsetX = waveOffset * math.cos(perpendicularAngle);
        final offsetY = waveOffset * math.sin(perpendicularAngle);

        path.lineTo(x + offsetX, baseY + offsetY);
      }
    }
    {
      final startX1 = centerX + shiftX;
      final endX1 = rightBottomX; //width + shiftX;
      final direction1 = 1;

      // Draw bottom connecting line
      path.lineTo(endX1, height);

      for (double t = 1; t >= 0; t -= 0.01) {
        final x = startX1 + direction1 * (endX1 - startX1) * t;
        final baseY = startY + (height - startY) * t;

        final distance =
            math.sqrt(math.pow(x - startX1, 2) + math.pow(baseY - startY, 2));
        final waveOffset = amplitude *
            math.sin(2 * math.pi * distance / wavelength + phaseShift);

        final angle = math.atan2(height - startY, endX1 - startX1);
        final perpendicularAngle = angle + (math.pi / 2);

        final offsetX = waveOffset * math.cos(perpendicularAngle);
        final offsetY = waveOffset * math.sin(perpendicularAngle);

        path.lineTo(x + offsetX, baseY + offsetY);
      }
    }
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RocketExhaustWidget extends StatefulWidget {
  double launchProgress;
  RocketExhaustWidget({super.key, required this.launchProgress});

  @override
  _RocketExhaustWidgetState createState() => _RocketExhaustWidgetState();
}

class _RocketExhaustWidgetState extends State<RocketExhaustWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bottomWidthController;

  late Animation<double> _bottomWidthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();

    _bottomWidthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bottomWidthAnimation = CurvedAnimation(
      parent: _bottomWidthController,
      curve: SteepEndCurve(steepness: 30.0),
    );

    _bottomWidthController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _bottomWidthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _bottomWidthAnimation]),
      builder: (context, child) {
        return CustomPaint(
          painter: RocketExhaustPainter(
            outerPhaseShift: -_controller.value * 2 * math.pi,
            innerPhaseShift: -_controller.value * 4 * math.pi,
            bottomWidthProgress: _bottomWidthAnimation.value,
            launchProgress1: widget.launchProgress,
          ),
          child: Container(),
        );
      },
    );
  }
}
