import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/models/Video.dart';
import 'package:health/screens/home_page/home_page_screen.dart';
import 'package:health/screens/videos/components/body.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../config/constants.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({Key? key}) : super(key: key);

  @override
  _VideosScreenState createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> _getAuthToken() async {
    final SharedPreferences prefs = await _prefs;

    String token = prefs.getString('auth_token').toString();
  }

  @override
  void initState() {
    super.initState();
    _getAuthToken();
  }

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
