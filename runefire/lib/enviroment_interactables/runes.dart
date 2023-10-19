import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/animation.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/enviroment_interactables/expendables.dart';
import 'package:runefire/enviroment_interactables/interactable.dart';
import 'package:runefire/enviroment_interactables/proximity_item.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/enums.dart';
import 'package:recase/recase.dart';
import 'package:runefire/entities/entity_class.dart';

import '../player/player.dart';
import '../game/enviroment.dart';

class ExperienceAttract extends Expendable {
  ExperienceAttract({required Player player}) : super(player: player);
  @override
  ExpendableType expendableType = ExpendableType.experienceAttractRune;

  @override
  void applyExpendable() {
    final activeExperiennceItems = player.world.physicsWorld.bodies
        .where((element) => element.userData is ExperienceItem);

    //Player effect
    //SFX

    for (var element in activeExperiennceItems) {
      final item = element.userData as ExperienceItem;
      item.setTarget = player;
    }
  }
}

class StunEnemiesRune extends Expendable {
  StunEnemiesRune({required Player player}) : super(player: player);
  @override
  ExpendableType expendableType = ExpendableType.stunRune;

  @override
  void applyExpendable() {
    final enemies = player.world.physicsWorld.bodies.where((element) =>
        element.userData is Enemy &&
        player.gameEnviroment.gameCamera.visibleWorldRect
            .containsPoint(element.worldCenter));

    //Player effect
    //SFX

    for (var element in enemies) {
      final item = element.userData as Enemy;
      item.addAttribute(AttributeType.stun,
          isTemporary: true, perpetratorEntity: player);
    }
  }
}

class TeleportRune extends Expendable {
  TeleportRune({required Player player}) : super(player: player);
  @override
  ExpendableType expendableType = ExpendableType.teleportRune;

  @override
  void applyExpendable() {
    Vector2 newPos = player.center;
    final length = player.gameEnviroment.boundsDistanceFromCenter * .8;

    //Dumb logic, prevents teleporting into current area
    //TODO - add logic to prevent teleporting into walls
    while (player.gameEnviroment.gameCamera.visibleWorldRect
        .containsPoint(newPos)) {
      newPos = (Vector2.random() * length * 2) - Vector2.all(length);
    }

    player.body.setTransform(newPos, 0);
  }
}

class FearEnemiesRune extends Expendable {
  FearEnemiesRune({required Player player}) : super(player: player);
  @override
  ExpendableType expendableType = ExpendableType.fearEnemiesRunes;

  @override
  void applyExpendable() {
    final enemies = player.world.physicsWorld.bodies.where((element) =>
        element.userData is Enemy &&
        player.gameEnviroment.gameCamera.visibleWorldRect
            .containsPoint(element.worldCenter));

    //Player effect
    //SFX

    for (var element in enemies) {
      final item = element.userData as Enemy;
      item.addAttribute(AttributeType.fear,
          level: 1, isTemporary: true, duration: 3, perpetratorEntity: player);
    }
  }
}

class HealingRune extends Expendable {
  HealingRune({required Player player}) : super(player: player);
  @override
  ExpendableType expendableType = ExpendableType.healingRune;

  @override
  void applyExpendable() {
    player.heal(player.damageTaken);
  }
}

class WeaponPickup extends Expendable {
  WeaponType weaponType;
  WeaponPickup({required this.weaponType, required super.player});

  @override
  ExpendableType expendableType = ExpendableType.weapon;

  @override
  bool get instantApply => true;

  @override
  void applyExpendable() {
    player.playerData.availableWeapons.add(weaponType);
    // owner.playerData.save();
    //TODO add animation yno
  }
}
