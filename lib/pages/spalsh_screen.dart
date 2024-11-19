import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:imraatun/pages/home_screen.dart'; // Adjust the path to HomeScreen

class SplashScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged; // Add onLanguageChanged callback

  const SplashScreen({super.key, required this.onLanguageChanged});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _logoOpacity = 0.0; // Initial opacity of the logo
  double _textOpacity = 0.0; // Initial opacity of the text
  double _scale = 0.5; // Initial scale for logo animation

  @override
  void initState() {
    super.initState();
    _startAnimations();
    _navigateToHome();
  }

  // Function to start animations for logo and text
  void _startAnimations() {
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _logoOpacity = 1.0; // Fade in the logo
        _scale = 1.0; // Scale up the logo
      });
    });

    Timer(const Duration(seconds: 1), () {
      setState(() {
        _textOpacity = 1.0; // Fade in the text
      });
    });
  }

  // Function to navigate to HomeScreen after 3 seconds
  void _navigateToHome() {
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            onLanguageChanged:
                widget.onLanguageChanged, // Pass the callback to HomeScreen
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.5, end: _scale),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: AnimatedOpacity(
                    opacity: _logoOpacity,
                    duration: const Duration(seconds: 1),
                    child: SvgPicture.asset(
                      'assets/svgs/3.svg', // Update with your actual logo asset
                      height: 150,
                      width: 150,
                    ),
                  ),
                );
              },
            ),
            AnimatedOpacity(
              opacity: _textOpacity,
              duration: const Duration(seconds: 1),
              child: SvgPicture.asset(
                'assets/svgs/yassminetext.svg',
                height: 120,
                width: 120,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
