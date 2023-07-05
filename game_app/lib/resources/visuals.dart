import 'dart:io';

import 'package:flutter/material.dart';

final Color buttonDownColor = Colors.brown.shade400;
final Color buttonUpColor = Colors.red.shade400;
const Color backgroundColor = Color.fromARGB(255, 22, 1, 20);
const Color unlockedColor = Color.fromARGB(255, 122, 89, 118);
const Color equippedColor = Color.fromARGB(255, 204, 131, 197);
const Color lockedColor = Color.fromARGB(255, 61, 36, 58);

final defaultStyle = TextStyle(
  fontSize: Platform.isAndroid || Platform.isIOS ? 21 : 35,
  fontFamily: "HeroSpeak",
  fontWeight: FontWeight.bold,
  color: buttonUpColor,
  shadows: const [
    BoxShadow(
        color: Colors.black12,
        offset: Offset(3, 3),
        spreadRadius: 3,
        blurRadius: 0)
  ],
);
