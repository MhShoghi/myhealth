import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/screens/ranges/components/body.dart';

class RangesScreen extends StatelessWidget {
  final range;
  const RangesScreen({Key? key, this.range}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text('جزئیات شاخص', style: TextStyle(color: Colors.black)),
        backgroundColor: bgLightColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: bgLightColor,
      body: RangesBody(range: range),
    );
  }
}
