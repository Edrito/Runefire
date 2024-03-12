import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recase/recase.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/events/event_management.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/player/player_constants.dart' as player_constants;
import 'package:runefire/main.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/resources/data_classes/system_data.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/weapons/custom_weapons.dart';
import 'package:runefire/weapons/player_magic_weapons.dart';
import 'package:runefire/weapons/player_melee_weapons.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';
import 'package:runefire/weapons/player_projectile_weapons.dart';

import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/enemies/enemy_mushroom.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/game/background.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/game/hexed_forest_game.dart';
import 'package:runefire/game/menu_game.dart';
import 'package:runefire/weapons/enemy_weapons.dart';
import 'package:runefire/weapons/projectiles.dart';
import 'package:runefire/weapons/secondary_abilities.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:uuid/uuid.dart';

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
  mushroomRunner,
  mushroomRunnerScared
}

extension EnemyTypeExtension on EnemyType {
  String get enemyName {
    switch (this) {
      case EnemyType.mushroomBoss:
        return 'Mushroom Boss';
      default:
        return name.titleCase;
    }
  }

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
          upgradeLevel: level,
        );
      case EnemyType.mushroomBoomer:
        return MushroomBoomer(
          initialPosition: position,
          eventManagement: eventManagement,
          enviroment: gameEnviroment,
          upgradeLevel: level,
        );
      case EnemyType.mushroomShooter:
        return MushroomShooter(
          eventManagement: eventManagement,
          initialPosition: position,
          enviroment: gameEnviroment,
          upgradeLevel: level,
        );
      case EnemyType.mushroomBurrower:
        return MushroomBurrower(
          eventManagement: eventManagement,
          initialPosition: position,
          enviroment: gameEnviroment,
          upgradeLevel: level,
        );
      case EnemyType.mushroomSpinner:
        return MushroomSpinner(
          initialPosition: position,
          eventManagement: eventManagement,
          enviroment: gameEnviroment,
          upgradeLevel: level,
        );
      case EnemyType.mushroomRunner:
        return MushroomRunner(
          initialPosition: position,
          eventManagement: eventManagement,
          enviroment: gameEnviroment,
          upgradeLevel: level,
        );
      case EnemyType.mushroomRunnerScared:
        return MushroomRunnerScared(
          initialPosition: position,
          eventManagement: eventManagement,
          enviroment: gameEnviroment,
          upgradeLevel: level,
        );
      case EnemyType.mushroomBrawler:
        return MushroomDummy(
          initialPosition: position,
          eventManagement: eventManagement,
          enviroment: gameEnviroment,
          upgradeLevel: level,
        );
      case EnemyType.mushroomBoss:
        return MushroomBoss(
          initialPosition: position,
          eventManagement: eventManagement,
          enviroment: gameEnviroment,
          upgradeLevel: level,
        );
      case EnemyType.mushroomDummy:
        return MushroomDummy(
          initialPosition: position,
          eventManagement: eventManagement,
          enviroment: gameEnviroment,
          upgradeLevel: level,
        );
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
  pierce,
  maxAmmo,
  additionalAttackCount,
  description,
}

enum SemiAutoType { regular, release, charge }

enum StatusEffects {
  burn(isStatusBar: false), //done
  bleed(isStatusBar: false), //done
  chill, //done
  electrified(isStatusBar: false), //done
  slow, //done
  stun, //done
  confused, //done
  fear, //done
  marked(isStatusBar: false), //done
  frozen(otherEffect: true), //Other
  empowered(); //done

  AttributeType get getCorrospondingAttribute {
    return AttributeType.values.firstWhere((element) => element.name == name);
  }

  const StatusEffects({
    this.isStatusBar = true,
    this.otherEffect = false,
  });
  final bool isStatusBar;
  final bool otherEffect;
}

enum AttackType { guns, melee, magic }

enum MeleeType { slash, stab, crush }

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
enum CharacterType {
  runeKnight,
  //  sorcerer,
  //  warlock, wizard, witch, unknown
}

//Unlock cost
extension CharacterTypeUnlockCost on CharacterType {
  // int get unlockCost {
  //   switch (this) {
  //     case CharacterType.regular:
  //       return 0;
  //     case CharacterType.sorcerer:
  //       return 10000;

