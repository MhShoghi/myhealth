import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/screens/home_page/home_page_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../size_config.dart';
import './components/body.dart';
import 'package:snack/snack.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = '/splash';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> _getAuthToken() async {
    final SharedPreferences prefs = await _prefs;

    return prefs.getString('auth_token').toString();
  }

  @override
  void initState() {
    super.initState();

    // ignore: unnecessary_null_comparison
    _getAuthToken().then((token) => token.isNotEmpty && token != null
        ? {
            SnackBar(
              content: Text('خوش آمدید'),
            ).show(context),
            Navigator.of(context).push(_homeScreenRoute()),
          }
        : null);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Body(),
    );
  }
}

Route _homeScreenRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => HomePageScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end);
      final offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
