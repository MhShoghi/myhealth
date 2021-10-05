import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/screens/forget_password/components/body.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLightColor,
      body: ForgetPasswordBody(),
    );
  }
}
