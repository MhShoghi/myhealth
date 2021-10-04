import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';

import 'components/body.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      color: bgLightColor,
      child: ProfileBody(),
    );
  }
}
