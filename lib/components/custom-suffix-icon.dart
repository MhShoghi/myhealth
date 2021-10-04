import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomSuffixIcon extends StatelessWidget {
  const CustomSuffixIcon(this.svgIcon);
  final String svgIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20,
      ),
      child: SvgPicture.asset(
        svgIcon,
        height: 18,
      ),
    );
  }
}
