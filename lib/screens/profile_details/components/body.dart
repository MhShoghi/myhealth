import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/size_config.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snack/snack.dart';
import '../../../config/constants.dart';

class ProfileDetailsBody extends StatefulWidget {
  const ProfileDetailsBody({Key? key}) : super(key: key);

  @override
  _ProfileDetailsBodyState createState() => _ProfileDetailsBodyState();
}

class _ProfileDetailsBodyState extends State<ProfileDetailsBody> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<String> errors = [];
  Map userObject = {};
  Map rangeObject = {};
  bool loading = false;

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

  Future<void> fetchProfileData({token}) async {
    setState(() {
      loading = true;
    });
    final http.Response response = await http
        .get(Uri.parse(API_URL + '/users/me'), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'authorization': token
    });

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        loading = false;
        userObject.addAll(responseBody['result']['user']);
      });
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

  Future<void> fetchUserInfo({token}) async {
    setState(() {
      loading = true;
    });
    final http.Response response = await http
        .get(Uri.parse(API_URL + '/users/bmi'), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'authorization': token
    });

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        rangeObject.addAll(responseBody['result']['range']);
        loading = false;
      });
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
  void initState() {
    _getAuthToken().then((token) => {
          token.isNotEmpty && token != ''
              ? {fetchProfileData(token: token), fetchUserInfo(token: token)}
              : null
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: !loading && userObject.isNotEmpty
                ? Column(
                    children: [
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'اطلاعات شخصی',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 20),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      buildInfoItem(
                          label: 'نام و نام خانوادگی',
                          value: userObject['user_name'] ?? 'مشخص نشده'),
                      SizedBox(
                        height: 10,
                      ),
                      buildInfoItem(
                          label: ':شماره موبایل',
                          value:
                              userObject['user_phone_number'] ?? 'مشخص نشده'),
                      SizedBox(
                        height: 10,
                      ),
                      buildInfoItem(
                          label: ':ایمیل',
                          value: userObject['user_email'] ?? 'مشخص نشده'),
                      SizedBox(
                        height: 10,
                      ),
                      buildInfoItem(
                          label: ':تاریخ تولد',
                          value: userObject['user_birthday'] ?? 'مشخص نشده'),
                      SizedBox(
                        height: 10,
                      ),
                      buildInfoItem(
                          label: ':سن',
                          value: userObject['user_age'] ?? 'مشخص نشده'),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'سابقه بیماری',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 20),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: [
                          buildDisease(
                              label: 'دیابت: ',
                              value: userObject['user_disease_diabet']
                                  ? 'بله'
                                  : 'خیر'),
                          SizedBox(
                            height: 10,
                          ),
                          buildDisease(
                              label: 'قلب: ',
                              value: userObject['user_disease_heart']
                                  ? 'بله'
                                  : 'خیر'),
                          SizedBox(
                            height: 10,
                          ),
                          buildDisease(
                              label: 'کبد: ',
                              value: userObject['user_disease_liver']
                                  ? 'بله'
                                  : 'خیر'),
                          SizedBox(
                            height: 10,
                          ),
                          buildDisease(
                              label: 'کلیه: ',
                              value: userObject['user_disease_kidney']
                                  ? 'بله'
                                  : 'خیر'),
                          SizedBox(
                            height: 10,
                          ),
                          buildDisease(
                              label: 'ریه: ',
                              value: userObject['user_disease_lung']
                                  ? 'بله'
                                  : 'خیر'),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                      Divider(),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'اطلاعات فردی',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 20),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Flexible(
                              child: buildProfileDetailsItem(
                                  label: 'سابقه بیماری',
                                  value: userObject['user_disease_background']
                                      ? 'بله'
                                      : 'خیر',
                                  icon: Icons.history,
                                  textColor: Color.fromRGBO(155, 7, 7, 1),
                                  color: Colors.red.withOpacity(0.4))),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                              child: buildProfileDetailsItem(
                                  label: 'وضعیت بدنی',
                                  value: rangeObject['range_status'] ??
                                      'مشخص نشده',
                                  icon: Icons.info_outline,
                                  textColor: Colors.purple,
                                  color: Colors.purple.withOpacity(0.4))),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Flexible(
                              child: buildProfileDetailsItem(
                                  label: 'ویدیوهای من',
                                  value: '۷ ویدیو',
                                  icon: Icons.video_collection,
                                  textColor: Colors.blue,
                                  color: Colors.blue.withOpacity(0.4))),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                              child: buildProfileDetailsItem(
                                  label: 'برنامه های من',
                                  value: '۴ برنامه',
                                  icon: Icons.restaurant,
                                  textColor: Color.fromRGBO(175, 98, 15, 1),
                                  color: orangeColor.withOpacity(0.4))),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  )
                : Container(
                    height: SizeConfig.screenHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text('در حال بارگذاری')
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Container buildDisease({label, value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
          color: lightOrangeColor, borderRadius: BorderRadius.circular(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(value),
          SizedBox(
            width: 5,
          ),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Container buildProfileDetailsItem(
      {required Color color, textColor, label, icon, value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(10), color: color),
      child: Center(
          child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                child: Icon(
                  icon,
                  color: color,
                )),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                value ?? 'نامشخص',
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        ],
      )),
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
}
