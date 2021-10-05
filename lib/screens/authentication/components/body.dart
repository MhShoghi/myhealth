import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health/components/snackbar.dart';
import 'package:health/config/Helper.dart';
import 'package:health/config/colors.dart';
import 'package:health/config/constants.dart';
import 'package:health/routes/routes.dart';
import 'package:health/screens/complete_register/complete_register_screen.dart';
import 'package:health/screens/home_page/home_page_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snack/snack.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'package:http/http.dart' as http;

class AuthenticationBody extends StatefulWidget {
  const AuthenticationBody({Key? key}) : super(key: key);

  @override
  _AuthenticationBodyState createState() => _AuthenticationBodyState();
}

class _AuthenticationBodyState extends State<AuthenticationBody> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  String verifyCode = '';
  String phoneNumber = '';
  Future<void> _getPhoneNumber() async {
    final SharedPreferences prefs = await _prefs;
    var userPhoneNumber = prefs.getString('user_phone_number').toString();

    setState(() {
      phoneNumber = userPhoneNumber;
    });
  }

  Future<void> _setJwtAuthToken({required token}) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('auth_token', token).then((bool success) {});
  }

  Future<dynamic> authenticateUser({verifyCode, phoneNumber}) async {
    final http.Response response = await http.post(
        Uri.parse(API_URL + '/auth/verify'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<dynamic, dynamic>{
          'phone_number': phoneNumber,
          'verify_code': verifyCode
        }));

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseBody['userProfileIsComplete'] == false) {
      _btnController.success();
      _setJwtAuthToken(token: responseBody['result']['user_auth_token']);

      buildSnackBar(
              icon: Icons.error_outline_outlined,
              iconColor: bgButtonYellow,
              text: 'اطلاعات فردی شما کامل نیست')
          .show(context);

      Helper.navigate(
          duration: 3, route: completeRegisterRoute(), context: context);
    } else if (response.statusCode == 200 &&
        responseBody['userProfileIsComplete'] == true) {
      _btnController.success();
      _setJwtAuthToken(token: responseBody['result']['user_auth_token']);

      Timer(
          Duration(seconds: 3),
          () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => HomePageScreen()))
              });
    } else {
      _btnController.error();

      buildSnackBar(
              text: responseBody['errors'][0]['message'],
              icon: Icons.info,
              iconColor: redColor)
          .show(context);

      Timer(Duration(seconds: 3), () => {_btnController.reset()});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getPhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      'احراز هویت',
                      style: TextStyle(
                          fontSize: 28,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'کد ۴ رقمی ارسال شده بر روی تلفن همراه خود را وارد کنید',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w100),
                    )
                  ],
                ),
                Spacer(
                  flex: 1,
                ),
                Row(
                  children: [
                    Text(
                      'کد فعالسازی',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: PinCodeTextField(
                          appContext: context,
                          length: 5,
                          obscureText: false,
                          textStyle: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w400),
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(10),
                            inactiveColor: Colors.transparent,
                            inactiveFillColor: Colors.grey.withOpacity(0.3),
                            activeColor: Colors.black,
                            errorBorderColor: Colors.red,
                            activeFillColor: Colors.grey.withOpacity(0.3),
                            selectedColor: Colors.grey,
                            selectedFillColor: Colors.grey.withOpacity(0.3),
                            fieldHeight:
                                MediaQuery.of(context).size.width * 0.15,
                            fieldWidth:
                                MediaQuery.of(context).size.width * 0.15,
                          ),
                          animationDuration: Duration(milliseconds: 300),
                          enableActiveFill: true,
                          keyboardType: TextInputType.number,
                          onCompleted: (v) {
                            setState(() {
                              verifyCode = v;
                            });
                          },
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(
                  flex: 2,
                ),
                Container(
                  width: double.infinity,
                  height: 60,
                  child: RoundedLoadingButton(
                      color: primaryColor,
                      borderRadius: 10,
                      width: MediaQuery.of(context).size.width,
                      controller: _btnController,
                      onPressed: () {
                        authenticateUser(
                            phoneNumber: phoneNumber, verifyCode: verifyCode);
                      },
                      child: Text(
                        'بررسی',
                        style: TextStyle(fontSize: 18),
                      )),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
