import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as UI;
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'dart:io' as io;

import 'package:runefire/main.dart';

double hypotenuse(double x, double y) {
  return sqrt(pow(x, 2) + pow(y, 2));
}

///Takes a double tuple and returns a random value between the two

double randomBetween((double, double) val) {
  return (rng.nextDouble() * (val.$2 - val.$1)) + val.$1;
}

bool assetExists(String asset) {
// for a file
// await io.File(asset).exists();
  return io.File(asset).existsSync();
}

double roundDouble(double value, int places) {
  final mod = pow(10.0, places).toDouble();
  return (value * mod).round().toDouble() / mod;
}

Image buildImageAsset(
  String asset, {
  BoxFit fit = BoxFit.cover,
  Color? color,
  double? scale,
}) {
  return Image.asset(
    asset,
    color: color,
    scale: scale,
    filterQuality: FilterQuality.none,
    fit: fit,
    isAntiAlias: true,
  );
}

String convertSecondsToMinutesSeconds(int seconds) {
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  final minutesString = minutes.toString().padLeft(2, '0');
  final secondsString = remainingSeconds.toString().padLeft(2, '0');
  return '$minutesString:$secondsString';
}

List<Vector2> getCirclePoints(double radius, int count) {
  if (radius <= 0 || count < 1) {
    throw ArgumentError(
      'Radius must be positive and count must be at least 1.',
    );
  }

  final angleIncrement = 2 * pi / count;
  final points = <Vector2>[];

  for (var i = 0; i < count; i++) {
    final angle =
        -pi / 2 + angleIncrement * i; // Adjusting to start at northwest
    final x = radius * cos(angle);
    final y = radius * sin(angle);
    points.add(Vector2(x, y));
  }

  return points;
}

Future<UI.Image> loadUiImage(String imageAssetPath) async {
  final data = await rootBundle.load(imageAssetPath);
  final completer = Completer<UI.Image>();
  UI.decodeImageFromList(Uint8List.view(data.buffer), completer.complete);
  return completer.future;
}

List<Entity> getEntitiesInRadius(
  Entity entity,
  double radius,
  GameEnviroment gameEnv, {
  bool Function(Entity entity)? test,
}) {
  final entities = <Entity>[];
  for (final e in gameEnv.activeEntites
      .where((element) => test?.call(element) ?? true)) {
    if (e != entity) {
      final distance = e.position.distanceTo(entity.position);
      if (distance <= radius) {
        entities.add(e);
      }
    }
  }
  return entities;
}
