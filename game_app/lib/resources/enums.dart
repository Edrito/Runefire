import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/weapons/weapon_mixin.dart';
import 'package:game_app/weapons/weapons.dart';

import '../entities/entity.dart';
import '../game/background.dart';
import '../game/enviroment.dart';
import '../game/forest_game.dart';
import '../weapons/projectiles.dart';
import '../weapons/weapon_class.dart';

enum EntityType { player, enemy, npc }

enum FixtureType { sensor, body }

enum EntityStatus {
  dodge,
  spawn,
  idle,
  run,
  walk,
  jump,
  dash,
  dead,
  damage,
  attack
}

enum WeaponStatus { attack, reload, charge, spawn, idle }

enum JoystickDirection {
  up,
  upLeft,
  upRight,
  right,
  down,
  downRight,
  downLeft,
  left,
  idle,
}

extension CharacterTypeFilename on CharacterType {}

enum EnemyType {
  flameHead,
}

enum GameLevel { space, forest, home }

enum CharacterType { wizard, rogue }

extension EnemyTypeFilename on EnemyType {
  String getFilename() {
    switch (this) {
      case EnemyType.flameHead:
        return 'flame_head.png';

      default:
        return '';
    }
  }
}

enum ExperienceAmount { small, medium, large }

enum InputType {
  keyboard,
  mouseMove,
  aimJoy,
  moveJoy,
  tapClick,
  secondaryClick,
  mouseDrag,
  mouseDragStart,
  ai,
}

extension ExperienceAmountExtension on ExperienceAmount {
  String getSpriteString() {
    switch (this) {
      case ExperienceAmount.small:
        return 'experience/small.png';
      case ExperienceAmount.medium:
        return 'experience/medium.png';

      case ExperienceAmount.large:
        return 'experience/large.png';
    }
  }

  double get experienceAmount {
    switch (this) {
      case ExperienceAmount.small:
        return 1;
      case ExperienceAmount.medium:
        return 10;
      case ExperienceAmount.large:
        return 100;
    }
  }
}

enum ProjectileType { bullet, arrow, laser, fireball }

extension ProjectileTypeExtension on ProjectileType {
  BodyComponent generateProjectile(
      {required Vector2 delta,
      required Vector2 originPositionVar,
      required ProjectileFunctionality ancestorVar,
      double chargeAmount = 1}) {
    switch (this) {
      case ProjectileType.laser:
        return Laser(
            originPosition: originPositionVar,
            delta: delta,
            weaponAncestor: ancestorVar,
            power: chargeAmount);
      case ProjectileType.bullet:
        return Bullet(
            originPosition: originPositionVar,
            delta: delta,
            weaponAncestor: ancestorVar,
            power: chargeAmount);
      case ProjectileType.fireball:
        return Fireball(
            weaponAncestor: ancestorVar,
            originPosition: originPositionVar,
            delta: delta,
            power: chargeAmount);

      default:
        return Bullet(
            originPosition: originPositionVar,
            delta: delta,
            weaponAncestor: ancestorVar,
            power: chargeAmount);
    }
  }
}

extension GameLevelExtension on GameLevel {
  String getTileFilename() {
    switch (this) {
      case GameLevel.space:
        return 'isometric-sandbox-map.tmx';
      case GameLevel.forest:
        return 'isometric-sandbox-map.tmx';
      case GameLevel.home:
        return 'home-room.tmx';
      default:
        return '';
    }
  }

  BackgroundComponent buildBackground(GameEnviroment gameRef) {
    switch (this) {
      case GameLevel.space:
        return ForestBackground(gameRef);
      case GameLevel.forest:
        return ForestBackground(gameRef);

      case GameLevel.home:
        return ForestBackground(gameRef);
    }
  }
}

enum WeaponSpritePosition { hand, mouse, back }

enum AttackType { projectile, melee, special }

enum WeaponState { shooting, reloading, idle }

extension SecondaryWeaponTypeExtension on SecondaryType {
  dynamic build(Weapon primaryWeaponAncestor, [int? upgradeLevel = 0]) {
    switch (this) {
      case SecondaryType.reloadAndRapidFire:
        return RapidFire(primaryWeaponAncestor, 5);
      case SecondaryType.pistol:
        return Portal.create(
            upgradeLevel, primaryWeaponAncestor.entityAncestor);
    }
  }
}

enum WeaponType {
  pistol(Pistol.create, 'assets/images/weapons/pistol.png', 5,
      AttackType.projectile),
  shotgun(Shotgun.create, 'assets/images/weapons/shotgun.png', 5,
      AttackType.projectile),
  portal(Portal.create, 'assets/images/weapons/portal.png', 5,
      AttackType.projectile),
  shiv(Sword.create, 'assets/images/weapons/sword.png', 5, AttackType.melee),
  bow(Bow.create, 'assets/images/weapons/bow.png', 10, AttackType.projectile);

  const WeaponType(
      this.createFunction, this.icon, this.maxLevel, this.attackType);
  final String icon;
  final int maxLevel;
  final AttackType attackType;
  final Function createFunction;
}

extension WeaponTypeFilename on WeaponType {
  Weapon build(AimFunctionality? ancestor, SecondaryType? secondaryWeaponType,
      [int? upgradeLevel = 0]) {
    Weapon? returnWeapon;

    switch (this) {
      case WeaponType.pistol:
        returnWeapon = Pistol.create(upgradeLevel, ancestor);
        break;
      case WeaponType.shotgun:
        returnWeapon = Shotgun.create(upgradeLevel, ancestor);
        break;

      case WeaponType.bow:
        returnWeapon = Bow.create(upgradeLevel, ancestor);
        break;

      case WeaponType.shiv:
        returnWeapon = Sword.create(upgradeLevel, ancestor);

        break;
      case WeaponType.portal:
        returnWeapon = Portal.create(upgradeLevel, ancestor);
        break;
    }
    if (returnWeapon is SecondaryFunctionality) {
      (returnWeapon).setSecondaryFunctionality =
          secondaryWeaponType?.build(returnWeapon, upgradeLevel);
    }
    return returnWeapon;
  }
}

enum SemiAutoType { regular, release, charge }

enum DamageType { regular, magic, energy, psychic, fire }

typedef WeaponCreateFunction = Weapon Function(Entity);

class DamageInstance {
  DamageInstance(
      {required this.damageBase, required this.damageType, this.duration = 1});

  Color getColor() {
    switch (damageType) {
      case DamageType.regular:
        return Colors.white;
      case DamageType.magic:
        return Colors.blue;
      case DamageType.psychic:
        return Colors.purple;
      case DamageType.fire:
        return Colors.red;
      case DamageType.energy:
        return Colors.yellow;
    }
  }

  double damageBase;
  double get damage => damageBase;

  DamageType damageType;
  double duration;
}

enum SecondaryType {
  reloadAndRapidFire(
      'assets/images/weapons/portal.png', 5, weaponIsReloadFunctionality),
  pistol('assets/images/weapons/portal.png', 5, alwaysCompatible);

  const SecondaryType(this.icon, this.maxLevel, this.compatibilityCheck);

  ///Based on a input weapon, return true or false to
  ///see if the weapon is compatible with the secondary ability
  final CompatibilityFunction compatibilityCheck;
  final String icon;
  final int maxLevel;
}

typedef CompatibilityFunction = bool Function(Weapon);

bool alwaysCompatible(Weapon weapon) => true;

bool weaponIsReloadFunctionality(Weapon weapon) {
  bool test = weapon is ReloadFunctionality;
  return test;
}
