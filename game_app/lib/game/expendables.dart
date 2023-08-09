import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:game_app/attributes/attributes_structure.dart';
import 'package:game_app/enemies/enemy.dart';
import 'package:game_app/game/interactable.dart';
import 'package:game_app/game/proximity_item.dart';
import 'package:recase/recase.dart';

import '../player/player.dart';
import 'enviroment.dart';

enum ExpendableType {
  experienceAttract(iconName: 'experience_attract.png'),
  fearEnemies(iconName: 'fear_enemies.png'),
  teleportRune,
  stunRune,
  healingRune;

  const ExpendableType({this.iconName = 'fear_enemies.png'});
  final String iconName;
  Future<Sprite> buildSprite() async {
    return await Sprite.load('expendables/$iconName');
  }
}

extension ExpendableTypeExtension on ExpendableType {
  Expendable build(Player owner) {
    switch (this) {
      case ExpendableType.experienceAttract:
        return ExperienceAttract(owner: owner);
      case ExpendableType.fearEnemies:
        return FearEnemies(owner: owner);
      // case ExpendableType.teleportRune:
      //   return TeleportRune();
      // case ExpendableType.stunRune:
      //   return StunRune();
      // case ExpendableType.healingRune:
      //   return HealingRune();
      default:
        return FearEnemies(owner: owner);
    }
  }

  InteractableExpendable buildInteractable({
    required Vector2 initialPosition,
    required GameEnviroment gameEnviroment,
  }) {
    return InteractableExpendable(
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
}

class ExperienceAttract extends Expendable {
  ExperienceAttract({required Player owner}) : super(owner: owner);
  @override
  ExpendableType expendableType = ExpendableType.experienceAttract;

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

class FearEnemies extends Expendable {
  FearEnemies({required Player owner}) : super(owner: owner);
  @override
  ExpendableType expendableType = ExpendableType.fearEnemies;

  @override
  void applyExpendable() {
    final enemies =
        owner.world.bodies.where((element) => element.userData is Enemy);

    //Player effect
    //SFX

    for (var element in enemies) {
      final item = element.userData as Enemy;
      item.addAttribute(AttributeType.fear,
          level: 1, isTemporary: true, duration: 3, perpetratorEntity: owner);
    }
  }
}

class InteractableExpendable extends InteractableComponent {
  InteractableExpendable({
    required this.expendableType,
    required super.initialPosition,
    required super.gameEnviroment,
  });

  @override
  Future<void> onLoad() async {
    spriteComponent = SpriteAnimationComponent(
        anchor: Anchor.center,
        animation: SpriteAnimation.spriteList(
            [await expendableType.buildSprite()],
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

    player.pickupExpendable(expendableType.build(gameEnviroment.player!));

    removeFromParent();
  }

  @override
  set displayedTextString(String displayedTextString) {
    this.displayedTextString = displayedTextString;
  }
}
