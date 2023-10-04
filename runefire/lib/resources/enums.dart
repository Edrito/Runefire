import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/game/event_management.dart';
import 'package:runefire/player/player_constants.dart' as player_constants;
import 'package:runefire/main.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/weapons/player_magic_weapons.dart';
import 'package:runefire/weapons/player_melee_weapons.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';
import 'package:runefire/weapons/player_projectile_weapons.dart';

import '../enemies/enemy.dart';
import '../enemies/enemy_mushroom.dart';
import '../entities/entity_class.dart';
import '../player/player.dart';
import '../game/background.dart';
import '../game/enviroment.dart';
import '../game/hexed_forest_game.dart';
import '../game/menu_game.dart';
import '../weapons/enemy_weapons.dart';
import '../weapons/projectiles.dart';
import '../weapons/secondary_abilities.dart';
import '../weapons/weapon_class.dart';

enum AudioType {
  sfx,
  music,
  voice,
  ui,
}

enum SourceAttackLocation {
  body,
  weaponTip,
  weaponMid,
  mouse,
  closestEnemyToMouse,
  distanceFromPlayer,
  closestEnemyToPlayer,
  customOffset,
}

enum EnemyType {
  mushroomBrawler,
  mushroomHopper,
  mushroomBoss,
  mushroomBurrower,
  mushroomShooter,
  mushroomBoomer,
  mushroomDummy,
  mushroomSpinner,
  mushroomRunner
}

extension EnemyTypeExtension on EnemyType {
  Enemy build(
    Vector2 position,
    GameEnviroment gameEnviroment,
    int level,
    EventManagement eventManagement,
  ) {
    switch (this) {
      case EnemyType.mushroomHopper:
        return MushroomHopper(
            initialPosition: position,
            enviroment: gameEnviroment,
            eventManagement: eventManagement,
            upgradeLevel: level);
      case EnemyType.mushroomBoomer:
        return MushroomBoomer(
            initialPosition: position,
            eventManagement: eventManagement,
            enviroment: gameEnviroment,
            upgradeLevel: level);
      case EnemyType.mushroomShooter:
        return MushroomShooter(
            eventManagement: eventManagement,
            initialPosition: position,
            enviroment: gameEnviroment,
            upgradeLevel: level);
      case EnemyType.mushroomBurrower:
        return MushroomBurrower(
            eventManagement: eventManagement,
            initialPosition: position,
            enviroment: gameEnviroment,
            upgradeLevel: level);
      case EnemyType.mushroomSpinner:
        return MushroomSpinner(
            initialPosition: position,
            eventManagement: eventManagement,
            enviroment: gameEnviroment,
            upgradeLevel: level);
      case EnemyType.mushroomRunner:
        return MushroomRunner(
            initialPosition: position,
            eventManagement: eventManagement,
            enviroment: gameEnviroment,
            upgradeLevel: level);
      default:
        return MushroomDummy(
            initialPosition: position,
            eventManagement: eventManagement,
            enviroment: gameEnviroment,
            upgradeLevel: level);
    }
  }
}

enum AudioDurationType { bgm, long, short }

enum AudioScope { game, menu, global }

enum EntityType { player, enemy, npc, child }

enum FixtureType { sensor, body }

enum WeaponDescription {
  attackRate,
  damage,
  reloadTime,
  velocity,
  staminaCost,
  semiOrAuto,
  maxAmmo,
  additionalAttackCount,
}

enum SemiAutoType { regular, release, charge }

enum StatusEffects {
  burn,
  chill,
  electrified,
  stun,
  psychic,
  fear,
  marked,
  empowered
}

enum AttackType { guns, melee, magic }

enum MeleeType { slash, stab, crush }

enum DamageType { physical, magic, fire, psychic, energy, frost, healing }

enum DamageKind { dot, area, regular }

enum EntityStatus {
  dodge,
  custom,
  spawn,
  idle,
  // charge,
  run,
  walk,
  jump,
  dash,
  dead,
  damage,
  attack
}

enum WeaponStatus { attack, reload, charge, spawn, idle, chargeIdle, dead }

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

///All have a mage theme
enum CharacterType { regular, sorcerer, warlock, wizard, witch, unknown }

