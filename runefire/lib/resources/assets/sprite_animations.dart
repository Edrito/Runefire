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
  late Future<SpriteAnimation> aethertideSpearIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsAethertideSpear.aethertideSpear.flamePath,
    1,
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

  late Future<SpriteAnimation> blackMuzzleFlash1 = loadSpriteAnimation(
    5,
    'weapons/projectiles/black_muzzle_flash.png',
    .03,
    false,
  );

  late Future<SpriteAnimation> burnEffect1 = loadSpriteAnimation(
    8,
    ImagesAssetsStatusEffects.burningLoop1.flamePath,
    defaultFrameDuration,
    true,
  );

  late Future<SpriteAnimation> burnEffectEnd1 = loadSpriteAnimation(
    4,
    ImagesAssetsStatusEffects.burningEnd1.flamePath,
    defaultFrameDuration,
    false,
  );

  late Future<SpriteAnimation> burnEffectStart1 = loadSpriteAnimation(
    4,
    ImagesAssetsStatusEffects.burningStart1.flamePath,
    defaultFrameDuration,
    false,
  );

  late Future<SpriteAnimation> crustEffect1 = loadSpriteAnimation(
    4,
    'weapons/melee/small_crush_effect.png',
    .07,
    false,
  );

  late Future<SpriteAnimation> crystalPistolIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsCrystalPistol.crystalPistol.flamePath,
    1,
    true,
  );

  late Future<SpriteAnimation> crystalSwordIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsCrystalSword.crystalSword.flamePath,
    1,
    true,
  );

  late Future<SpriteAnimation> damageTypeEnergyEffect1 = loadSpriteAnimation(
    3,
    ImagesAssetsDamageEffects.energy.flamePath,
    .13,
    true,
  );

  late Future<SpriteAnimation> damageTypeFireEffect1 = loadSpriteAnimation(
    5,
    ImagesAssetsDamageEffects.fire.flamePath,
    .1,
    true,
  );

  late Future<SpriteAnimation> damageTypeFrostEffect1 = loadSpriteAnimation(
    2,
    ImagesAssetsDamageEffects.frost.flamePath,
    .25,
    true,
  );

  late Future<SpriteAnimation> damageTypeMagicEffect1 = loadSpriteAnimation(
    6,
    ImagesAssetsDamageEffects.magic.flamePath,
    .251,
    true,
  );

  late Future<SpriteAnimation> damageTypePhysicalEffect1 = loadSpriteAnimation(
    4,
    ImagesAssetsDamageEffects.physical.flamePath,
    .05,
    true,
  );

  late Future<SpriteAnimation> damageTypePsychicEffect1 = loadSpriteAnimation(
    3,
    ImagesAssetsDamageEffects.psychic.flamePath,
    .1,
    true,
  );

//EntityEffects
  late Future<SpriteAnimation> dashEffect1 =
      loadSpriteAnimation(7, 'entity_effects/dash_effect.png', .1, false);

  late Future<SpriteAnimation> defaultWandAttack1 = loadSpriteAnimation(
    1,
    ImagesAssetsDefaultWand.wandIdle.flamePath,
    2,
    false,
  );

  late Future<SpriteAnimation> defaultWandIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsDefaultWand.wandIdle.flamePath,
    .2,
    true,
  );

  late Future<SpriteAnimation> eldritchRunnerIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsEldritchRunner.eldritchRunner.flamePath,
    .2,
    true,
  );

  late Future<SpriteAnimation> elementalAbsorb1 = loadSpriteAnimation(
    6,
    'attribute_sprites/hovering_crystal_6.png',
    .05,
    false,
  );

  late Future<SpriteAnimation> emberBowIdle1 =
      loadSpriteAnimation(1, ImagesAssetsEmberBow.emberBow.flamePath, .2, true);

//EnergyElemental
  late Future<SpriteAnimation> energyElementalIdle1 =
      loadSpriteAnimation(7, 'attribute_sprites/spark_child_1_7.png', .2, true);

  late Future<SpriteAnimation> energyElementalRun1 =
      loadSpriteAnimation(7, 'attribute_sprites/spark_child_1_7.png', .1, true);

  late Future<SpriteAnimation> energyStrikeMedium1 =
      loadSpriteAnimation(10, 'effects/energy_1_10.png', .05, false);

  late Future<SpriteAnimation> exitArrow1 = loadSpriteAnimation(
    8,
    ImagesAssetsEntityEffects.exitArrow.flamePath,
    .25,
    true,
  );

  late Future<SpriteAnimation> exitPortalBlue1 = loadSpriteAnimation(
    4,
    ImagesAssetsEntityEffects.exitPortalBlue.flamePath,
    .2,
    true,
  );

