import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/size_config.dart';

import 'components/body.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: bgLightColor,
      body: Body(),
    );
  }
}
