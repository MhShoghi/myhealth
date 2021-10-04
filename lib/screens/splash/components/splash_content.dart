import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';

import '../../../size_config.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({
    Key? key,
    required this.image,
  }) : super(key: key);

  final String image;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(
          flex: 2,
        ),
        Image.asset(
          image,
          width: getProportionateScreenWidth(265),
          height: getProportionateScreenHeight(235),
        )
      ],
    );
  }
}