//Charge Effects

  // late Future<SpriteAnimation> fireChargeCharged1 = loadSpriteAnimation(
  //   6,
  //   'weapons/charge/fire_charge_charged.png',
  //   .05,
  //   false,
  // );

  // late Future<SpriteAnimation> fireChargeEnd1 =
  //     loadSpriteAnimation(4, 'weapons/charge/fire_charge_end.png', .07, false);

  // late Future<SpriteAnimation> fireChargePlay1 =
  //     loadSpriteAnimation(3, 'weapons/charge/fire_charge_play.png', .1, true);

  // late Future<SpriteAnimation> fireChargeSpawn1 = loadSpriteAnimation(
  //   5,
  //   'weapons/charge/fire_charge_spawn.png',
  //   .01,
  //   false,
  // );

  late Future<SpriteAnimation> mushroomSpore1 = loadSpriteAnimation(
    2,
    ImagesAssetsBackground.mushroomSpore.flamePath,
    .5,
    true,
  );

//MagicEffects
  late Future<SpriteAnimation> defaultBlueAreaEffect1 = loadSpriteAnimation(
    11,
    ImagesAssetsEffects.defaultAreaEffect11.flamePath,
    .3,
    true,
  );
  late Future<SpriteAnimation> defaultRedAreaEffect1 = loadSpriteAnimation(
    11,
    ImagesAssetsEffects.redDefaultAreaEffect11.flamePath,
    .3,
    true,
  );
  late Future<SpriteAnimation> defaultBrownAreaEffect1 = loadSpriteAnimation(
    11,
    ImagesAssetsEffects.brownDefaultAreaEffect11.flamePath,
    .3,
    true,
  );
  late Future<SpriteAnimation> defaultGreenAreaEffect1 = loadSpriteAnimation(
    11,
    ImagesAssetsEffects.greenDefaultAreaEffect11.flamePath,
    .3,
    true,
  );
  late Future<SpriteAnimation> fireExplosionMedium1 =
      loadSpriteAnimation(16, 'effects/explosion_1_16.png', .05, false);

  late Future<SpriteAnimation> fireMuzzleFlash1 = loadSpriteAnimation(
    5,
    'weapons/projectiles/fire_muzzle_flash.png',
    .03,
    false,
  );

  late Future<SpriteAnimation> fireOrbMedium1 = loadSpriteAnimation(
    18,
    ImagesAssetsEffects.fireOrb118.flamePath,
    .05,
    false,
  );
  late Future<SpriteAnimation> healingOrbMedium1 = loadSpriteAnimation(
    18,
    ImagesAssetsEffects.healingOrb118.flamePath,
    .05,
    false,
  );
  late Future<SpriteAnimation> magicOrbMedium1 = loadSpriteAnimation(
    18,
    ImagesAssetsEffects.magicOrb118.flamePath,
    .05,
    false,
  );

  late Future<SpriteAnimation> energyOrbMedium1 = loadSpriteAnimation(
    18,
    ImagesAssetsEffects.energyOrb118.flamePath,
    .05,
    false,
  );
  late Future<SpriteAnimation> frostOrbMedium1 = loadSpriteAnimation(
    18,
    ImagesAssetsEffects.frostOrb118.flamePath,
    .05,
    false,
  );

  late Future<SpriteAnimation> physicalOrbMedium1 = loadSpriteAnimation(
    18,
    ImagesAssetsEffects.physicalOrb118.flamePath,
    .05,
    false,
  );
  late Future<SpriteAnimation> fireSwordIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsFlameSword.flameSword.flamePath,
    1,
    true,
  );

  late Future<SpriteAnimation> frostKatanaIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsFrostKatana.frostKatana.flamePath,
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

//Magic

  late Future<SpriteAnimation> hexwoodMaim1 = loadSpriteAnimation(
    17,
    ImagesAssetsHexwoodMaim.hexwoodMaim.flamePath,
    .1,
    false,
  );

  late Future<SpriteAnimation> holyBulletPlay1 = loadSpriteAnimation(
    1,
    'weapons/projectiles/bullets/holy_bullet_play.png',
    1,
    true,
  );