//Unlock cost
extension CharacterTypeUnlockCost on CharacterType {
  int get unlockCost {
    switch (this) {
      case CharacterType.regular:
        return 0;
      case CharacterType.sorcerer:
        return 10000;

      case CharacterType.warlock:
        return 10000;
      case CharacterType.wizard:
        return 10000;
      case CharacterType.witch:
        return 10000;
      case CharacterType.unknown:
        return 20000;
    }
  }
}

enum GameLevel { hexedForest, dungeon, graveyard, menu }

enum GameDifficulty { quick, regular, hard, chaos }

extension GameDifficultyExtension on GameDifficulty {
  List<String> get difficultyDescription {
    switch (this) {
      case GameDifficulty.quick:
        return ['Quick and easy.', 'No Achievements.'];
      case GameDifficulty.regular:
        return [];
      case GameDifficulty.hard:
        return [
          'Enemies have more health, hit harder, and are faster.',
          'Gain increased experience.'
        ];
      case GameDifficulty.chaos:
        return [
          'Enemies will also gain your abilities.',
          'Unique and powerful weapons can be discovered.'
        ];
    }
  }

  Color get color {
    switch (this) {
      case GameDifficulty.quick:
        return ApolloColorPalette.offWhite.color;
      case GameDifficulty.regular:
        return Colors.transparent;
      case GameDifficulty.hard:
        return ApolloColorPalette.red.color;
      case GameDifficulty.chaos:
        return ApolloColorPalette.purple.color;
    }
  }
}

extension CharacterTypeExtension on CharacterType {
  void applyBaseCharacterStats(Player player) {
    switch (this) {
      case CharacterType.regular:
        player.dashCooldown.baseParameter =
            player_constants.regularDashCooldown;
        player.dashDistance.baseParameter =
            player_constants.regularDashDistance;
        player.height.baseParameter = player_constants.regularHeight;
        player.invincibilityDuration.baseParameter =
            player_constants.regularInvincibilityDuration;
        player.maxHealth.baseParameter = player_constants.regularMaxHealth;
        player.speed.baseParameter = player_constants.regularSpeed;
        player.stamina.baseParameter = player_constants.regularStamina;
        player.dodgeChance.baseParameter = player_constants.regularDodgeChance;
      default:
        player.dashCooldown.baseParameter =
            player_constants.regularDashCooldown;
        player.dashDistance.baseParameter =
            player_constants.regularDashDistance;
        player.height.baseParameter = player_constants.regularHeight;
        player.invincibilityDuration.baseParameter =
            player_constants.regularInvincibilityDuration;
        player.maxHealth.baseParameter = player_constants.regularMaxHealth;
        player.speed.baseParameter = player_constants.regularSpeed;
        player.stamina.baseParameter = player_constants.regularStamina;
        player.dodgeChance.baseParameter = player_constants.regularDodgeChance;
    }
  }
}

extension GameLevelExtension on GameLevel {
  Color get levelColor {
    switch (this) {
      case GameLevel.hexedForest:
        return ApolloColorPalette.blue.color;
      case GameLevel.dungeon:
        return ApolloColorPalette.paleGray.color;
      case GameLevel.graveyard:
        return ApolloColorPalette.extraLightGray.color;
      default:
        return Colors.green;
    }
  }

  String get levelImage {
    switch (this) {
      case GameLevel.hexedForest:
        return 'assets/images/background/hexed_forest_display.png';
      case GameLevel.dungeon:
        return 'assets/images/background/dungeon.png';
      case GameLevel.graveyard:
        return 'assets/images/background/graveyard.jpg';
      default:
        return 'assets/images/background/hexed_forest_display.png';
    }
  }

  Enviroment buildEnvrioment() {
    switch (this) {
      case GameLevel.hexedForest:
        return ForestGame();
      // case GameLevel.dungeon:
      // return DungeonGame(gameDifficulty);
      // case GameLevel.graveyard:
      // return DungeonGame(gameDifficulty);

      case GameLevel.menu:
        return MenuGame();

      default:
        return ForestGame();
    }
  }

