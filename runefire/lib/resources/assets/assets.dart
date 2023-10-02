// ignore_for_file: library_private_types_in_public_api, unused_field
extension StringExtension on String {
  String get flamePath => split('/').skip(2).join('/');
}

class AudioAssetsPowerWord {
  ///fall.wav
  static const String fall = "assets/audio/sfx/magic/power_word/fall.wav";
  static const List<String> allFiles = [
    fall,
  ];
  static List<String> allFilesFlame = [
    fall.flamePath,
  ];
}

class AudioAssetsProjectile {
  ///laser_sound_1.mp3
  static const String laserSound1 =
      "assets/audio/sfx/projectile/laser_sound_1.mp3";
  static const List<String> allFiles = [
    laserSound1,
  ];
  static List<String> allFilesFlame = [
    laserSound1.flamePath,
  ];
}

class FontsAssetsFonts {
  ///alagard.ttf
  static const String alagard = "assets/fonts/alagard.ttf";

  ///hero-speak.ttf
  static const String heroSpeak = "assets/fonts/hero-speak.ttf";

  ///yusei-magic.ttf
  static const String yuseiMagic = "assets/fonts/yusei-magic.ttf";
  static const List<String> allFiles = [
    alagard,
    heroSpeak,
    yuseiMagic,
  ];
  static List<String> allFilesFlame = [
    alagard.flamePath,
    heroSpeak.flamePath,
    yuseiMagic.flamePath,
  ];
}

class ImagesAssetsAttributes {
  ///attackRate.png
  /// 32x32
  static const String attackRate = "assets/images/attributes/attackRate.png";

  ///topSpeed.png
  /// 14x14
  static const String topSpeed = "assets/images/attributes/topSpeed.png";
  static const List<String> allFiles = [
    attackRate,
    topSpeed,
  ];
  static List<String> allFilesFlame = [
    attackRate.flamePath,
    topSpeed.flamePath,
  ];
}

class ImagesAssetsAttributeSprites {
  ///hovering_crystal_6.png
  /// 768x128
  static const String hoveringCrystal6 =
      "assets/images/attribute_sprites/hovering_crystal_6.png";

  ///hovering_crystal_attack_6.png
  /// 768x128
  static const String hoveringCrystalAttack6 =
      "assets/images/attribute_sprites/hovering_crystal_attack_6.png";

  ///mark_enemy_4.png
  /// 512x128
  static const String markEnemy4 =
      "assets/images/attribute_sprites/mark_enemy_4.png";

  ///spark_child_1_7.png
  /// 224x32
  static const String sparkChild17 =
      "assets/images/attribute_sprites/spark_child_1_7.png";
  static const List<String> allFiles = [
    hoveringCrystal6,
    hoveringCrystalAttack6,
    markEnemy4,
    sparkChild17,
  ];
  static List<String> allFilesFlame = [
    hoveringCrystal6.flamePath,
    hoveringCrystalAttack6.flamePath,
    markEnemy4.flamePath,
    sparkChild17.flamePath,
  ];
}

class ImagesAssetsBackground {
  ///blank.png
  /// 50x50
  static const String blank = "assets/images/background/blank.png";

  ///cave.png
  /// 720x405
  static const String cave = "assets/images/background/cave.png";

  ///caveFront.png
  /// 720x405
  static const String caveFront = "assets/images/background/caveFront.png";

  ///caveFrontEffectMask.png
  /// 720x405
  static const String caveFrontEffectMask =
      "assets/images/background/caveFrontEffectMask.png";

  ///dungeon.png
  /// 618x333
  static const String dungeon = "assets/images/background/dungeon.png";

  ///graveyard.jpg
  static const String graveyard = "assets/images/background/graveyard.jpg";

  ///hexed_forest_display.png
  /// 1920x1280
  static const String hexedForestDisplay =
      "assets/images/background/hexed_forest_display.png";

  ///innerRingPatterns.png
  /// 200x200
  static const String innerRingPatterns =
      "assets/images/background/innerRingPatterns.png";

  ///mushroom_garden.png
  /// 800x800
  static const String mushroomGarden =
      "assets/images/background/mushroom_garden.png";

  ///outerRing.png
  /// 128x128
  static const String outerRing = "assets/images/background/outerRing.png";

  ///outerRingPatterns.png
  /// 100x100
  static const String outerRingPatterns =
      "assets/images/background/outerRingPatterns.png";

  ///preview_glare.jpg
  static const String previewGlare =
      "assets/images/background/preview_glare.jpg";

  ///test_tile.png
  /// 50x50
  static const String testTile = "assets/images/background/test_tile.png";
  static const List<String> allFiles = [
    blank,
    cave,
    caveFront,
    caveFrontEffectMask,
    dungeon,
    graveyard,
    hexedForestDisplay,
    innerRingPatterns,
    mushroomGarden,
    outerRing,
    outerRingPatterns,
    previewGlare,
    testTile,
  ];
  static List<String> allFilesFlame = [
    blank.flamePath,
    cave.flamePath,
    caveFront.flamePath,
    caveFrontEffectMask.flamePath,
    dungeon.flamePath,
    graveyard.flamePath,
    hexedForestDisplay.flamePath,
    innerRingPatterns.flamePath,
    mushroomGarden.flamePath,
    outerRing.flamePath,
    outerRingPatterns.flamePath,
    previewGlare.flamePath,
    testTile.flamePath,
  ];
}

class ImagesAssetsRunes {
  ///rune1.png
  /// 13x15
  static const String rune1 = "assets/images/background/runes/rune1.png";

  ///rune2.png
  /// 11x16
  static const String rune2 = "assets/images/background/runes/rune2.png";

  ///rune3.png
  /// 11x15
  static const String rune3 = "assets/images/background/runes/rune3.png";

  ///rune4.png
  /// 14x15
  static const String rune4 = "assets/images/background/runes/rune4.png";

  ///rune5.png
  /// 13x14
  static const String rune5 = "assets/images/background/runes/rune5.png";

  ///rune6.png
  /// 14x11
  static const String rune6 = "assets/images/background/runes/rune6.png";

  ///rune7.png
  /// 17x17
  static const String rune7 = "assets/images/background/runes/rune7.png";

