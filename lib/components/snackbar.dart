
import 'package:flutter/material.dart';

SnackBar buildSnackBar({text, icon, iconColor}) {
  return SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          text,
          style: TextStyle(fontFamily: 'Dana'),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(
          width: 5,
        ),
        Icon(
          icon,
          color: iconColor,
        ),
      ],
    ),
  );
}
