import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/config/colors.dart';
import 'package:health/size_config.dart';
import 'body.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SizeConfig().init(context);
    return Scaffold(
      // backgroundColor: Color.fromRGBO(32, 212, 137, 1),
      backgroundColor: primaryColor,
      body: Body(),
    );
  }
}
