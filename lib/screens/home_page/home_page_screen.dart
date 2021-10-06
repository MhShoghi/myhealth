import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/config/colors.dart';
import 'package:health/config/constants.dart';
import 'package:health/screens/calculate_bmi/calculate_bmi_screen.dart';
import 'package:health/screens/home_page/components/body.dart';
import 'package:health/screens/profile/profile_screen.dart';
import 'package:health/screens/videos/videos_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snack/snack.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var userObject = {};

  double _value = 10;
  bool loadingVideos = false;
  bool loading = false;

  Future<String> _getAuthToken() async {
    final SharedPreferences prefs = await _prefs;

    return prefs.getString('auth_token').toString();
  }

  Future<void> fetchUserData({token}) async {
    loading = true;
    final http.Response response = await http.get(
      Uri.parse(API_URL + '/users/me'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': token
      },
    );

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      loading = false;
      var user = responseBody['result']['user'];

      setState(() {
        userObject.addAll(user);
        _value = user['user_bmi'];
      });
    } else {
      loading = false;
      SnackBar(
        content: Row(
          children: [Text(responseBody['errors'][0]['message'])],
        ),
      ).show(context);
    }
  }

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _getAuthToken()
        .then((value) => {
              if (value.isNotEmpty) {fetchUserData(token: value)}
            })
        .catchError((err) => {});
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomePageBody(),
      // VideosScreen(),
      CalculateBmiScreen(),
      ProfileScreen()
    ];
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'خانه'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calculate), label: 'محاسبه'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: 'پروفایل')
          ],
        ),
        body: tabs[_currentIndex],
      ),
    );
  }
}