  ///rune8.png
  /// 15x16
  static const String rune8 = "assets/images/background/runes/rune8.png";
  static const List<String> allFiles = [
    rune1,
    rune2,
    rune3,
    rune4,
    rune5,
    rune6,
    rune7,
    rune8,
  ];
  static List<String> allFilesFlame = [
    rune1.flamePath,
    rune2.flamePath,
    rune3.flamePath,
    rune4.flamePath,
    rune5.flamePath,
    rune6.flamePath,
    rune7.flamePath,
    rune8.flamePath,
  ];
}

class ImagesAssetsEffects {
  ///energy_1_10.png
  /// 640x128
  static const String energy110 = "assets/images/effects/energy_1_10.png";

  ///explosion_1_16.png
  /// 1024x64
  static const String explosion116 = "assets/images/effects/explosion_1_16.png";

  ///psychic_1_11.png
  /// 704x100
  static const String psychic111 = "assets/images/effects/psychic_1_11.png";

  ///star_5.png
  /// 80x16
  static const String star5 = "assets/images/effects/star_5.png";
  static const List<String> allFiles = [
    energy110,
    explosion116,
    psychic111,
    star5,
  ];
  static List<String> allFilesFlame = [
    energy110.flamePath,
    explosion116.flamePath,
    psychic111.flamePath,
    star5.flamePath,
  ];
}

class ImagesAssetsEnemySprites {
  ///death.png
  /// 640x64
  static const String death = "assets/images/enemy_sprites/death.png";

  ///idle.png
  /// 480x48
  static const String idle = "assets/images/enemy_sprites/idle.png";

  ///run.png
  /// 384x48
  static const String run = "assets/images/enemy_sprites/run.png";
  static const List<String> allFiles = [
    death,
    idle,
    run,
  ];
  static List<String> allFilesFlame = [
    death.flamePath,
    idle.flamePath,
    run.flamePath,
  ];
}

class ImagesAssetsMushroomBoomer {
  ///death.png
  /// 640x64
  static const String death =
      "assets/images/enemy_sprites/mushroomBoomer/death.png";

  ///idle.png
  /// 480x48
  static const String idle =
      "assets/images/enemy_sprites/mushroomBoomer/idle.png";

  ///jump.png
  /// 144x48
  static const String jump =
      "assets/images/enemy_sprites/mushroomBoomer/jump.png";

  ///land.png
  /// 432x48
  static const String land =
      "assets/images/enemy_sprites/mushroomBoomer/land.png";

  ///roll.png
  /// 336x48
  static const String roll =
      "assets/images/enemy_sprites/mushroomBoomer/roll.png";

  ///run.png
  /// 384x48
  static const String run =
      "assets/images/enemy_sprites/mushroomBoomer/run.png";

  ///walk.png
  /// 384x48
  static const String walk =
      "assets/images/enemy_sprites/mushroomBoomer/walk.png";
  static const List<String> allFiles = [
    death,
    idle,
    jump,
    land,
    roll,
    run,
    walk,
  ];
  static List<String> allFilesFlame = [
    death.flamePath,
    idle.flamePath,
    jump.flamePath,
    land.flamePath,
    roll.flamePath,
    run.flamePath,
    walk.flamePath,
  ];
}

class ImagesAssetsMushroomBurrower {
  ///burrow_in.png
  /// 432x48
  static const String burrowIn =
      "assets/images/enemy_sprites/mushroomBurrower/burrow_in.png";

  ///burrow_out.png
  /// 432x48
  static const String burrowOut =
      "assets/images/enemy_sprites/mushroomBurrower/burrow_out.png";

  ///death.png
  /// 640x64
  static const String death =
      "assets/images/enemy_sprites/mushroomBurrower/death.png";

  ///idle.png
  /// 480x48
  static const String idle =
      "assets/images/enemy_sprites/mushroomBurrower/idle.png";

  ///jump.png
  /// 144x48
  static const String jump =
      "assets/images/enemy_sprites/mushroomBurrower/jump.png";

  ///roll.png
  /// 336x48
  static const String roll =
      "assets/images/enemy_sprites/mushroomBurrower/roll.png";

  ///run.png
  /// 384x48
  static const String run =
      "assets/images/enemy_sprites/mushroomBurrower/run.png";

  ///walk.png
  /// 384x48
  static const String walk =
      "assets/images/enemy_sprites/mushroomBurrower/walk.png";
  static const List<String> allFiles = [
    burrowIn,
    burrowOut,
    death,
    idle,
    jump,
    roll,
    run,
    walk,
  ];
  static List<String> allFilesFlame = [
    burrowIn.flamePath,
    burrowOut.flamePath,
    death.flamePath,
    idle.flamePath,
    jump.flamePath,
    roll.flamePath,
    run.flamePath,
    walk.flamePath,
  ];
}

class ImagesAssetsMushroomHopper {
  ///death.png
  /// 640x64
  static const String death =
      "assets/images/enemy_sprites/mushroomHopper/death.png";

  ///idle.png
  /// 480x48
  static const String idle =
      "assets/images/enemy_sprites/mushroomHopper/idle.png";

  ///jump.png
  /// 144x48
  static const String jump =
      "assets/images/enemy_sprites/mushroomHopper/jump.png";

  ///land.png
  /// 432x48
  static const String land =
      "assets/images/enemy_sprites/mushroomHopper/land.png";

  ///roll.png
  /// 336x48
  static const String roll =
      "assets/images/enemy_sprites/mushroomHopper/roll.png";

  ///run.png
  /// 384x48
  static const String run =
      "assets/images/enemy_sprites/mushroomHopper/run.png";

  ///walk.png
  /// 384x48
  static const String walk =
      "assets/images/enemy_sprites/mushroomHopper/walk.png";
  static const List<String> allFiles = [
    death,
    idle,
    jump,
    land,
    roll,
    run,
    walk,
  ];
  static List<String> allFilesFlame = [
    death.flamePath,
    idle.flamePath,
    jump.flamePath,
    land.flamePath,
    roll.flamePath,
    run.flamePath,
    walk.flamePath,
  ];
}

class ImagesAssetsMushroomRunner {
  ///dead.png
  /// 128x32
  static const String dead =
      "assets/images/enemy_sprites/mushroomRunner/dead.png";

  ///idle.png
  /// 64x32
  static const String idle =
      "assets/images/enemy_sprites/mushroomRunner/idle.png";