  BackgroundComponent buildBackground(Enviroment gameRef) {
    switch (this) {
      // case GameLevel.space:
      //   return ForestBackground(gameRef);
      case GameLevel.hexedForest:
        return HexedForestBackground(gameRef);
      case GameLevel.menu:
        return BlankBackground(gameRef);
      default:
        return HexedForestBackground(gameRef);
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
  // mouseDragStart,
  ai,
  attribute,
}

extension ExperienceAmountExtension on ExperienceAmount {
  String get fileName {
    switch (this) {
      case ExperienceAmount.small:
        return ImagesAssetsExperience.small;
      case ExperienceAmount.medium:
        return ImagesAssetsExperience.medium;
      case ExperienceAmount.large:
        return ImagesAssetsExperience.large;
    }
  }

  double get experienceAmount {
    switch (this) {
      case ExperienceAmount.small:
        return 5;
      case ExperienceAmount.medium:
        return 20;
      case ExperienceAmount.large:
        return 150;
    }
  }

  Color get color {
    switch (this) {
      case ExperienceAmount.small:
        return ApolloColorPalette.lightGreen.color;

      case ExperienceAmount.medium:
        return ApolloColorPalette.orange.color;

      case ExperienceAmount.large:
        return ApolloColorPalette.lightRed.color;
    }
  }
}

enum ProjectileType {
  spriteBullet,
  paintBullet,
  laser,
  followLaser,
  magicProjectile,
  holyBullet,
  blackSpriteBullet
}

extension ProjectileTypeExtension on ProjectileType {
  Projectile generateProjectile(
      {required Vector2 delta,
      required Vector2 originPositionVar,
      required ProjectileFunctionality ancestorVar,
      DamageType? primaryDamageType,
      double size = .3,
      double chargeAmount = 1}) {
    switch (this) {
      case ProjectileType.laser:
        return PaintLaser(
            originPosition: originPositionVar,
            size: size,
            delta: delta,
            weaponAncestor: ancestorVar,
            power: chargeAmount);
      case ProjectileType.followLaser:
        return FollowLaser(
            originPosition: originPositionVar,
            delta: delta,
            size: size,
            weaponAncestor: ancestorVar,
            power: chargeAmount);
      case ProjectileType.spriteBullet:
        return SpriteBullet(
            originPosition: originPositionVar,
            delta: delta,
            size: size,
            weaponAncestor: ancestorVar,
            power: chargeAmount);
      case ProjectileType.blackSpriteBullet:
        return SpriteBullet(
            originPosition: originPositionVar,
            delta: delta,
            size: size,
            customBulletName: "black",
            weaponAncestor: ancestorVar,
            // customHitAnimation: spriteAnimations.,
            power: chargeAmount);

      case ProjectileType.magicProjectile:
        return MagicalProjectile(
          weaponAncestor: ancestorVar,
          originPosition: originPositionVar,
          delta: delta,
          primaryDamageType: primaryDamageType,
          size: size,
        );
      case ProjectileType.paintBullet:
        return PaintBullet(
            weaponAncestor: ancestorVar,
            originPosition: originPositionVar,
            delta: delta,
            primaryDamageType: primaryDamageType,
            size: size,
            power: chargeAmount);

      case ProjectileType.holyBullet:
        return SpriteBullet(
            originPosition: originPositionVar,
            delta: delta,
            size: size,
            weaponAncestor: ancestorVar,
            customSpawnAnimation: spriteAnimations.holyBulletSpawn1,
            customPlayAnimation: spriteAnimations.holyBulletPlay1,
            power: chargeAmount);
    }
  }
}

enum WeaponSpritePosition { hand, mouse, back }

// enum WeaponState { shooting, reloading, idle }

extension SecondaryWeaponTypeExtension on SecondaryType {
  dynamic build(Weapon? primaryWeaponAncestor, [int upgradeLevel = 0]) {
    switch (this) {
      case SecondaryType.reloadAndRapidFire:
        return RapidFire(primaryWeaponAncestor, 5, upgradeLevel);
      case SecondaryType.pistol:
        return BlankProjectileWeapon(
            upgradeLevel, primaryWeaponAncestor?.entityAncestor!);
      case SecondaryType.explodeProjectiles:
        return ExplodeProjectile(primaryWeaponAncestor, 5, upgradeLevel);
    }
  }
}

enum WeaponType {
  crystalPistol('assets/images/weapons/pistol.png', 5, AttackType.guns, 0),
  scryshot('assets/images/weapons/long_rifle.png', 5, AttackType.guns, 0),
  arcaneBlaster(
      'assets/images/weapons/arcane_blaster.png', 5, AttackType.guns, 0),
  prismaticBeam(
      'assets/images/weapons/prismatic_beam.png', 5, AttackType.guns, 0),
  railspire('assets/images/weapons/railspire.png', 5, AttackType.guns, 0),
  swordOfJustice(
      'assets/images/weapons/sword_of_justice.png', 5, AttackType.melee, 1250),
  eldritchRunner(
      'assets/images/weapons/eldritch_runner.png', 5, AttackType.guns, 0),
  scatterBlast(
      'assets/images/weapons/scatter_vine.png', 5, AttackType.guns, 500),
  holySword('assets/images/weapons/energy_sword.png', 5, AttackType.melee, 500),
  frostKatana(
      'assets/images/weapons/frost_katana.png', 5, AttackType.melee, 500),
  flameSword('assets/images/weapons/fire_sword.png', 5, AttackType.melee, 500),
  phaseDagger('assets/images/weapons/dagger.png', 5, AttackType.melee, 0),
  blankProjectileWeapon(
      'assets/images/weapons/dagger.png', 5, AttackType.guns, 0),
  icecicleMagic('assets/images/weapons/book_idle.png', 5, AttackType.magic, 0),
  psychicMagic('assets/images/weapons/book_idle.png', 5, AttackType.magic, 0),
  fireballMagic('assets/images/weapons/book_idle.png', 5, AttackType.magic, 0),
  energyMagic('assets/images/weapons/book_idle.png', 5, AttackType.magic, 0),
  magicBlast('assets/images/weapons/book_idle.png', 5, AttackType.magic, 0),
  magicMissile('assets/images/weapons/book_idle.png', 5, AttackType.magic, 0),

  largeSword('assets/images/weapons/large_sword.png', 5, AttackType.melee, 600),
  spear('assets/images/weapons/spear.png', 5, AttackType.melee, 0),
  powerWord('assets/images/weapons/book_idle.png', 5, AttackType.magic, 1500),
  crystalSword(
      'assets/images/weapons/crystal_sword.png', 5, AttackType.melee, 100),
  ;

  const WeaponType(this.icon, this.maxLevel, this.attackType, this.baseCost);
  final String icon;
  final int maxLevel;
  final AttackType attackType;
  final int baseCost;

  String get flameImage {
    final split = icon.split('/');
    return "${split[2]}/${split[3]}";
  }
}

extension WeaponTypeFilename on WeaponType {
  Weapon build(AimFunctionality ancestor, SecondaryType? secondaryWeaponType,
      GameRouter gameRouter,
      [int? customWeaponLevel]) {
    Weapon? returnWeapon;
    int upgradeLevel = customWeaponLevel ??
        gameRouter.playerDataComponent.dataObject.unlockedWeapons[this] ??
        0;

    switch (this) {
      case WeaponType.crystalPistol:
        returnWeapon = CrystalPistol(upgradeLevel, ancestor);
        break;
      case WeaponType.scatterBlast:
        returnWeapon = Shotgun(upgradeLevel, ancestor);
        break;
      case WeaponType.railspire:
        returnWeapon = Railspire(upgradeLevel, ancestor);
        break;
      case WeaponType.magicMissile:
        returnWeapon = MagicMissile(upgradeLevel, ancestor);
        break;
      case WeaponType.frostKatana:
        returnWeapon = FrostKatana(upgradeLevel, ancestor);
        break;
      case WeaponType.fireballMagic:
        returnWeapon = FireballMagic(upgradeLevel, ancestor);
        break;
      case WeaponType.powerWord:
        returnWeapon = PowerWord(upgradeLevel, ancestor);
        break;
      case WeaponType.blankProjectileWeapon:
        returnWeapon = BlankProjectileWeapon(upgradeLevel, ancestor);
        break;
      case WeaponType.arcaneBlaster:
        returnWeapon = ArcaneBlaster(upgradeLevel, ancestor);
        break;
      case WeaponType.scryshot:
        returnWeapon = LongRangeRifle(upgradeLevel, ancestor);
        break;
      case WeaponType.swordOfJustice:
        returnWeapon = SwordOfJustice(upgradeLevel, ancestor);
        break;
      case WeaponType.eldritchRunner:
        returnWeapon = RocketLauncher(upgradeLevel, ancestor);
        break;
      case WeaponType.prismaticBeam:
        returnWeapon = LaserRifle(upgradeLevel, ancestor);
        break;
      case WeaponType.icecicleMagic:
        returnWeapon = Icecicle(upgradeLevel, ancestor);
        break;
      case WeaponType.psychicMagic:
        returnWeapon = PsychicMagic(upgradeLevel, ancestor);
        break;
      case WeaponType.energyMagic:
        returnWeapon = EnergyMagic(upgradeLevel, ancestor);
        break;
      case WeaponType.phaseDagger:
        returnWeapon = PhaseDagger(upgradeLevel, ancestor);

      case WeaponType.largeSword:
        returnWeapon = LargeSword(upgradeLevel, ancestor);
        break;
      case WeaponType.magicBlast:
        returnWeapon = MagicBlast(upgradeLevel, ancestor);
        break;
      case WeaponType.spear:
        returnWeapon = AethertideSpear(upgradeLevel, ancestor);
        break;
      case WeaponType.holySword:
        returnWeapon = HolySword(upgradeLevel, ancestor);
      case WeaponType.crystalSword:
        returnWeapon = CrystalSword(upgradeLevel, ancestor);

        break;
      case WeaponType.flameSword:
        returnWeapon = FlameSword(upgradeLevel, ancestor);

        break;
    }
    if (returnWeapon is SecondaryFunctionality && secondaryWeaponType != null) {
      int secondaryWeaponUpgrade = gameRouter.playerDataComponent.dataObject
              .unlockedSecondarys[secondaryWeaponType] ??
          0;
      returnWeapon.setSecondaryFunctionality =
          secondaryWeaponType.build(returnWeapon, secondaryWeaponUpgrade);
    }
    ancestor.add(returnWeapon);
    return returnWeapon;
  }

  Weapon buildTemp(int upgradeLevel) {
    Weapon? returnWeapon;

    switch (this) {
      case WeaponType.crystalPistol:
        returnWeapon = CrystalPistol(upgradeLevel, null);
        break;
      case WeaponType.scatterBlast:
        returnWeapon = Shotgun(upgradeLevel, null);
        break;
      case WeaponType.railspire:
        returnWeapon = Railspire(upgradeLevel, null);
        break;
      case WeaponType.blankProjectileWeapon:
        returnWeapon = BlankProjectileWeapon(upgradeLevel, null);
        break;
      case WeaponType.arcaneBlaster:
        returnWeapon = ArcaneBlaster(upgradeLevel, null);
        break;
      case WeaponType.fireballMagic:
        returnWeapon = FireballMagic(upgradeLevel, null);
        break;
      case WeaponType.frostKatana:
        returnWeapon = FrostKatana(upgradeLevel, null);
      case WeaponType.scryshot:
        returnWeapon = LongRangeRifle(upgradeLevel, null);
        break;
      case WeaponType.eldritchRunner:
        returnWeapon = RocketLauncher(upgradeLevel, null);
        break;
      case WeaponType.crystalSword:
        returnWeapon = CrystalSword(upgradeLevel, null);
        break;
      case WeaponType.magicMissile:
        returnWeapon = MagicMissile(upgradeLevel, null);
        break;
      case WeaponType.prismaticBeam:
        returnWeapon = LaserRifle(upgradeLevel, null);
        break;
      case WeaponType.psychicMagic:
        returnWeapon = PsychicMagic(upgradeLevel, null);
        break;
      case WeaponType.magicBlast:
        returnWeapon = MagicBlast(upgradeLevel, null);
        break;
      case WeaponType.energyMagic:
        returnWeapon = EnergyMagic(upgradeLevel, null);
        break;
      case WeaponType.phaseDagger:
        returnWeapon = PhaseDagger(upgradeLevel, null);
      case WeaponType.swordOfJustice:
        returnWeapon = SwordOfJustice(upgradeLevel, null);

      case WeaponType.largeSword:
        returnWeapon = LargeSword(upgradeLevel, null);

        break;
      case WeaponType.powerWord:
        returnWeapon = PowerWord(upgradeLevel, null);
        break;
      case WeaponType.icecicleMagic:
        returnWeapon = Icecicle(upgradeLevel, null);
        break;

      case WeaponType.spear:
        returnWeapon = AethertideSpear(upgradeLevel, null);
        break;
      case WeaponType.holySword:
        returnWeapon = HolySword(upgradeLevel, null);

        break;
      case WeaponType.flameSword:
        returnWeapon = FlameSword(upgradeLevel, null);

        break;
    }

    return returnWeapon;
  }
}

extension DamageTypeExtension on DamageType {
  Color get color {
    switch (this) {
      case DamageType.physical:
        return Colors.white;
      case DamageType.energy:
        return ApolloColorPalette.yellow.color;
      case DamageType.psychic:
        return ApolloColorPalette.purple.color;
      case DamageType.magic:
        return ApolloColorPalette.lightBlue.color;
      case DamageType.fire:
        return ApolloColorPalette.orange.color;
      case DamageType.frost:
        return ApolloColorPalette.lightCyan.color;
      case DamageType.healing:
        return ApolloColorPalette.lightGreen.color;
    }
  }
}

class DamageInstance {
  DamageInstance({
    required this.damageMap,
    required this.source,
    required this.victim,
    required this.sourceAttack,
    this.sourceWeapon,
    this.isCrit = false,
    this.damageKind = DamageKind.regular,
    this.statusEffectChance,
  });

  ///Modifies [damageMap] based on entity resistances
  void applyResistances(Entity other) {
    for (var element in damageMap.entries) {
      DamageType damageType = element.key;
      double damageInc = element.value;

      damageInc *=
          other.damageTypeResistance.damagePercentIncrease[element.key] ??= 1;

      damageMap[damageType] = damageInc;
    }
  }

  void checkCrit(bool force) {
    double rngCrit = rng.nextDouble();
    double critDamageIncrease = 1;
    if (!force && victim.consumeMark()) {
      force = true;
    }
    if (rngCrit <=
            source.critChance.parameter +
                (sourceWeapon?.critChance.parameter ?? 0) ||
        force) {
      isCrit = true;
      critDamageIncrease = max(source.critDamage.parameter,
          (sourceWeapon?.critDamage.parameter ?? 1));
    }

    increaseByPercent(critDamageIncrease);
  }

  dynamic sourceAttack;
  Map<StatusEffects, double>? statusEffectChance;
  Entity source;
  HealthFunctionality victim;
  Weapon? sourceWeapon;
  DamageKind damageKind;
  AttackType get attackType =>
      sourceWeapon?.weaponType.attackType ?? AttackType.guns;
  Map<DamageType, double> damageMap;

  double get damage => damageMap.entries
      .where((element) => element.key != DamageType.healing)
      .fold(0, (previousValue, element) => previousValue + element.value);
  bool isCrit;

  void increaseByPercent(double percent) {
    for (var element in damageMap.entries) {
      damageMap[element.key] = element.value * percent;
    }
  }

  // The copyWith function to create a new DamageInstance with updated properties
  DamageInstance copyWith({
    Map<DamageType, double>? damageMap,
    Entity? source,
    HealthFunctionality? victim,
    Weapon? sourceWeapon,
    dynamic sourceAttack,
    Map<StatusEffects, double>? statusEffectChance,
    DamageKind? damageKind,
    bool? isCrit,
  }) {
    return DamageInstance(
      damageMap: damageMap ?? this.damageMap,
      source: source ?? this.source,
      victim: victim ?? this.victim,
      sourceAttack: sourceAttack ?? this.sourceAttack,
      sourceWeapon: sourceWeapon ?? this.sourceWeapon,
      damageKind: damageKind ?? this.damageKind,
      statusEffectChance: statusEffectChance ?? this.statusEffectChance,
      isCrit: isCrit ?? this.isCrit,
    );
  }
}

enum SecondaryType {
  reloadAndRapidFire(ImagesAssetsSecondaryIcons.rapidFire, 5, rapidReload, 500),
  pistol(ImagesAssetsSecondaryIcons.blank, 5, alwaysCompatible, 500),
  explodeProjectiles(ImagesAssetsSecondaryIcons.explodeProjectiles, 5,
      weaponIsProjectileFunctionality, 500);

  const SecondaryType(
      this.icon, this.maxLevel, this.compatibilityCheck, this.baseCost);

  ///Based on a input weapon, return true or false to
  ///see if the weapon is compatible with the secondary ability
  final CompatibilityFunction compatibilityCheck;
  final String icon;
  final int maxLevel;
  final int baseCost;
}

typedef CompatibilityFunction = bool Function(Weapon);

bool alwaysCompatible(Weapon weapon) => true;

bool weaponIsReloadFunctionality(Weapon weapon) {
  bool test = weapon is ReloadFunctionality;
  return test;
}

bool rapidReload(Weapon weapon) {
  if (weapon is! ReloadFunctionality) return false;

  if (weapon is SemiAutomatic &&
      (weapon as SemiAutomatic).semiAutoType != SemiAutoType.regular) {
    return false;
  }
  return true;
}

bool weaponIsProjectileFunctionality(Weapon weapon) {
  bool test = weapon is ProjectileFunctionality;
  return test;
}