  //     case CharacterType.warlock:
  //       return 10000;
  //     case CharacterType.wizard:
  //       return 10000;
  //     case CharacterType.witch:
  //       return 10000;
  //     case CharacterType.unknown:
  //       return 20000;
  //   }
  // }

  FileDataClass get assetObject {
    switch (this) {
      case CharacterType.runeKnight:
        return ImagesAssetsRuneknight.runeknightIcon1;
      default:
        return ImagesAssetsRuneknight.runeknightIcon1;
    }
  }

  String get characterCharacteristics {
    switch (this) {
      case CharacterType.runeKnight:
        return 'No notable features, just a regular mage.';
      default:
        return 'misc';
    }
  }

  String get howToUnlock {
    switch (this) {
      case CharacterType.runeKnight:
        return '...';
      default:
        return '...';
    }
  }
}

enum GameLevel { hexedForest, necromancersGraveyard, menu }

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
          'Gain increased experience.',
        ];
      case GameDifficulty.chaos:
        return [
          'Enemies will also gain your abilities.',
          'Unique and powerful weapons can be discovered.',
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

  bool isUnlocked(
    PlayerData playerData,
    SystemData systemData,
    GameLevel gameLevel,
  ) {
    if (!systemData.availableDifficulties.contains(this) && !kDebugMode) {
      return false;
    }
    switch (this) {
      case GameDifficulty.quick:
        return true;
      case GameDifficulty.regular:
        return true;
      case GameDifficulty.hard:
        return playerData.gamesWon.keys
            .contains((gameLevel, GameDifficulty.regular));
      case GameDifficulty.chaos:
        return playerData.gamesWon.keys
            .contains((gameLevel, GameDifficulty.hard));
      default:
        return false;
    }
  }
}

extension CharacterTypeExtension on CharacterType {
  void applyBaseCharacterStats(Player player) {
    switch (this) {
      case CharacterType.runeKnight:
        player.dashCooldown.baseParameter =
            player_constants.regularDashCooldown;
        player.dashDistance.baseParameter =
            player_constants.regularDashDistance;
        player.height.baseParameter = player_constants.regularHeight;
        player.invincibilityDuration.baseParameter =
            player_constants.regularInvincibilityDuration;
        player.maxHealth.baseParameter = player_constants.regularMaxHealth;
        // player.maxHealth.baseParameter = 2;
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
        return ApolloColorPalette.darkestBlue.color;
      // case GameLevel.dungeon:
      //   return ApolloColorPalette.paleGray.color;
      case GameLevel.necromancersGraveyard:
        return ApolloColorPalette.extraLightGray.color;
      default:
        return Colors.green;
    }
  }

  bool isUnlocked(PlayerData playerData, SystemData systemData) {
    if (!systemData.availableLevels.contains(this) && !kDebugMode) {
      return false;
    }
    switch (this) {
      case GameLevel.hexedForest:
        return true;
      // case GameLevel.dungeon:
      //   return playerData.gamesWon.keys
      //       .any((element) => element.$1 == GameLevel.hexedForest);
      case GameLevel.necromancersGraveyard:
        return playerData.gamesWon.keys
            .any((element) => element.$1 == GameLevel.hexedForest);
      default:
        return false;
    }
  }