  ///run.png
  /// 64x32
  static const String run =
      "assets/images/enemy_sprites/mushroomRunner/run.png";
  static const List<String> allFiles = [
    dead,
    idle,
    run,
  ];
  static List<String> allFilesFlame = [
    dead.flamePath,
    idle.flamePath,
    run.flamePath,
  ];
}

class ImagesAssetsMushroomShooter {
  ///death.png
  /// 640x64
  static const String death =
      "assets/images/enemy_sprites/mushroomShooter/death.png";

  ///idle.png
  /// 480x48
  static const String idle =
      "assets/images/enemy_sprites/mushroomShooter/idle.png";

  ///jump.png
  /// 144x48
  static const String jump =
      "assets/images/enemy_sprites/mushroomShooter/jump.png";

  ///land.png
  /// 432x48
  static const String land =
      "assets/images/enemy_sprites/mushroomShooter/land.png";

  ///roll.png
  /// 336x48
  static const String roll =
      "assets/images/enemy_sprites/mushroomShooter/roll.png";

  ///run.png
  /// 384x48
  static const String run =
      "assets/images/enemy_sprites/mushroomShooter/run.png";

  ///walk.png
  /// 384x48
  static const String walk =
      "assets/images/enemy_sprites/mushroomShooter/walk.png";
  static const List<String> allFiles = [
    death,
    idle,
    jump,
    land,
    roll,
    run,
    walk,
  ];
  static List<String> allFilesFlame = [
    death.flamePath,
    idle.flamePath,
    jump.flamePath,
    land.flamePath,
    roll.flamePath,
    run.flamePath,
    walk.flamePath,
  ];
}

class ImagesAssetsMushroomSpinner {
  ///death.png
  /// 640x64
  static const String death =
      "assets/images/enemy_sprites/mushroomSpinner/death.png";

  ///idle.png
  /// 480x48
  static const String idle =
      "assets/images/enemy_sprites/mushroomSpinner/idle.png";

  ///jump.png
  /// 144x48
  static const String jump =
      "assets/images/enemy_sprites/mushroomSpinner/jump.png";

  ///run.png
  /// 384x48
  static const String run =
      "assets/images/enemy_sprites/mushroomSpinner/run.png";

  ///spin.png
  /// 336x48
  static const String spin =
      "assets/images/enemy_sprites/mushroomSpinner/spin.png";

  ///spin_end.png
  /// 432x48
  static const String spinEnd =
      "assets/images/enemy_sprites/mushroomSpinner/spin_end.png";

  ///spin_start.png
  /// 432x48
  static const String spinStart =
      "assets/images/enemy_sprites/mushroomSpinner/spin_start.png";

  ///walk.png
  /// 384x48
  static const String walk =
      "assets/images/enemy_sprites/mushroomSpinner/walk.png";
  static const List<String> allFiles = [
    death,
    idle,
    jump,
    run,
    spin,
    spinEnd,
    spinStart,
    walk,
  ];
  static List<String> allFilesFlame = [
    death.flamePath,
    idle.flamePath,
    jump.flamePath,
    run.flamePath,
    spin.flamePath,
    spinEnd.flamePath,
    spinStart.flamePath,
    walk.flamePath,
  ];
}

class ImagesAssetsEntityEffects {
  ///dash_effect.png
  /// 448x32
  static const String dashEffect =
      "assets/images/entity_effects/dash_effect.png";

  ///jump_effect.png
  /// 450x23
  static const String jumpEffect =
      "assets/images/entity_effects/jump_effect.png";
  static const List<String> allFiles = [
    dashEffect,
    jumpEffect,
  ];
  static List<String> allFilesFlame = [
    dashEffect.flamePath,
    jumpEffect.flamePath,
  ];
}

class ImagesAssetsExpendables {
  ///blank.png
  /// 32x32
  static const String blank = "assets/images/expendables/blank.png";

  ///blank_alt.png
  /// 32x32
  static const String blankAlt = "assets/images/expendables/blank_alt.png";

  ///experience_attract.png
  /// 32x32
  static const String experienceAttract =
      "assets/images/expendables/experience_attract.png";

  ///fear_enemies.png
  /// 32x32
  static const String fearEnemies =
      "assets/images/expendables/fear_enemies.png";
  static const List<String> allFiles = [
    blank,
    blankAlt,
    experienceAttract,
    fearEnemies,
  ];
  static List<String> allFilesFlame = [
    blank.flamePath,
    blankAlt.flamePath,
    experienceAttract.flamePath,
    fearEnemies.flamePath,
  ];
}

class ImagesAssetsExperience {
  ///large.png
  /// 16x16
  static const String large = "assets/images/experience/large.png";

  ///medium.png
  /// 16x16
  static const String medium = "assets/images/experience/medium.png";

  ///small.png
  /// 16x16
  static const String small = "assets/images/experience/small.png";
  static const List<String> allFiles = [
    large,
    medium,
    small,
  ];
  static List<String> allFilesFlame = [
    large.flamePath,
    medium.flamePath,
    small.flamePath,
  ];
}

class ImagesAssetsPowerups {
  ///energy.png
  /// 47x58
  static const String energy = "assets/images/powerups/energy.png";

  ///power.png
  /// 54x63
  static const String power = "assets/images/powerups/power.png";

  ///start.png
  /// 72x62
  static const String start = "assets/images/powerups/start.png";
  static const List<String> allFiles = [
    energy,
    power,
    start,
  ];
  static List<String> allFilesFlame = [
    energy.flamePath,
    power.flamePath,
    start.flamePath,
  ];
}

class ImagesAssetsSecondaryIcons {
  ///blank.png
  /// 32x32
  static const String blank = "assets/images/secondary_icons/blank.png";

  ///explode_projectiles.png
  /// 32x32
  static const String explodeProjectiles =
      "assets/images/secondary_icons/explode_projectiles.png";

  ///rapid_fire.png
  /// 32x32
  static const String rapidFire =
      "assets/images/secondary_icons/rapid_fire.png";
  static const List<String> allFiles = [
    blank,
    explodeProjectiles,
    rapidFire,
  ];
  static List<String> allFilesFlame = [
    blank.flamePath,
    explodeProjectiles.flamePath,
    rapidFire.flamePath,
  ];
}

