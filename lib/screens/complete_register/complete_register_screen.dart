import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/screens/complete_register/components/body.dart';
import 'package:health/size_config.dart';

class CompleteRegisterScreen extends StatelessWidget {
  const CompleteRegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: bgLightColor,
      body: CompleteRegisterBody(),
    );
  }
}
