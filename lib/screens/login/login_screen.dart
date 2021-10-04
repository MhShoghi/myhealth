import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';

import 'package:health/screens/login/components/body.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLightColor,
      body: LoginBody(),
    );
  }
}
