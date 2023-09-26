import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/sprite.dart';
import 'package:runefire/resources/visuals.dart';

Future<SpriteAnimation> loadSpriteAnimation(
    int numberOfSprites, String source, double stepTime, bool loop,
    [double? scaledToDimension]) async {
  final sprite = (await Sprite.load(source));
  Vector2 newScale = sprite.srcSize;
  if (scaledToDimension != null) {
    newScale.scaleTo(scaledToDimension);
  }
  newScale = Vector2(newScale.x / numberOfSprites, newScale.y);
  return SpriteSheet(image: sprite.image, srcSize: newScale).createAnimation(
      row: 0,
      stepTime: stepTime,
      loop: loop,
      to: loop ? null : numberOfSprites);
}

class SpriteAnimations {
//EntityEffects
  late Future<SpriteAnimation> dashEffect1 =
      loadSpriteAnimation(7, 'entity_effects/dash_effect.png', .1, false);
  late Future<SpriteAnimation> jumpEffect1 =
      loadSpriteAnimation(6, 'entity_effects/jump_effect.png', .1, false);

//Player

//Character One

  late Future<SpriteAnimation> playerCharacterOneIdle1 =
      loadSpriteAnimation(1, 'sprites/idle.png', .15, true);
  late Future<SpriteAnimation> playerCharacterOneJump1 =
      loadSpriteAnimation(6, 'sprites/jump.png', .1, false);
  late Future<SpriteAnimation> playerCharacterOneDash1 =
      loadSpriteAnimation(5, 'sprites/roll.png', .075, false);
  // late Future<SpriteAnimation> playerCharacterOneWalk1 =
  //     loadSpriteAnimation(8, 'sprites/walk.png', .1, true);
  late Future<SpriteAnimation> playerCharacterOneRun1 =
      loadSpriteAnimation(6, 'sprites/run.png', .13, true);
  late Future<SpriteAnimation> playerCharacterOneHit1 =
      loadSpriteAnimation(3, 'sprites/hit.png', .1, true);
  late Future<SpriteAnimation> playerCharacterOneDead1 =
      loadSpriteAnimation(6, 'sprites/death.png', .2, false);

//Enemies
//Mushroom Hopper
  late Future<SpriteAnimation> mushroomHopperIdle1 = loadSpriteAnimation(
      10, 'enemy_sprites/mushroomHopper/idle.png', .1, true);
  late Future<SpriteAnimation> mushroomHopperJump1 = loadSpriteAnimation(
      3, 'enemy_sprites/mushroomHopper/jump.png', .1, false);
  late Future<SpriteAnimation> mushroomHopperDead1 = loadSpriteAnimation(
      10, 'enemy_sprites/mushroomHopper/death.png', .1, false);

//Mushroom Runner

  late Future<SpriteAnimation> mushroomRunnerIdle1 = loadSpriteAnimation(
      2, 'enemy_sprites/mushroomRunner/idle.png', .15, true);

  late Future<SpriteAnimation> mushroomRunnerRun1 =
      loadSpriteAnimation(2, 'enemy_sprites/mushroomRunner/run.png', .15, true);
  late Future<SpriteAnimation> mushroomRunnerDead1 = loadSpriteAnimation(
      4, 'enemy_sprites/mushroomRunner/dead.png', .15, false);
//Mushroom Boomer

  late Future<SpriteAnimation> mushroomBoomerIdle1 = loadSpriteAnimation(
      10, 'enemy_sprites/mushroomBoomer/idle.png', .1, true);
  late Future<SpriteAnimation> mushroomBoomerWalk1 =
      loadSpriteAnimation(8, 'enemy_sprites/mushroomBoomer/walk.png', .1, true);
  late Future<SpriteAnimation> mushroomBoomerRun1 =
      loadSpriteAnimation(8, 'enemy_sprites/mushroomBoomer/run.png', .1, true);
  late Future<SpriteAnimation> mushroomBoomerDead1 = loadSpriteAnimation(
      10, 'enemy_sprites/mushroomBoomer/death.png', .1, false);

//Mushroom Shooter

