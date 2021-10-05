import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/screens/welcome/welcome_screen.dart';


void main() {
  SystemChrome.setEnabledSystemUIOverlays([
    SystemUiOverlay.top,
  ]);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyHealth',
      darkTheme: ThemeData(brightness: Brightness.dark),
      theme: ThemeData(fontFamily: 'Dana'),
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}
