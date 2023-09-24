import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:runefire/resources/functions/vector_functions.dart';

import '../../main.dart';

///Takes a double tuple and returns a random value between the two

double randomBetween((double, double) val) {
  return (rng.nextDouble() * (val.$2 - val.$1)) + val.$1;
}

double roundDouble(double value, int places) {
  double mod = pow(10.0, places).toDouble();
  return ((value * mod).round().toDouble() / mod);
}

Widget buildImageAsset(String asset,
    {BoxFit fit = BoxFit.cover, Color? color}) {
  return Image.asset(
    asset,
    color: color,
    filterQuality: FilterQuality.none,
    fit: fit,
  );
}

String convertSecondsToMinutesSeconds(int seconds) {
  int minutes = seconds ~/ 60;
  int remainingSeconds = seconds % 60;
  String minutesString = minutes.toString().padLeft(2, '0');
  String secondsString = remainingSeconds.toString().padLeft(2, '0');
  return "$minutesString:$secondsString";
}

List<Vector2> getCirclePoints(double radius, int count) {
  if (radius <= 0 || count < 1) {
    throw ArgumentError(
        'Radius must be positive and count must be at least 1.');
  }

  double angleIncrement = 2 * pi / count;
  List<Vector2> points = [];

  for (int i = 0; i < count; i++) {
    double angle =
        -pi / 2 + angleIncrement * i; // Adjusting to start at northwest
    double x = radius * cos(angle);
    double y = radius * sin(angle);
    points.add(Vector2(x, y));
  }

  return points;
}
