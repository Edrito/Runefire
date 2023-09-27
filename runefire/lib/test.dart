// ignore_for_file: unused_import

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/game/event_management.dart';
import 'package:runefire/enviroment_interactables/expendables.dart';
import 'package:runefire/enviroment_interactables/runes.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/enums.dart';

import 'entities/child_entities.dart';

void conductTests(GameEnviroment gameEnviroment) async {
  final player = gameEnviroment.player;
  Future.delayed(3.seconds).then((value) {
    for (var element in gameEnviroment.player!.world.physicsWorld.bodies) {
      if (element.userData is Enemy) {
        final enemy = element.userData as Enemy;
        enemy.addAttribute(
          AttributeType.stun,
          perpetratorEntity: player,
        );
      }
    }
  });

  while (true) {
    await Future.delayed(2.seconds).then((value) {
      gameEnviroment.hud.applyBossHitEffect(DamageType.values.random());
    });
  }
}

void updateFunction(Enviroment enviroment, double dt) {
  // if (enviroment is GameEnviroment) {
  //   final count = enviroment.gameRef.world.bodies
  //       .where((element) =>
  //           element.userData is Enemy &&
  //           enviroment.gameCamera.visibleWorldRect
  //               .containsPoint(element.worldCenter))
  //       .length;

  //   print(count);
  // }
}
