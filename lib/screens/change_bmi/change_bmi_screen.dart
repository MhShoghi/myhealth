import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/screens/change_bmi/components/body.dart';

class ChangeBmiScreen extends StatelessWidget {
  const ChangeBmiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      backgroundColor: bgLightColor,
      body: ChangeBmiBody(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: bgLightColor,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'تغییر BMI',
        textDirection: TextDirection.rtl,
        style: TextStyle(color: Colors.black),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
