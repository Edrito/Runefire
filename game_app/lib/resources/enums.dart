import 'package:flame/components.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/weapons/weapon_mixin.dart';
import 'package:game_app/weapons/weapons.dart';

import '../game/background.dart';
import '../game/forest_game.dart';
import '../game/home_room.dart';
import '../weapons/projectiles.dart';
import '../weapons/weapon_class.dart';
import 'classes.dart';

enum EntityType { player, enemy, npc }

enum EntityStatus { spawn, idle, run, walk, jump, dash, dead, damage, attack }

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

enum ProjectileType { pellet, bullet, arrow, fireball }

extension ProjectileTypeExtension on ProjectileType {
  String getFilename() {
    switch (this) {
      case ProjectileType.pellet:
        return 'pellet.png';
      case ProjectileType.bullet:
        return 'bullet.png';
      case ProjectileType.arrow:
        return 'arrow.png';
      case ProjectileType.fireball:
        return 'fireball.png';
      default:
        return '';
    }
  }

  Projectile generateProjectile(
      {required Vector2 delta,
      required double speed,
      required Vector2 originPositionVar,
      required ProjectileFunctionality ancestorVar,
      required String idVar}) {
    switch (this) {
      case ProjectileType.pellet:
        return Pellet(
          originPosition: originPositionVar,
          speed: speed,
          delta: delta,
          weaponAncestor: ancestorVar,
          id: idVar,
        );
      case ProjectileType.bullet:
        return Bullet(
          originPosition: originPositionVar,
          speed: speed,
          delta: delta,
          weaponAncestor: ancestorVar,
          id: idVar,
        );
      case ProjectileType.arrow:
        return Arrow(
          weaponAncestor: ancestorVar,
          originPosition: originPositionVar,
          speed: speed,
          delta: delta,
          id: idVar,
        );
      case ProjectileType.fireball:
        return Fireball(
          originPosition: originPositionVar,
          weaponAncestor: ancestorVar,
          speed: speed,
          delta: delta,
          id: idVar,
        );
      default:
        return Bullet(
          originPosition: originPositionVar,
          speed: speed,
          delta: delta,
          weaponAncestor: ancestorVar,
          id: idVar,
        );
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

enum WeaponState { shooting, reloading, idle }

enum WeaponType {
  pistol,
  shotgun,
  portal,
  sword,
  bow,
}

extension WeaponTypeFilename on WeaponType {
  Weapon build(AimFunctionality? ancestor, [int upgradeLevel = 0]) {
    switch (this) {
      case WeaponType.pistol:
        return Pistol.create(upgradeLevel, ancestor);
      case WeaponType.shotgun:
        return Shotgun.create(upgradeLevel, ancestor);

      case WeaponType.bow:
        return Bow.create(upgradeLevel, ancestor);

      case WeaponType.sword:
        return Sword.create(upgradeLevel, ancestor);

      case WeaponType.portal:
        return Portal.create(upgradeLevel, ancestor);
    }
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
