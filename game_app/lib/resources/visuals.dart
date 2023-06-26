import 'dart:io';

import 'package:flutter/material.dart';

TextStyle get fontStyle => TextStyle(
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

Color buttonDownColor = Colors.brown.shade400;
Color buttonUpColor = Colors.red.shade400;
Color backgroundColor = const Color.fromARGB(255, 37, 112, 108);
