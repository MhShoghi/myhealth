import 'dart:async';
import 'dart:convert';
import 'package:health/components/form_error.dart';
import 'package:health/config/colors.dart';
import 'package:health/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snack/snack.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ChangePasswordBody extends StatefulWidget {
  const ChangePasswordBody({Key? key}) : super(key: key);

  @override
  _ChangePasswordBodyState createState() => _ChangePasswordBodyState();
}

class _ChangePasswordBodyState extends State<ChangePasswordBody> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _formKey = GlobalKey<FormState>();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  String oldPassword = '';
  String newPassword = '';
  String newPasswordConfirm = '';

  List<String> errors = [];

  Future<String> _getAuthToken() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('auth_token').toString();
  }

  Future<dynamic> changePassword(
      {oldPassword, newPassword, newPasswordConfrim, token}) async {
    final http.Response response = await http.post(
      Uri.parse(API_URL + '/users/change/password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': token
      },
      body: jsonEncode(<dynamic, dynamic>{
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirm': newPasswordConfirm
      }),
    );

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _btnController.success();

      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(responseBody['message'], style: TextStyle(fontFamily: 'Dana')),
            SizedBox(
              width: 5,
            ),
            Icon(
              Icons.login,
              color: Colors.greenAccent,
            ),
          ],
        ),
      ).show(context);
    } else {
      _btnController.error();

      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              responseBody['errors'][0]['message'],
              style: TextStyle(fontFamily: 'Dana'),
            ),
            SizedBox(
              width: 5,
            ),
            Icon(
              Icons.notifications,
              color: Colors.redAccent,
            ),
          ],
        ),
      ).show(context);
      Timer(Duration(seconds: 2), () => {_btnController.reset()});
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'تغییر رمز عبور',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 20),
                ),
                Text(
                  'در اینجا میتوانید رمز عبور حساب کاربری خود را تغییر دهید، کافیست رمز عبور قبلی خود و رمز عبور جدید را وارد کنید',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w200,
                      fontSize: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildOldPasswordFormField(),
                        SizedBox(
                          height: 10,
                        ),
                        buildNewPasswordFormField(),
                        SizedBox(
                          height: 10,
                        ),
                        buildNewPasswordConfirmFormField(),
                        SizedBox(
                          height: 10,
                        ),
                        Directionality(
                          child: FormError(errors: errors),
                          textDirection: TextDirection.rtl,
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
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  var token = await _getAuthToken();
                                  changePassword(
                                      token: token,
                                      newPassword: newPassword,
                                      oldPassword: oldPassword,
                                      newPasswordConfrim: newPasswordConfirm);
                                } else {
                                  _btnController.error();
                                  Timer(Duration(seconds: 2),
                                      () => {_btnController.reset()});
                                }
                              },
                              child: Text(
                                'تغییر',
                                style: TextStyle(fontSize: 18),
                              )),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildOldPasswordFormField() {
    return Container(
      decoration: BoxDecoration(
          border: errors.contains(kOldPasswordNullError)
              ? Border.all(color: Colors.red)
              : null,
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.0)),
      child: TextFormField(
        textAlign: TextAlign.right,
        onSaved: (newValue) => oldPassword = newValue.toString(),
        onChanged: (value) {
          if (value.isNotEmpty && errors.contains(kOldPasswordNullError)) {
            setState(() {
              errors.remove(kOldPasswordNullError);
            });
            return null;
          }

          return null;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            setState(() {
              addError(error: kOldPasswordNullError);
            });
            return '';
          }
        },
        obscureText: true,

        // controller: controller,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'رمز عبور فعلی',
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

  Container buildNewPasswordFormField() {
    return Container(
      decoration: BoxDecoration(
          border: errors.contains(kNewPasswordNullError)
              ? Border.all(color: Colors.red)
              : null,
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.0)),
      child: TextFormField(
        textAlign: TextAlign.right,
        onSaved: (newValue) => newPassword = newValue.toString(),
        onChanged: (value) {
          if (value.isNotEmpty && errors.contains(kNewPasswordNullError)) {
            setState(() {
              errors.remove(kNewPasswordNullError);
            });
            return null;
          }

          return null;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            setState(() {
              addError(error: kNewPasswordNullError);
            });
            return '';
          }
        },
        obscureText: true,

        // controller: controller,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'رمز عبور جدید',
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

  Container buildNewPasswordConfirmFormField() {
    return Container(
      decoration: BoxDecoration(
          border: errors.contains(kNewPasswordConfirmNullError)
              ? Border.all(color: Colors.red)
              : null,
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.0)),
      child: TextFormField(
        textAlign: TextAlign.right,
        onSaved: (newValue) => newPasswordConfirm = newValue.toString(),
        onChanged: (value) {
          if (value.isNotEmpty &&
              errors.contains(kNewPasswordConfirmNullError)) {
            setState(() {
              errors.remove(kNewPasswordConfirmNullError);
            });
            return null;
          }

          return null;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            setState(() {
              addError(error: kNewPasswordConfirmNullError);
            });
            return '';
          }
        },
        obscureText: true,

        // controller: controller,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'تکرار رمز عبور جدید',
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
