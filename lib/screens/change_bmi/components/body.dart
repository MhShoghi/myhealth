import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health/components/form_error.dart';
import 'package:health/config/colors.dart';
import 'package:health/size_config.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snack/snack.dart';

import '../../../config/constants.dart';

class ChangeBmiBody extends StatefulWidget {
  const ChangeBmiBody({Key? key}) : super(key: key);

  @override
  _ChangeBmiBodyState createState() => _ChangeBmiBodyState();
}

class _ChangeBmiBodyState extends State<ChangeBmiBody> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  List<String> errors = [];

  final _formKey = GlobalKey<FormState>();

  String age = '';
  String height = '';
  String weight = '';

  Future<String> _getAuthToken() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('auth_token').toString();
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

  Future<void> changeData({token, age, height, weight}) async {
    final http.Response response = await http.post(
      Uri.parse(API_URL + '/users/bmi'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': token
      },
      body: jsonEncode(<dynamic, dynamic>{
        'age': age.toString(),
        'height': height.toString(),
        'weight': weight.toString(),
      }),
    );

    var responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _btnController.success();
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'شاخص BMI شما ویرایش شد',
              style: TextStyle(fontFamily: 'Dana'),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(
              width: 5,
            ),
            Icon(
              Icons.edit,
              color: primaryColor,
            ),
          ],
        ),
      ).show(context);

      Timer(Duration(seconds: 3), () => {_btnController.reset()});
    } else {
      _btnController.error();
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(responseBody['errors'][0]['message']),
            SizedBox(
              width: 5,
            ),
            Icon(
              Icons.notifications,
              color: redColor,
            ),
          ],
        ),
      ).show(context);
      Timer(Duration(seconds: 3), () => {_btnController.reset()});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                Container(
                  width: SizeConfig.screenWidth * 0.7,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        child: Text(
                          'محاسبه مجدد شاخص توده بدنی',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: Text(
                          'در صورتی که وزن یا اطلاعات شما تغییر کرده است میتوانید با تغییر دادن اطلاعات زیر برنامه غذایی و ویدیوهای جدید دریافت کنید ',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w200),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              buildAgeFormField(),
                              SizedBox(
                                height: 5,
                              ),
                              buildHeightFormField(),
                              SizedBox(
                                height: 5,
                              ),
                              buildWeightFormField(),
                              SizedBox(
                                height: 15,
                              ),
                              Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: FormError(errors: errors)),
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

                                        var token = await _getAuthToken();

                                        changeData(
                                            token: token,
                                            age: age,
                                            height: height,
                                            weight: weight);
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
                            ],
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildInfoItem({label, value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            label,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Container buildWeightFormField() {
    return Container(
      decoration: BoxDecoration(
          border: errors.contains(kWeightNullError)
              ? Border.all(color: Colors.red)
              : null,
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: TextFormField(
          textAlign: TextAlign.right,
          onSaved: (newValue) => weight = newValue.toString(),
          onChanged: (value) {
            if (value.isNotEmpty && errors.contains(kWeightNullError)) {
              setState(() {
                errors.remove(kWeightNullError);
              });
              return null;
            }

            return null;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              setState(() {
                addError(error: kWeightNullError);
              });
              return '';
            }

            return null;
          },

          // controller: controller,
          style: TextStyle(color: Colors.black),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            fillColor: bgButtonYellow,
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)),
            errorStyle: TextStyle(height: 0),
            hintText: 'وزن',

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

  Container buildHeightFormField() {
    return Container(
      decoration: BoxDecoration(
          border: errors.contains(kHeightNullError)
              ? Border.all(color: Colors.red)
              : null,
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: TextFormField(
          textAlign: TextAlign.right,
          onSaved: (newValue) => height = newValue.toString(),
          onChanged: (value) {
            if (value.isNotEmpty && errors.contains(kHeightNullError)) {
              setState(() {
                errors.remove(kHeightNullError);
              });
              return null;
            }

            return null;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              setState(() {
                addError(error: kHeightNullError);
              });
              return '';
            }

            return null;
          },

          // controller: controller,
          style: TextStyle(color: Colors.black),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            fillColor: bgButtonYellow,
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)),
            errorStyle: TextStyle(height: 0),
            hintText: 'قد',

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

  Container buildAgeFormField() {
    return Container(
      decoration: BoxDecoration(
          border: errors.contains(kAgeNullError)
              ? Border.all(color: Colors.red)
              : null,
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: TextFormField(
          textAlign: TextAlign.right,
          onSaved: (newValue) => age = newValue.toString(),
          onChanged: (value) {
            if (value.isNotEmpty && errors.contains(kAgeNullError)) {
              setState(() {
                errors.remove(kAgeNullError);
              });
              return null;
            }

            return null;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              setState(() {
                addError(error: kAgeNullError);
              });
              return '';
            }

            return null;
          },

          // controller: controller,
          style: TextStyle(color: Colors.black),
          keyboardType: TextInputType.number,

          decoration: InputDecoration(
            fillColor: bgButtonYellow,
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)),
            errorStyle: TextStyle(height: 0),
            hintText: 'سن',

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
}
