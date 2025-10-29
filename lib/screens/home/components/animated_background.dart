import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.brightness == Brightness.light
        ? Colors.white
        : Colors.black;
    final circleColor = theme.brightness == Brightness.light
        ? Colors.deepPurple[100]
        : Colors.deepPurple[900];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: CirclePainter(_animation.value, circleColor!),
          child: Container(
            color: backgroundColor,
          ),
        );
      },
    );
  }
}

class CirclePainter extends CustomPainter {
  final double value;
  final Color color;

  CirclePainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color.withOpacity(0.5);

    final double maxRadius = size.width * 0.4;
    final double radius1 = maxRadius * (0.5 + 0.5 * (1 - value));
    final double radius2 = maxRadius * (0.5 + 0.5 * (0.5 - value));
    final double radius3 = maxRadius * (0.5 + 0.5 * value);

    canvas.drawCircle(
        Offset(size.width * 0.3, size.height * 0.3), radius1, paint);
    canvas.drawCircle(
        Offset(size.width * 0.7, size.height * 0.5), radius2, paint);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.7), radius3, paint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
