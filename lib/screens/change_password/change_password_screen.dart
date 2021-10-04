import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/screens/change_password/components/body.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLightColor,
      appBar: AppBar(
        backgroundColor: bgLightColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ChangePasswordBody(),
    );
  }
}
