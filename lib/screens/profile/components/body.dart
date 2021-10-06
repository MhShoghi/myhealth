import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/config/colors.dart';
import 'package:health/routes/routes.dart';
import 'package:health/screens/change_bmi/change_bmi_screen.dart';
import 'package:health/screens/change_password/change_password_screen.dart';
import 'package:health/screens/profile_details/profile_details_screen.dart';
import 'package:health/size_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snack/snack.dart';
import '../../../config/constants.dart';

class ProfileBody extends StatefulWidget {
  const ProfileBody({Key? key}) : super(key: key);

  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Values

  // ignore: non_constant_identifier_names
  String _user_name = '';
  // ignore: non_constant_identifier_names
  String _user_family = '';

  String _user_phone_number = '';

  String user_profile_image =
      API_BASE_URL + '/thumbnails/' + 'Okwd0n-1633456912460.png';

  bool loading = false;

  Future<void> _removeAuthToken() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('auth_token', '').then((bool success) => {});
  }

  Future pickImage() async {
    try {
      // final image = await ImagePicker()

      // if (image == null) return;
      // final imageTemporary = File(image.path);
      // setState(() {
      //   this.image = imageTemporary;
      // });

    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> fetchUserData({token}) async {
    setState(() {
      loading = true;
    });
    final http.Response response = await http.get(
      Uri.parse(API_URL + '/users/me'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': token
      },
    );

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      var user = responseBody['result']['user'];

      setState(() {
        loading = false;
        _user_name = user['user_name'];
        _user_family = user['user_family'];
        _user_phone_number = user['user_phone_number'];

        user_profile_image = user['user_profile_image'] != null
            ? API_BASE_URL + '/profiles/' + user['user_profile_image']
            : API_BASE_URL + '/thumbnails/' + 'Okwd0n-1633456912460.png';
      });
    } else {
      setState(() {
        loading = false;
      });
      SnackBar(
        content: Row(
          children: [Text(responseBody['errors'][0]['message'])],
        ),
      ).show(context);
    }
  }

  Future<String> _getAuthToken() async {
    SharedPreferences prefs = await _prefs;
    return prefs.getString('auth_token').toString();
  }

  @override
  void initState() {
    _getAuthToken()
        .then((value) => {
              if (value.isNotEmpty) {fetchUserData(token: value)}
            })
        .catchError((err) => {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            !loading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: SizeConfig.screenWidth * 0.08,
                          backgroundImage:
                              NetworkImage(user_profile_image, scale: 1)),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              '$_user_name $_user_family',
                              maxLines: 2,
                              softWrap: true,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Text(_user_phone_number)
                        ],
                      )
                    ],
                  )
                : Center(child: CircularProgressIndicator()),
            SizedBox(
              height: 40,
            ),
            Column(
              children: [
                ProfileItemLink(
                  label: 'اطلاعات من',
                  icon: Icons.info_outline,
                  press: () {
                    Navigator.of(context).push(_createRoute());
                  },
                ),
                ProfileItemLink(
                  label: 'تغییر BMI',
                  icon: Icons.track_changes,
                  press: () {
                    Navigator.of(context).push(_changeBmiRoute());
                  },
                ),
                ProfileItemLink(
                  icon: Icons.password,
                  label: 'تغییر رمز عبور',
                  press: () =>
                      {Navigator.of(context).push(_changePasswordRoute())},
                ),
                ProfileItemLink(
                  icon: Icons.logout,
                  label: 'خروج از حساب کاربری',
                  press: () {
                    _removeAuthToken();

                    Navigator.of(context).push(loginRoute());
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const ProfileDetailsScreen(),
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

Route _changeBmiRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ChangeBmiScreen(),
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

Route _changePasswordRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        ChangePasswordScreen(),
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

class ProfileItemLink extends StatelessWidget {
  const ProfileItemLink({
    Key? key,
    required this.press,
    required this.label,
    required this.icon,
  }) : super(key: key);

  final VoidCallback press;
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: bgLightColor, shadowColor: Colors.transparent),
          onPressed: press,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w100),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
              )
            ],
          ),
        ),
      ),
    );
  }
}
