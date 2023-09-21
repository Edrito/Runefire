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

void conductTests(GameEnviroment gameEnviroment) {
  final player = gameEnviroment.player;
  Future.delayed(2.1.seconds).then((value) {
    player?.addAttribute(AttributeType.explosiveDash,
        damageType: DamageType.psychic);
  });
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