class ImagesAssetsSprites {
  ///death.png
  /// 96x16
  static const String death = "assets/images/sprites/death.png";

  ///hit.png
  /// 48x16
  static const String hit = "assets/images/sprites/hit.png";

  ///idle.png
  /// 96x96
  static const String idle = "assets/images/sprites/idle.png";

  ///jump.png
  /// 96x16
  static const String jump = "assets/images/sprites/jump.png";

  ///roll.png
  /// 80x16
  static const String roll = "assets/images/sprites/roll.png";

  ///run.png
  /// 96x16
  static const String run = "assets/images/sprites/run.png";

  ///walk.png
  /// 384x48
  static const String walk = "assets/images/sprites/walk.png";
  static const List<String> allFiles = [
    death,
    hit,
    idle,
    jump,
    roll,
    run,
    walk,
  ];
  static List<String> allFilesFlame = [
    death.flamePath,
    hit.flamePath,
    idle.flamePath,
    jump.flamePath,
    roll.flamePath,
    run.flamePath,
    walk.flamePath,
  ];
}

class ImagesAssetsRuneknight {
  ///runeknight_dash_1.png
  /// 336x48
  static const String runeknightDash1 =
      "assets/images/sprites/runeknight/runeknight_dash_1.png";

  ///runeknight_death_1.png
  /// 384x48
  static const String runeknightDeath1 =
      "assets/images/sprites/runeknight/runeknight_death_1.png";

  ///runeknight_hit_1.png
  /// 192x48
  static const String runeknightHit1 =
      "assets/images/sprites/runeknight/runeknight_hit_1.png";

  ///runeknight_idle_1.png
  /// 288x48
  static const String runeknightIdle1 =
      "assets/images/sprites/runeknight/runeknight_idle_1.png";

  ///runeknight_jump_1.png
  /// 144x48
  static const String runeknightJump1 =
      "assets/images/sprites/runeknight/runeknight_jump_1.png";

  ///runeknight_run_1.png
  /// 384x48
  static const String runeknightRun1 =
      "assets/images/sprites/runeknight/runeknight_run_1.png";
  static const List<String> allFiles = [
    runeknightDash1,
    runeknightDeath1,
    runeknightHit1,
    runeknightIdle1,
    runeknightJump1,
    runeknightRun1,
  ];
  static List<String> allFilesFlame = [
    runeknightDash1.flamePath,
    runeknightDeath1.flamePath,
    runeknightHit1.flamePath,
    runeknightIdle1.flamePath,
    runeknightJump1.flamePath,
    runeknightRun1.flamePath,
  ];
}

class ImagesAssetsStatusEffects {
  ///fire_effect.png
  /// 64x16
  static const String fireEffect =
      "assets/images/status_effects/fire_effect.png";
  static const List<String> allFiles = [
    fireEffect,
  ];
  static List<String> allFilesFlame = [
    fireEffect.flamePath,
  ];
}

class ImagesAssetsUi {
  ///ammo.png
  /// 8x8
  static const String ammo = "assets/images/ui/ammo.png";

  ///ammo_empty.png
  /// 8x8
  static const String ammoEmpty = "assets/images/ui/ammo_empty.png";

  ///arrow_black.png
  /// 12x8
  static const String arrowBlack = "assets/images/ui/arrow_black.png";

  ///attribute_background.png
  /// 128x96
  static const String attributeBackground =
      "assets/images/ui/attribute_background.png";

  ///attribute_background_mask.png
  /// 128x96
  static const String attributeBackgroundMask =
      "assets/images/ui/attribute_background_mask.png";

  ///attribute_background_mask_small.png
  /// 128x48
  static const String attributeBackgroundMaskSmall =
      "assets/images/ui/attribute_background_mask_small.png";

  ///attribute_background_small.png
  /// 128x48
  static const String attributeBackgroundSmall =
      "assets/images/ui/attribute_background_small.png";

  ///attribute_border.png
  /// 128x96
  static const String attributeBorder = "assets/images/ui/attribute_border.png";

  ///attribute_border_small.png
  /// 128x48
  static const String attributeBorderSmall =
      "assets/images/ui/attribute_border_small.png";

  ///bag.png
  /// 736x714
  static const String bag = "assets/images/ui/bag.png";

  ///banner.png
  /// 128x36
  static const String banner = "assets/images/ui/banner.png";

  ///book.png
  /// 24x32
  static const String book = "assets/images/ui/book.png";

  ///boss_bar_border.png
  /// 16x16
  static const String bossBarBorder = "assets/images/ui/boss_bar_border.png";

  ///boss_bar_center.png
  /// 96x16
  static const String bossBarCenter = "assets/images/ui/boss_bar_center.png";

  ///boss_bar_left.png
  /// 32x16
  static const String bossBarLeft = "assets/images/ui/boss_bar_left.png";

  ///boss_bar_right.png
  /// 32x16
  static const String bossBarRight = "assets/images/ui/boss_bar_right.png";

  ///health_bar.png
  /// 128x32
  static const String healthBar = "assets/images/ui/health_bar.png";

  ///level_indicator_gun_blue.png
  /// 16x16
  static const String levelIndicatorGunBlue =
      "assets/images/ui/level_indicator_gun_blue.png";

  ///level_indicator_gun_red.png
  /// 16x16
  static const String levelIndicatorGunRed =
      "assets/images/ui/level_indicator_gun_red.png";

  ///level_indicator_magic_blue.png
  /// 16x16
  static const String levelIndicatorMagicBlue =
      "assets/images/ui/level_indicator_magic_blue.png";

  ///level_indicator_magic_red.png
  /// 16x16
  static const String levelIndicatorMagicRed =
      "assets/images/ui/level_indicator_magic_red.png";

  ///level_indicator_sword_blue.png
  /// 16x16
  static const String levelIndicatorSwordBlue =
      "assets/images/ui/level_indicator_sword_blue.png";

  ///level_indicator_sword_red.png
  /// 16x16
  static const String levelIndicatorSwordRed =
      "assets/images/ui/level_indicator_sword_red.png";

  ///magic_hand_L.png
  /// 64x128
  static const String magicHandL = "assets/images/ui/magic_hand_L.png";

  ///magic_hand_R.png
  /// 64x128
  static const String magicHandR = "assets/images/ui/magic_hand_R.png";

