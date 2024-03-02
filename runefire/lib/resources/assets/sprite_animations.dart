import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/sprite.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/visuals.dart';

Future<SpriteAnimation> loadSpriteAnimation(
  int numberOfSprites,
  String source,
  double stepTime,
  bool loop,
) async {
  final sprite = await Sprite.load(source);
  var newScale = sprite.srcSize;
  newScale = Vector2(newScale.x / numberOfSprites, newScale.y);
  return SpriteSheet(image: sprite.image, srcSize: newScale).createAnimation(
    row: 0,
    stepTime: stepTime,
    loop: loop,
    to: loop ? null : numberOfSprites,
  );
}

class SpriteAnimations {
//EntityEffects
  late Future<SpriteAnimation> dashEffect1 =
      loadSpriteAnimation(7, 'entity_effects/dash_effect.png', .1, false);
  late Future<SpriteAnimation> jumpEffect1 =
      loadSpriteAnimation(6, 'entity_effects/jump_effect.png', .1, false);

//Player

//Character One

  late Future<SpriteAnimation> playerCharacterOneIdle1 = loadSpriteAnimation(
    6,
    ImagesAssetsRuneknight.runeknightIdle1.flamePath,
    .15,
    true,
  );
  late Future<SpriteAnimation> playerCharacterOneJump1 = loadSpriteAnimation(
    3,
    ImagesAssetsRuneknight.runeknightJump1.flamePath,
    .2,
    false,
  );
  late Future<SpriteAnimation> playerCharacterOneDash1 = loadSpriteAnimation(
    6,
    ImagesAssetsRuneknight.runeknightDash1.flamePath,
    .075,
    false,
  );
  // late Future<SpriteAnimation> playerCharacterOneWalk1 =
  //     loadSpriteAnimation(8, 'sprites/walk.png', .1, true);
  late Future<SpriteAnimation> playerCharacterOneRun1 = loadSpriteAnimation(
    8,
    ImagesAssetsRuneknight.runeknightRun1.flamePath,
    .13,
    true,
  );
  late Future<SpriteAnimation> playerCharacterOneHit1 = loadSpriteAnimation(
    4,
    ImagesAssetsRuneknight.runeknightHit1.flamePath,
    .08,
    false,
  );
  late Future<SpriteAnimation> playerCharacterOneDead1 = loadSpriteAnimation(
    8,
    ImagesAssetsRuneknight.runeknightDeath1.flamePath,
    .2,
    false,
  );

//Enemies
//Mushroom Hopper
  late Future<SpriteAnimation> mushroomHopperIdle1 = loadSpriteAnimation(
    10,
    'enemy_sprites/mushroomHopper/idle.png',
    .1,
    true,
  );
  late Future<SpriteAnimation> mushroomHopperJump1 = loadSpriteAnimation(
    3,
    'enemy_sprites/mushroomHopper/jump.png',
    .1,
    false,
  );
  late Future<SpriteAnimation> mushroomHopperDead1 = loadSpriteAnimation(
    10,
    'enemy_sprites/mushroomHopper/death.png',
    .1,
    false,
  );

//Mushroom Runner

  late Future<SpriteAnimation> mushroomRunnerIdle1 = loadSpriteAnimation(
    2,
    'enemy_sprites/mushroomRunner/idle.png',
    .15,
    true,
  );

  late Future<SpriteAnimation> mushroomRunnerRun1 =
      loadSpriteAnimation(2, 'enemy_sprites/mushroomRunner/run.png', .15, true);
  late Future<SpriteAnimation> mushroomRunnerDead1 = loadSpriteAnimation(
    4,
    'enemy_sprites/mushroomRunner/dead.png',
    .15,
    false,
  );
//Mushroom Boomer

  late Future<SpriteAnimation> mushroomBoomerIdle1 = loadSpriteAnimation(
    2,
    'enemy_sprites/mushroomBoomer/idle.png',
    .15,
    true,
  );
  late Future<SpriteAnimation> mushroomBoomerRun1 =
      loadSpriteAnimation(4, 'enemy_sprites/mushroomBoomer/run.png', .1, true);
  late Future<SpriteAnimation> mushroomBoomerDead1 = loadSpriteAnimation(
    7,
    'enemy_sprites/mushroomBoomer/death.png',
    .15,
    false,
  );

