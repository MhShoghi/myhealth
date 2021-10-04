import 'package:flutter/material.dart';
import 'package:health/screens/calculate_bmi/components/body.dart';

import '../../size_config.dart';

class CalculateBmiScreen extends StatelessWidget {
  const CalculateBmiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CalculateBmiBody(),
    );
  }
}
