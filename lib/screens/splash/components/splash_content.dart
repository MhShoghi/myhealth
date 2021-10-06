import 'package:flutter/material.dart';

import '../../../size_config.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({
    Key? key,
    required this.image,
    required this.text,
  }) : super(key: key);

  final String image;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          image,
          width: getProportionateScreenWidth(265),
          height: getProportionateScreenHeight(235),
          fit: BoxFit.contain,
        ),
        SizedBox(
          height: 30,
        ),
        Text(
          text,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