  late Future<SpriteAnimation> mushroomBoomerIdle2 = loadSpriteAnimation(
    2,
    'enemy_sprites/mushroomBoomer/idle2.png',
    .1,
    true,
  );
  late Future<SpriteAnimation> mushroomBoomerRun2 =
      loadSpriteAnimation(4, 'enemy_sprites/mushroomBoomer/run2.png', .1, true);
  late Future<SpriteAnimation> mushroomBoomerDead2 = loadSpriteAnimation(
    7,
    'enemy_sprites/mushroomBoomer/death2.png',
    .15,
    false,
  );

//Mushroom Shooter

  late Future<SpriteAnimation> mushroomShooterIdle1 = loadSpriteAnimation(
    10,
    'enemy_sprites/mushroomShooter/idle.png',
    .1,
    true,
  );
  late Future<SpriteAnimation> mushroomShooterRun1 =
      loadSpriteAnimation(8, 'enemy_sprites/mushroomShooter/run.png', .1, true);
  late Future<SpriteAnimation> mushroomShooterDead1 = loadSpriteAnimation(
    10,
    'enemy_sprites/mushroomShooter/death.png',
    .1,
    false,
  );
  late Future<SpriteAnimation> mushroomShooterAttack1 = loadSpriteAnimation(
    3,
    'enemy_sprites/mushroomShooter/jump.png',
    .1,
    false,
  );

//Mushroom Spinner

  late Future<SpriteAnimation> mushroomSpinnerIdle1 = loadSpriteAnimation(
    2,
    'enemy_sprites/mushroomSpinner/idle.png',
    .15,
    true,
  );
  late Future<SpriteAnimation> mushroomSpinnerSpinStart1 = loadSpriteAnimation(
    9,
    'enemy_sprites/mushroomSpinner/spin_start.png',
    .05,
    false,
  );
  late Future<SpriteAnimation> mushroomSpinnerSpinEnd1 = loadSpriteAnimation(
    9,
    'enemy_sprites/mushroomSpinner/spin_end.png',
    .05,
    false,
  );
  late Future<SpriteAnimation> mushroomSpinnerSpin1 = loadSpriteAnimation(
    4,
    'enemy_sprites/mushroomSpinner/spin.png',
    .05,
    true,
  );
  late Future<SpriteAnimation> mushroomSpinnerDead1 = loadSpriteAnimation(
    5,
    'enemy_sprites/mushroomSpinner/death.png',
    .1,
    false,
  );
  late Future<SpriteAnimation> mushroomSpinnerRun1 = loadSpriteAnimation(
    2,
    'enemy_sprites/mushroomSpinner/run.png',
    .15,
    true,
  );

  late Future<SpriteAnimation> mushroomBurrowerIdle1 = loadSpriteAnimation(
    2,
    'enemy_sprites/mushroomBurrower/idle.png',
    .25,
    true,
  );
  // late Future<SpriteAnimation> mushroomBurrowerDead1 = loadSpriteAnimation(
  //   10,
  //   'enemy_sprites/mushroomBurrower/death.png',
  //   .1,
  //   false,
  // );
  late Future<SpriteAnimation> mushroomBurrowerJump1 = loadSpriteAnimation(
    4,
    'enemy_sprites/mushroomBurrower/jump.png',
    .1,
    false,
  );
  late Future<SpriteAnimation> mushroomBurrowerBurrowIn1 = loadSpriteAnimation(
    4,
    'enemy_sprites/mushroomBurrower/burrow_in.png',
    1,
    false,
  );
  late Future<SpriteAnimation> mushroomBurrowerBurrowOut1 = loadSpriteAnimation(
    4,
    'enemy_sprites/mushroomBurrower/burrow_out.png',
    1,
    false,
  );

//WeaponHitEffects
  late Future<SpriteAnimation> slashEffect1 = loadSpriteAnimation(
    4,
    'weapons/melee/small_slash_effect.png',
    .07,
    false,
  );
  late Future<SpriteAnimation> crustEffect1 = loadSpriteAnimation(
    4,
    'weapons/melee/small_crush_effect.png',
    .07,
    false,
  );
  late Future<SpriteAnimation> scratchEffect1 =
      loadSpriteAnimation(6, ImagesAssetsMelee.scratch1.flamePath, .07, false);

  late Future<SpriteAnimation> stabEffect1 =
      loadSpriteAnimation(4, 'weapons/melee/small_stab_effect.png', .07, false);

//ChildEntities
  late Future<SpriteAnimation> hoveringCrystalIdle1 = loadSpriteAnimation(
    6,
    'attribute_sprites/hovering_crystal_6.png',
    .3,
    true,
  );
  late Future<SpriteAnimation> hoveringCrystalAttack1 = loadSpriteAnimation(
    6,
    'attribute_sprites/hovering_crystal_attack_6.png',
    .05,
    false,
  );
  late Future<SpriteAnimation> elementalAbsorb1 = loadSpriteAnimation(
    6,
    'attribute_sprites/hovering_crystal_6.png',
    .05,
    false,
  );
//EnergyElemental
  late Future<SpriteAnimation> energyElementalIdle1 =
      loadSpriteAnimation(7, 'attribute_sprites/spark_child_1_7.png', .2, true);

