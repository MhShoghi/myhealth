import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../size_config.dart';

class FormResponseError extends StatelessWidget {
  const FormResponseError({
    Key? key,
    required this.errors,
  }) : super(key: key);

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    return Column(
        children: List.generate(
            errors.length, (index) => formErrorText(error: errors[index])));
  }

  Container formErrorText({String error = ''}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/Error.svg',
            height: getProportionateScreenWidth(14),
            width: getProportionateScreenWidth(14),
          ),
          SizedBox(
            width: getProportionateScreenWidth(10),
          ),
          Text(
            error,
            style: TextStyle(fontSize: 15, color: Colors.white),
          )
        ],
      ),
    );
  }
}