  late Future<SpriteAnimation> mushroomShooterIdle1 = loadSpriteAnimation(
      10, 'enemy_sprites/mushroomShooter/idle.png', .1, true);
  late Future<SpriteAnimation> mushroomShooterRun1 =
      loadSpriteAnimation(8, 'enemy_sprites/mushroomShooter/run.png', .1, true);
  late Future<SpriteAnimation> mushroomShooterDead1 = loadSpriteAnimation(
      10, 'enemy_sprites/mushroomShooter/death.png', .1, false);
  late Future<SpriteAnimation> mushroomShooterAttack1 = loadSpriteAnimation(
      3, 'enemy_sprites/mushroomShooter/jump.png', .1, false);

//Mushroom Spinner

  late Future<SpriteAnimation> mushroomSpinnerIdle1 = loadSpriteAnimation(
      10, 'enemy_sprites/mushroomSpinner/idle.png', .1, true);
  late Future<SpriteAnimation> mushroomSpinnerSpinStart1 = loadSpriteAnimation(
      9, 'enemy_sprites/mushroomSpinner/spin_start.png', .1, false);
  late Future<SpriteAnimation> mushroomSpinnerSpinEnd1 = loadSpriteAnimation(
      9, 'enemy_sprites/mushroomSpinner/spin_end.png', .1, false);
  late Future<SpriteAnimation> mushroomSpinnerSpin1 = loadSpriteAnimation(
      7, 'enemy_sprites/mushroomSpinner/spin.png', .02, true);
  late Future<SpriteAnimation> mushroomSpinnerDead1 = loadSpriteAnimation(
      10, 'enemy_sprites/mushroomSpinner/death.png', .1, false);
  late Future<SpriteAnimation> mushroomSpinnerRun1 =
      loadSpriteAnimation(8, 'enemy_sprites/mushroomSpinner/run.png', .1, true);

  late Future<SpriteAnimation> mushroomBurrowerIdle1 = loadSpriteAnimation(
      10, 'enemy_sprites/mushroomSpinner/idle.png', .1, true);
  late Future<SpriteAnimation> mushroomBurrowerDead1 = loadSpriteAnimation(
      10, 'enemy_sprites/mushroomBurrower/death.png', .1, false);
  late Future<SpriteAnimation> mushroomBurrowerBurrowIn1 = loadSpriteAnimation(
      9, 'enemy_sprites/mushroomBurrower/burrow_in.png', 1, false);
  late Future<SpriteAnimation> mushroomBurrowerBurrowOut1 = loadSpriteAnimation(
      9, 'enemy_sprites/mushroomBurrower/burrow_out.png', 1, false);

//WeaponHitEffects
  late Future<SpriteAnimation> slashEffect1 = loadSpriteAnimation(
      4, 'weapons/melee/small_slash_effect.png', .05, false);
  late Future<SpriteAnimation> crustEffect1 = loadSpriteAnimation(
      4, 'weapons/melee/small_crush_effect.png', .05, false);

  late Future<SpriteAnimation> stabEffect1 =
      loadSpriteAnimation(4, 'weapons/melee/small_stab_effect.png', .05, false);

//ChildEntities
  late Future<SpriteAnimation> hoveringCrystalIdle1 = loadSpriteAnimation(
      6, 'attribute_sprites/hovering_crystal_6.png', .3, true);
  late Future<SpriteAnimation> hoveringCrystalAttack1 = loadSpriteAnimation(
      6, 'attribute_sprites/hovering_crystal_attack_6.png', .05, false);
  late Future<SpriteAnimation> elementalAbsorb1 = loadSpriteAnimation(
      6, 'attribute_sprites/hovering_crystal_6.png', .05, false);
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
      4, 'status_effects/fire_effect.png', defaultFrameDuration, true);
  late Future<SpriteAnimation> markedEffect1 = loadSpriteAnimation(
      4, 'attribute_sprites/mark_enemy_4.png', defaultFrameDuration, true);