  late Future<SpriteAnimation> energyElementalRun1 =
      loadSpriteAnimation(7, 'attribute_sprites/spark_child_1_7.png', .1, true);

//MagicEffects
  late Future<SpriteAnimation> fireExplosionMedium1 =
      loadSpriteAnimation(16, 'effects/explosion_1_16.png', .05, false);

  late Future<SpriteAnimation> energyStrikeMedium1 =
      loadSpriteAnimation(10, 'effects/energy_1_10.png', .05, false);

  late Future<SpriteAnimation> psychicStrikeMedium1 =
      loadSpriteAnimation(11, 'effects/psychic_1_11.png', .05, false);

//Status Effects

  late Future<SpriteAnimation> burnEffect1 = loadSpriteAnimation(
    4,
    ImagesAssetsStatusEffects.fireEffect.flamePath,
    defaultFrameDuration,
    true,
  );
  late Future<SpriteAnimation> markedEffect1 = loadSpriteAnimation(
    4,
    ImagesAssetsAttributeSprites.markEnemy4.flamePath,
    defaultFrameDuration,
    true,
  );

//Weapon Effects
  late Future<SpriteAnimation> holyBulletSpawn1 = loadSpriteAnimation(
    1,
    'weapons/projectiles/bullets/holy_bullet_spawn.png',
    .1,
    false,
  );
  late Future<SpriteAnimation> holyBulletPlay1 = loadSpriteAnimation(
    1,
    'weapons/projectiles/bullets/holy_bullet_play.png',
    1,
    true,
  );

  late Future<SpriteAnimation> magicMuzzleFlash1 = loadSpriteAnimation(
    5,
    'weapons/projectiles/magic_muzzle_flash.png',
    .07,
    false,
  );
  late Future<SpriteAnimation> fireMuzzleFlash1 = loadSpriteAnimation(
    5,
    'weapons/projectiles/fire_muzzle_flash.png',
    .03,
    false,
  );
  late Future<SpriteAnimation> blackMuzzleFlash1 = loadSpriteAnimation(
    5,
    'weapons/projectiles/black_muzzle_flash.png',
    .03,
    false,
  );

  late Future<SpriteAnimation> damageTypeFireEffect1 = loadSpriteAnimation(
    5,
    ImagesAssetsDamageEffects.fire.flamePath,
    .1,
    true,
  );
  late Future<SpriteAnimation> damageTypeEnergyEffect1 = loadSpriteAnimation(
    3,
    ImagesAssetsDamageEffects.energy.flamePath,
    .13,
    true,
  );
  late Future<SpriteAnimation> damageTypeFrostEffect1 = loadSpriteAnimation(
    2,
    ImagesAssetsDamageEffects.frost.flamePath,
    .05,
    true,
  );
  late Future<SpriteAnimation> damageTypePsychicEffect1 = loadSpriteAnimation(
    3,
    ImagesAssetsDamageEffects.psychic.flamePath,
    .1,
    true,
  );
  late Future<SpriteAnimation> damageTypePhysicalEffect1 = loadSpriteAnimation(
    4,
    ImagesAssetsDamageEffects.physical.flamePath,
    .05,
    true,
  );
  late Future<SpriteAnimation> damageTypeMagicEffect1 = loadSpriteAnimation(
    6,
    ImagesAssetsDamageEffects.magic.flamePath,
    .1,
    true,
  );
  // late Future<SpriteAnimation> damageTypHealingEffect1 = loadSpriteAnimation(
  //   2,
  //   ImagesAssetsDamageEffects..flamePath,
  //   .1,
  //   true,
  // );
  //DamageType effects

//Weapons
//Guns
  late Future<SpriteAnimation> arcaneBlasterIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsArcaneBlaster.arcaneBlaster.flamePath,
    .2,
    true,
  );

  late Future<SpriteAnimation> crystalPistolIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsCrystalPistol.crystalPistol.flamePath,
    1,
    true,
  );

  late Future<SpriteAnimation> scatterVineIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsScatterBlast.scatterBlast.flamePath,
    1,
    true,
  );

  late Future<SpriteAnimation> scryshotAttack1 = loadSpriteAnimation(
    6,
    ImagesAssetsScryshot.scryshotAttack.flamePath,
    .02,
    false,
  );
  late Future<SpriteAnimation> scryshotIdle1 = loadSpriteAnimation(
    19,
    ImagesAssetsScryshot.scryshotIdle.flamePath,
    .2,
    true,
  );
  late Future<SpriteAnimation> prismaticBeamIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsPrismaticBeam.prismaticBeam.flamePath,
    .2,
    true,
  );
  late Future<SpriteAnimation> eldritchRunnerIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsEldritchRunner.eldritchRunner.flamePath,
    .2,
    true,
  );
  late Future<SpriteAnimation> railspireIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsRailspire.railspire.flamePath,
    .2,
    true,
  );

  late Future<SpriteAnimation> emberBowIdle1 =
      loadSpriteAnimation(1, ImagesAssetsEmberBow.emberBow.flamePath, .2, true);

