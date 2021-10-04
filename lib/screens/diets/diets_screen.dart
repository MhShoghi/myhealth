import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/screens/diets/components/body.dart';

class DietsScreen extends StatelessWidget {
  const DietsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgLightColor,
        centerTitle: true,
        title: Text(
          'برنامه غذایی',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      backgroundColor: bgLightColor,
      body: DietsBody(),
    );
  }
}
