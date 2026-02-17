import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:texty/views/widgets/common_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _textScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _textScaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.go('/login');
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return CommonBackground(
      child: Stack(
        children: [
          // App Name Scaling
          Center(
            child: ScaleTransition(
              scale: _textScaleAnimation,
              child: Image.asset(
                'assets/images/app_name.png',
                width: 250,
              ),
            ),
          ),

          // Plane Animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double planeX;
              double planeY = screenSize.height / 2;
              double rotation = 0;

              if (_controller.value < 0.2) {
                // Not visible yet
                planeX = -150;
              } else if (_controller.value < 0.4) {
                // Moving from left to loop start
                planeX = -150 +
                    (screenSize.width * 0.4 + 150) *
                        ((_controller.value - 0.2) / 0.2);
              } else if (_controller.value < 0.8) {
                // Circular loop around the first part of the text
                double loopProgress = (_controller.value - 0.4) / 0.4;
                double angle = loopProgress * 2 * math.pi;
                double radius = 60;

                // Center of the loop (around the 'T' in 'Texty')
                double centerX = screenSize.width / 2 - 60;
                double centerY = screenSize.height / 2;

                planeX = centerX + radius * math.cos(angle - math.pi / 2);
                planeY = centerY + radius * math.sin(angle - math.pi / 2);

                // Rotation to face the path
                rotation = angle;
              } else {
                // Moving to final position at 'ty'
                double moveProgress = (_controller.value - 0.8) / 0.2;
                double startX = screenSize.width / 2 - 60;
                double endX = screenSize.width / 2 + 40; // Positioned near 'ty'

                planeX = startX + (endX - startX) * moveProgress;
                planeY = screenSize.height / 2 +
                    30; // Moved further down as requested
                rotation = 0.2; // Slight tilt
              }

              return Positioned(
                left: planeX,
                top: planeY - 50, // Offset half plane height (100/2)
                child: Transform.rotate(
                  angle: rotation,
                  child: Image.asset(
                    'assets/images/plane.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