//Magic

  late Future<SpriteAnimation> hexwoodMaim1 = loadSpriteAnimation(
    17,
    ImagesAssetsHexwoodMaim.hexwoodMaim.flamePath,
    .1,
    false,
  );

  late Future<SpriteAnimation> satanicBookIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsDefaultBook.bookIdle.flamePath,
    .2,
    true,
  );
  late Future<SpriteAnimation> satanicBookAttack1 = loadSpriteAnimation(
    1,
    ImagesAssetsDefaultBook.bookFire.flamePath,
    2,
    false,
  );

  //Swords

  late Future<SpriteAnimation> phaseDaggerIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsPhaseDagger.phaseDagger.flamePath,
    1,
    true,
  );

  late Future<SpriteAnimation> crystalSwordIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsCrystalSword.crystalSword.flamePath,
    1,
    true,
  );
  late Future<SpriteAnimation> mindStaffIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsMindStaff.mindStaff.flamePath,
    1,
    true,
  );

  late Future<SpriteAnimation> aethertideSpearIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsAethertideSpear.aethertideSpear.flamePath,
    1,
    true,
  );
  late Future<SpriteAnimation> sanctifiedEdgeIdle1 = loadSpriteAnimation(
    3,
    ImagesAssetsSanctifiedEdge.sanctifiedEdgeIdle.flamePath,
    1,
    true,
  );

  late Future<SpriteAnimation> fireSwordIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsFlameSword.flameSword.flamePath,
    1,
    true,
  );

  late Future<SpriteAnimation> largeSwordIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsLargeSword.largeSword.flamePath,
    1,
    true,
  );

  late Future<SpriteAnimation> swordOfJusticeIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsSwordOfJustice.swordOfJustice.flamePath,
    1,
    true,
  );
  late Future<SpriteAnimation> frostKatanaIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsFrostKatana.frostKatana.flamePath,
    1,
    true,
  );

//Charge Effects

  late Future<SpriteAnimation> fireChargePlay1 =
      loadSpriteAnimation(3, 'weapons/charge/fire_charge_play.png', .1, true);
  late Future<SpriteAnimation> fireChargeEnd1 =
      loadSpriteAnimation(4, 'weapons/charge/fire_charge_end.png', .07, false);
  late Future<SpriteAnimation> fireChargeSpawn1 = loadSpriteAnimation(
    5,
    'weapons/charge/fire_charge_spawn.png',
    .01,
    false,
  );
  late Future<SpriteAnimation> fireChargeCharged1 = loadSpriteAnimation(
    6,
    'weapons/charge/fire_charge_charged.png',
    .05,
    false,
  );

//UI

  late Future<SpriteAnimation> uiHealthBar1 =
      loadSpriteAnimation(1, 'ui/health_bar.png', 1, true);
  late Future<SpriteAnimation> exitArrow1 = loadSpriteAnimation(
    8,
    ImagesAssetsEntityEffects.exitArrow.flamePath,
    .25,
    true,
  );
  late Future<SpriteAnimation> uiHeartBeatAnimation = loadSpriteAnimation(
    5,
    ImagesAssetsUi.heart.flamePath,
    1,
    true,
  );

  //ENV EFFECTS
  late Future<SpriteAnimation> ghostHandAttackRed1 = loadSpriteAnimation(
    20,
    ImagesAssetsEnemySprites.ghostHandAttackRed.flamePath,
    .1,
    false,
  );

  late Future<SpriteAnimation> exitPortalBlue1 = loadSpriteAnimation(
    4,
    ImagesAssetsEntityEffects.exitPortalBlue.flamePath,
    .2,
    true,
  );
}
