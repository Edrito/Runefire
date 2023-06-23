import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/weapons/weapon_mixin.dart';
import 'package:game_app/weapons/weapons.dart';

import '../entities/entity.dart';
import '../game/background.dart';
import '../game/enviroment.dart';
import '../game/forest_game.dart';
import '../game/home_room.dart';
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

  int get experienceAmount {
    switch (this) {
      case ExperienceAmount.small:
        return 5;
      case ExperienceAmount.medium:
        return 20;
      case ExperienceAmount.large:
        return 100;
    }
  }
}

enum CurrentGameState { mainMenu, transition, gameplay }

enum ProjectileType { bullet, arrow, laser }

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
      case ProjectileType.arrow:
        return Bullet(
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
        return HomeBackground(gameRef);
      case GameLevel.forest:
        return ForestBackground(gameRef);

      case GameLevel.home:
        return HomeBackground(gameRef);
    }
  }
}

enum WeaponSpritePosition { hand, mouse, back, attack, none }

enum AttackType { melee, point, projectile }

enum SecondaryWeaponType {
  reloadAndRapidFire,
}

enum WeaponState { shooting, reloading, idle }

extension SecondaryWeaponTypeExtension on SecondaryWeaponType {
  // SecondaryWeaponFunctionality build(Weapon primaryWeaponAncestor,
  //     [int upgradeLevel = 0]) {
  //   switch (this) {
  //     case SecondaryWeaponType.reloadAndRapidFire:
  //       return Pistol.create(upgradeLevel, ancestor, secondaryWeapon);
  //   }
  // }
}

enum WeaponType {
  pistol,
  shotgun,
  portal,
  sword,
  bow,
}

extension WeaponTypeFilename on WeaponType {
  Weapon build(
      AimFunctionality ancestor, SecondaryWeaponType? secondaryWeaponType,
      [int upgradeLevel = 0]) {
    Weapon? returnWeapon;
    Weapon? secondaryWeapon;

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

      case WeaponType.sword:
        returnWeapon = Sword.create(upgradeLevel, ancestor);

        break;
      case WeaponType.portal:
        returnWeapon = Portal.create(upgradeLevel, ancestor);
        break;
    }

    return returnWeapon;
  }

  String icon() {
    switch (this) {
      case WeaponType.pistol:
        return 'pistol.png';
      case WeaponType.shotgun:
        return 'shotgun.png';

      case WeaponType.bow:
        return 'bow.png';

      case WeaponType.sword:
        return 'sword.png';

      case WeaponType.portal:
        return 'portal.png';
    }
  }
}

enum SemiAutoType { regular, release, charge }

typedef WeaponCreateFunction = Weapon Function(Entity);