  String get levelImage {
    switch (this) {
      case GameLevel.hexedForest:
        return 'assets/images/background/hexed_forest_display.png';
      // case GameLevel.dungeon:
      //   return 'assets/images/background/dungeon.png';
      case GameLevel.necromancersGraveyard:
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

// enum InputType {
//   keyboard,
//   mouse,
//   aimJoy,
//   moveJoy,
//   primary,
//   secondary,
//   // mouseDragStart,
//   general,
//   ai,
//   attribute,
// }

extension ExperienceAmountExtension on ExperienceAmount {
  FileDataClass get fileData {
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
        return 10;
      case ExperienceAmount.medium:
        return 40;
      case ExperienceAmount.large:
        return 200;
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
  blackSpriteBullet,
  slowFire
}

extension ProjectileTypeExtension on ProjectileType {
  Projectile generateProjectile(
    ProjectileConfiguration projectileConfiguration,
  ) {
    switch (this) {
      case ProjectileType.laser:
        return PaintLaser(
          projectileConfiguration,
        );
      case ProjectileType.followLaser:
        return FollowLaser(
          projectileConfiguration,
        );
      case ProjectileType.spriteBullet:
        return SpriteBullet(
          projectileConfiguration,
        );
      case ProjectileType.blackSpriteBullet:
        return SpriteBullet(
          projectileConfiguration,
          customBulletName: 'black',
        );

      case ProjectileType.magicProjectile:
        return MagicalProjectile(
          projectileConfiguration,
        );
      case ProjectileType.slowFire:
        return MagicalProjectile(
          projectileConfiguration,
          showParticles: false,
        );
      case ProjectileType.paintBullet:
        return PaintBullet(
          projectileConfiguration,
        );

      case ProjectileType.holyBullet:
        return SpriteBullet(
          projectileConfiguration,
          customSpawnAnimation: spriteAnimations.holyBulletSpawn1,
          customPlayAnimation: spriteAnimations.holyBulletPlay1,
        );
    }
  }
}

enum WeaponSpritePosition { hand, mouse, back }

// enum WeaponState { shooting, reloading, idle }

enum WeaponType {
  ///Guns
  crystalPistol(5, AttackType.guns, 0),
  arcaneBlaster(
    5,
    AttackType.guns,
    0,
  ),

  scatterBlast(
    5,
    AttackType.guns,
    500,
  ),

  shimmerRifle(
    5,
    AttackType.guns,
    500,
  ),
  emberBow(
    5,
    AttackType.guns,
    500,
  ),

  scryshot(5, AttackType.guns, 0),

  prismaticBeam(
    5,
    AttackType.guns,
    0,
    isPlayerWeapon: false,
  ),
  railspire(5, AttackType.guns, 0),
  eldritchRunner(
    5,
    AttackType.guns,
    0,
  ),

  ///Swords
  crystalSword(
    5,
    AttackType.melee,
    100,
  ),
  tuiCamai(
    5,
    AttackType.melee,
    100,
  ),
  swordKladenets(
    5,
    AttackType.melee,
    isPlayerWeapon: false,
    100,
  ),
  mindStaff(
    5,
    AttackType.melee,
    100,
  ),
  phaseDagger(5, AttackType.melee, 0),
  aethertideSpear(5, AttackType.melee, 0),
  largeSword(5, AttackType.melee, 600),
  frostKatana(
    5,
    AttackType.melee,
    500,
  ),
  sanctifiedEdge(5, AttackType.melee, 500),
  fireSword(5, AttackType.melee, 500),

  swordOfJustice(
    5,
    AttackType.melee,
    1250,
  ),

  ///Magic
  magicMissile(5, AttackType.magic, 0),
  icecicleMagic(5, AttackType.magic, 0),
  psychicMagic(5, AttackType.magic, 0),
  fireballMagic(5, AttackType.magic, 0),
  elementalChannel(5, AttackType.magic, 0),
  energyMagic(
    5,
    AttackType.magic,
    0,
    isPlayerWeapon: false,
  ),
  magicBlast(5, AttackType.magic, 0),
  powerWord(5, AttackType.magic, 1500),
  hexwoodMaim(5, AttackType.magic, 0),
  breathOfFire(
    5,
    AttackType.magic,
    0,
  ),

  ///MISC
  ///

  blankGun(
    5,
    AttackType.guns,
    0,
    isPlayerWeapon: false,
  ),
  blankMelee(
    5,
    AttackType.melee,
    0,
    isPlayerWeapon: false,
  ),
  blankMagic(
    5,
    AttackType.magic,
    0,
    isPlayerWeapon: false,
  ),

  hiddenArcingWeapon(
    3,
    AttackType.guns,
    0,
    isPlayerWeapon: false,
  ),

  blankProjectileWeapon(
    5,
    AttackType.guns,
    0,
    isPlayerWeapon: false,
  ),
  mushroomBossWeapon1(
    5,
    AttackType.guns,
    0,
    isPlayerWeapon: false,
  ),
  ;

  const WeaponType(
    this.maxLevel,
    this.attackType,
    this.baseCost, {
    this.isPlayerWeapon = true,
  });
  final int maxLevel;
  final AttackType attackType;
  final int baseCost;
  final bool isPlayerWeapon;

  String get flamePath => getImageClass.flamePath;
  String get path => getImageClass.path;
  String get iconPath => getIconClass.path;
  FileDataClass get getIconClass {
    switch (this) {
      case WeaponType.emberBow:
        return ImagesAssetsEmberBow.emberBow;
      case WeaponType.shimmerRifle:
        return ImagesAssetsScryshot.icon;

      case WeaponType.crystalPistol:
        return ImagesAssetsCrystalPistol.icon;
      case WeaponType.scatterBlast:
        return ImagesAssetsScatterBlast.icon;

      case WeaponType.railspire:
        return ImagesAssetsRailspire.railspire;
      case WeaponType.eldritchRunner:
        return ImagesAssetsEldritchRunner.eldritchRunner;
      case WeaponType.crystalSword:
        return ImagesAssetsCrystalSword.icon;
      case WeaponType.phaseDagger:
        return ImagesAssetsPhaseDagger.icon;
      case WeaponType.aethertideSpear:
        return ImagesAssetsAethertideSpear.icon;
      case WeaponType.mindStaff:
        return ImagesAssetsMindStaff.icon;
      case WeaponType.largeSword:
        return ImagesAssetsLargeSword.largeSword;
      case WeaponType.frostKatana:
        return ImagesAssetsFrostKatana.icon;
      case WeaponType.sanctifiedEdge:
        return ImagesAssetsSanctifiedEdge.icon;
      case WeaponType.fireSword:
        return ImagesAssetsFlameSword.icon;
      case WeaponType.swordOfJustice:
        return ImagesAssetsSwordOfJustice.swordOfJustice;

      case WeaponType.tuiCamai:
        return ImagesAssetsTuiCamai.tuiCamai;
      case WeaponType.swordKladenets:
        return ImagesAssetsSwordKladenets.swordKladenets;
      case WeaponType.magicMissile:
        return ImagesAssetsDefaultWand.icon;
      case WeaponType.icecicleMagic:
        return ImagesAssetsDefaultWand.icon;
      // case WeaponType.psychicMagic:
      //   return ImagesAssetsPsychicMagic.bookIdle;
      // case WeaponType.fireballMagic:
      //   return ImagesAssetsFireballMagic.bookIdle;
      // case WeaponType.energyMagic:
      //   return ImagesAssetsEnergyMagic.bookIdle;
      // case WeaponType.breathOfFire:
      //   return ImagesAssetsBreathOfFire.bookIdle;
      // case WeaponType.magicBlast:
      //   return ImagesAssetsMagicBlast.bookIdle;
      case WeaponType.powerWord:
        return ImagesAssetsPowerWord.icon;
      // case WeaponType.elementalChannel:
      //   return ImagesAssetsElementalChannel.bookIdle;
      case WeaponType.hexwoodMaim:
        return ImagesAssetsDefaultWand.icon;
      // case WeaponType.blankProjectileWeapon:
      //   return ImagesAssetsBlankProjectileWeapon.bookIdle;

      case WeaponType.arcaneBlaster:
        return ImagesAssetsArcaneBlaster.icon;

      case WeaponType.scryshot:
        return ImagesAssetsScryshot.icon;
      case WeaponType.prismaticBeam:
        return ImagesAssetsPrismaticBeam.prismaticBeam;

      default:
        return ImagesAssetsDefaultBook.bookIdle;
    }
  }

  FileDataClass get getImageClass {
    switch (this) {
      case WeaponType.emberBow:
        return ImagesAssetsEmberBow.emberBow;
      case WeaponType.shimmerRifle:
        return ImagesAssetsScryshot.scryshot;

      case WeaponType.crystalPistol:
        return ImagesAssetsCrystalPistol.crystalPistol;
      case WeaponType.scatterBlast:
        return ImagesAssetsScatterBlast.scatterBlast;

      case WeaponType.railspire:
        return ImagesAssetsRailspire.railspire;
      case WeaponType.eldritchRunner:
        return ImagesAssetsEldritchRunner.eldritchRunner;
      case WeaponType.crystalSword:
        return ImagesAssetsCrystalSword.crystalSword;
      case WeaponType.phaseDagger:
        return ImagesAssetsPhaseDagger.phaseDagger;
      case WeaponType.aethertideSpear:
        return ImagesAssetsAethertideSpear.aethertideSpear;
      case WeaponType.mindStaff:
        return ImagesAssetsMindStaff.mindStaff;
      case WeaponType.largeSword:
        return ImagesAssetsLargeSword.largeSword;
      case WeaponType.frostKatana:
        return ImagesAssetsFrostKatana.frostKatana;
      case WeaponType.sanctifiedEdge:
        return ImagesAssetsSanctifiedEdge.sanctifiedEdge;
      case WeaponType.fireSword:
        return ImagesAssetsFlameSword.flameSword;
      case WeaponType.swordOfJustice:
        return ImagesAssetsSwordOfJustice.swordOfJustice;

      case WeaponType.tuiCamai:
        return ImagesAssetsTuiCamai.tuiCamai;
      case WeaponType.swordKladenets:
        return ImagesAssetsSwordKladenets.swordKladenets;
      case WeaponType.magicMissile:
        return ImagesAssetsDefaultWand.wandIdle;
      case WeaponType.icecicleMagic:
        return ImagesAssetsDefaultWand.wandIdle;
      case WeaponType.psychicMagic:
        return ImagesAssetsDefaultWand.wandIdle;
      // case WeaponType.fireballMagic:
      //   return ImagesAssetsFireballMagic.bookIdle;
      // case WeaponType.energyMagic:
      //   return ImagesAssetsEnergyMagic.bookIdle;
      // case WeaponType.breathOfFire:
      //   return ImagesAssetsBreathOfFire.bookIdle;
      // case WeaponType.magicBlast:
      //   return ImagesAssetsMagicBlast.bookIdle;
      case WeaponType.powerWord:
        return ImagesAssetsPowerWord.idle;
      // case WeaponType.elementalChannel:
      //   return ImagesAssetsElementalChannel.bookIdle;
      case WeaponType.hexwoodMaim:
        return ImagesAssetsDefaultWand.wandIdle;
      // case WeaponType.blankProjectileWeapon:
      //   return ImagesAssetsBlankProjectileWeapon.bookIdle;

      case WeaponType.arcaneBlaster:
        return ImagesAssetsArcaneBlaster.arcaneBlaster;

      case WeaponType.scryshot:
        return ImagesAssetsScryshot.scryshot;
      case WeaponType.prismaticBeam:
        return ImagesAssetsPrismaticBeam.prismaticBeam;

      default:
        return ImagesAssetsDefaultBook.bookIdle;
    }
  }
}

extension WeaponTypeFilename on WeaponType {
  Weapon build({
    AimFunctionality? ancestor,
    SecondaryType? secondaryWeaponType,
    PlayerData? playerData,
    int? customWeaponLevel,
  }) {
    Weapon? returnWeapon;
    final upgradeLevel =
        customWeaponLevel ?? playerData?.unlockedWeapons[this] ?? 0;

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

      case WeaponType.swordKladenets:
        returnWeapon = SwordKladenets(upgradeLevel, ancestor);
        break;
      case WeaponType.powerWord:
        returnWeapon = PowerWord(upgradeLevel, ancestor);
        break;
      case WeaponType.tuiCamai:
        returnWeapon = TuiCamai(upgradeLevel, ancestor);
        break;

      case WeaponType.arcaneBlaster:
        returnWeapon = ArcaneBlaster(upgradeLevel, ancestor);
        break;
      case WeaponType.mindStaff:
        returnWeapon = MindStaff(upgradeLevel, ancestor);
        break;
      case WeaponType.scryshot:
        returnWeapon = Scryshot(upgradeLevel, ancestor);
        break;
      case WeaponType.swordOfJustice:
        returnWeapon = SwordOfJustice(upgradeLevel, ancestor);
        break;
      case WeaponType.eldritchRunner:
        returnWeapon = EldritchRunner(upgradeLevel, ancestor);
        break;
      case WeaponType.prismaticBeam:
        returnWeapon = PrismaticBeam(upgradeLevel, ancestor);
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
      case WeaponType.hexwoodMaim:
        returnWeapon = HexwoodMaim(upgradeLevel, ancestor);
        break;
      case WeaponType.elementalChannel:
        returnWeapon = ElementalChannel(upgradeLevel, ancestor);
        break;
      case WeaponType.phaseDagger:
        returnWeapon = PhaseDagger(upgradeLevel, ancestor);

      case WeaponType.largeSword:
        returnWeapon = LargeSword(upgradeLevel, ancestor);
        break;
      case WeaponType.magicBlast:
        returnWeapon = MagicBlast(upgradeLevel, ancestor);
        break;
      case WeaponType.breathOfFire:
        returnWeapon = BreathOfFire(upgradeLevel, ancestor);
        break;
      case WeaponType.aethertideSpear:
        returnWeapon = AethertideSpear(upgradeLevel, ancestor);
        break;
      case WeaponType.sanctifiedEdge:
        returnWeapon = SanctifiedEdge(upgradeLevel, ancestor);
      case WeaponType.crystalSword:
        returnWeapon = CrystalSword(upgradeLevel, ancestor);

        break;
      case WeaponType.fireSword:
        returnWeapon = FlameSword(upgradeLevel, ancestor);

        break;
      case WeaponType.shimmerRifle:
        returnWeapon = ShimmerRifle(upgradeLevel, ancestor);
        break;

      case WeaponType.emberBow:
        returnWeapon = EmberBow(upgradeLevel, ancestor);
        break;

      //Misc

      case WeaponType.hiddenArcingWeapon:
        returnWeapon = HiddenArcingWeapon(upgradeLevel, ancestor);
        break;
      case WeaponType.blankProjectileWeapon:
        returnWeapon = BlankProjectileWeapon(upgradeLevel, ancestor);
        break;
      case WeaponType.mushroomBossWeapon1:
        returnWeapon = MushroomBossWeapon1(upgradeLevel, ancestor);
        break;
      default:
        returnWeapon = BlankProjectileWeapon(upgradeLevel, ancestor);
    }
    if (returnWeapon is SecondaryFunctionality && secondaryWeaponType != null) {
      final secondaryWeaponUpgrade =
          playerData?.unlockedSecondarys[secondaryWeaponType] ?? 0;
      returnWeapon.setSecondaryFunctionality =
          secondaryWeaponType.build(returnWeapon, secondaryWeaponUpgrade);
    }
    ancestor?.add(returnWeapon);
    return returnWeapon;
  }

  Weapon buildTemp(int upgradeLevel) {
    return build(
      customWeaponLevel: upgradeLevel,
    );
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
    this.canBeDodgedWithJump = false,
    this.damageKind = DamageKind.regular,
    Map<StatusEffects, double>? statusEffectChance,
  }) {
    if (statusEffectChance != null) {
      this.statusEffectChance.addAll(statusEffectChance);
    }
  }
  late final id = const Uuid().v4();
  String get sourceAttackId {
    if (sourceAttack is Projectile) {
      return (sourceAttack as Projectile).projectileId;
    } else if (sourceAttack is Weapon) {
      return (sourceAttack as Weapon).weaponId;
    } else if (sourceAttack is Entity) {
      return (sourceAttack as Entity).entityId;
    } else if (sourceAttack is AreaEffect) {
      return (sourceAttack as AreaEffect).areaId;
    } else {
      return id;
    }
  }

  final bool canBeDodgedWithJump;
  final DamageKind damageKind;
  final Map<DamageType, double> damageMap;
  bool isCrit;
  final Entity source;
  final dynamic sourceAttack;
  final HealthFunctionality victim;

  final Weapon? sourceWeapon;
  final Map<StatusEffects, double> statusEffectChance = {};

  AttackType get attackType =>
      sourceWeapon?.weaponType.attackType ?? AttackType.guns;

  double get damage => damageMap.entries
      .where((element) => element.key != DamageType.healing)
      .fold(0, (previousValue, element) => previousValue + element.value);

  ///Modifies [damageMap] based on entity resistances
  void applyResistances(Entity other) {
    for (final element in damageMap.entries) {
      final damageType = element.key;
      var damageInc = element.value;

      damageInc *=
          other.damageTypeResistance.damagePercentIncrease[element.key] ??= 1;

      damageMap[damageType] = damageInc;
    }
  }

  void checkCrit({bool force = false}) {
    final rngCrit = rng.nextDouble();
    var critDamageIncrease = 1.0;
    var forceModified = force;

    if (!forceModified && victim.consumeMark()) {
      forceModified = true;
    }
    if (rngCrit <=
            source.critChance.parameter +
                (sourceWeapon?.critChance.parameter ?? 0) ||
        forceModified) {
      isCrit = true;
      critDamageIncrease = max(
        source.critDamage.parameter,
        sourceWeapon?.critDamage.parameter ?? 1,
      );
    }
    increaseByPercent(critDamageIncrease);
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

  void increaseByPercent(double percent) {
    for (final element in damageMap.entries) {
      damageMap[element.key] = element.value * percent;
    }
  }
}

enum SecondaryType {
  essentialFocus(ImagesAssetsSecondaryIcons.blank, 0, alwaysCompatible, 0),
  rapidFire(
    ImagesAssetsSecondaryIcons.rapidFire,
    2,
    reloadFunctionality,
    500,
  ),
  instantReload(
    ImagesAssetsSecondaryIcons.rapidFire,
    2,
    reloadFunctionality,
    500,
  ),
  pistolAttachment(ImagesAssetsSecondaryIcons.blank, 5, alwaysCompatible, 500),
  elementalBlast(ImagesAssetsSecondaryIcons.blank, 3, alwaysCompatible, 500),
  surroundAttack(
    ImagesAssetsSecondaryIcons.blank,
    1,
    hasProjectileOrMeleeFunctionality,
    500,
  ),
  shadowBlink(
    ImagesAssetsSecondaryIcons.explodeProjectiles,
    3,
    weaponIsMelee,
    500,
  ),
  bloodlust(
    ImagesAssetsSecondaryIcons.explodeProjectiles,
    2,
    weaponIsMelee,
    500,
  ),
  explodeProjectiles(
    ImagesAssetsSecondaryIcons.explodeProjectiles,
    3,
    weaponShootsProjectiles,
    500,
  );

  const SecondaryType(
    this.icon,
    this.maxLevel,
    this.compatibilityCheck,
    this.baseCost, {
    // ignore: unused_element
    this.isPlayerOnly = true,
  });

  ///Based on a input weapon, return true or false to
  ///see if the weapon is compatible with the secondary ability
  final CompatibilityFunction compatibilityCheck;
  final FileDataClass icon;
  final int maxLevel;
  final bool isPlayerOnly;
  final int baseCost;
}

typedef CompatibilityFunction = bool Function(Weapon);

bool alwaysCompatible(Weapon weapon) => true;

bool hasProjectileOrMeleeFunctionality(Weapon weapon) =>
    weapon is ProjectileFunctionality || weapon is MeleeFunctionality;

bool weaponIsReloadFunctionality(Weapon weapon) {
  final test = weapon is ReloadFunctionality;
  return test;
}

bool weaponIsMelee(Weapon weapon) {
  final test = weapon.weaponType.attackType == AttackType.melee;
  return test;
}

bool reloadFunctionality(Weapon weapon) {
  if (weapon is! ReloadFunctionality) {
    return false;
  }

  // if (weapon is SemiAutomatic &&
  //     (weapon as SemiAutomatic).semiAutoType != SemiAutoType.regular) {
  //   return false;
  // }
  return true;
}

bool weaponShootsProjectiles(Weapon weapon) {
  final test = weapon is ProjectileFunctionality &&
      weapon.projectileType != ProjectileType.laser &&
      weapon.projectileType != ProjectileType.followLaser;
  return test;
}

bool weaponIsProjectileFunctionality(Weapon weapon) {
  final test = weapon is ProjectileFunctionality;
  return test;
}

extension SecondaryWeaponTypeExtension on SecondaryType {
  dynamic build(Weapon? primaryWeaponAncestor, [int upgradeLevel = 0]) {
    switch (this) {
      case SecondaryType.rapidFire:
        return RapidFire(primaryWeaponAncestor, 5, upgradeLevel);
      case SecondaryType.pistolAttachment:
        return BlankProjectileWeapon(
          upgradeLevel,
          primaryWeaponAncestor?.entityAncestor,
        );
      case SecondaryType.surroundAttack:
        return SurroundAttack(primaryWeaponAncestor, 5, upgradeLevel);
      case SecondaryType.elementalBlast:
        return ElementalBlast(primaryWeaponAncestor, 5, upgradeLevel);

      case SecondaryType.explodeProjectiles:
        return ExplodeProjectile(primaryWeaponAncestor, 5, upgradeLevel);
      case SecondaryType.shadowBlink:
        return ShadowBlink(primaryWeaponAncestor, 5, upgradeLevel);
      case SecondaryType.bloodlust:
        return Bloodlust(primaryWeaponAncestor, 5, upgradeLevel);
      case SecondaryType.essentialFocus:
        return EssentialFocusSecondary(primaryWeaponAncestor, 0, upgradeLevel);
      case SecondaryType.instantReload:
        return InstantReload(primaryWeaponAncestor, 10, upgradeLevel);
    }
  }
}
