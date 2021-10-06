import 'dart:async';
import 'package:flutter/material.dart';
import 'package:health/components/snackbar.dart';
import 'package:health/config/Helper.dart';
import 'package:health/routes/routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:group_button/group_button.dart';

import 'package:health/components/form_error.dart';
import 'package:health/config/colors.dart';
import 'package:health/config/constants.dart';

import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snack/snack.dart';

import 'package:persian_datetime_picker/persian_datetime_picker.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  Future<void> _setPhoneNumber({required phonNumber}) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('user_phone_number', phoneNumber).then((bool success) {});
  }

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

  String name = '';
  String family = '';
  String email = '';
  String phoneNumber = '';
  String birthDay = '';
  var birthDayLabel;
  int gender = 0;
  String password = '';
  String confirmPassword = '';
  List<String> errors = [];
  List<String> responseErrors = [];

  String selectedDate = Jalali.now().toJalaliDateTime();

  Future<dynamic> registerUser(
      {name,
      family,
      email,
      phoneNumber,
      birthday,
      gender,
      password,
      confirmPassword}) async {
    final http.Response response = await http.post(
      Uri.parse(API_URL + '/users/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'name': name.toString(),
        'family': family.toString(),
        'email': email.toString(),
        'gender': gender,
        'birthday': birthDay.toString(),
        'phone_number': phoneNumber.toString(),
        'password': password.toString(),
        'confirm_password': confirmPassword.toString()
      }),
    );

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _btnController.success();

      _setPhoneNumber(phonNumber: phoneNumber);

      buildSnackBar(
              text: 'ثبت نام شما با موفقیت انجام شد',
              iconColor: primaryColor,
              icon: Icons.app_registration_outlined)
          .show(context);

      Helper.navigate(
          duration: 3, route: authenticateRoute(), context: context);
    } else {
      _btnController.error();
      SnackBar(
          content: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(responseBody['errors'][0]['message']),
          SizedBox(width: 5),
          Icon(
            Icons.info,
            color: Colors.red,
          ),
        ],
      )).show(context);
      Timer(Duration(seconds: 2), () => {_btnController.reset()});
    }
  }

  @override
  void initState() {
    super.initState();
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
                        'ثبت نام',
                        style: TextStyle(
                            fontSize: 28,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'برای استفاده کامل از امکانات برنامه اطلاعات زیر را به طور صحیح وارد کنید',
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
                          Column(
                            children: [
                              buildNameFormField(),
                              SizedBox(
                                height: 10,
                              ),
                              buildFamilyFormField()
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          buildPhoneNumberFormField(),
                          SizedBox(
                            height: 10,
                          ),

                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 40),
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'جنسیت',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Flexible(
                                        child: GroupButton(
                                      isRadio: true,
                                      selectedButton: 0,
                                      onSelected: (int index, isSelected) {
                                        setState(() {
                                          gender = index;
                                        });
                                      },
                                      buttons: ["مرد", "زن"],
                                      unselectedColor: bgDarkColor,
                                      unselectedTextStyle:
                                          TextStyle(color: Colors.white),
                                      selectedTextStyle:
                                          TextStyle(color: Colors.white),
                                      selectedColor: primaryColor,
                                      spacing: 30,
                                      borderRadius: BorderRadius.circular(5),
                                    )),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 5),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.3),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'تاریخ تولد',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      Container(
                                        child: birthDay == ''
                                            ? TextButton(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      color: Colors.black,
                                                      size: 20,
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      'انتخاب تاریخ',
                                                      style: TextStyle(
                                                          color: bgDarkColor,
                                                          fontSize: 12),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () async {
                                                  Jalali? picked =
                                                      await showPersianDatePicker(
                                                    context: context,
                                                    initialDate: Jalali.now(),
                                                    firstDate: Jalali(1330, 8),
                                                    lastDate: Jalali(1401, 9),
                                                  );
                                                  var day = picked?.day;
                                                  var month = picked?.month;
                                                  var year = picked?.year;
                                                  var full =
                                                      picked?.formatFullDate();

                                                  setState(() {
                                                    birthDayLabel = full;
                                                    birthDay =
                                                        '$day - $month - $year';
                                                  });
                                                },
                                              )
                                            : Row(
                                                children: [
                                                  Text(birthDayLabel),
                                                  IconButton(
                                                    tooltip: 'تغییر تاریخ',
                                                    onPressed: () async {
                                                      Jalali? picked =
                                                          await showPersianDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            Jalali.now(),
                                                        firstDate:
                                                            Jalali(1330, 8),
                                                        lastDate:
                                                            Jalali(1401, 9),
                                                      );
                                                      var day = picked?.day;
                                                      var month = picked?.month;
                                                      var year = picked?.year;
                                                      var full = picked
                                                          ?.formatFullDate();

                                                      setState(() {
                                                        birthDayLabel = full;
                                                        birthDay =
                                                            '$day - $month - $year';
                                                      });
                                                    },
                                                    icon: Icon(Icons
                                                        .change_circle_outlined),
                                                  )
                                                ],
                                              ),
                                      )
                                    ],
                                  ))
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          buildEmailFormField(),
                          SizedBox(
                            height: 10,
                          ),

                          Column(
                            children: [
                              buildPasswordFormField(),
                              SizedBox(
                                height: 10,
                              ),
                              buildPasswordConfirmFormField()
                            ],
                          ),
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
                                color: primaryColor,
                                borderRadius: 10,
                                width: MediaQuery.of(context).size.width,
                                controller: _btnController,
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();

                                    registerUser(
                                        name: name,
                                        family: family,
                                        phoneNumber: phoneNumber,
                                        birthday: birthDay,
                                        gender: gender,
                                        email: email,
                                        password: password,
                                        confirmPassword: confirmPassword);
                                  } else {
                                    _btnController.error();

                                    Timer(Duration(seconds: 2),
                                        () => {_btnController.reset()});
                                  }
                                },
                                child: Text(
                                  'ثبت نام',
                                  style: TextStyle(fontSize: 18),
                                )),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('قبلا ثبت نام کرده اید؟'),
                              TextButton(
                                child: Text(
                                  'ورود',
                                  style: TextStyle(color: primaryColor),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(loginRoute());
                                },
                              )
                            ],
                          )
                          // FormError(errors: responseErrors),
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

  Container buildNameFormField() {
    return Container(
      decoration: BoxDecoration(
          border: errors.contains(kNameNullError)
              ? Border.all(color: Colors.red)
              : null,
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: TextFormField(
          initialValue: name,
          onSaved: (newValue) => name = newValue.toString(),
          onChanged: (value) {
            setState(() {
              name = value.toString();
            });
            if (value.isNotEmpty && errors.contains(kNameNullError)) {
              setState(() {
                errors.remove(kNameNullError);
              });
              return null;
            }

            return null;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              setState(() {
                addError(error: kNameNullError);
              });
              return '';
            }

            return null;
          },

          // controller: controller,
          style: TextStyle(color: Colors.black),

          decoration: InputDecoration(
            fillColor: bgButtonYellow,
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)),
            errorStyle: TextStyle(height: 0),
            hintText: 'نام',

            focusedErrorBorder: InputBorder.none,
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
      ),
    );
  }

  Container buildFamilyFormField() {
    return Container(
      decoration: BoxDecoration(
          border: errors.contains(kFamilyNullError)
              ? Border.all(color: Colors.red)
              : null,
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: TextFormField(
          onSaved: (newValue) => family = newValue.toString(),
          onChanged: (value) {
            if (value.isNotEmpty && errors.contains(kFamilyNullError)) {
              setState(() {
                errors.remove(kFamilyNullError);
              });
              return null;
            }

            return null;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              setState(() {
                addError(error: kFamilyNullError);
              });
              return '';
            }
          },

          // controller: controller,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            errorStyle: TextStyle(height: 0),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)),
            hintText: 'نام خانوادگی',
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
      ),
    );
  }

  Container buildPhoneNumberFormField() {
    return Container(
      decoration: BoxDecoration(
          border: errors.contains(kPhoneNumberNullError)
              ? Border.all(color: Colors.red)
              : null,
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: TextFormField(
          maxLength: 11,

          keyboardType: TextInputType.number,
          onSaved: (newValue) => phoneNumber = newValue.toString(),
          onChanged: (value) {
            if (value.isNotEmpty && errors.contains(kPhoneNumberNullError)) {
              setState(() {
                errors.remove(kPhoneNumberNullError);
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
          },

          // controller: controller,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintMaxLines: 1,
            errorStyle: TextStyle(height: 0),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)),
            hintText: 'شماره تلفن همراه',
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
      ),
    );
  }

  Container buildEmailFormField() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.0)),
      child: TextFormField(
        onSaved: (newValue) => email = newValue.toString(),
        onChanged: (value) {},
        validator: (value) {},
        // controller: controller,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          errorStyle: TextStyle(height: 0),

          errorBorder: InputBorder.none,
          hintText: 'ایمیل (دلخواه)',
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
        textDirection: TextDirection.ltr,
        // controller: controller,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'رمز عبور',
          errorStyle: TextStyle(height: 0),
          errorBorder: InputBorder.none,
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

  Container buildPasswordConfirmFormField() {
    return Container(
      decoration: BoxDecoration(
          border: errors.contains(kPassConfrimNullError)
              ? Border.all(color: Colors.red)
              : null,
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.0)),
      child: TextFormField(
        textDirection: TextDirection.ltr,
        obscureText: true,
        onSaved: (newValue) => confirmPassword = newValue.toString(),
        onChanged: (value) {
          if (value.isNotEmpty && errors.contains(kPassConfrimNullError)) {
            setState(() {
              errors.remove(kPassConfrimNullError);
            });
            return null;
          }

          return null;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            setState(() {
              addError(error: kPassConfrimNullError);
            });
            return '';
          }
        },

        // controller: controller,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'تکرار رمز عبور',
          errorStyle: TextStyle(height: 0),
          errorBorder: InputBorder.none,
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
