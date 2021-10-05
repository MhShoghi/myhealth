import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health/classes/Http.dart';
import 'package:health/components/form_error.dart';
import 'package:health/components/round_button.dart';
import 'package:health/components/snackbar.dart';
import 'package:health/config/Helper.dart';
import 'package:health/config/colors.dart';
import 'package:health/config/constants.dart';
import 'package:health/routes/routes.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:http/http.dart' as http;
import 'package:snack/snack.dart';

class ForgetPasswordBody extends StatefulWidget {
  const ForgetPasswordBody({Key? key}) : super(key: key);

  @override
  _ForgetPasswordBodyState createState() => _ForgetPasswordBodyState();
}

class _ForgetPasswordBodyState extends State<ForgetPasswordBody> {
  // Define initializers
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final _formKey = GlobalKey<FormState>();

  // Define attributes
  String phoneNumber = '';
  List<String> errors = [];

  // Define methods
  Future<void> forgetPassword({userPhoneNumber}) async {
    Future<http.Response> futureResponse = Http.post(
        uri: 'users/password/forget',
        body: jsonEncode(<String, dynamic>{'userPhoneNumber': userPhoneNumber}),
        headers: <String, String>{'Content-type': 'application/json'});

    var response = await futureResponse;

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _btnController.success();

      Helper.navigate(
          duration: 3,
          route: recoveryPasswordRoute(phoneNumber: phoneNumber),
          context: context);
      buildSnackBar(
              icon: Icons.password_outlined,
              iconColor: primaryColor,
              text: 'درخواست بازیابی رمز عبور ارسال شد')
          .show(context);

      Helper.resetButton(controller: _btnController, duration: 3);
    } else {
      _btnController.error();

      Helper.resetButton(duration: 3, controller: _btnController);

      buildSnackBar(
              icon: Icons.error,
              iconColor: redColor,
              text: responseBody['errors'][0]['message'])
          .show(context);
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
        child: SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              'فراموشی رمز عبور',
              style: TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              'جهت بازیابی رمز عبور، شماره موبایل خود را وارد کنید',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w100),
            ),
            SizedBox(
              height: 30,
            ),
            Form(
              key: _formKey,
              child: buildPhoneNumberFormField(),
            ),
            Directionality(
                textDirection: TextDirection.rtl,
                child: FormError(errors: errors)),
            RoundButton(
              btnController: _btnController,
              label: 'بازیابی',
              onPress: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  forgetPassword(userPhoneNumber: phoneNumber);
                } else {
                  _btnController.error();
                  Timer(Duration(seconds: 2), () => {_btnController.reset()});
                }
              },
            ),
          ],
        ),
      ),
    ));
  }

  Container buildPhoneNumberFormField() {
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
        textAlign: TextAlign.right,
        onSaved: (newValue) => phoneNumber = newValue.toString(),
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
}

class DefaultSnack extends StatelessWidget {
  const DefaultSnack({
    Key? key,
    required this.text,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final Color iconColor;

  @override
  SnackBar build(BuildContext context) {
    return SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            text,
            style: TextStyle(fontFamily: 'Dana'),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(
            width: 5,
          ),
          Icon(
            icon,
            color: iconColor,
          ),
        ],
      ),
    );
  }
}


// Define Routes
