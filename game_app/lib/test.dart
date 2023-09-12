// ignore_for_file: unused_import

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/attributes/attributes_structure.dart';
import 'package:game_app/enemies/enemy.dart';
import 'package:game_app/game/enviroment.dart';
import 'package:game_app/game/event_management.dart';
import 'package:game_app/enviroment_interactables/expendables.dart';
import 'package:game_app/enviroment_interactables/runes.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/enums.dart';

import 'entities/child_entities.dart';

void conductTests(GameEnviroment gameEnviroment) {
  final player = gameEnviroment.player;
  Future.delayed(2.1.seconds).then((value) {
    gameEnviroment.physicsComponent.add(ExpendableType.weapon.buildInteractable(
        initialPosition: Vector2.zero(),
        gameEnviroment: gameEnviroment,
        weaponType: WeaponType.arcaneBlaster));
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