//Weapon Effects
  late Future<SpriteAnimation> holyBulletSpawn1 = loadSpriteAnimation(
      1, 'weapons/projectiles/bullets/holy_bullet_spawn.png', .1, false);
  late Future<SpriteAnimation> holyBulletPlay1 = loadSpriteAnimation(
      1, 'weapons/projectiles/bullets/holy_bullet_play.png', 1, true);

  late Future<SpriteAnimation> magicMuzzleFlash1 = loadSpriteAnimation(
      5, 'weapons/projectiles/magic_muzzle_flash.png', .07, false);
  late Future<SpriteAnimation> fireMuzzleFlash1 = loadSpriteAnimation(
      5, 'weapons/projectiles/fire_muzzle_flash.png', .03, false);
  late Future<SpriteAnimation> blackMuzzleFlash1 = loadSpriteAnimation(
      5, 'weapons/projectiles/black_muzzle_flash.png', .03, false);

//Weapons
//Guns
  late Future<SpriteAnimation> arcaneBlasterIdle1 =
      loadSpriteAnimation(1, 'weapons/arcane_blaster.png', .2, true);

  late Future<SpriteAnimation> crystalPistolIdle1 =
      loadSpriteAnimation(1, 'weapons/pistol.png', 1, true);

  late Future<SpriteAnimation> scatterVineIdle1 =
      loadSpriteAnimation(1, 'weapons/scatter_vine.png', 1, true);

  late Future<SpriteAnimation> scryshotAttack1 =
      loadSpriteAnimation(6, 'weapons/long_rifle_attack.png', .02, false);
  late Future<SpriteAnimation> scryshotIdle1 =
      loadSpriteAnimation(19, 'weapons/long_rifle_idle.png', .2, true);
  late Future<SpriteAnimation> prismaticBeamIdle1 =
      loadSpriteAnimation(1, 'weapons/prismatic_beam.png', .2, true);
  late Future<SpriteAnimation> eldritchRunnerIdle1 =
      loadSpriteAnimation(1, 'weapons/eldritch_runner.png', .2, true);
  late Future<SpriteAnimation> railspireIdle1 =
      loadSpriteAnimation(1, 'weapons/railspire.png', .2, true);

//Magic

  late Future<SpriteAnimation> satanicBookIdle1 =
      loadSpriteAnimation(1, 'weapons/book_idle.png', .2, true);
  late Future<SpriteAnimation> satanicBookAttack1 =
      loadSpriteAnimation(1, 'weapons/book_fire.png', 2, false);

  //Swords

  late Future<SpriteAnimation> phaseDaggerIdle1 =
      loadSpriteAnimation(1, 'weapons/dagger.png', 1, true);

  late Future<SpriteAnimation> crystalSwordIdle1 =
      loadSpriteAnimation(1, 'weapons/crystal_sword.png', 1, true);

  late Future<SpriteAnimation> aethertideSpearIdle1 =
      loadSpriteAnimation(1, 'weapons/spear.png', 1, true);
  late Future<SpriteAnimation> holySwordIdle1 =
      loadSpriteAnimation(1, 'weapons/energy_sword.png', 1, true);

  late Future<SpriteAnimation> fireSwordIdle1 =
      loadSpriteAnimation(1, 'weapons/fire_sword.png', 1, true);

  late Future<SpriteAnimation> largeSwordIdle1 =
      loadSpriteAnimation(1, 'weapons/large_sword.png', 1, true);

  late Future<SpriteAnimation> swordOfJusticeIdle1 =
      loadSpriteAnimation(1, 'weapons/sword_of_justice.png', 1, true);
  late Future<SpriteAnimation> frostKatanaIdle1 =
      loadSpriteAnimation(1, 'weapons/frost_katana.png', 1, true);

//Charge Effects

  late Future<SpriteAnimation> fireChargePlay1 =
      loadSpriteAnimation(3, 'weapons/charge/fire_charge_play.png', .1, true);
  late Future<SpriteAnimation> fireChargeEnd1 =
      loadSpriteAnimation(4, 'weapons/charge/fire_charge_end.png', .07, false);
  late Future<SpriteAnimation> fireChargeSpawn1 = loadSpriteAnimation(
      5, 'weapons/charge/fire_charge_spawn.png', .01, false);
  late Future<SpriteAnimation> fireChargeCharged1 = loadSpriteAnimation(
      6, 'weapons/charge/fire_charge_charged.png', .05, false);

//UI

  late Future<SpriteAnimation> uiHealthBar1 =
      loadSpriteAnimation(1, 'ui/health_bar.png', 1, true);
}
