// ignore_for_file: library_private_types_in_public_api, unused_field 
extension StringExtension on String {String get flamePath => (split('/')..removeAt(0)..removeAt(0)) .fold("", (previousValue, element) => "$previousValue/$element").substring(1);}
class AudioAssetsPowerWord {
static const String fall = "assets/audio/sfx/magic/power_word/fall.wav";
}
class AudioAssetsProjectile {
static const String laserSound1 = "assets/audio/sfx/projectile/laser_sound_1.mp3";
}
class FontsAssetsFonts {
static const String alagard = "assets/fonts/alagard.ttf";
static const String heroSpeak = "assets/fonts/hero-speak.ttf";
static const String yuseiMagic = "assets/fonts/yusei-magic.ttf";
}
class ImagesAssetsAttributes {
static const String attackRate = "assets/images/attributes/attackRate.png";
static const String topSpeed = "assets/images/attributes/topSpeed.png";
}
class ImagesAssetsAttributeSprites {
static const String hoveringCrystal6 = "assets/images/attribute_sprites/hovering_crystal_6.png";
static const String hoveringCrystalAttack6 = "assets/images/attribute_sprites/hovering_crystal_attack_6.png";
static const String markEnemy4 = "assets/images/attribute_sprites/mark_enemy_4.png";
static const String sparkChild17 = "assets/images/attribute_sprites/spark_child_1_7.png";
}
class ImagesAssetsBackground {
static const String blank = "assets/images/background/blank.png";
static const String cave = "assets/images/background/cave.png";
static const String caveFront = "assets/images/background/caveFront.png";
static const String caveFrontEffectMask = "assets/images/background/caveFrontEffectMask.png";
static const String dungeon = "assets/images/background/dungeon.png";
static const String graveyard = "assets/images/background/graveyard.jpg";
static const String hexedForestDisplay = "assets/images/background/hexed_forest_display.png";
static const String innerRingPatterns = "assets/images/background/innerRingPatterns.png";
static const String mushroomGarden = "assets/images/background/mushroom_garden.png";
static const String outerRing = "assets/images/background/outerRing.png";
static const String outerRingPatterns = "assets/images/background/outerRingPatterns.png";
static const String previewGlare = "assets/images/background/preview_glare.jpg";
static const String testTile = "assets/images/background/test_tile.png";
}
class ImagesAssetsEffects {
static const String energy110 = "assets/images/effects/energy_1_10.png";
static const String explosion116 = "assets/images/effects/explosion_1_16.png";
static const String psychic111 = "assets/images/effects/psychic_1_11.png";
static const String star5 = "assets/images/effects/star_5.png";
}
class ImagesAssetsEnemySprites {
static const String death = "assets/images/enemy_sprites/death.png";
static const String idle = "assets/images/enemy_sprites/idle.png";
static const String run = "assets/images/enemy_sprites/run.png";
}
class ImagesAssetsMushroomBoomer {
static const String death = "assets/images/enemy_sprites/mushroomBoomer/death.png";
static const String idle = "assets/images/enemy_sprites/mushroomBoomer/idle.png";
static const String jump = "assets/images/enemy_sprites/mushroomBoomer/jump.png";
static const String land = "assets/images/enemy_sprites/mushroomBoomer/land.png";
static const String roll = "assets/images/enemy_sprites/mushroomBoomer/roll.png";
static const String run = "assets/images/enemy_sprites/mushroomBoomer/run.png";
static const String walk = "assets/images/enemy_sprites/mushroomBoomer/walk.png";
}
class ImagesAssetsMushroomBurrower {
static const String burrowIn = "assets/images/enemy_sprites/mushroomBurrower/burrow_in.png";
static const String burrowOut = "assets/images/enemy_sprites/mushroomBurrower/burrow_out.png";
static const String death = "assets/images/enemy_sprites/mushroomBurrower/death.png";
static const String idle = "assets/images/enemy_sprites/mushroomBurrower/idle.png";
static const String jump = "assets/images/enemy_sprites/mushroomBurrower/jump.png";
static const String roll = "assets/images/enemy_sprites/mushroomBurrower/roll.png";
static const String run = "assets/images/enemy_sprites/mushroomBurrower/run.png";
static const String walk = "assets/images/enemy_sprites/mushroomBurrower/walk.png";
}
class ImagesAssetsMushroomHopper {
static const String death = "assets/images/enemy_sprites/mushroomHopper/death.png";
static const String idle = "assets/images/enemy_sprites/mushroomHopper/idle.png";
static const String jump = "assets/images/enemy_sprites/mushroomHopper/jump.png";
static const String land = "assets/images/enemy_sprites/mushroomHopper/land.png";
static const String roll = "assets/images/enemy_sprites/mushroomHopper/roll.png";
static const String run = "assets/images/enemy_sprites/mushroomHopper/run.png";
static const String walk = "assets/images/enemy_sprites/mushroomHopper/walk.png";
}
class ImagesAssetsMushroomRunner {
static const String dead = "assets/images/enemy_sprites/mushroomRunner/dead.png";
static const String idle = "assets/images/enemy_sprites/mushroomRunner/idle.png";
static const String run = "assets/images/enemy_sprites/mushroomRunner/run.png";
}
class ImagesAssetsMushroomShooter {
static const String death = "assets/images/enemy_sprites/mushroomShooter/death.png";
static const String idle = "assets/images/enemy_sprites/mushroomShooter/idle.png";
static const String jump = "assets/images/enemy_sprites/mushroomShooter/jump.png";
static const String land = "assets/images/enemy_sprites/mushroomShooter/land.png";
static const String roll = "assets/images/enemy_sprites/mushroomShooter/roll.png";
static const String run = "assets/images/enemy_sprites/mushroomShooter/run.png";
static const String walk = "assets/images/enemy_sprites/mushroomShooter/walk.png";
}
class ImagesAssetsMushroomSpinner {
static const String death = "assets/images/enemy_sprites/mushroomSpinner/death.png";
static const String idle = "assets/images/enemy_sprites/mushroomSpinner/idle.png";
static const String jump = "assets/images/enemy_sprites/mushroomSpinner/jump.png";
static const String run = "assets/images/enemy_sprites/mushroomSpinner/run.png";
static const String spin = "assets/images/enemy_sprites/mushroomSpinner/spin.png";
static const String spinEnd = "assets/images/enemy_sprites/mushroomSpinner/spin_end.png";
static const String spinStart = "assets/images/enemy_sprites/mushroomSpinner/spin_start.png";
static const String walk = "assets/images/enemy_sprites/mushroomSpinner/walk.png";
}
class ImagesAssetsEntityEffects {
static const String dashEffect = "assets/images/entity_effects/dash_effect.png";
static const String jumpEffect = "assets/images/entity_effects/jump_effect.png";
}
class ImagesAssetsExpendables {
static const String blank = "assets/images/expendables/blank.png";
static const String blankAlt = "assets/images/expendables/blank_alt.png";
static const String experienceAttract = "assets/images/expendables/experience_attract.png";
static const String fearEnemies = "assets/images/expendables/fear_enemies.png";
}
class ImagesAssetsExperience {
static const String large = "assets/images/experience/large.png";
static const String medium = "assets/images/experience/medium.png";
static const String small = "assets/images/experience/small.png";
}
class ImagesAssetsPowerups {
static const String energy = "assets/images/powerups/energy.png";
static const String power = "assets/images/powerups/power.png";
static const String start = "assets/images/powerups/start.png";
}
class ImagesAssetsSecondaryIcons {
static const String blank = "assets/images/secondary_icons/blank.png";
static const String explodeProjectiles = "assets/images/secondary_icons/explode_projectiles.png";
static const String rapidFire = "assets/images/secondary_icons/rapid_fire.png";
}
class ImagesAssetsSprites {
static const String death = "assets/images/sprites/death.png";
static const String hit = "assets/images/sprites/hit.png";
static const String idle = "assets/images/sprites/idle.png";
static const String jump = "assets/images/sprites/jump.png";
static const String roll = "assets/images/sprites/roll.png";
static const String run = "assets/images/sprites/run.png";
static const String walk = "assets/images/sprites/walk.png";
}
class ImagesAssetsStatusEffects {
static const String fireEffect = "assets/images/status_effects/fire_effect.png";
}
class ImagesAssetsUi {
static const String ammo = "assets/images/ui/ammo.png";
static const String ammoEmpty = "assets/images/ui/ammo_empty.png";
static const String arrowBlack = "assets/images/ui/arrow_black.png";
static const String attributeBackground = "assets/images/ui/attribute_background.png";
static const String attributeBackgroundMask = "assets/images/ui/attribute_background_mask.png";
static const String attributeBackgroundMaskSmall = "assets/images/ui/attribute_background_mask_small.png";
static const String attributeBackgroundSmall = "assets/images/ui/attribute_background_small.png";
static const String attributeBorder = "assets/images/ui/attribute_border.png";
static const String attributeBorderSmall = "assets/images/ui/attribute_border_small.png";
static const String bag = "assets/images/ui/bag.png";
static const String banner = "assets/images/ui/banner.png";
static const String book = "assets/images/ui/book.png";
static const String bossBarBorder = "assets/images/ui/boss_bar_border.png";
static const String bossBarCenter = "assets/images/ui/boss_bar_center.png";
static const String bossBarLeft = "assets/images/ui/boss_bar_left.png";
static const String bossBarRight = "assets/images/ui/boss_bar_right.png";
static const String healthBar = "assets/images/ui/health_bar.png";
static const String levelIndicatorGunBlue = "assets/images/ui/level_indicator_gun_blue.png";
static const String levelIndicatorGunRed = "assets/images/ui/level_indicator_gun_red.png";
static const String levelIndicatorMagicBlue = "assets/images/ui/level_indicator_magic_blue.png";
static const String levelIndicatorMagicRed = "assets/images/ui/level_indicator_magic_red.png";
static const String levelIndicatorSwordBlue = "assets/images/ui/level_indicator_sword_blue.png";
static const String levelIndicatorSwordRed = "assets/images/ui/level_indicator_sword_red.png";
static const String magicHandL = "assets/images/ui/magic_hand_L.png";
static const String magicHandR = "assets/images/ui/magic_hand_R.png";
static const String magicHandSmallL = "assets/images/ui/magic_hand_small_L.png";
static const String magicHandSmallR = "assets/images/ui/magic_hand_small_R.png";
static const String padlock = "assets/images/ui/padlock.png";
static const String placeholderFace = "assets/images/ui/placeholder_face.png";
static const String plusBlue = "assets/images/ui/plus_blue.png";
static const String plusRed = "assets/images/ui/plus_red.png";
static const String weaponLevelIndicator = "assets/images/ui/weapon_level_indicator.png";
static const String xpBarBorder = "assets/images/ui/xp_bar_border.png";
static const String xpBarCenter = "assets/images/ui/xp_bar_center.png";
static const String xpBarLeft = "assets/images/ui/xp_bar_left.png";
static const String xpBarRight = "assets/images/ui/xp_bar_right.png";
}
class ImagesAssetsAmmo {
static const String ammo = "assets/images/ui/ammo/ammo.png";
static const String ammoEmpty = "assets/images/ui/ammo/ammo_empty.png";
}
class ImagesAssetsPermanentAttributes {
static const String defence = "assets/images/ui/permanent_attributes/defence.png";
static const String elemental = "assets/images/ui/permanent_attributes/elemental.png";
static const String mobility = "assets/images/ui/permanent_attributes/mobility.png";
static const String offence = "assets/images/ui/permanent_attributes/offence.png";
static const String resistance = "assets/images/ui/permanent_attributes/resistance.png";
static const String rune = "assets/images/ui/permanent_attributes/rune.png";
static const String runeLocked = "assets/images/ui/permanent_attributes/rune_locked.png";
static const String utility = "assets/images/ui/permanent_attributes/utility.png";
}
class ImagesAssetsWeapons {
static const String arcaneBlaster = "assets/images/weapons/arcane_blaster.png";
static const String bookFire = "assets/images/weapons/book_fire.png";
static const String bookIdle = "assets/images/weapons/book_idle.png";
static const String crystalSword = "assets/images/weapons/crystal_sword.png";
static const String dagger = "assets/images/weapons/dagger.png";
static const String eldritchRunner = "assets/images/weapons/eldritch_runner.png";
static const String energySword = "assets/images/weapons/energy_sword.png";
static const String fireSword = "assets/images/weapons/fire_sword.png";
static const String frostKatana = "assets/images/weapons/frost_katana.png";
static const String largeSword = "assets/images/weapons/large_sword.png";
static const String longRifle = "assets/images/weapons/long_rifle.png";
static const String longRifleAttack = "assets/images/weapons/long_rifle_attack.png";
static const String longRifleIdle = "assets/images/weapons/long_rifle_idle.png";
static const String muzzleFlash = "assets/images/weapons/muzzle_flash.png";
static const String pistol = "assets/images/weapons/pistol.png";
static const String prismaticBeam = "assets/images/weapons/prismatic_beam.png";
static const String railspire = "assets/images/weapons/railspire.png";
static const String scatterVine = "assets/images/weapons/scatter_vine.png";
static const String shotgun = "assets/images/weapons/shotgun.png";
static const String spear = "assets/images/weapons/spear.png";
static const String swordOfJustice = "assets/images/weapons/sword_of_justice.png";
}
class ImagesAssetsCharge {
static const String fireChargeCharged = "assets/images/weapons/charge/fire_charge_charged.png";
static const String fireChargeEnd = "assets/images/weapons/charge/fire_charge_end.png";
static const String fireChargePlay = "assets/images/weapons/charge/fire_charge_play.png";
static const String fireChargeSpawn = "assets/images/weapons/charge/fire_charge_spawn.png";
}
class ImagesAssetsMelee {
static const String smallCrushEffect = "assets/images/weapons/melee/small_crush_effect.png";
static const String smallSlashEffect = "assets/images/weapons/melee/small_slash_effect.png";
static const String smallStabEffect = "assets/images/weapons/melee/small_stab_effect.png";
}
class ImagesAssetsProjectiles {
static const String blackMuzzleFlash = "assets/images/weapons/projectiles/black_muzzle_flash.png";
static const String fireMuzzleFlash = "assets/images/weapons/projectiles/fire_muzzle_flash.png";
static const String magicMuzzleFlash = "assets/images/weapons/projectiles/magic_muzzle_flash.png";
}
class ImagesAssetsBlasts {
static const String fireBlastEnd = "assets/images/weapons/projectiles/blasts/fire_blast_end.png";
static const String fireBlastPlay = "assets/images/weapons/projectiles/blasts/fire_blast_play.png";
static const String fireBlastPlayAlt = "assets/images/weapons/projectiles/blasts/fire_blast_play_alt.png";
}
class ImagesAssetsBullets {
static const String blackBulletEnd = "assets/images/weapons/projectiles/bullets/black_bullet_end.png";
static const String blackBulletHit = "assets/images/weapons/projectiles/bullets/black_bullet_hit.png";
static const String blackBulletPlay = "assets/images/weapons/projectiles/bullets/black_bullet_play.png";
static const String blackBulletSpawn = "assets/images/weapons/projectiles/bullets/black_bullet_spawn.png";
static const String energyBulletEnd = "assets/images/weapons/projectiles/bullets/energy_bullet_end.png";
static const String energyBulletHit = "assets/images/weapons/projectiles/bullets/energy_bullet_hit.png";
static const String energyBulletPlay = "assets/images/weapons/projectiles/bullets/energy_bullet_play.png";
static const String energyBulletSpawn = "assets/images/weapons/projectiles/bullets/energy_bullet_spawn.png";
static const String fireBulletEnd = "assets/images/weapons/projectiles/bullets/fire_bullet_end.png";
static const String fireBulletHit = "assets/images/weapons/projectiles/bullets/fire_bullet_hit.png";
static const String fireBulletPlay = "assets/images/weapons/projectiles/bullets/fire_bullet_play.png";
static const String fireBulletSpawn = "assets/images/weapons/projectiles/bullets/fire_bullet_spawn.png";
static const String frostBulletEnd = "assets/images/weapons/projectiles/bullets/frost_bullet_end.png";
static const String frostBulletHit = "assets/images/weapons/projectiles/bullets/frost_bullet_hit.png";
static const String frostBulletPlay = "assets/images/weapons/projectiles/bullets/frost_bullet_play.png";
static const String frostBulletSpawn = "assets/images/weapons/projectiles/bullets/frost_bullet_spawn.png";
static const String healingBulletEnd = "assets/images/weapons/projectiles/bullets/healing_bullet_end.png";
static const String healingBulletHit = "assets/images/weapons/projectiles/bullets/healing_bullet_hit.png";
static const String healingBulletPlay = "assets/images/weapons/projectiles/bullets/healing_bullet_play.png";
static const String healingBulletSpawn = "assets/images/weapons/projectiles/bullets/healing_bullet_spawn.png";
static const String holyBulletPlay = "assets/images/weapons/projectiles/bullets/holy_bullet_play.png";
static const String holyBulletSpawn = "assets/images/weapons/projectiles/bullets/holy_bullet_spawn.png";
static const String magicBulletEnd = "assets/images/weapons/projectiles/bullets/magic_bullet_end.png";
static const String magicBulletHit = "assets/images/weapons/projectiles/bullets/magic_bullet_hit.png";
static const String magicBulletPlay = "assets/images/weapons/projectiles/bullets/magic_bullet_play.png";
static const String magicBulletSpawn = "assets/images/weapons/projectiles/bullets/magic_bullet_spawn.png";
static const String physicalBulletEnd = "assets/images/weapons/projectiles/bullets/physical_bullet_end.png";
static const String physicalBulletHit = "assets/images/weapons/projectiles/bullets/physical_bullet_hit.png";
static const String physicalBulletPlay = "assets/images/weapons/projectiles/bullets/physical_bullet_play.png";
static const String physicalBulletSpawn = "assets/images/weapons/projectiles/bullets/physical_bullet_spawn.png";
static const String psychicBulletEnd = "assets/images/weapons/projectiles/bullets/psychic_bullet_end.png";
static const String psychicBulletHit = "assets/images/weapons/projectiles/bullets/psychic_bullet_hit.png";
static const String psychicBulletPlay = "assets/images/weapons/projectiles/bullets/psychic_bullet_play.png";
static const String psychicBulletSpawn = "assets/images/weapons/projectiles/bullets/psychic_bullet_spawn.png";
}
class ImagesAssetsMagic {
static const String energyHit = "assets/images/weapons/projectiles/magic/energy_hit.png";
static const String energyPlay = "assets/images/weapons/projectiles/magic/energy_play.png";
static const String fireHit = "assets/images/weapons/projectiles/magic/fire_hit.png";
static const String firePlay = "assets/images/weapons/projectiles/magic/fire_play.png";
static const String firePlayBig = "assets/images/weapons/projectiles/magic/fire_play_big.png";
static const String frostHit = "assets/images/weapons/projectiles/magic/frost_hit.png";
static const String frostPlay = "assets/images/weapons/projectiles/magic/frost_play.png";
static const String frostPlayBig = "assets/images/weapons/projectiles/magic/frost_play_big.png";
static const String frostSpawn = "assets/images/weapons/projectiles/magic/frost_spawn.png";
static const String frostSpawnBig = "assets/images/weapons/projectiles/magic/frost_spawn_big.png";
static const String magicPlay = "assets/images/weapons/projectiles/magic/magic_play.png";
static const String magicPlayBig = "assets/images/weapons/projectiles/magic/magic_play_big.png";
static const String psychicHit = "assets/images/weapons/projectiles/magic/psychic_hit.png";
static const String psychicPlay = "assets/images/weapons/projectiles/magic/psychic_play.png";
static const String psychicPlayBig = "assets/images/weapons/projectiles/magic/psychic_play_big.png";
static const String psychicSpawnBig = "assets/images/weapons/projectiles/magic/psychic_spawn_big.png";
}
