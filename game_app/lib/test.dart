// ignore_for_file: unused_import

import 'package:flame/components.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/game/enviroment.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/enums.dart';

import 'attributes/child_entities.dart';

void conductTests(GameEnviroment gameEnviroment) {
  Future.delayed(1.seconds).then((value) {
    gameEnviroment.player?.addHeadEntity(TeslaCrystal(
        initialPosition: Vector2.zero(),
        parentEntity: gameEnviroment.player!,
        enviroment: gameEnviroment,
        upgradeLevel: 1));
  });
  for (var i = 0; i < 30; i++) {
    Future.delayed((3 + (i * .1)).seconds).then((value) {
      gameEnviroment.player?.addBodyEntity(TeslaCrystal(
          initialPosition: Vector2.zero(),
          parentEntity: gameEnviroment.player!,
          distance: rng.nextInt(3).toDouble() / 2,
          enviroment: gameEnviroment,
          upgradeLevel: 1));
    });
  }
}
