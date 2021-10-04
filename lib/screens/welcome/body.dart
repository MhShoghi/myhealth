import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health/screens/register/register_screen.dart';
import 'package:health/screens/splash/splash_screen.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  double opacity = 1.0;
  @override
  void initState() {
    super.initState();
    opacity = 0;

    changeOpacity();

    Timer(
        Duration(seconds: 4),
        () => Navigator.of(context).push(_splashRoute()));
  }

  changeOpacity() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        opacity = 1;
        changeOpacity();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: AnimatedOpacity(
                    // If the widget is visible, animate to 0.0 (invisible).
                    // If the widget is hidden, animate to 1.0 (fully visible).
                    opacity: opacity,
                    duration: const Duration(seconds: 3),
                    // The green box must be a child of the AnimatedOpacity widget.
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Image.asset(
                          'assets/images/MyHealthLogo.png',
                        )),
                  ),
                ),
                Container(child: Image.asset('assets/images/winner.png'))
              ],
            ),
          ),
        ));
  }
}


Route _splashRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
         SplashScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end);
      final offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}