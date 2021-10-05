import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({
    Key? key,
    required RoundedLoadingButtonController btnController,
    required this.label,
    required this.onPress,
  })  : _btnController = btnController,
        super(key: key);

  final RoundedLoadingButtonController _btnController;

  final String label;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      child: RoundedLoadingButton(
          successColor: Colors.green,
          color: primaryColor,
          borderRadius: 10,
          width: MediaQuery.of(context).size.width,
          controller: _btnController,
          onPressed: onPress,
          child: Text(
            label,
            style: TextStyle(fontSize: 18),
          )),
    );
  }
}