  ///magic_hand_small_L.png
  /// 32x64
  static const String magicHandSmallL =
      "assets/images/ui/magic_hand_small_L.png";

  ///magic_hand_small_R.png
  /// 32x64
  static const String magicHandSmallR =
      "assets/images/ui/magic_hand_small_R.png";

  ///padlock.png
  /// 32x32
  static const String padlock = "assets/images/ui/padlock.png";

  ///placeholder_face.png
  /// 16x20
  static const String placeholderFace = "assets/images/ui/placeholder_face.png";

  ///plus_blue.png
  /// 16x16
  static const String plusBlue = "assets/images/ui/plus_blue.png";

  ///plus_red.png
  /// 16x16
  static const String plusRed = "assets/images/ui/plus_red.png";

  ///weapon_level_indicator.png
  /// 32x32
  static const String weaponLevelIndicator =
      "assets/images/ui/weapon_level_indicator.png";

  ///xp_bar_border.png
  /// 16x16
  static const String xpBarBorder = "assets/images/ui/xp_bar_border.png";

  ///xp_bar_center.png
  /// 16x16
  static const String xpBarCenter = "assets/images/ui/xp_bar_center.png";

  ///xp_bar_left.png
  /// 16x16
  static const String xpBarLeft = "assets/images/ui/xp_bar_left.png";

  ///xp_bar_right.png
  /// 16x16
  static const String xpBarRight = "assets/images/ui/xp_bar_right.png";
  static const List<String> allFiles = [
    ammo,
    ammoEmpty,
    arrowBlack,
    attributeBackground,
    attributeBackgroundMask,
    attributeBackgroundMaskSmall,
    attributeBackgroundSmall,
    attributeBorder,
    attributeBorderSmall,
    bag,
    banner,
    book,
    bossBarBorder,
    bossBarCenter,
    bossBarLeft,
    bossBarRight,
    healthBar,
    levelIndicatorGunBlue,
    levelIndicatorGunRed,
    levelIndicatorMagicBlue,
    levelIndicatorMagicRed,
    levelIndicatorSwordBlue,
    levelIndicatorSwordRed,
    magicHandL,
    magicHandR,
    magicHandSmallL,
    magicHandSmallR,
    padlock,
    placeholderFace,
    plusBlue,
    plusRed,
    weaponLevelIndicator,
    xpBarBorder,
    xpBarCenter,
    xpBarLeft,
    xpBarRight,
  ];
  static List<String> allFilesFlame = [
    ammo.flamePath,
    ammoEmpty.flamePath,
    arrowBlack.flamePath,
    attributeBackground.flamePath,
    attributeBackgroundMask.flamePath,
    attributeBackgroundMaskSmall.flamePath,
    attributeBackgroundSmall.flamePath,
    attributeBorder.flamePath,
    attributeBorderSmall.flamePath,
    bag.flamePath,
    banner.flamePath,
    book.flamePath,
    bossBarBorder.flamePath,
    bossBarCenter.flamePath,
    bossBarLeft.flamePath,
    bossBarRight.flamePath,
    healthBar.flamePath,
    levelIndicatorGunBlue.flamePath,
    levelIndicatorGunRed.flamePath,
    levelIndicatorMagicBlue.flamePath,
    levelIndicatorMagicRed.flamePath,
    levelIndicatorSwordBlue.flamePath,
    levelIndicatorSwordRed.flamePath,
    magicHandL.flamePath,
    magicHandR.flamePath,
    magicHandSmallL.flamePath,
    magicHandSmallR.flamePath,
    padlock.flamePath,
    placeholderFace.flamePath,
    plusBlue.flamePath,
    plusRed.flamePath,
    weaponLevelIndicator.flamePath,
    xpBarBorder.flamePath,
    xpBarCenter.flamePath,
    xpBarLeft.flamePath,
    xpBarRight.flamePath,
  ];
}

class ImagesAssetsAmmo {
  ///ammo.png
  /// 8x8
  static const String ammo = "assets/images/ui/ammo/ammo.png";

  ///ammo_empty.png
  /// 8x8
  static const String ammoEmpty = "assets/images/ui/ammo/ammo_empty.png";
  static const List<String> allFiles = [
    ammo,
    ammoEmpty,
  ];
  static List<String> allFilesFlame = [
    ammo.flamePath,
    ammoEmpty.flamePath,
  ];
}

class ImagesAssetsPermanentAttributes {
  ///defence.png
  /// 10x13
  static const String defence =
      "assets/images/ui/permanent_attributes/defence.png";

  ///elemental.png
  /// 16x16
  static const String elemental =
      "assets/images/ui/permanent_attributes/elemental.png";

  ///mobility.png
  /// 12x16
  static const String mobility =
      "assets/images/ui/permanent_attributes/mobility.png";

  ///offence.png
  /// 13x12
  static const String offence =
      "assets/images/ui/permanent_attributes/offence.png";

  ///resistance.png
  /// 13x15
  static const String resistance =
      "assets/images/ui/permanent_attributes/resistance.png";

  ///rune.png
  /// 11x13
  static const String rune = "assets/images/ui/permanent_attributes/rune.png";

  ///rune_locked.png
  /// 11x13
  static const String runeLocked =
      "assets/images/ui/permanent_attributes/rune_locked.png";

  ///utility.png
  /// 11x14
  static const String utility =
      "assets/images/ui/permanent_attributes/utility.png";
  static const List<String> allFiles = [
    defence,
    elemental,
    mobility,
    offence,
    resistance,
    rune,
    runeLocked,
    utility,
  ];
  static List<String> allFilesFlame = [
    defence.flamePath,
    elemental.flamePath,
    mobility.flamePath,
    offence.flamePath,
    resistance.flamePath,
    rune.flamePath,
    runeLocked.flamePath,
    utility.flamePath,
  ];
}

class ImagesAssetsWeapons {
  ///arcane_blaster.png
  /// 33x79
  static const String arcaneBlaster =
      "assets/images/weapons/arcane_blaster.png";

  ///book_fire.png
  /// 63x32
  static const String bookFire = "assets/images/weapons/book_fire.png";

  ///book_idle.png
  /// 62x41
  static const String bookIdle = "assets/images/weapons/book_idle.png";

