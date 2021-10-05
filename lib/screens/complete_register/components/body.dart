import 'dart:async';
import 'dart:convert';

import 'package:custom_check_box/custom_check_box.dart';
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
      disease_diabet,
      disease_liver,
      disease_kidney,
      disease_heart,
      disease_lung,
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
        'disease_diabet': disease_diabet,
        'disease_kidney': disease_kidney,
        'disease_lung': disease_lung,
        'disease_heart': disease_heart,
        'disease_liver': disease_liver,
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
  bool disease_diabet = false;
  bool disease_kidney = false;
  bool disease_lung = false;
  bool disease_heart = false;
  bool disease_liver = false;
  bool disease_all = false;
  List<int> exercise_days = [];
  List<int> exercise_hours = [];

  List<String> errors = [];

  void setAllDiseasesToTrue() {
    setState(() {
      disease_diabet = true;
      disease_kidney = true;
      disease_lung = true;
      disease_heart = true;
      disease_liver = true;
      disease_all = true;
    });
  }

  void setAllDiseasesToFalse() {
    setState(() {
      disease_diabet = false;
      disease_kidney = false;
      disease_lung = false;
      disease_heart = false;
      disease_liver = false;
      disease_all = false;
    });
  }

  void toggleDiseases() {
    disease_all ? setAllDiseasesToFalse() : setAllDiseasesToTrue();
  }

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
                                'سابقه بیماری دارید؟',
                                style: TextStyle(color: Colors.black),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: buildDiseaseCheckBox(
                                        label: 'دیابت',
                                        press: (value) {
                                          setState(() {
                                            disease_diabet = value;
                                          });
                                        },
                                        value: disease_diabet),
                                  ),
                                  Flexible(
                                      flex: 1,
                                      child: buildDiseaseCheckBox(
                                          label: 'قلب',
                                          press: (value) {
                                            setState(() {
                                              disease_heart = value;
                                            });
                                          },
                                          value: disease_heart)),
                                  Flexible(
                                    flex: 1,
                                    child: buildDiseaseCheckBox(
                                        label: 'ریه',
                                        press: (value) {
                                          setState(() {
                                            disease_lung = value;
                                          });
                                        },
                                        value: disease_lung),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: buildDiseaseCheckBox(
                                        label: 'کبد',
                                        press: (value) {
                                          setState(() {
                                            disease_liver = value;
                                          });
                                        },
                                        value: disease_liver),
                                  ),
                                  Flexible(
                                      flex: 1,
                                      child: buildDiseaseCheckBox(
                                          label: 'کلیه',
                                          press: (value) {
                                            setState(() {
                                              disease_kidney = value;
                                            });
                                          },
                                          value: disease_kidney)),
                                  Flexible(
                                    flex: 1,
                                    child: buildDiseaseCheckBox(
                                        label: 'همه',
                                        press: (value) => toggleDiseases(),
                                        value: disease_all),
                                  ),
                                ],
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
                                    TextStyle(color: Colors.white),
                                selectedColor: primaryColor,
                                spacing: 10,
                                mainGroupAlignment: MainGroupAlignment.start,
                                buttonWidth: SizeConfig.screenWidth > 420
                                    ? MediaQuery.of(context).size.width * 0.15
                                    : MediaQuery.of(context).size.width * 0.35,
                                borderRadius: BorderRadius.circular(5),
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
                                    TextStyle(color: Colors.white),
                                selectedColor: primaryColor,
                                spacing: 10,
                                mainGroupAlignment: MainGroupAlignment.start,
                                buttonWidth: SizeConfig.screenWidth > 420
                                    ? MediaQuery.of(context).size.width * 0.15
                                    : MediaQuery.of(context).size.width * 0.35,
                                borderRadius: BorderRadius.circular(5),
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
                              exercise_days: exercise_days,
                              exercise_hours: exercise_hours,
                              disease_diabet: disease_diabet,
                              disease_heart: disease_heart,
                              disease_lung: disease_lung,
                              disease_liver: disease_liver,
                              disease_kidney: disease_kidney,
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

  Row buildDiseaseCheckBox({required label, required press, value = false}) {
    return Row(
      children: [
        CustomCheckBox(borderRadius: 3, value: value, onChanged: press),
        Text(label),
      ],
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
