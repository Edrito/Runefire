// ignore_for_file: unused_import

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/achievements/achievements.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/hidden_child_entities/child_entities.dart';
import 'package:runefire/enviroment_interactables/areas.dart';
import 'package:runefire/enviroment_interactables/expendables.dart';
import 'package:runefire/enviroment_interactables/runes.dart';
import 'package:runefire/events/event_class.dart';
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
  // await Future.delayed(1.seconds);
  // player?.stamina.baseParameter = 40000;
  player?.maxLives.baseParameter = 2;

  // player?.onHitOtherEntity.add((damage) {
  //   if (damage.victim is Enemy) {
  //     (damage.victim as Enemy).addAttribute(
  //       AttributeType.bleed,
  //       perpetratorEntity: player,
  //       isTemporary: true,
  //     );
  //   }
  //   return false;
  // });
  // for (final element in DamageType.getValuesWithoutHealing) {
  //   player?.modifyElementalPower(element, .76);
  // }
  player?.modifyElementalPower(DamageType.frost, 1);

  player?.addAttribute(AttributeType.meleeAttackFrozenEnemyShove);

  Future.delayed(5.seconds).then((value) {
    gameEnviroment.activeEntites.whereType<Enemy>().forEach((element) {
      element.addAttribute(
        AttributeType.frozen,
        perpetratorEntity: player,
        isTemporary: true,
        duration: 10,
      );
    });
  });

  // while (true) {
  //   await Future.delayed(.5.seconds);
  //   print(player?.currentAttributeTypes);
  // }

  // player?.addAttribute(
  //   AttributeType.chanceToRevive,
  // );

  // gameEnviroment.addPhysicsComponent([
  //   InteractableWeaponPickup(
  //     weaponType: WeaponType.emberBow,
  //     initialPosition: SpawnLocation.inside.grabNewPosition(gameEnviroment),
  //     gameEnviroment: gameEnviroment,
  //   ),
  // ]);
  // gameEnviroment.addPhysicsComponent([
  //   MushroomSpores(
  //     gameEnviroment: gameEnviroment,
  //     position: SpawnLocation.inside.grabNewPosition(gameEnviroment),
  //     upgradeLevel: 2,
  //   ),
  // ]);
  // return;

  // player?.clearWeapons();
  // player?.carriedWeapons.add(
  //   WeaponType.crystalSword.build(
  //     ancestor: player,
  //     playerData: gameEnviroment.gameRef.playerDataComponent.dataObject,
  //     secondaryWeaponType: SecondaryType.elementalBlast,
  //   ),
  // );
  // player?.swapWeapon(
  //   player.currentWeapon,
  // );
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