  ///crystal_sword.png
  /// 35x114
  static const String crystalSword = "assets/images/weapons/crystal_sword.png";

  ///dagger.png
  /// 22x51
  static const String dagger = "assets/images/weapons/dagger.png";

  ///eldritch_runner.png
  /// 43x86
  static const String eldritchRunner =
      "assets/images/weapons/eldritch_runner.png";

  ///energy_sword.png
  /// 54x142
  static const String energySword = "assets/images/weapons/energy_sword.png";

  ///fire_sword.png
  /// 42x103
  static const String fireSword = "assets/images/weapons/fire_sword.png";

  ///frost_katana.png
  /// 28x152
  static const String frostKatana = "assets/images/weapons/frost_katana.png";

  ///large_sword.png
  /// 26x90
  static const String largeSword = "assets/images/weapons/large_sword.png";

  ///long_rifle.png
  /// 64x128
  static const String longRifle = "assets/images/weapons/long_rifle.png";

  ///long_rifle_attack.png
  /// 192x64
  static const String longRifleAttack =
      "assets/images/weapons/long_rifle_attack.png";

  ///long_rifle_idle.png
  /// 608x64
  static const String longRifleIdle =
      "assets/images/weapons/long_rifle_idle.png";

  ///muzzle_flash.png
  /// 32x32
  static const String muzzleFlash = "assets/images/weapons/muzzle_flash.png";

  ///pistol.png
  /// 28x44
  static const String pistol = "assets/images/weapons/pistol.png";

  ///prismatic_beam.png
  /// 32x74
  static const String prismaticBeam =
      "assets/images/weapons/prismatic_beam.png";

  ///railspire.png
  /// 36x89
  static const String railspire = "assets/images/weapons/railspire.png";

  ///scatter_vine.png
  /// 18x102
  static const String scatterVine = "assets/images/weapons/scatter_vine.png";

  ///shotgun.png
  /// 189x365
  static const String shotgun = "assets/images/weapons/shotgun.png";

  ///spear.png
  /// 15x152
  static const String spear = "assets/images/weapons/spear.png";

  ///sword_of_justice.png
  /// 46x135
  static const String swordOfJustice =
      "assets/images/weapons/sword_of_justice.png";
  static const List<String> allFiles = [
    arcaneBlaster,
    bookFire,
    bookIdle,
    crystalSword,
    dagger,
    eldritchRunner,
    energySword,
    fireSword,
    frostKatana,
    largeSword,
    longRifle,
    longRifleAttack,
    longRifleIdle,
    muzzleFlash,
    pistol,
    prismaticBeam,
    railspire,
    scatterVine,
    shotgun,
    spear,
    swordOfJustice,
  ];
  static List<String> allFilesFlame = [
    arcaneBlaster.flamePath,
    bookFire.flamePath,
    bookIdle.flamePath,
    crystalSword.flamePath,
    dagger.flamePath,
    eldritchRunner.flamePath,
    energySword.flamePath,
    fireSword.flamePath,
    frostKatana.flamePath,
    largeSword.flamePath,
    longRifle.flamePath,
    longRifleAttack.flamePath,
    longRifleIdle.flamePath,
    muzzleFlash.flamePath,
    pistol.flamePath,
    prismaticBeam.flamePath,
    railspire.flamePath,
    scatterVine.flamePath,
    shotgun.flamePath,
    spear.flamePath,
    swordOfJustice.flamePath,
  ];
}

class ImagesAssetsCharge {
  ///fire_charge_charged.png
  /// 192x32
  static const String fireChargeCharged =
      "assets/images/weapons/charge/fire_charge_charged.png";

  ///fire_charge_end.png
  /// 64x16
  static const String fireChargeEnd =
      "assets/images/weapons/charge/fire_charge_end.png";

  ///fire_charge_play.png
  /// 48x16
  static const String fireChargePlay =
      "assets/images/weapons/charge/fire_charge_play.png";

  ///fire_charge_spawn.png
  /// 80x16
  static const String fireChargeSpawn =
      "assets/images/weapons/charge/fire_charge_spawn.png";
  static const List<String> allFiles = [
    fireChargeCharged,
    fireChargeEnd,
    fireChargePlay,
    fireChargeSpawn,
  ];
  static List<String> allFilesFlame = [
    fireChargeCharged.flamePath,
    fireChargeEnd.flamePath,
    fireChargePlay.flamePath,
    fireChargeSpawn.flamePath,
  ];
}

class ImagesAssetsMelee {
  ///small_crush_effect.png
  /// 104x53
  static const String smallCrushEffect =
      "assets/images/weapons/melee/small_crush_effect.png";

  ///small_slash_effect.png
  /// 154x16
  static const String smallSlashEffect =
      "assets/images/weapons/melee/small_slash_effect.png";

  ///small_stab_effect.png
  /// 164x36
  static const String smallStabEffect =
      "assets/images/weapons/melee/small_stab_effect.png";
  static const List<String> allFiles = [
    smallCrushEffect,
    smallSlashEffect,
    smallStabEffect,
  ];
  static List<String> allFilesFlame = [
    smallCrushEffect.flamePath,
    smallSlashEffect.flamePath,
    smallStabEffect.flamePath,
  ];
}

class ImagesAssetsProjectiles {
  ///black_muzzle_flash.png
  /// 80x48
  static const String blackMuzzleFlash =
      "assets/images/weapons/projectiles/black_muzzle_flash.png";

  ///fire_muzzle_flash.png
  /// 80x48
  static const String fireMuzzleFlash =
      "assets/images/weapons/projectiles/fire_muzzle_flash.png";

  ///magic_muzzle_flash.png
  /// 80x48
  static const String magicMuzzleFlash =
      "assets/images/weapons/projectiles/magic_muzzle_flash.png";
  static const List<String> allFiles = [
    blackMuzzleFlash,
    fireMuzzleFlash,
    magicMuzzleFlash,
  ];
  static List<String> allFilesFlame = [
    blackMuzzleFlash.flamePath,
    fireMuzzleFlash.flamePath,
    magicMuzzleFlash.flamePath,
  ];
}

class ImagesAssetsBlasts {
  ///fire_blast_end.png
  /// 128x32
  static const String fireBlastEnd =
      "assets/images/weapons/projectiles/blasts/fire_blast_end.png";