//Weapon Effects
  late Future<SpriteAnimation> holyBulletSpawn1 = loadSpriteAnimation(
    1,
    'weapons/projectiles/bullets/holy_bullet_spawn.png',
    .1,
    false,
  );

  late Future<SpriteAnimation> hoveringCrystalAttack1 = loadSpriteAnimation(
    6,
    'attribute_sprites/hovering_crystal_attack_6.png',
    .05,
    false,
  );

//ChildEntities
  late Future<SpriteAnimation> hoveringCrystalIdle1 = loadSpriteAnimation(
    6,
    'attribute_sprites/hovering_crystal_6.png',
    .3,
    true,
  );

  late Future<SpriteAnimation> jumpEffect1 =
      loadSpriteAnimation(6, 'entity_effects/jump_effect.png', .1, false);

  late Future<SpriteAnimation> largeSwordIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsLargeSword.largeSword.flamePath,
    1,
    true,
  );

  late Future<SpriteAnimation> magicMuzzleFlash1 = loadSpriteAnimation(
    5,
    'weapons/projectiles/magic_muzzle_flash.png',
    .07,
    false,
  );

//Status Effects

  late Future<SpriteAnimation> markedEffect1 = loadSpriteAnimation(
    2,
    ImagesAssetsStatusEffects.marked.flamePath,
    defaultFrameDuration,
    true,
  );

  late Future<SpriteAnimation> mindStaffIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsMindStaff.mindStaff.flamePath,
    1,
    true,
  );

  late Future<SpriteAnimation> mushroomBoomerDead1 = loadSpriteAnimation(
    7,
    'enemy_sprites/mushroomBoomer/death.png',
    .15,
    false,
  );

  late Future<SpriteAnimation> mushroomBoomerDead2 = loadSpriteAnimation(
    7,
    'enemy_sprites/mushroomBoomer/death2.png',
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

  late Future<SpriteAnimation> mushroomBoomerIdle2 = loadSpriteAnimation(
    2,
    'enemy_sprites/mushroomBoomer/idle2.png',
    .1,
    true,
  );

  late Future<SpriteAnimation> mushroomBoomerRun1 =
      loadSpriteAnimation(4, 'enemy_sprites/mushroomBoomer/run.png', .1, true);

  late Future<SpriteAnimation> mushroomBoomerRun2 =
      loadSpriteAnimation(4, 'enemy_sprites/mushroomBoomer/run2.png', .1, true);

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

  late Future<SpriteAnimation> mushroomBurrowerIdle1 = loadSpriteAnimation(
    2,
    'enemy_sprites/mushroomBurrower/idle.png',
    .25,
    true,
  );

  late Future<SpriteAnimation> mushroomBurrowerJump1 = loadSpriteAnimation(
    4,
    'enemy_sprites/mushroomBurrower/jump.png',
    .1,
    false,
  );

  late Future<SpriteAnimation> mushroomHopperDead1 = loadSpriteAnimation(
    10,
    'enemy_sprites/mushroomHopper/death.png',
    .1,
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
  late Future<SpriteAnimation> mushroomRunnerDead1 = loadSpriteAnimation(
    4,
    'enemy_sprites/mushroomRunner/dead.png',
    .15,
    false,
  );

//Mushroom Runner scared

  late Future<SpriteAnimation> mushroomRunnerScaredIdle1 = loadSpriteAnimation(
    2,
    'enemy_sprites/mushroomRunnerScared/idle.png',
    .15,
    true,
  );

  late Future<SpriteAnimation> mushroomRunnerScaredRun1 = loadSpriteAnimation(
    2,
    'enemy_sprites/mushroomRunnerScared/run.png',
    .15,
    true,
  );

  late Future<SpriteAnimation> mushroomRunnerScaredDead1 = loadSpriteAnimation(
    4,
    'enemy_sprites/mushroomRunnerScared/dead.png',
    .15,
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

//Mushroom Shooter

  late Future<SpriteAnimation> mushroomShooterIdle1 = loadSpriteAnimation(
    2,
    'enemy_sprites/mushroomShooter/idle.png',
    .1,
    true,
  );

  late Future<SpriteAnimation> mushroomShooterRun1 =
      loadSpriteAnimation(2, 'enemy_sprites/mushroomShooter/run.png', .1, true);

  late Future<SpriteAnimation> mushroomShooterAttack1 = loadSpriteAnimation(
    5,
    'enemy_sprites/mushroomShooter/attack.png',
    .15,
    false,
  );

  late Future<SpriteAnimation> mushroomShooterDead1 = loadSpriteAnimation(
    4,
    'enemy_sprites/mushroomShooter/death.png',
    .15,
    false,
  );

//Mushroom Spinner

  late Future<SpriteAnimation> mushroomSpinnerDead1 = loadSpriteAnimation(
    5,
    'enemy_sprites/mushroomSpinner/death.png',
    .1,
    false,
  );

  late Future<SpriteAnimation> mushroomSpinnerIdle1 = loadSpriteAnimation(
    2,
    'enemy_sprites/mushroomSpinner/idle.png',
    .15,
    true,
  );

  late Future<SpriteAnimation> mushroomSpinnerRun1 = loadSpriteAnimation(
    2,
    'enemy_sprites/mushroomSpinner/run.png',
    .15,
    true,
  );

  late Future<SpriteAnimation> mushroomSpinnerSpin1 = loadSpriteAnimation(
    4,
    'enemy_sprites/mushroomSpinner/spin.png',
    .05,
    true,
  );

  late Future<SpriteAnimation> mushroomSpinnerSpinEnd1 = loadSpriteAnimation(
    9,
    'enemy_sprites/mushroomSpinner/spin_end.png',
    .05,
    false,
  );

  late Future<SpriteAnimation> mushroomSpinnerSpinStart1 = loadSpriteAnimation(
    9,
    'enemy_sprites/mushroomSpinner/spin_start.png',
    .05,
    false,
  );

  //Swords

  late Future<SpriteAnimation> phaseDaggerIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsPhaseDagger.phaseDagger.flamePath,
    1,
    true,
  );

  late Future<SpriteAnimation> pheonixRebirth1 = loadSpriteAnimation(
    5,
    ImagesAssetsEffects.pheonixRevive15.flamePath,
    .2,
    false,
  );

  late Future<SpriteAnimation> playerCharacterOneDash1 = loadSpriteAnimation(
    6,
    ImagesAssetsRuneknight.runeknightDash1.flamePath,
    .075,
    false,
  );

  late Future<SpriteAnimation> playerCharacterOneDead1 = loadSpriteAnimation(
    8,
    ImagesAssetsRuneknight.runeknightDeath1.flamePath,
    .2,
    false,
  );

  late Future<SpriteAnimation> playerCharacterOneHit1 = loadSpriteAnimation(
    4,
    ImagesAssetsRuneknight.runeknightHit1.flamePath,
    .08,
    false,
  );

//Mushroom Spinner

  late Future<SpriteAnimation> mushroomBossDead1 = loadSpriteAnimation(
    ImagesAssetsMushroomBoss.die.potentialFrameCount!,
    ImagesAssetsMushroomBoss.die.flamePath,
    .2,
    false,
  );

  late Future<SpriteAnimation> mushroomBossSpawn1 = loadSpriteAnimation(
    ImagesAssetsMushroomBoss.spawn.potentialFrameCount!,
    ImagesAssetsMushroomBoss.spawn.flamePath,
    .1,
    false,
  );

  late Future<SpriteAnimation> mushroomBossIdle1 = loadSpriteAnimation(
    ImagesAssetsMushroomBoss.idle.potentialFrameCount!,
    ImagesAssetsMushroomBoss.idle.flamePath,
    .1,
    true,
  );

  late Future<SpriteAnimation> mushroomBossSpin1 = loadSpriteAnimation(
    ImagesAssetsMushroomBoss.spin.potentialFrameCount!,
    ImagesAssetsMushroomBoss.spin.flamePath,
    .2,
    true,
  );

  late Future<SpriteAnimation> mushroomBossEyeCloseIdle1 = loadSpriteAnimation(
    ImagesAssetsMushroomBoss.eyeCloseIdle.potentialFrameCount!,
    ImagesAssetsMushroomBoss.eyeCloseIdle.flamePath,
    .2,
    true,
  );
  late Future<SpriteAnimation> mushroomBossSpinStart1 = loadSpriteAnimation(
    ImagesAssetsMushroomBoss.spinStart.potentialFrameCount!,
    ImagesAssetsMushroomBoss.spinStart.flamePath,
    .1,
    false,
  );

  late Future<SpriteAnimation> mushroomBossSpinEnd1 = loadSpriteAnimation(
    ImagesAssetsMushroomBoss.spinEnd.potentialFrameCount!,
    ImagesAssetsMushroomBoss.spinEnd.flamePath,
    .1,
    false,
  );

  late Future<SpriteAnimation> mushroomBossEyeClose1 = loadSpriteAnimation(
    ImagesAssetsMushroomBoss.eyeClose.potentialFrameCount!,
    ImagesAssetsMushroomBoss.eyeClose.flamePath,
    .1,
    false,
  );
  late Future<SpriteAnimation> mushroomBossEyeOpen1 = loadSpriteAnimation(
    ImagesAssetsMushroomBoss.eyeOpen.potentialFrameCount!,
    ImagesAssetsMushroomBoss.eyeOpen.flamePath,
    .1,
    false,
  );

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

  // late Future<SpriteAnimation> playerCharacterOneWalk1 =
  //     loadSpriteAnimation(8, 'sprites/walk.png', .1, true);
  late Future<SpriteAnimation> playerCharacterOneRun1 = loadSpriteAnimation(
    8,
    ImagesAssetsRuneknight.runeknightRun1.flamePath,
    .13,
    true,
  );

  late Future<SpriteAnimation> prismaticBeamIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsPrismaticBeam.prismaticBeam.flamePath,
    .2,
    true,
  );

  late Future<SpriteAnimation> psychicOrbMedium1 = loadSpriteAnimation(
    18,
    ImagesAssetsEffects.psychicOrb118.flamePath,
    .05,
    false,
  );

  late Future<SpriteAnimation> railspireIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsRailspire.railspire.flamePath,
    .2,
    true,
  );

  late Future<SpriteAnimation> sanctifiedEdgeIdle1 = loadSpriteAnimation(
    3,
    ImagesAssetsSanctifiedEdge.sanctifiedEdgeIdle.flamePath,
    1,
    true,
  );

  late Future<SpriteAnimation> powerWordIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsPowerWord.idle.flamePath,
    .2,
    true,
  );

  late Future<SpriteAnimation> satanicBookAttack1 = loadSpriteAnimation(
    1,
    ImagesAssetsDefaultBook.bookFire.flamePath,
    2,
    false,
  );

  late Future<SpriteAnimation> satanicBookIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsDefaultBook.bookIdle.flamePath,
    .2,
    true,
  );

  late Future<SpriteAnimation> scatterVineIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsScatterBlast.scatterBlast.flamePath,
    1,
    true,
  );

  late Future<SpriteAnimation> scratchEffect1 =
      loadSpriteAnimation(6, ImagesAssetsMelee.scratch1.flamePath, .07, false);

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

