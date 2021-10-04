import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:health/components/default_button.dart';
import 'package:health/components/form_error.dart';
import 'package:health/config/colors.dart';
import 'package:health/screens/home_page/home_page_screen.dart';
import 'package:health/size_config.dart';
import 'package:http/http.dart' as http;
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/constants.dart';
import 'package:snack/snack.dart';

class CompleteRegisterBody extends StatefulWidget {
  const CompleteRegisterBody({Key? key}) : super(key: key);

  @override
  _CompleteRegisterBodyState createState() => _CompleteRegisterBodyState();
}

class _CompleteRegisterBodyState extends State<CompleteRegisterBody> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late dynamic authorizationToken;

  Future<String> _getAuthToken() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('auth_token').toString();
  }

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

  Future<void> sendData(
      {age,
      height,
      weight,
      background_disease,
      background_disease_description,
      exercise_days,
      exercise_hours,
      token}) async {
    final http.Response response = await http.post(
      Uri.parse(API_URL + '/users/complete'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': token
      },
      body: jsonEncode(<dynamic, dynamic>{
        'age': age.toString(),
        'height': height.toString(),
        'weight': weight.toString(),
        'disease_background': background_disease,
        'disease_background_description':
            background_disease_description.toString(),
        'exercise_days': exercise_days,
        'exercise_hours': exercise_hours
      }),
    );

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _btnController.success();

      Navigator.push(
          context, MaterialPageRoute(builder: (ctx) => HomePageScreen()));
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
      Timer(Duration(seconds: 3), () => {_btnController.reset()});
    }
  }

  void removeError({String error = ''}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  String age = '';
  String height = '';
  String weight = '';
  int background_disease = 0;
  String background_disease_description = '';
  List<int> exercise_days = [];
  List<int> exercise_hours = [];

  List<String> errors = [];

  @override
  void initState() {
    super.initState();
    _getAuthToken();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
          child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                Text(
                  'اطلاعات فردی',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                ),
                Text(
                  'برای استفاده از امکانات برنامه و هچنین ارائه خدمات بهتر لطفا اطلاعات زیر به طور صحیح وارد کنید',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w100),
                ),
                SizedBox(
                  height: 20,
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Flexible(child: buildAgeFormField()),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(child: buildHeightFormField()),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        buildWeightFormField(),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'سابقه بیماری',
                                style: TextStyle(color: Colors.black),
                              ),
                              GroupButton(
                                buttonWidth: SizeConfig.screenWidth > 400
                                    ? MediaQuery.of(context).size.width * 0.15
                                    : MediaQuery.of(context).size.width * 0.30,
                                isRadio: true,
                                selectedButton: 0,
                                onSelected: (int index, isSelected) {
                                  setState(() {
                                    background_disease = index;
                                  });
                                },
                                buttons: ["خیر", "بله"],
                                unselectedColor: bgDarkColor,
                                unselectedTextStyle:
                                    TextStyle(color: Colors.white),
                                selectedTextStyle:
                                    TextStyle(color: Colors.black),
                                selectedColor: bgButtonYellow,
                                spacing: 30,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        buildDiseaseBackgroundFormField(),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'انتخاب روز جهت تمرین',
                                style: TextStyle(color: Colors.black),
                              ),
                              GroupButton(
                                isRadio: false,
                                onSelected: (int index, isSelected) {
                                  if (isSelected) {
                                    setState(() {
                                      exercise_days.add(index);
                                    });
                                  } else {
                                    setState(() {
                                      exercise_days.remove(index);
                                    });
                                  }
                                },
                                buttons: [
                                  'شنبه',
                                  'یکشنبه',
                                  'دوشنبه',
                                  'سه شنبه',
                                  'چهارشنبه',
                                  'پنجشنبه',
                                  'جمعه',
                                ],
                                unselectedColor: bgDarkColor,
                                unselectedTextStyle:
                                    TextStyle(color: Colors.white),
                                selectedTextStyle:
                                    TextStyle(color: Colors.black),
                                selectedColor: bgButtonYellow,
                                spacing: 10,
                                mainGroupAlignment: MainGroupAlignment.start,
                                buttonWidth: SizeConfig.screenWidth > 400
                                    ? MediaQuery.of(context).size.width * 0.15
                                    : MediaQuery.of(context).size.width * 0.35,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'انتخاب ساعت جهت تمرین',
                                style: TextStyle(color: Colors.black),
                              ),
                              GroupButton(
                                isRadio: false,
                                onSelected: (int index, isSelected) {
                                  if (isSelected) {
                                    setState(() {
                                      exercise_hours.add(index);
                                    });
                                  } else {
                                    setState(() {
                                      exercise_hours.remove(index);
                                    });
                                  }
                                },
                                buttons: [
                                  'صبح',
                                  'ظهر',
                                  'عصر',
                                ],
                                unselectedColor: bgDarkColor,
                                unselectedTextStyle:
                                    TextStyle(color: Colors.white),
                                selectedTextStyle:
                                    TextStyle(color: Colors.black),
                                selectedColor: bgButtonYellow,
                                spacing: 10,
                                mainGroupAlignment: MainGroupAlignment.start,
                                buttonWidth: SizeConfig.screenWidth > 400
                                    ? MediaQuery.of(context).size.width * 0.15
                                    : MediaQuery.of(context).size.width * 0.35,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                SizedBox(
                  height: 10,
                ),
                FormError(errors: errors),
                SizedBox(
                  height: 10,
                ),
                TextButton(
                    onPressed: () {
                      _btnController.reset();
                    },
                    child: Text('sdfsdf')),
                Container(
                  width: double.infinity,
                  height: 60,
                  child: RoundedLoadingButton(
                      color: primaryColor,
                      borderRadius: 10,
                      width: MediaQuery.of(context).size.width,
                      controller: _btnController,
                      onPressed: () async {
                        var token = await _getAuthToken();
                        if (token == null || token.isEmpty) {
                          SnackBar(
                            content: Text('توکن ارسال نشده است'),
                          ).show(context);
                        }

                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          sendData(
                              age: age,
                              height: height,
                              weight: weight,
                              background_disease: background_disease,
                              background_disease_description:
                                  background_disease_description,
                              exercise_days: exercise_days,
                              exercise_hours: exercise_hours,
                              token: token);

                          _btnController.success();

                          Timer(Duration(seconds: 3),
                              () => {_btnController.reset()});
                        } else {
                          _btnController.error();

                          Timer(Duration(seconds: 3),
                              () => {_btnController.reset()});
                        }
                      },
                      child: Text(
                        'ثبت اطلاعات',
                        style: TextStyle(fontSize: 18),
                      )),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Container buildDiseaseBackgroundFormField() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: TextFormField(
          maxLines: 3,
          onSaved: (newValue) =>
              background_disease_description = newValue.toString(),
          onChanged: (value) {
            return null;
          },
          validator: (value) {
            return null;
          },

          // controller: controller,
          style: TextStyle(color: Colors.black),

          decoration: InputDecoration(
            fillColor: bgButtonYellow,
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)),
            errorStyle: TextStyle(height: 0),
            hintText: 'سابقه بیماری خود را بنویسید',

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
