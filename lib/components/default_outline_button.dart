import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';


class DefaultOutlineButton extends StatelessWidget {
  const DefaultOutlineButton({
    Key? key,
    required this.text,
    required this.press,
  }) : super(key: key);

  final String text;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: primaryColor)),
          onPressed: press,
          child: Text(
            text,
            style: TextStyle(fontSize: 18, color: primaryColor),
          )),
    );
  }
}
