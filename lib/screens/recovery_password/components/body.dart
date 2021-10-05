import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health/classes/Http.dart';
import 'package:health/components/form_error.dart';
import 'package:health/components/round_button.dart';
import 'package:health/components/snackbar.dart';
import 'package:health/config/Helper.dart';
import 'package:health/config/colors.dart';
import 'package:health/routes/routes.dart';
import 'package:snack/snack.dart';
import 'package:health/config/constants.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:http/http.dart' as http;

class RecoveryPasswordBody extends StatefulWidget {
  final phoneNumber;
  const RecoveryPasswordBody({Key? key, this.phoneNumber}) : super(key: key);

  @override
  _RecoveryPasswordBodyState createState() =>
      _RecoveryPasswordBodyState(phoneNumber: phoneNumber);
}

class _RecoveryPasswordBodyState extends State<RecoveryPasswordBody> {
  final phoneNumber;
  // Define initializers
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final _formKey = GlobalKey<FormState>();

  TextEditingController textEditingController = TextEditingController();

  // Define attributes

  String verifyCode = '';
  String newPassword = '';
  String newConfirmPassword = '';
  List<String> errors = [];

  // Constructor
  _RecoveryPasswordBodyState({this.phoneNumber});

  // Define methods
  Future<void> recoveryPassword(
      {userPhoneNumber, verifyCode, newPassword, newConfirmPassword}) async {
    Future<http.Response> futureResponse = Http.post(
        uri: 'users/password/recovery',
        body: jsonEncode(<String, dynamic>{
          'userPhoneNumber': userPhoneNumber,
          'verifyCode': verifyCode,
          'newPassword': newPassword,
          'newConfirmPassword': newConfirmPassword
        }),
        headers: <String, String>{'Content-type': 'application/json'});

    var response = await futureResponse;

    var responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _btnController.success();

      buildSnackBar(
              icon: Icons.change_circle_outlined,
              iconColor: primaryColor,
              text: 'رمز عبور جدید اعمال شد. مجدد وارد شوید')
          .show(context);
      Helper.navigate(context: context, duration: 2, route: loginRoute());
    } else {
      _btnController.error();

      buildSnackBar(
              icon: Icons.error,
              iconColor: redColor,
              text: responseBody['errors'][0]['message'])
          .show(context);
      Helper.resetButton(controller: _btnController, duration: 3);
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
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'بازیابی رمز عبور',
                style: TextStyle(
                    fontSize: 28,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                'جهت بازیابی رمز عبور، اطلاعات زیر را وارد کنید',
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
                child: Column(
                  children: [
                    buildPinCodeFormField(context),
                    buildNewPasswordFormField(),
                    SizedBox(
                      height: 10,
                    ),
                    buildNewPasswordConfirmFormField()
                  ],
                ),
              ),
              Directionality(
                  textDirection: TextDirection.rtl,
                  child: FormError(errors: errors)),
              RoundButton(
                btnController: _btnController,
                label: 'ثبت',
                onPress: () {
                  if (textEditingController.text.isEmpty ||
                      textEditingController.text.length < 5) {
                    addError(error: kVerificationCodeNullError);
                    _btnController.error();
                  } else {
                    removeError(error: kVerificationCodeNullError);
                  }
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    recoveryPassword(
                        userPhoneNumber: phoneNumber,
                        verifyCode: verifyCode,
                        newPassword: newPassword,
                        newConfirmPassword: newConfirmPassword);
                  } else {
                    _btnController.error();
                    Timer(Duration(seconds: 2), () => {_btnController.reset()});
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ));
  }

  PinCodeTextField buildPinCodeFormField(BuildContext context) {
    return PinCodeTextField(
      enablePinAutofill: false,
      appContext: context,
      length: 5,
      obscureText: false,
      textStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
      animationType: AnimationType.fade,
      controller: textEditingController,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(10),
        inactiveColor: Colors.transparent,
        inactiveFillColor: Colors.grey.withOpacity(0.3),
        activeColor: Colors.black,
        errorBorderColor: errors.contains(kVerificationCodeNullError)
            ? Colors.red
            : Colors.transparent,
        activeFillColor: Colors.grey.withOpacity(0.3),
        selectedColor: Colors.grey,
        selectedFillColor: Colors.grey.withOpacity(0.3),
        fieldHeight: MediaQuery.of(context).size.width * 0.15,
        fieldWidth: MediaQuery.of(context).size.width * 0.15,
      ),
      animationDuration: Duration(milliseconds: 300),
      enableActiveFill: true,
      onSubmitted: (value) => verifyCode = value,
      keyboardType: TextInputType.number,
      onCompleted: (v) {
        setState(() {
          verifyCode = v;
        });
      },
      onChanged: (value) {},
      validator: (value) {},
      onSaved: (newValue) => verifyCode = newValue.toString(),
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
        onSaved: (newValue) => newConfirmPassword = newValue.toString(),
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
