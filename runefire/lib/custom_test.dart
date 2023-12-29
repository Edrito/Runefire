// ignore_for_file: unused_import

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/achievements/achievements.dart';
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
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/game_state_class.dart';

bool disableEnemies = false;

Future<void> conductTests(GameEnviroment gameEnviroment) async {
  final player = gameEnviroment.player;
  await player?.loaded;
  await Future.delayed(1.seconds);
  player?.stamina.baseParameter = 40000;
  player?.maxLives.baseParameter = 2;
  // player?.currentWeapon?.attackCountIncrease.setParameterFlatValue('a', 5);
  // player?.swapWeapon();

  // player?.currentWeapon?.attackCountIncrease.setParameterFlatValue('a', 5);

  // for (final element in WeaponType.values
  //     .where((element) => element.attackType == AttackType.magic)) {
  player?.clearWeapons();
  // player?.carriedWeapons.add(
  //   element.build(
  //     ancestor: player,
  //     gameRouter: gameEnviroment.gameRef,
  //   ),
  // );
  player?.carriedWeapons.add(
    WeaponType.energyMagic.build(
      ancestor: player,
      playerData: gameEnviroment.gameRef.playerDataComponent.dataObject,
      secondaryWeaponType: SecondaryType.surroundAttack,
    ),
  );
  player?.swapWeapon(
    player.currentWeapon,
  );
  // await Future.delayed(20.seconds);
  // }
}

//   await Future.delayed(5.seconds);
// }

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
