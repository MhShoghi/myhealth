import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/screens/diets/components/body.dart';

import 'components/body.dart';

class DietDetailsScreen extends StatefulWidget {
  final diet;
  const DietDetailsScreen({Key? key, this.diet}) : super(key: key);

  @override
  _DietDetailsScreenState createState() => _DietDetailsScreenState(diet: diet);
}

class _DietDetailsScreenState extends State<DietDetailsScreen> {
  final diet;

  _DietDetailsScreenState({this.diet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgLightColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: bgLightColor,
      body: DietDetailsBody(diet: diet),
    );
  }
}