//WeaponHitEffects
  late Future<SpriteAnimation> slashEffect1 = loadSpriteAnimation(
    4,
    'weapons/melee/small_slash_effect.png',
    .07,
    false,
  );

  late Future<SpriteAnimation> stabEffect1 =
      loadSpriteAnimation(4, 'weapons/melee/small_stab_effect.png', .07, false);

  late Future<SpriteAnimation> statusEffectBleedEffect1 = loadSpriteAnimation(
    2,
    ImagesAssetsStatusEffects.bleed.flamePath,
    .5,
    true,
  );

  late Future<SpriteAnimation> statusEffectElectrified1 = loadSpriteAnimation(
    3,
    ImagesAssetsStatusEffects.electrified.flamePath,
    defaultFrameDuration,
    true,
  );

  late Future<SpriteAnimation> statusEffectFearEffect1 = loadSpriteAnimation(
    2,
    ImagesAssetsStatusEffects.fear.flamePath,
    .5,
    true,
  );

  late Future<SpriteAnimation> statusEffectStunEffect1 = loadSpriteAnimation(
    4,
    ImagesAssetsStatusEffects.stun.flamePath,
    .1,
    true,
  );

  late Future<SpriteAnimation> statusEffectsEmpowered1 = loadSpriteAnimation(
    2,
    ImagesAssetsStatusEffects.empowered.flamePath,
    defaultFrameDuration,
    true,
  );

  late Future<SpriteAnimation> statusEffectsSlow1 = loadSpriteAnimation(
    8,
    ImagesAssetsStatusEffects.slow.flamePath,
    defaultFrameDuration,
    true,
  );

  late Future<SpriteAnimation> swordOfJusticeIdle1 = loadSpriteAnimation(
    1,
    ImagesAssetsSwordOfJustice.swordOfJustice.flamePath,
    1,
    true,
  );

//UI

  late Future<SpriteAnimation> uiHealthBar1 =
      loadSpriteAnimation(1, 'ui/health_bar.png', 1, true);

  late Future<SpriteAnimation> uiHeartBeatAnimation = loadSpriteAnimation(
    5,
    ImagesAssetsUi.heart.flamePath,
    1,
    true,
  );
}
