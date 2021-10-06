import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';

class VideoTagItem extends StatelessWidget {
  const VideoTagItem({
    Key? key,
    required this.label,
  }) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      decoration: BoxDecoration(
          color: lighBlueColor, borderRadius: BorderRadius.circular(10)),
      child: Center(
          child: Text(
        label,
        style: TextStyle(fontSize: 16),
      )),
    ));
  }
}
