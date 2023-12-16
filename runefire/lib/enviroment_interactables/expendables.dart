import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/animation.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/enviroment_interactables/interactable.dart';
import 'package:runefire/enviroment_interactables/proximity_item.dart';
import 'package:runefire/enviroment_interactables/runes.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/enums.dart';
import 'package:recase/recase.dart';
import 'package:runefire/resources/functions/vector_functions.dart';

import 'package:runefire/player/player.dart';
import 'package:runefire/game/enviroment.dart';

enum ExpendableType {
  experienceAttractRune(iconName: 'experience_attract.png'),
  fearEnemiesRunes(),
  teleportRune,
  weapon,
  stunRune,
  healingRune;

  const ExpendableType({this.iconName = 'fear_enemies.png'});
  final String iconName;
  Future<Sprite> buildSprite({WeaponType? weaponType}) async {
    return await Sprite.load(weaponType?.flamePath ?? 'expendables/$iconName');
  }
}

extension ExpendableTypeExtension on ExpendableType {
  Expendable build(Player player, {WeaponType? weaponType}) {
    switch (this) {
      case ExpendableType.experienceAttractRune:
        return ExperienceAttract(player: player);
      case ExpendableType.fearEnemiesRunes:
        return FearEnemiesRune(player: player);
      case ExpendableType.teleportRune:
        return TeleportRune(player: player);
      case ExpendableType.stunRune:
        return StunEnemiesRune(player: player);
      case ExpendableType.healingRune:
        return HealingRune(player: player);
      case ExpendableType.weapon:
        return WeaponPickup(player: player, weaponType: weaponType!);
      default:
        return FearEnemiesRune(player: player);
    }
  }

  InteractableRunePickup buildInteractable({
    required Vector2 initialPosition,
    required GameEnviroment gameEnviroment,
    WeaponType? weaponType,
  }) {
    if (weaponType != null) {
      return InteractableWeaponPickup(
        expendableType: this,
        initialPosition: initialPosition,
        weaponType: weaponType,
        gameEnviroment: gameEnviroment,
      );
    }
    return InteractableRunePickup(
      expendableType: this,
      initialPosition: initialPosition,
      gameEnviroment: gameEnviroment,
    );
  }
}

abstract class Expendable {
  Expendable({required this.player});
  abstract ExpendableType expendableType;
  Player player;
  bool applyExpendable();
  bool instantApply = false;
}

class InteractableWeaponPickup extends InteractableRunePickup {
  InteractableWeaponPickup({
    required this.weaponType,
    required super.expendableType,
    required super.initialPosition,
    required super.gameEnviroment,
  });
  WeaponType weaponType;
  @override
  Future<Sprite> buildSprite() async {
    return await expendableType.buildSprite(weaponType: weaponType);
  }
}

class InteractableRunePickup extends InteractableComponent {
  InteractableRunePickup({
    required this.expendableType,
    required super.initialPosition,
    required super.gameEnviroment,
  });

  Future<Sprite> buildSprite() async {
    return await expendableType.buildSprite();
  }

  @override
  Future<void> onLoad() async {
    final spirte = await buildSprite();
    spriteComponent = SpriteAnimationComponent(
      anchor: Anchor.center,
      size: spirte.srcSize..scaledToHeight(null, env: gameEnviroment),
      animation: SpriteAnimation.spriteList([spirte], stepTime: 1),
    );
    spriteComponent.add(
      MoveEffect.by(
        Vector2(0, -.2),
        InfiniteEffectController(
          EffectController(
            duration: 1,
            reverseCurve: Curves.easeInOut,
            reverseDuration: 1,
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
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
      final temp = previousExpendable.expendableType.buildInteractable(
        initialPosition: initialPosition,
        gameEnviroment: gameEnviroment,
      );
      gameEnviroment.addPhysicsComponent([temp]);
    }

    if (this is InteractableWeaponPickup) {
      final weapon = this as InteractableWeaponPickup;
      player.pickupExpendable(
        expendableType.build(
          gameEnviroment.player!,
          weaponType: weapon.weaponType,
        ),
      );
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
