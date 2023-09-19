// ignore_for_file: overridden_fields

import 'dart:async';

import 'package:flame/components.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../entities/entity_mixin.dart';
import '../resources/functions/functions.dart';
import '../resources/enums.dart';

class Icecicle extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  Icecicle(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.frost] = (5, 10);
    maxAttacks.baseParameter = 20;
    attackTickRate.baseParameter = .35;
  }
  @override
  WeaponType weaponType = WeaponType.icecicleMagic;

  // @override
  // void mapUpgrade() {
  //   unMapUpgrade();

  //   super.mapUpgrade();
  // }

  // @override
  // void unMapUpgrade() {}

  @override
  // TODO: implement removeSpriteOnAttack
  bool get removeSpriteOnAttack => true;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      // case WeaponSpritePosition.back:
      //   return WeaponSpriteAnimation(
      //     Vector2.all(0),
      //     Vector2(-.175, 2.65),
      //     weaponAnimations: {
      //       WeaponStatus.idle:
      //           await loadSpriteAnimation(1, 'weapons/book_idle.png', .2, true),
      //     },
      //     parentJoint: parentJoint,
      //     weapon: this,
      //   );
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          Vector2(-.175, 2.65),
          weaponAnimations: {
            // WeaponStatus.attack: await loadSpriteAnimation(
            //     7, 'weapons/long_rifle_attack.png', .02, false),
            'muzzle_flash': await loadSpriteAnimation(
                1, 'weapons/muzzle_flash.png', .2, false),
            WeaponStatus.idle:
                await loadSpriteAnimation(1, 'weapons/book_idle.png', .2, true),
            WeaponStatus.attack:
                await loadSpriteAnimation(1, 'weapons/book_fire.png', 2, false),
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double distanceFromPlayer = 1;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    // WeaponSpritePosition.back,
    WeaponSpritePosition.hand,
  ];

  @override
  ProjectileType? projectileType = ProjectileType.spriteBullet;

  @override
  double weaponSize = .85;
}
