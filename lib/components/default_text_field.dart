import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';

class DefaultTextField extends StatelessWidget {
  const DefaultTextField({
    @required this.label,
    Key? key,
    required this.controller,
    required this.validator,
  }) : super(key: key);

  final label;
  final TextEditingController controller;
  final validator;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: bgTextFieldColor, borderRadius: BorderRadius.circular(10.0)),
      child: TextFormField(
        validator: validator,
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey),
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