  ///fire_blast_play.png
  /// 128x32
  static const String fireBlastPlay =
      "assets/images/weapons/projectiles/blasts/fire_blast_play.png";

  ///fire_blast_play_alt.png
  /// 128x32
  static const String fireBlastPlayAlt =
      "assets/images/weapons/projectiles/blasts/fire_blast_play_alt.png";
  static const List<String> allFiles = [
    fireBlastEnd,
    fireBlastPlay,
    fireBlastPlayAlt,
  ];
  static List<String> allFilesFlame = [
    fireBlastEnd.flamePath,
    fireBlastPlay.flamePath,
    fireBlastPlayAlt.flamePath,
  ];
}

class ImagesAssetsBullets {
  ///black_bullet_end.png
  /// 48x16
  static const String blackBulletEnd =
      "assets/images/weapons/projectiles/bullets/black_bullet_end.png";

  ///black_bullet_hit.png
  /// 246x36
  static const String blackBulletHit =
      "assets/images/weapons/projectiles/bullets/black_bullet_hit.png";

  ///black_bullet_play.png
  /// 64x16
  static const String blackBulletPlay =
      "assets/images/weapons/projectiles/bullets/black_bullet_play.png";

  ///black_bullet_spawn.png
  /// 64x16
  static const String blackBulletSpawn =
      "assets/images/weapons/projectiles/bullets/black_bullet_spawn.png";

  ///energy_bullet_end.png
  /// 48x16
  static const String energyBulletEnd =
      "assets/images/weapons/projectiles/bullets/energy_bullet_end.png";

  ///energy_bullet_hit.png
  /// 96x16
  static const String energyBulletHit =
      "assets/images/weapons/projectiles/bullets/energy_bullet_hit.png";

  ///energy_bullet_play.png
  /// 64x16
  static const String energyBulletPlay =
      "assets/images/weapons/projectiles/bullets/energy_bullet_play.png";

  ///energy_bullet_spawn.png
  /// 64x16
  static const String energyBulletSpawn =
      "assets/images/weapons/projectiles/bullets/energy_bullet_spawn.png";

  ///fire_bullet_end.png
  /// 48x16
  static const String fireBulletEnd =
      "assets/images/weapons/projectiles/bullets/fire_bullet_end.png";

  ///fire_bullet_hit.png
  /// 96x16
  static const String fireBulletHit =
      "assets/images/weapons/projectiles/bullets/fire_bullet_hit.png";

  ///fire_bullet_play.png
  /// 64x16
  static const String fireBulletPlay =
      "assets/images/weapons/projectiles/bullets/fire_bullet_play.png";

  ///fire_bullet_spawn.png
  /// 64x16
  static const String fireBulletSpawn =
      "assets/images/weapons/projectiles/bullets/fire_bullet_spawn.png";

  ///frost_bullet_end.png
  /// 48x16
  static const String frostBulletEnd =
      "assets/images/weapons/projectiles/bullets/frost_bullet_end.png";

  ///frost_bullet_hit.png
  /// 96x16
  static const String frostBulletHit =
      "assets/images/weapons/projectiles/bullets/frost_bullet_hit.png";

  ///frost_bullet_play.png
  /// 64x16
  static const String frostBulletPlay =
      "assets/images/weapons/projectiles/bullets/frost_bullet_play.png";

  ///frost_bullet_spawn.png
  /// 64x16
  static const String frostBulletSpawn =
      "assets/images/weapons/projectiles/bullets/frost_bullet_spawn.png";

  ///healing_bullet_end.png
  /// 48x16
  static const String healingBulletEnd =
      "assets/images/weapons/projectiles/bullets/healing_bullet_end.png";

  ///healing_bullet_hit.png
  /// 96x16
  static const String healingBulletHit =
      "assets/images/weapons/projectiles/bullets/healing_bullet_hit.png";

  ///healing_bullet_play.png
  /// 64x16
  static const String healingBulletPlay =
      "assets/images/weapons/projectiles/bullets/healing_bullet_play.png";

  ///healing_bullet_spawn.png
  /// 64x16
  static const String healingBulletSpawn =
      "assets/images/weapons/projectiles/bullets/healing_bullet_spawn.png";

  ///holy_bullet_play.png
  /// 45x101
  static const String holyBulletPlay =
      "assets/images/weapons/projectiles/bullets/holy_bullet_play.png";

  ///holy_bullet_spawn.png
  /// 45x101
  static const String holyBulletSpawn =
      "assets/images/weapons/projectiles/bullets/holy_bullet_spawn.png";

  ///magic_bullet_end.png
  /// 48x16
  static const String magicBulletEnd =
      "assets/images/weapons/projectiles/bullets/magic_bullet_end.png";

  ///magic_bullet_hit.png
  /// 96x16
  static const String magicBulletHit =
      "assets/images/weapons/projectiles/bullets/magic_bullet_hit.png";

  ///magic_bullet_play.png
  /// 64x16
  static const String magicBulletPlay =
      "assets/images/weapons/projectiles/bullets/magic_bullet_play.png";

  ///magic_bullet_spawn.png
  /// 64x16
  static const String magicBulletSpawn =
      "assets/images/weapons/projectiles/bullets/magic_bullet_spawn.png";

  ///physical_bullet_end.png
  /// 48x16
  static const String physicalBulletEnd =
      "assets/images/weapons/projectiles/bullets/physical_bullet_end.png";

  ///physical_bullet_hit.png
  /// 96x16
  static const String physicalBulletHit =
      "assets/images/weapons/projectiles/bullets/physical_bullet_hit.png";

  ///physical_bullet_play.png
  /// 64x16
  static const String physicalBulletPlay =
      "assets/images/weapons/projectiles/bullets/physical_bullet_play.png";

  ///physical_bullet_spawn.png
  /// 64x16
  static const String physicalBulletSpawn =
      "assets/images/weapons/projectiles/bullets/physical_bullet_spawn.png";

  ///psychic_bullet_end.png
  /// 48x16
  static const String psychicBulletEnd =
      "assets/images/weapons/projectiles/bullets/psychic_bullet_end.png";

  ///psychic_bullet_hit.png
  /// 96x16
  static const String psychicBulletHit =
      "assets/images/weapons/projectiles/bullets/psychic_bullet_hit.png";

