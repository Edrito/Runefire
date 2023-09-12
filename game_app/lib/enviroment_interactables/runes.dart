import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/animation.dart';
import 'package:game_app/attributes/attributes_structure.dart';
import 'package:game_app/enemies/enemy.dart';
import 'package:game_app/enviroment_interactables/expendables.dart';
import 'package:game_app/enviroment_interactables/interactable.dart';
import 'package:game_app/enviroment_interactables/proximity_item.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/enums.dart';
import 'package:recase/recase.dart';

import '../player/player.dart';
import '../game/enviroment.dart';

class ExperienceAttract extends Expendable {
  ExperienceAttract({required Player owner}) : super(owner: owner);
  @override
  ExpendableType expendableType = ExpendableType.experienceAttractRune;

  @override
  void applyExpendable() {
    final activeExperiennceItems = owner.world.bodies
        .where((element) => element.userData is ExperienceItem);

    //Player effect
    //SFX

    for (var element in activeExperiennceItems) {
      final item = element.userData as ExperienceItem;
      item.setTarget = owner;
    }
  }
}

class StunEnemiesRune extends Expendable {
  StunEnemiesRune({required Player owner}) : super(owner: owner);
  @override
  ExpendableType expendableType = ExpendableType.stunRune;

  @override
  void applyExpendable() {
    final enemies = owner.world.bodies.where((element) =>
        element.userData is Enemy &&
        owner.gameEnviroment.gameCamera.visibleWorldRect
            .containsPoint(element.worldCenter));

    //Player effect
    //SFX

    for (var element in enemies) {
      final item = element.userData as Enemy;
      item.addAttribute(AttributeType.stun,
          isTemporary: true, perpetratorEntity: owner);
    }
  }
}

class TeleportRune extends Expendable {
  TeleportRune({required Player owner}) : super(owner: owner);
  @override
  ExpendableType expendableType = ExpendableType.teleportRune;

  @override
  void applyExpendable() {
    Vector2 newPos = owner.center;
    final length = owner.gameEnviroment.boundsDistanceFromCenter * .8;

    //Dumb logic, prevents teleporting into current area
    //TODO - add logic to prevent teleporting into walls
    while (owner.gameEnviroment.gameCamera.visibleWorldRect
        .containsPoint(newPos)) {
      newPos = (Vector2.random() * length * 2) - Vector2.all(length);
    }

    owner.body.setTransform(newPos, 0);
  }
}

class FearEnemiesRune extends Expendable {
  FearEnemiesRune({required Player owner}) : super(owner: owner);
  @override
  ExpendableType expendableType = ExpendableType.fearEnemiesRunes;

  @override
  void applyExpendable() {
    final enemies = owner.world.bodies.where((element) =>
        element.userData is Enemy &&
        owner.gameEnviroment.gameCamera.visibleWorldRect
            .containsPoint(element.worldCenter));

    //Player effect
    //SFX

    for (var element in enemies) {
      final item = element.userData as Enemy;
      item.addAttribute(AttributeType.fear,
          level: 1, isTemporary: true, duration: 3, perpetratorEntity: owner);
    }
  }
}

class HealingRune extends Expendable {
  HealingRune({required Player owner}) : super(owner: owner);
  @override
  ExpendableType expendableType = ExpendableType.healingRune;

  @override
  void applyExpendable() {
    owner.heal(owner.damageTaken);
  }
}

class WeaponPickup extends Expendable {
  WeaponType weaponType;
  WeaponPickup({required this.weaponType, required super.owner});

  @override
  ExpendableType expendableType = ExpendableType.weapon;

  @override
  bool get instantApply => true;

  @override
  void applyExpendable() {
    owner.playerData.availableWeapons.add(weaponType);
    // owner.playerData.save();
    //TODO add animation yno
  }
}
