import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:our_mobile_app/screens/onboding/components/LogInClass.dart';
import 'package:our_mobile_app/screens/onboding/components/SignUpClass.dart';
import 'SignUPform.dart';
import 'dart:math' as math;

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void toggleForm() {
    if (_pageController.page == 0) {
      _pageController.animateToPage(
        1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _animationController.forward();
    } else {
      _pageController.animateToPage(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // backgroundColor: Color.fromRGBO(58, 28, 113, 1),
      //   title: Text('Auth Screen'),
      // ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: TrianglePainter(rotation: _animation.value),
                child: Container(),
              );
            },
          ),
          Center(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70.0, sigmaY: 70.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0),
                ),
              ),
            ),
          ),
          PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              LogInPage(toggleForm: toggleForm),
              SignUpPage(toggleForm: toggleForm),


            ],
          ),
        ],
      ),
    );
  }
}




class TrianglePainter extends CustomPainter {
  final double rotation;

  TrianglePainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.fill;

    final path = Path();

    // Calculate the triangle position based on rotation
    final triangleSize = 900.0;
    final offsetX = size.width / 1 - triangleSize / 1;
    final offsetY = size.height / 2 - triangleSize / 2;
    final radians = rotation * math.pi;

    path.moveTo(offsetX + triangleSize / 2, offsetY);
    path.lineTo(offsetX, offsetY + triangleSize);
    path.lineTo(offsetX + triangleSize, offsetY + triangleSize);
    path.close();

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(radians);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
