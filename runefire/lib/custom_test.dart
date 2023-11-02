// ignore_for_file: unused_import

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/child_entities.dart';
import 'package:runefire/enviroment_interactables/expendables.dart';
import 'package:runefire/enviroment_interactables/runes.dart';
import 'package:runefire/events/event_management.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/main.dart';
import 'package:runefire/menus/overlays.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/game_state_class.dart';

Future<void> conductTests(GameEnviroment gameEnviroment) async {
  final player = gameEnviroment.player;
  await Future.delayed(1.seconds);
  player?.attributesToGrabDebug.add(AttributeType.psychicReach);

  while (true) {
    await Future.delayed(1.seconds).then((value) {
      final elementIncreasing = DamageType.values.random();
      player?.modifyElementalPower(elementIncreasing, .1);
      if (gameEnviroment.hud.isLoaded) {
        gameEnviroment.hud.applyBossHitEffect(DamageType.values.random());
      }
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