  ///psychic_bullet_play.png
  /// 64x16
  static const String psychicBulletPlay =
      "assets/images/weapons/projectiles/bullets/psychic_bullet_play.png";

  ///psychic_bullet_spawn.png
  /// 64x16
  static const String psychicBulletSpawn =
      "assets/images/weapons/projectiles/bullets/psychic_bullet_spawn.png";
  static const List<String> allFiles = [
    blackBulletEnd,
    blackBulletHit,
    blackBulletPlay,
    blackBulletSpawn,
    energyBulletEnd,
    energyBulletHit,
    energyBulletPlay,
    energyBulletSpawn,
    fireBulletEnd,
    fireBulletHit,
    fireBulletPlay,
    fireBulletSpawn,
    frostBulletEnd,
    frostBulletHit,
    frostBulletPlay,
    frostBulletSpawn,
    healingBulletEnd,
    healingBulletHit,
    healingBulletPlay,
    healingBulletSpawn,
    holyBulletPlay,
    holyBulletSpawn,
    magicBulletEnd,
    magicBulletHit,
    magicBulletPlay,
    magicBulletSpawn,
    physicalBulletEnd,
    physicalBulletHit,
    physicalBulletPlay,
    physicalBulletSpawn,
    psychicBulletEnd,
    psychicBulletHit,
    psychicBulletPlay,
    psychicBulletSpawn,
  ];
  static List<String> allFilesFlame = [
    blackBulletEnd.flamePath,
    blackBulletHit.flamePath,
    blackBulletPlay.flamePath,
    blackBulletSpawn.flamePath,
    energyBulletEnd.flamePath,
    energyBulletHit.flamePath,
    energyBulletPlay.flamePath,
    energyBulletSpawn.flamePath,
    fireBulletEnd.flamePath,
    fireBulletHit.flamePath,
    fireBulletPlay.flamePath,
    fireBulletSpawn.flamePath,
    frostBulletEnd.flamePath,
    frostBulletHit.flamePath,
    frostBulletPlay.flamePath,
    frostBulletSpawn.flamePath,
    healingBulletEnd.flamePath,
    healingBulletHit.flamePath,
    healingBulletPlay.flamePath,
    healingBulletSpawn.flamePath,
    holyBulletPlay.flamePath,
    holyBulletSpawn.flamePath,
    magicBulletEnd.flamePath,
    magicBulletHit.flamePath,
    magicBulletPlay.flamePath,
    magicBulletSpawn.flamePath,
    physicalBulletEnd.flamePath,
    physicalBulletHit.flamePath,
    physicalBulletPlay.flamePath,
    physicalBulletSpawn.flamePath,
    psychicBulletEnd.flamePath,
    psychicBulletHit.flamePath,
    psychicBulletPlay.flamePath,
    psychicBulletSpawn.flamePath,
  ];
}

class ImagesAssetsMagic {
  ///energy_hit.png
  /// 128x32
  static const String energyHit =
      "assets/images/weapons/projectiles/magic/energy_hit.png";

  ///energy_play.png
  /// 288x71
  static const String energyPlay =
      "assets/images/weapons/projectiles/magic/energy_play.png";

  ///fire_hit.png
  /// 128x32
  static const String fireHit =
      "assets/images/weapons/projectiles/magic/fire_hit.png";

  ///fire_play.png
  /// 52x48
  static const String firePlay =
      "assets/images/weapons/projectiles/magic/fire_play.png";

  ///fire_play_big.png
  /// 64x32
  static const String firePlayBig =
      "assets/images/weapons/projectiles/magic/fire_play_big.png";

  ///frost_hit.png
  /// 576x96
  static const String frostHit =
      "assets/images/weapons/projectiles/magic/frost_hit.png";

  ///frost_play.png
  /// 48x32
  static const String frostPlay =
      "assets/images/weapons/projectiles/magic/frost_play.png";

  ///frost_play_big.png
  /// 48x32
  static const String frostPlayBig =
      "assets/images/weapons/projectiles/magic/frost_play_big.png";

  ///frost_spawn.png
  /// 48x32
  static const String frostSpawn =
      "assets/images/weapons/projectiles/magic/frost_spawn.png";

  ///frost_spawn_big.png
  /// 48x32
  static const String frostSpawnBig =
      "assets/images/weapons/projectiles/magic/frost_spawn_big.png";

  ///magic_play.png
  /// 288x32
  static const String magicPlay =
      "assets/images/weapons/projectiles/magic/magic_play.png";

  ///magic_play_big.png
  /// 1152x128
  static const String magicPlayBig =
      "assets/images/weapons/projectiles/magic/magic_play_big.png";

  ///psychic_hit.png
  /// 80x16
  static const String psychicHit =
      "assets/images/weapons/projectiles/magic/psychic_hit.png";

  ///psychic_play.png
  /// 128x32
  static const String psychicPlay =
      "assets/images/weapons/projectiles/magic/psychic_play.png";

  ///psychic_play_big.png
  /// 64x16
  static const String psychicPlayBig =
      "assets/images/weapons/projectiles/magic/psychic_play_big.png";

  ///psychic_spawn_big.png
  /// 96x16
  static const String psychicSpawnBig =
      "assets/images/weapons/projectiles/magic/psychic_spawn_big.png";
  static const List<String> allFiles = [
    energyHit,
    energyPlay,
    fireHit,
    firePlay,
    firePlayBig,
    frostHit,
    frostPlay,
    frostPlayBig,
    frostSpawn,
    frostSpawnBig,
    magicPlay,
    magicPlayBig,
    psychicHit,
    psychicPlay,
    psychicPlayBig,
    psychicSpawnBig,
  ];
  static List<String> allFilesFlame = [
    energyHit.flamePath,
    energyPlay.flamePath,
    fireHit.flamePath,
    firePlay.flamePath,
    firePlayBig.flamePath,
    frostHit.flamePath,
    frostPlay.flamePath,
    frostPlayBig.flamePath,
    frostSpawn.flamePath,
    frostSpawnBig.flamePath,
    magicPlay.flamePath,
    magicPlayBig.flamePath,
    psychicHit.flamePath,
    psychicPlay.flamePath,
    psychicPlayBig.flamePath,
    psychicSpawnBig.flamePath,
  ];
}
