import 'package:flutter/material.dart';
import 'package:health/components/default_button.dart';
import 'package:health/components/default_outline_button.dart';
import 'package:health/config/colors.dart';
import 'package:health/screens/login/login_screen.dart';
import 'package:health/screens/register/register_screen.dart';

import '../../../size_config.dart';
import 'splash_content.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {
      "text": "Welcome to Tokoto, Let's shop!",
      "image": "assets/images/splash_1.png"
    },
    {
      "text":
          "We help people connect with store \naround United State of America",
      "image": "assets/images/splash_2.png"
    },
    {
      "text": "We show the easy way to shop. \nJust stay at home with us",
      "image": "assets/images/splash_3.png"
    },
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Spacer(),
            Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 50,
                child: Image.asset(
                  'assets/images/MyHealthLogo.png',
                  fit: BoxFit.cover,
                )),
            Expanded(
                flex: 3,
                child: PageView.builder(
                    onPageChanged: (value) {
                      setState(() {
                        currentPage = value;
                      });
                    },
                    itemCount: splashData.length,
                    itemBuilder: (context, index) => SplashContent(
                          image: splashData[index]['image'].toString(),
                        ))),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(20)),
                child: Column(children: [
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      splashData.length,
                      (int index) => buildDot(index: index),
                    ),
                  ),
                  Spacer(
                    flex: 3,
                  ),
                  DefaultOutlineButton(
                    press: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => RegisterScreen()));
                    },
                    text: 'ثبت نام',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  DefaultButton(
                    press: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (ctx) => LoginScreen()));
                    },
                    text: 'ورود',
                  ),
                  Spacer()
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 5),
      width: currentPage == index ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: currentPage == index ? primaryColor : Color(0xFFD8D8D8)),
    );
  }
}
