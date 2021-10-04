import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';

class VideoDetailItem extends StatelessWidget {
  const VideoDetailItem({
    Key? key,
    required this.size,
    required this.label,
    required this.icon,
  }) : super(key: key);

  final Size size;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      decoration: BoxDecoration(
          color: lightOrangeColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            icon,
            size: size.width * 0.06,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          )
        ],
      ),
    ));
  }
}
