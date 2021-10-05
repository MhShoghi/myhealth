import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health/components/form_error.dart';
import 'package:health/config/colors.dart';
import 'package:health/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snack/snack.dart';

class CalculateBmiBody extends StatefulWidget {
  const CalculateBmiBody({Key? key}) : super(key: key);

  @override
  _CalculateBmiBodyState createState() => _CalculateBmiBodyState();
}

class _CalculateBmiBodyState extends State<CalculateBmiBody> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  String _bmiResult = '';
  bool loading = false;
  List<String> errors = [];
  String height = '';
  String weight = '';
  bool display = false;
  Map bmiResult = {};

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

  Future<String> _getAuthToken() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('auth_token').toString();
  }

  Future<void> calculateBMI({token, age, height, weight}) async {
    setState(() {
      loading = true;
      display = false;
    });
    final http.Response response = await http.post(
      Uri.parse(API_URL + '/users/calculate/bmi'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': token
      },
      body: jsonEncode(<dynamic, dynamic>{
        'height': height.toString(),
        'weight': weight.toString(),
      }),
    );

    var responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _btnController.success();
      setState(() {
        bmiResult.addAll(responseBody['result']);
        loading = false;
        display = true;
      });

      Timer(Duration(seconds: 2), () => {_btnController.reset()});
    } else {
      setState(() {
        loading = false;
      });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Column(
              children: [
                Text(
                  'محاسبه BMI',
                  style: TextStyle(fontSize: 28),
                ),
                Text(
                    'در این صفحه میتوانید شاخص BMI بر اساس قد و وزن دلخواه را بدست بیاورید'),
                SizedBox(
                  height: 40,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildHeightFormField(),
                      SizedBox(
                        height: 10,
                      ),
                      buildWeightFormField(),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                FormError(errors: errors),
                SizedBox(
                  height: 5,
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

                          var token = await _getAuthToken();

                          calculateBMI(
                              token: token, height: height, weight: weight);
                        } else {
                          _btnController.error();

                          Timer(Duration(seconds: 2),
                              () => {_btnController.reset()});
                        }
                      },
                      child: Text(
                        'محاسبه',
                        style: TextStyle(fontSize: 18),
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                display
                    ? Column(
                        children: [
                          Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 30),
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      width: double.infinity,
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 50,
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                              decoration: BoxDecoration(
                                                  color: Colors.blueAccent),
                                              child: Center(
                                                child: Text(
                                                  bmiResult['range']
                                                      ['range_status'],
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                              )),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('وضعیت جسمانی')
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      width: double.infinity,
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 50,
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                              decoration: BoxDecoration(
                                                  color: redColor),
                                              child: Center(
                                                child: Text(
                                                  bmiResult['bmi'].toString(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                              )),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('نتیجه شاخص')
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'توضیحات: ',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    bmiResult['range']['range_description'],
                                    softWrap: true,
                                    style: TextStyle(wordSpacing: 4),
                                  ),
                                ],
                              ))
                        ],
                      )
                    : Text(' ')
              ],
            ),
          ),
        ),
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
          keyboardType: TextInputType.number,
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

          decoration: InputDecoration(
            fillColor: bgButtonYellow,
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)),
            errorStyle: TextStyle(height: 0),
            hintText: 'وزن (کیلوگرم)',

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
          keyboardType: TextInputType.number,
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

          decoration: InputDecoration(
            fillColor: bgButtonYellow,
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)),
            errorStyle: TextStyle(height: 0),
            hintText: 'قد (سانتی متر)',

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
