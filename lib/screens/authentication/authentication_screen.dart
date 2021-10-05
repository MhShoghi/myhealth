import 'package:flutter/material.dart';

import 'package:health/config/colors.dart';
import 'package:health/screens/authentication/components/body.dart';

class AuthenticationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLightColor,
      body: AuthenticationBody(),
    );
  }
}
