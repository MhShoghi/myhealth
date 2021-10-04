import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/screens/videos/components/body.dart';

class VideosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgLightColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'تمرینات ورزشی',
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
      ),
      backgroundColor: bgLightColor,
      body: VideoBody(),
    );
  }
}
