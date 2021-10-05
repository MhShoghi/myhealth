import 'dart:async';
import 'package:flutter/material.dart';

class Helper {
  static navigate({required duration, required route, required context}) {
    Timer(
        Duration(seconds: duration), () => {Navigator.of(context).push(route)});
  }

  static resetButton({required duration, required controller}) {
    Timer(Duration(seconds: duration), () => {controller.reset()});
  }
}
