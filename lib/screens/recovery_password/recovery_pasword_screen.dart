import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/screens/recovery_password/components/body.dart';

class RecoveryPasswordScreen extends StatelessWidget {
  final phoneNumber;
  const RecoveryPasswordScreen({Key? key, this.phoneNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLightColor,
      body: RecoveryPasswordBody(phoneNumber:phoneNumber),
    );
  }
}
