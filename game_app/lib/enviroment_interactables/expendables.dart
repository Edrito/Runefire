import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/animation.dart';
import 'package:game_app/attributes/attributes_structure.dart';
import 'package:game_app/enemies/enemy.dart';
import 'package:game_app/enviroment_interactables/interactable.dart';
import 'package:game_app/enviroment_interactables/proximity_item.dart';
import 'package:game_app/enviroment_interactables/runes.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/enums.dart';
import 'package:recase/recase.dart';

import '../player/player.dart';
import '../game/enviroment.dart';

enum ExpendableType {
  experienceAttractRune(iconName: 'experience_attract.png'),
  fearEnemiesRunes(iconName: 'fear_enemies.png'),
  teleportRune,
  weapon,
  stunRune,
  healingRune;

  const ExpendableType({this.iconName = 'fear_enemies.png'});
  final String iconName;
  Future<Sprite> buildSprite({WeaponType? weaponType}) async {
    return await Sprite.load(weaponType?.flameImage ?? 'expendables/$iconName');
  }
}

extension ExpendableTypeExtension on ExpendableType {
  Expendable build(Player owner, {WeaponType? weaponType}) {
    switch (this) {
      case ExpendableType.experienceAttractRune:
        return ExperienceAttract(owner: owner);
      case ExpendableType.fearEnemiesRunes:
        return FearEnemiesRune(owner: owner);
      case ExpendableType.teleportRune:
        return TeleportRune(owner: owner);
      case ExpendableType.stunRune:
        return StunEnemiesRune(owner: owner);
      case ExpendableType.healingRune:
        return HealingRune(owner: owner);
      case ExpendableType.weapon:
        return WeaponPickup(owner: owner, weaponType: weaponType!);
      default:
        return FearEnemiesRune(owner: owner);
    }
  }

  InteractablePickup buildInteractable(
      {required Vector2 initialPosition,
      required GameEnviroment gameEnviroment,
      WeaponType? weaponType}) {
    if (weaponType != null) {
      return InteractableWeaponPickup(
          expendableType: this,
          initialPosition: initialPosition,
          weaponType: weaponType,
          gameEnviroment: gameEnviroment);
    }
    return InteractablePickup(
        expendableType: this,
        initialPosition: initialPosition,
        gameEnviroment: gameEnviroment);
  }
}

abstract class Expendable {
  Expendable({required this.owner});
  abstract ExpendableType expendableType;
  Player owner;
  void applyExpendable();
  bool instantApply = false;
}

class InteractableWeaponPickup extends InteractablePickup {
  InteractableWeaponPickup(
      {required this.weaponType,
      required super.expendableType,
      required super.initialPosition,
      required super.gameEnviroment});
  WeaponType weaponType;
  @override
  Future<Sprite> buildSprite() async {
    return await expendableType.buildSprite(weaponType: weaponType);
  }
}

class InteractablePickup extends InteractableComponent {
  InteractablePickup({
    required this.expendableType,
    required super.initialPosition,
    required super.gameEnviroment,
  });

  Future<Sprite> buildSprite() async {
    return await expendableType.buildSprite();
  }

  @override
  Future<void> onLoad() async {
    spriteComponent = SpriteAnimationComponent(
        anchor: Anchor.center,
        animation: SpriteAnimation.spriteList([await buildSprite()],
            stepTime: 1, loop: true));
    spriteComponent.add(MoveEffect.by(
        Vector2(0, -.2),
        InfiniteEffectController(EffectController(
            duration: 1,
            reverseCurve: Curves.easeInOut,
            reverseDuration: 1,
            curve: Curves.easeInOut))));
    return super.onLoad();
  }

  ExpendableType expendableType;

  @override
  String get displayedTextString => expendableType.name.titleCase;

  @override
  late SpriteAnimationComponent spriteComponent;

  @override
  void interact() {
    final player = gameEnviroment.player!;
    final previousExpendable = player.currentExpendable;

    if (previousExpendable != null) {
      gameEnviroment.physicsComponent.add(previousExpendable.expendableType
          .buildInteractable(
              initialPosition: initialPosition,
              gameEnviroment: gameEnviroment));
    }

    if (this is InteractableWeaponPickup) {
      final weapon = this as InteractableWeaponPickup;
      player.pickupExpendable(expendableType.build(gameEnviroment.player!,
          weaponType: weapon.weaponType));
    } else {
      player.pickupExpendable(expendableType.build(gameEnviroment.player!));
    }

    removeFromParent();
  }

  @override
  set displayedTextString(String displayedTextString) {
    this.displayedTextString = displayedTextString;
  }
}
