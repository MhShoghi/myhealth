import 'dart:async';
import 'package:flutter/material.dart';
import 'package:health/components/form_error.dart';
import 'package:health/components/snackbar.dart';
import 'package:health/config/Helper.dart';
import 'package:health/routes/routes.dart';
import 'package:health/screens/forget_password/forget_password_screen.dart';
import 'package:health/screens/home_page/home_page_screen.dart';
import 'package:health/screens/register/register_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:health/config/colors.dart';
import 'package:health/config/constants.dart';
import 'package:snack/snack.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginBody extends StatefulWidget {
  @override
  _LoginBodyState createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  final _formKey = GlobalKey<FormState>();

  void addError({String error = ''}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String error = ''}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  Future<void> _setAuthToken({token}) async {
    final SharedPreferences prefs = await _prefs;

    prefs
        .setString('auth_token', token)
        .then((bool success) => {})
        .catchError((err) => {});
  }

  String username = '';
  String password = '';

  List<String> errors = [];

  String selectedDate = Jalali.now().toJalaliDateTime();

  Future<void> _setPhoneNumber({required phoneNumber}) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('user_phone_number', phoneNumber).then((bool success) {});
  }

  Future<dynamic> loginUser({
    username,
    password,
  }) async {
    final http.Response response = await http.post(
      Uri.parse(API_URL + '/users/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'user_name': username,
        'password': password,
      }),
    );

    var decodedResponse = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        decodedResponse['userProfileIsComplete'] == true) {
      _btnController.success();

      _setAuthToken(token: decodedResponse['result']['auth_token']);

      buildSnackBar(
              text: 'ورود موفقیت آمیز',
              icon: Icons.login,
              iconColor: primaryColor)
          .show(context);

      Helper.navigate(duration: 3, route: _homePageRoute(), context: context);
    } else if (response.statusCode == 200 &&
        decodedResponse['userProfileIsComplete'] == false) {
      _btnController.success();

      _setAuthToken(token: decodedResponse['result']['auth_token']);

      buildSnackBar(
              text: 'اطلاعات شما هنوز کامل نشده است',
              icon: Icons.info_outlined,
              iconColor: bgButtonYellow)
          .show(context);

      Helper.navigate(
          duration: 3, route: completeRegisterRoute(), context: context);
    } else if (response.statusCode == 201) {
      _btnController.success();

      _setPhoneNumber(phoneNumber: username);

      buildSnackBar(
              text: 'حساب کاربری شما فعال نیست',
              icon: Icons.domain_verification,
              iconColor: bgButtonYellow)
          .show(context);
      Helper.navigate(
          duration: 3, route: authenticateRoute(), context: context);
    } else {
      _btnController.error();

      buildSnackBar(
              text: decodedResponse['errors'][0]['message'],
              icon: Icons.notifications,
              iconColor: redColor)
          .show(context);
      Timer(Duration(seconds: 2), () => {_btnController.reset()});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Column(
                    children: [
                      Text(
                        'ورود',
                        style: TextStyle(
                            fontSize: 28,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'جهت ورود به برنامه اطلاعات زیر را وارد کنید',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w100),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildUserNameFormField(),
                          SizedBox(
                            height: 10,
                          ),
                          buildPasswordFormField(),
                          SizedBox(
                            height: 10,
                          ),
                          FormError(errors: errors),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            height: 60,
                            child: RoundedLoadingButton(
                                successColor: Colors.green,
                                color: primaryColor,
                                borderRadius: 10,
                                width: MediaQuery.of(context).size.width,
                                controller: _btnController,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();

                                    loginUser(
                                        username: username, password: password);
                                  } else {
                                    _btnController.error();
                                    Timer(Duration(seconds: 2),
                                        () => {_btnController.reset()});
                                  }
                                },
                                child: Text(
                                  'ورود',
                                  style: TextStyle(fontSize: 18),
                                )),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'هنوز ثبت نام نکرده اید؟',
                              ),
                              TextButton(
                                child: Text(
                                  'ثبت نام',
                                  style: TextStyle(color: primaryColor),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(_registerRoute());
                                },
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'رمز عبور خود را فراموش کرده اید؟',
                              ),
                              TextButton(
                                child: Text(
                                  'بازیابی',
                                  style: TextStyle(color: primaryColor),
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(_forgetPasswordRoute());
                                },
                              )
                            ],
                          )
                        ],
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container buildUserNameFormField() {
    return Container(
      decoration: BoxDecoration(
          border: errors.contains(kPhoneNumberNullError) ||
                  errors.contains(kPhoneNumberLengthError)
              ? Border.all(color: Colors.red)
              : null,
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.0)),
      child: TextFormField(
        keyboardType: TextInputType.number,
        onSaved: (newValue) => username = newValue.toString(),
        onChanged: (value) {
          if (value.isNotEmpty && errors.contains(kPhoneNumberNullError)) {
            setState(() {
              errors.remove(kPhoneNumberNullError);
            });
            return null;
          }

          if (value.length == 11 && errors.contains(kPhoneNumberLengthError)) {
            setState(() {
              errors.remove(kPhoneNumberLengthError);
            });
            return null;
          }

          return null;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            setState(() {
              addError(error: kPhoneNumberNullError);
            });
            return '';
          }

          if (value.length != 11) {
            setState(() {
              addError(error: kPhoneNumberLengthError);
            });
            return '';
          }
        },
        // controller: controller,
        style: TextStyle(color: Colors.black),

        decoration: InputDecoration(
          errorStyle: TextStyle(height: 0),

          errorBorder: InputBorder.none,
          border: InputBorder.none,
          hintText: 'شماره موبایل',
          hintStyle: TextStyle(color: Colors.black),
          contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              gapPadding: 10),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              gapPadding: 10),
          // suffixIcon: CustomSuffixIcon(
          //   'assets/icons/Mail.svg',
          // ),
        ),
      ),
    );
  }

  Container buildPasswordFormField() {
    return Container(
      decoration: BoxDecoration(
          border: errors.contains(kPassNullError)
              ? Border.all(color: Colors.red)
              : null,
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.0)),
      child: TextFormField(
        textDirection: TextDirection.ltr,
        onSaved: (newValue) => password = newValue.toString(),
        onChanged: (value) {
          if (value.isNotEmpty && errors.contains(kPassNullError)) {
            setState(() {
              errors.remove(kPassNullError);
            });
            return null;
          }

          return null;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            setState(() {
              addError(error: kPassNullError);
            });
            return '';
          }
        },
        obscureText: true,

        // controller: controller,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'رمز عبور',
          errorStyle: TextStyle(height: 0),
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.black),
          contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              gapPadding: 10),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              gapPadding: 10),
          // suffixIcon: CustomSuffixIcon(
          //   'assets/icons/Mail.svg',
          // ),
        ),
      ),
    );
  }
}

Route _registerRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => RegisterScreen(),
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

Route _forgetPasswordRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        ForgetPasswordScreen(),
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

Route _homePageRoute() {
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
