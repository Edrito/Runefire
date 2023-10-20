// ignore_for_file: library_private_types_in_public_api, unused_field 
import 'package:flame/components.dart';
extension Vector2Extension on (double, double)? {Vector2 get asVector2 => this == null ? Vector2.zero() : Vector2(this!.$1, this!.$2);}
typedef FileDataClass = ({  String path,  String flamePath,  (double, double)? size,});
class AudioAssetsPowerWord {
///fall.wav
static const FileDataClass fall = 
(path:"assets/audio/sfx/magic/power_word/fall.wav",flamePath:"sfx/magic/power_word/fall.wav", size:null  );static  List<String> allFiles = [fall.path,
];
static  List<String> allFilesFlame = [fall.flamePath,
];
}
class AudioAssetsProjectile {
///laser_sound_1.mp3
static const FileDataClass laserSound1 = 
(path:"assets/audio/sfx/projectile/laser_sound_1.mp3",flamePath:"sfx/projectile/laser_sound_1.mp3", size:null  );static  List<String> allFiles = [laserSound1.path,
];
static  List<String> allFilesFlame = [laserSound1.flamePath,
];
}
class FontsAssetsFonts {
///alagard.ttf
static const FileDataClass alagard = 
(path:"assets/fonts/alagard.ttf",flamePath:"alagard.ttf", size:null  );///hero-speak.ttf
static const FileDataClass heroSpeak = 
(path:"assets/fonts/hero-speak.ttf",flamePath:"hero-speak.ttf", size:null  );///yusei-magic.ttf
static const FileDataClass yuseiMagic = 
(path:"assets/fonts/yusei-magic.ttf",flamePath:"yusei-magic.ttf", size:null  );static  List<String> allFiles = [alagard.path,
heroSpeak.path,
yuseiMagic.path,
];
static  List<String> allFilesFlame = [alagard.flamePath,
heroSpeak.flamePath,
yuseiMagic.flamePath,
];
}
class ImagesAssetsAttributes {
///attackRate.png
static const FileDataClass attackRate = 
(path:"assets/images/attributes/attackRate.png",flamePath:"attributes/attackRate.png", size:(32.0,32.0)  );///topSpeed.png
static const FileDataClass topSpeed = 
(path:"assets/images/attributes/topSpeed.png",flamePath:"attributes/topSpeed.png", size:(14.0,14.0)  );static  List<String> allFiles = [attackRate.path,
topSpeed.path,
];
static  List<String> allFilesFlame = [attackRate.flamePath,
topSpeed.flamePath,
];
}
class ImagesAssetsAttributeSprites {
///hovering_crystal_6.png
static const FileDataClass hoveringCrystal6 = 
(path:"assets/images/attribute_sprites/hovering_crystal_6.png",flamePath:"attribute_sprites/hovering_crystal_6.png", size:(768.0,128.0)  );///hovering_crystal_attack_6.png
static const FileDataClass hoveringCrystalAttack6 = 
(path:"assets/images/attribute_sprites/hovering_crystal_attack_6.png",flamePath:"attribute_sprites/hovering_crystal_attack_6.png", size:(768.0,128.0)  );///mark_enemy_4.png
static const FileDataClass markEnemy4 = 
(path:"assets/images/attribute_sprites/mark_enemy_4.png",flamePath:"attribute_sprites/mark_enemy_4.png", size:(192.0,48.0)  );///spark_child_1_7.png
static const FileDataClass sparkChild17 = 
(path:"assets/images/attribute_sprites/spark_child_1_7.png",flamePath:"attribute_sprites/spark_child_1_7.png", size:(224.0,32.0)  );static  List<String> allFiles = [hoveringCrystal6.path,
hoveringCrystalAttack6.path,
markEnemy4.path,
sparkChild17.path,
];
static  List<String> allFilesFlame = [hoveringCrystal6.flamePath,
hoveringCrystalAttack6.flamePath,
markEnemy4.flamePath,
sparkChild17.flamePath,
];
}
class ImagesAssetsBackground {
///blank.png
static const FileDataClass blank = 
(path:"assets/images/background/blank.png",flamePath:"background/blank.png", size:(50.0,50.0)  );///cave.png
static const FileDataClass cave = 
(path:"assets/images/background/cave.png",flamePath:"background/cave.png", size:(720.0,405.0)  );///caveFront.png
static const FileDataClass caveFront = 
(path:"assets/images/background/caveFront.png",flamePath:"background/caveFront.png", size:(720.0,405.0)  );///caveFrontEffectMask.png
static const FileDataClass caveFrontEffectMask = 
(path:"assets/images/background/caveFrontEffectMask.png",flamePath:"background/caveFrontEffectMask.png", size:(720.0,405.0)  );///dungeon.png
static const FileDataClass dungeon = 
(path:"assets/images/background/dungeon.png",flamePath:"background/dungeon.png", size:(618.0,333.0)  );///graveyard.jpg
static const FileDataClass graveyard = 
(path:"assets/images/background/graveyard.jpg",flamePath:"background/graveyard.jpg", size:null  );///hexed_forest_display.png
static const FileDataClass hexedForestDisplay = 
(path:"assets/images/background/hexed_forest_display.png",flamePath:"background/hexed_forest_display.png", size:(1920.0,1280.0)  );///mushroom_garden.png
static const FileDataClass mushroomGarden = 
(path:"assets/images/background/mushroom_garden.png",flamePath:"background/mushroom_garden.png", size:(3600.0,3600.0)  );///outerRing.png
static const FileDataClass outerRing = 
(path:"assets/images/background/outerRing.png",flamePath:"background/outerRing.png", size:(128.0,128.0)  );///outerRingPatterns.png
static const FileDataClass outerRingPatterns = 
(path:"assets/images/background/outerRingPatterns.png",flamePath:"background/outerRingPatterns.png", size:(100.0,100.0)  );///preview_glare.jpg
static const FileDataClass previewGlare = 
(path:"assets/images/background/preview_glare.jpg",flamePath:"background/preview_glare.jpg", size:null  );///test_tile.png
static const FileDataClass testTile = 
(path:"assets/images/background/test_tile.png",flamePath:"background/test_tile.png", size:(50.0,50.0)  );static  List<String> allFiles = [blank.path,
cave.path,
caveFront.path,
caveFrontEffectMask.path,
dungeon.path,
graveyard.path,
hexedForestDisplay.path,
mushroomGarden.path,
outerRing.path,
outerRingPatterns.path,
previewGlare.path,
testTile.path,
];
static  List<String> allFilesFlame = [blank.flamePath,
cave.flamePath,
caveFront.flamePath,
caveFrontEffectMask.flamePath,
dungeon.flamePath,
graveyard.flamePath,
hexedForestDisplay.flamePath,
mushroomGarden.flamePath,
outerRing.flamePath,
outerRingPatterns.flamePath,
previewGlare.flamePath,
testTile.flamePath,
];
}
class ImagesAssetsRunes {
///rune1.png
static const FileDataClass rune1 = 
(path:"assets/images/background/runes/rune1.png",flamePath:"background/runes/rune1.png", size:(13.0,15.0)  );///rune2.png
static const FileDataClass rune2 = 
(path:"assets/images/background/runes/rune2.png",flamePath:"background/runes/rune2.png", size:(11.0,16.0)  );///rune3.png
static const FileDataClass rune3 = 
(path:"assets/images/background/runes/rune3.png",flamePath:"background/runes/rune3.png", size:(11.0,15.0)  );///rune4.png
static const FileDataClass rune4 = 
(path:"assets/images/background/runes/rune4.png",flamePath:"background/runes/rune4.png", size:(14.0,15.0)  );///rune5.png
static const FileDataClass rune5 = 
(path:"assets/images/background/runes/rune5.png",flamePath:"background/runes/rune5.png", size:(13.0,14.0)  );///rune6.png
static const FileDataClass rune6 = 
(path:"assets/images/background/runes/rune6.png",flamePath:"background/runes/rune6.png", size:(14.0,11.0)  );///rune7.png
static const FileDataClass rune7 = 
(path:"assets/images/background/runes/rune7.png",flamePath:"background/runes/rune7.png", size:(17.0,17.0)  );///rune8.png
static const FileDataClass rune8 = 
(path:"assets/images/background/runes/rune8.png",flamePath:"background/runes/rune8.png", size:(15.0,16.0)  );static  List<String> allFiles = [rune1.path,
rune2.path,
rune3.path,
rune4.path,
rune5.path,
rune6.path,
rune7.path,
rune8.path,
];
static  List<String> allFilesFlame = [rune1.flamePath,
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
static const FileDataClass energy110 = 
(path:"assets/images/effects/energy_1_10.png",flamePath:"effects/energy_1_10.png", size:(640.0,128.0)  );///explosion_1_16.png
static const FileDataClass explosion116 = 
(path:"assets/images/effects/explosion_1_16.png",flamePath:"effects/explosion_1_16.png", size:(1024.0,64.0)  );///psychic_1_11.png
static const FileDataClass psychic111 = 
(path:"assets/images/effects/psychic_1_11.png",flamePath:"effects/psychic_1_11.png", size:(704.0,100.0)  );///star_5.png
static const FileDataClass star5 = 
(path:"assets/images/effects/star_5.png",flamePath:"effects/star_5.png", size:(80.0,16.0)  );static  List<String> allFiles = [energy110.path,
explosion116.path,
psychic111.path,
star5.path,
];
static  List<String> allFilesFlame = [energy110.flamePath,
explosion116.flamePath,
psychic111.flamePath,
star5.flamePath,
];
}
class ImagesAssetsEnemySprites {
///death.png
static const FileDataClass death = 
(path:"assets/images/enemy_sprites/death.png",flamePath:"enemy_sprites/death.png", size:(640.0,64.0)  );///ghost_hand_attack_red.png
static const FileDataClass ghostHandAttackRed = 
(path:"assets/images/enemy_sprites/ghost_hand_attack_red.png",flamePath:"enemy_sprites/ghost_hand_attack_red.png", size:(960.0,48.0)  );///idle.png
static const FileDataClass idle = 
(path:"assets/images/enemy_sprites/idle.png",flamePath:"enemy_sprites/idle.png", size:(480.0,48.0)  );///run.png
static const FileDataClass run = 
(path:"assets/images/enemy_sprites/run.png",flamePath:"enemy_sprites/run.png", size:(384.0,48.0)  );static  List<String> allFiles = [death.path,
ghostHandAttackRed.path,
idle.path,
run.path,
];
static  List<String> allFilesFlame = [death.flamePath,
ghostHandAttackRed.flamePath,
idle.flamePath,
run.flamePath,
];
}
class ImagesAssetsMushroomBoomer {
///death.png
static const FileDataClass death = 
(path:"assets/images/enemy_sprites/mushroomBoomer/death.png",flamePath:"enemy_sprites/mushroomBoomer/death.png", size:(640.0,64.0)  );///idle.png
static const FileDataClass idle = 
(path:"assets/images/enemy_sprites/mushroomBoomer/idle.png",flamePath:"enemy_sprites/mushroomBoomer/idle.png", size:(480.0,48.0)  );///jump.png
static const FileDataClass jump = 
(path:"assets/images/enemy_sprites/mushroomBoomer/jump.png",flamePath:"enemy_sprites/mushroomBoomer/jump.png", size:(144.0,48.0)  );///land.png
static const FileDataClass land = 
(path:"assets/images/enemy_sprites/mushroomBoomer/land.png",flamePath:"enemy_sprites/mushroomBoomer/land.png", size:(432.0,48.0)  );///roll.png
static const FileDataClass roll = 
(path:"assets/images/enemy_sprites/mushroomBoomer/roll.png",flamePath:"enemy_sprites/mushroomBoomer/roll.png", size:(336.0,48.0)  );///run.png
static const FileDataClass run = 
(path:"assets/images/enemy_sprites/mushroomBoomer/run.png",flamePath:"enemy_sprites/mushroomBoomer/run.png", size:(384.0,48.0)  );///walk.png
static const FileDataClass walk = 
(path:"assets/images/enemy_sprites/mushroomBoomer/walk.png",flamePath:"enemy_sprites/mushroomBoomer/walk.png", size:(384.0,48.0)  );static  List<String> allFiles = [death.path,
idle.path,
jump.path,
land.path,
roll.path,
run.path,
walk.path,
];
static  List<String> allFilesFlame = [death.flamePath,
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
static const FileDataClass burrowIn = 
(path:"assets/images/enemy_sprites/mushroomBurrower/burrow_in.png",flamePath:"enemy_sprites/mushroomBurrower/burrow_in.png", size:(432.0,48.0)  );///burrow_out.png
static const FileDataClass burrowOut = 
(path:"assets/images/enemy_sprites/mushroomBurrower/burrow_out.png",flamePath:"enemy_sprites/mushroomBurrower/burrow_out.png", size:(432.0,48.0)  );///death.png
static const FileDataClass death = 
(path:"assets/images/enemy_sprites/mushroomBurrower/death.png",flamePath:"enemy_sprites/mushroomBurrower/death.png", size:(640.0,64.0)  );///idle.png
static const FileDataClass idle = 
(path:"assets/images/enemy_sprites/mushroomBurrower/idle.png",flamePath:"enemy_sprites/mushroomBurrower/idle.png", size:(480.0,48.0)  );///jump.png
static const FileDataClass jump = 
(path:"assets/images/enemy_sprites/mushroomBurrower/jump.png",flamePath:"enemy_sprites/mushroomBurrower/jump.png", size:(144.0,48.0)  );///roll.png
static const FileDataClass roll = 
(path:"assets/images/enemy_sprites/mushroomBurrower/roll.png",flamePath:"enemy_sprites/mushroomBurrower/roll.png", size:(336.0,48.0)  );///run.png
static const FileDataClass run = 
(path:"assets/images/enemy_sprites/mushroomBurrower/run.png",flamePath:"enemy_sprites/mushroomBurrower/run.png", size:(384.0,48.0)  );///walk.png
static const FileDataClass walk = 
(path:"assets/images/enemy_sprites/mushroomBurrower/walk.png",flamePath:"enemy_sprites/mushroomBurrower/walk.png", size:(384.0,48.0)  );static  List<String> allFiles = [burrowIn.path,
burrowOut.path,
death.path,
idle.path,
jump.path,
roll.path,
run.path,
walk.path,
];
static  List<String> allFilesFlame = [burrowIn.flamePath,
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
static const FileDataClass death = 
(path:"assets/images/enemy_sprites/mushroomHopper/death.png",flamePath:"enemy_sprites/mushroomHopper/death.png", size:(640.0,64.0)  );///idle.png
static const FileDataClass idle = 
(path:"assets/images/enemy_sprites/mushroomHopper/idle.png",flamePath:"enemy_sprites/mushroomHopper/idle.png", size:(480.0,48.0)  );///jump.png
static const FileDataClass jump = 
(path:"assets/images/enemy_sprites/mushroomHopper/jump.png",flamePath:"enemy_sprites/mushroomHopper/jump.png", size:(144.0,48.0)  );///land.png
static const FileDataClass land = 
(path:"assets/images/enemy_sprites/mushroomHopper/land.png",flamePath:"enemy_sprites/mushroomHopper/land.png", size:(432.0,48.0)  );///roll.png
static const FileDataClass roll = 
(path:"assets/images/enemy_sprites/mushroomHopper/roll.png",flamePath:"enemy_sprites/mushroomHopper/roll.png", size:(336.0,48.0)  );///run.png
static const FileDataClass run = 
(path:"assets/images/enemy_sprites/mushroomHopper/run.png",flamePath:"enemy_sprites/mushroomHopper/run.png", size:(384.0,48.0)  );///walk.png
static const FileDataClass walk = 
(path:"assets/images/enemy_sprites/mushroomHopper/walk.png",flamePath:"enemy_sprites/mushroomHopper/walk.png", size:(384.0,48.0)  );static  List<String> allFiles = [death.path,
idle.path,
jump.path,
land.path,
roll.path,
run.path,
walk.path,
];
static  List<String> allFilesFlame = [death.flamePath,
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
static const FileDataClass dead = 
(path:"assets/images/enemy_sprites/mushroomRunner/dead.png",flamePath:"enemy_sprites/mushroomRunner/dead.png", size:(128.0,32.0)  );///idle.png
static const FileDataClass idle = 
(path:"assets/images/enemy_sprites/mushroomRunner/idle.png",flamePath:"enemy_sprites/mushroomRunner/idle.png", size:(64.0,32.0)  );///run.png
static const FileDataClass run = 
(path:"assets/images/enemy_sprites/mushroomRunner/run.png",flamePath:"enemy_sprites/mushroomRunner/run.png", size:(64.0,32.0)  );static  List<String> allFiles = [dead.path,
idle.path,
run.path,
];
static  List<String> allFilesFlame = [dead.flamePath,
idle.flamePath,
run.flamePath,
];
}
class ImagesAssetsMushroomShooter {
///death.png
static const FileDataClass death = 
(path:"assets/images/enemy_sprites/mushroomShooter/death.png",flamePath:"enemy_sprites/mushroomShooter/death.png", size:(640.0,64.0)  );///idle.png
static const FileDataClass idle = 
(path:"assets/images/enemy_sprites/mushroomShooter/idle.png",flamePath:"enemy_sprites/mushroomShooter/idle.png", size:(480.0,48.0)  );///jump.png
static const FileDataClass jump = 
(path:"assets/images/enemy_sprites/mushroomShooter/jump.png",flamePath:"enemy_sprites/mushroomShooter/jump.png", size:(144.0,48.0)  );///land.png
static const FileDataClass land = 
(path:"assets/images/enemy_sprites/mushroomShooter/land.png",flamePath:"enemy_sprites/mushroomShooter/land.png", size:(432.0,48.0)  );///roll.png
static const FileDataClass roll = 
(path:"assets/images/enemy_sprites/mushroomShooter/roll.png",flamePath:"enemy_sprites/mushroomShooter/roll.png", size:(336.0,48.0)  );///run.png
static const FileDataClass run = 
(path:"assets/images/enemy_sprites/mushroomShooter/run.png",flamePath:"enemy_sprites/mushroomShooter/run.png", size:(384.0,48.0)  );///walk.png
static const FileDataClass walk = 
(path:"assets/images/enemy_sprites/mushroomShooter/walk.png",flamePath:"enemy_sprites/mushroomShooter/walk.png", size:(384.0,48.0)  );static  List<String> allFiles = [death.path,
idle.path,
jump.path,
land.path,
roll.path,
run.path,
walk.path,
];
static  List<String> allFilesFlame = [death.flamePath,
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
static const FileDataClass death = 
(path:"assets/images/enemy_sprites/mushroomSpinner/death.png",flamePath:"enemy_sprites/mushroomSpinner/death.png", size:(640.0,64.0)  );///idle.png
static const FileDataClass idle = 
(path:"assets/images/enemy_sprites/mushroomSpinner/idle.png",flamePath:"enemy_sprites/mushroomSpinner/idle.png", size:(480.0,48.0)  );///jump.png
static const FileDataClass jump = 
(path:"assets/images/enemy_sprites/mushroomSpinner/jump.png",flamePath:"enemy_sprites/mushroomSpinner/jump.png", size:(144.0,48.0)  );///run.png
static const FileDataClass run = 
(path:"assets/images/enemy_sprites/mushroomSpinner/run.png",flamePath:"enemy_sprites/mushroomSpinner/run.png", size:(384.0,48.0)  );///spin.png
static const FileDataClass spin = 
(path:"assets/images/enemy_sprites/mushroomSpinner/spin.png",flamePath:"enemy_sprites/mushroomSpinner/spin.png", size:(336.0,48.0)  );///spin_end.png
static const FileDataClass spinEnd = 
(path:"assets/images/enemy_sprites/mushroomSpinner/spin_end.png",flamePath:"enemy_sprites/mushroomSpinner/spin_end.png", size:(432.0,48.0)  );///spin_start.png
static const FileDataClass spinStart = 
(path:"assets/images/enemy_sprites/mushroomSpinner/spin_start.png",flamePath:"enemy_sprites/mushroomSpinner/spin_start.png", size:(432.0,48.0)  );///walk.png
static const FileDataClass walk = 
(path:"assets/images/enemy_sprites/mushroomSpinner/walk.png",flamePath:"enemy_sprites/mushroomSpinner/walk.png", size:(384.0,48.0)  );static  List<String> allFiles = [death.path,
idle.path,
jump.path,
run.path,
spin.path,
spinEnd.path,
spinStart.path,
walk.path,
];
static  List<String> allFilesFlame = [death.flamePath,
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
static const FileDataClass dashEffect = 
(path:"assets/images/entity_effects/dash_effect.png",flamePath:"entity_effects/dash_effect.png", size:(448.0,32.0)  );///exit_arrow.png
static const FileDataClass exitArrow = 
(path:"assets/images/entity_effects/exit_arrow.png",flamePath:"entity_effects/exit_arrow.png", size:(1024.0,128.0)  );///exit_portal_blue.png
static const FileDataClass exitPortalBlue = 
(path:"assets/images/entity_effects/exit_portal_blue.png",flamePath:"entity_effects/exit_portal_blue.png", size:(512.0,128.0)  );///jump_effect.png
static const FileDataClass jumpEffect = 
(path:"assets/images/entity_effects/jump_effect.png",flamePath:"entity_effects/jump_effect.png", size:(450.0,23.0)  );static  List<String> allFiles = [dashEffect.path,
exitArrow.path,
exitPortalBlue.path,
jumpEffect.path,
];
static  List<String> allFilesFlame = [dashEffect.flamePath,
exitArrow.flamePath,
exitPortalBlue.flamePath,
jumpEffect.flamePath,
];
}
class ImagesAssetsExpendables {
///blank.png
static const FileDataClass blank = 
(path:"assets/images/expendables/blank.png",flamePath:"expendables/blank.png", size:(32.0,32.0)  );///blank_alt.png
static const FileDataClass blankAlt = 
(path:"assets/images/expendables/blank_alt.png",flamePath:"expendables/blank_alt.png", size:(32.0,32.0)  );///experience_attract.png
static const FileDataClass experienceAttract = 
(path:"assets/images/expendables/experience_attract.png",flamePath:"expendables/experience_attract.png", size:(32.0,32.0)  );///fear_enemies.png
static const FileDataClass fearEnemies = 
(path:"assets/images/expendables/fear_enemies.png",flamePath:"expendables/fear_enemies.png", size:(32.0,32.0)  );static  List<String> allFiles = [blank.path,
blankAlt.path,
experienceAttract.path,
fearEnemies.path,
];
static  List<String> allFilesFlame = [blank.flamePath,
blankAlt.flamePath,
experienceAttract.flamePath,
fearEnemies.flamePath,
];
}
class ImagesAssetsExperience {
///all.png
static const FileDataClass all = 
(path:"assets/images/experience/all.png",flamePath:"experience/all.png", size:(16.0,16.0)  );///large.png
static const FileDataClass large = 
(path:"assets/images/experience/large.png",flamePath:"experience/large.png", size:(8.0,8.0)  );///medium.png
static const FileDataClass medium = 
(path:"assets/images/experience/medium.png",flamePath:"experience/medium.png", size:(8.0,8.0)  );///small.png
static const FileDataClass small = 
(path:"assets/images/experience/small.png",flamePath:"experience/small.png", size:(8.0,8.0)  );static  List<String> allFiles = [all.path,
large.path,
medium.path,
small.path,
];
static  List<String> allFilesFlame = [all.flamePath,
large.flamePath,
medium.flamePath,
small.flamePath,
];
}
class ImagesAssetsPowerups {
///energy.png
static const FileDataClass energy = 
(path:"assets/images/powerups/energy.png",flamePath:"powerups/energy.png", size:(47.0,58.0)  );///power.png
static const FileDataClass power = 
(path:"assets/images/powerups/power.png",flamePath:"powerups/power.png", size:(54.0,63.0)  );///start.png
static const FileDataClass start = 
(path:"assets/images/powerups/start.png",flamePath:"powerups/start.png", size:(72.0,62.0)  );static  List<String> allFiles = [energy.path,
power.path,
start.path,
];
static  List<String> allFilesFlame = [energy.flamePath,
power.flamePath,
start.flamePath,
];
}
class ImagesAssetsSecondaryIcons {
///blank.png
static const FileDataClass blank = 
(path:"assets/images/secondary_icons/blank.png",flamePath:"secondary_icons/blank.png", size:(32.0,32.0)  );///explode_projectiles.png
static const FileDataClass explodeProjectiles = 
(path:"assets/images/secondary_icons/explode_projectiles.png",flamePath:"secondary_icons/explode_projectiles.png", size:(32.0,32.0)  );///rapid_fire.png
static const FileDataClass rapidFire = 
(path:"assets/images/secondary_icons/rapid_fire.png",flamePath:"secondary_icons/rapid_fire.png", size:(32.0,32.0)  );static  List<String> allFiles = [blank.path,
explodeProjectiles.path,
rapidFire.path,
];
static  List<String> allFilesFlame = [blank.flamePath,
explodeProjectiles.flamePath,
rapidFire.flamePath,
];
}
class ImagesAssetsSprites {
///death.png
static const FileDataClass death = 
(path:"assets/images/sprites/death.png",flamePath:"sprites/death.png", size:(96.0,16.0)  );///hit.png
static const FileDataClass hit = 
(path:"assets/images/sprites/hit.png",flamePath:"sprites/hit.png", size:(48.0,16.0)  );///idle.png
static const FileDataClass idle = 
(path:"assets/images/sprites/idle.png",flamePath:"sprites/idle.png", size:(96.0,96.0)  );///jump.png
static const FileDataClass jump = 
(path:"assets/images/sprites/jump.png",flamePath:"sprites/jump.png", size:(96.0,16.0)  );///roll.png
static const FileDataClass roll = 
(path:"assets/images/sprites/roll.png",flamePath:"sprites/roll.png", size:(80.0,16.0)  );///run.png
static const FileDataClass run = 
(path:"assets/images/sprites/run.png",flamePath:"sprites/run.png", size:(96.0,16.0)  );///walk.png
static const FileDataClass walk = 
(path:"assets/images/sprites/walk.png",flamePath:"sprites/walk.png", size:(384.0,48.0)  );static  List<String> allFiles = [death.path,
hit.path,
idle.path,
jump.path,
roll.path,
run.path,
walk.path,
];
static  List<String> allFilesFlame = [death.flamePath,
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
static const FileDataClass runeknightDash1 = 
(path:"assets/images/sprites/runeknight/runeknight_dash_1.png",flamePath:"sprites/runeknight/runeknight_dash_1.png", size:(288.0,48.0)  );///runeknight_death_1.png
static const FileDataClass runeknightDeath1 = 
(path:"assets/images/sprites/runeknight/runeknight_death_1.png",flamePath:"sprites/runeknight/runeknight_death_1.png", size:(384.0,48.0)  );///runeknight_hit_1.png
static const FileDataClass runeknightHit1 = 
(path:"assets/images/sprites/runeknight/runeknight_hit_1.png",flamePath:"sprites/runeknight/runeknight_hit_1.png", size:(192.0,48.0)  );///runeknight_idle_1.png
static const FileDataClass runeknightIdle1 = 
(path:"assets/images/sprites/runeknight/runeknight_idle_1.png",flamePath:"sprites/runeknight/runeknight_idle_1.png", size:(288.0,48.0)  );///runeknight_jump_1.png
static const FileDataClass runeknightJump1 = 
(path:"assets/images/sprites/runeknight/runeknight_jump_1.png",flamePath:"sprites/runeknight/runeknight_jump_1.png", size:(144.0,48.0)  );///runeknight_run_1.png
static const FileDataClass runeknightRun1 = 
(path:"assets/images/sprites/runeknight/runeknight_run_1.png",flamePath:"sprites/runeknight/runeknight_run_1.png", size:(384.0,48.0)  );static  List<String> allFiles = [runeknightDash1.path,
runeknightDeath1.path,
runeknightHit1.path,
runeknightIdle1.path,
runeknightJump1.path,
runeknightRun1.path,
];
static  List<String> allFilesFlame = [runeknightDash1.flamePath,
runeknightDeath1.flamePath,
runeknightHit1.flamePath,
runeknightIdle1.flamePath,
runeknightJump1.flamePath,
runeknightRun1.flamePath,
];
}
class ImagesAssetsStatusEffects {
///fire_effect.png
static const FileDataClass fireEffect = 
(path:"assets/images/status_effects/fire_effect.png",flamePath:"status_effects/fire_effect.png", size:(64.0,16.0)  );static  List<String> allFiles = [fireEffect.path,
];
static  List<String> allFilesFlame = [fireEffect.flamePath,
];
}
class ImagesAssetsUi {
///ammo.png
static const FileDataClass ammo = 
(path:"assets/images/ui/ammo.png",flamePath:"ui/ammo.png", size:(8.0,8.0)  );///ammo_empty.png
static const FileDataClass ammoEmpty = 
(path:"assets/images/ui/ammo_empty.png",flamePath:"ui/ammo_empty.png", size:(8.0,8.0)  );///arrow_black.png
static const FileDataClass arrowBlack = 
(path:"assets/images/ui/arrow_black.png",flamePath:"ui/arrow_black.png", size:(12.0,8.0)  );///attribute_background.png
static const FileDataClass attributeBackground = 
(path:"assets/images/ui/attribute_background.png",flamePath:"ui/attribute_background.png", size:(128.0,96.0)  );///attribute_background_mask.png
static const FileDataClass attributeBackgroundMask = 
(path:"assets/images/ui/attribute_background_mask.png",flamePath:"ui/attribute_background_mask.png", size:(128.0,96.0)  );///attribute_background_mask_small.png
static const FileDataClass attributeBackgroundMaskSmall = 
(path:"assets/images/ui/attribute_background_mask_small.png",flamePath:"ui/attribute_background_mask_small.png", size:(128.0,48.0)  );///attribute_background_small.png
static const FileDataClass attributeBackgroundSmall = 
(path:"assets/images/ui/attribute_background_small.png",flamePath:"ui/attribute_background_small.png", size:(128.0,48.0)  );///attribute_border.png
static const FileDataClass attributeBorder = 
(path:"assets/images/ui/attribute_border.png",flamePath:"ui/attribute_border.png", size:(128.0,96.0)  );///attribute_border_base.png
static const FileDataClass attributeBorderBase = 
(path:"assets/images/ui/attribute_border_base.png",flamePath:"ui/attribute_border_base.png", size:(128.0,96.0)  );///attribute_border_base_small.png
static const FileDataClass attributeBorderBaseSmall = 
(path:"assets/images/ui/attribute_border_base_small.png",flamePath:"ui/attribute_border_base_small.png", size:(128.0,48.0)  );///attribute_border_mid.png
static const FileDataClass attributeBorderMid = 
(path:"assets/images/ui/attribute_border_mid.png",flamePath:"ui/attribute_border_mid.png", size:(128.0,96.0)  );///attribute_border_mid_small.png
static const FileDataClass attributeBorderMidSmall = 
(path:"assets/images/ui/attribute_border_mid_small.png",flamePath:"ui/attribute_border_mid_small.png", size:(128.0,48.0)  );///attribute_border_small.png
static const FileDataClass attributeBorderSmall = 
(path:"assets/images/ui/attribute_border_small.png",flamePath:"ui/attribute_border_small.png", size:(128.0,48.0)  );///bag.png
static const FileDataClass bag = 
(path:"assets/images/ui/bag.png",flamePath:"ui/bag.png", size:(736.0,714.0)  );///banner.png
static const FileDataClass banner = 
(path:"assets/images/ui/banner.png",flamePath:"ui/banner.png", size:(128.0,36.0)  );///book.png
static const FileDataClass book = 
(path:"assets/images/ui/book.png",flamePath:"ui/book.png", size:(24.0,32.0)  );///boss_bar_border.png
static const FileDataClass bossBarBorder = 
(path:"assets/images/ui/boss_bar_border.png",flamePath:"ui/boss_bar_border.png", size:(16.0,8.0)  );///boss_bar_center.png
static const FileDataClass bossBarCenter = 
(path:"assets/images/ui/boss_bar_center.png",flamePath:"ui/boss_bar_center.png", size:(96.0,8.0)  );///boss_bar_left.png
static const FileDataClass bossBarLeft = 
(path:"assets/images/ui/boss_bar_left.png",flamePath:"ui/boss_bar_left.png", size:(32.0,8.0)  );///boss_bar_right.png
static const FileDataClass bossBarRight = 
(path:"assets/images/ui/boss_bar_right.png",flamePath:"ui/boss_bar_right.png", size:(32.0,8.0)  );///elemental_column.png
static const FileDataClass elementalColumn = 
(path:"assets/images/ui/elemental_column.png",flamePath:"ui/elemental_column.png", size:(32.0,96.0)  );///health_bar.png
static const FileDataClass healthBar = 
(path:"assets/images/ui/health_bar.png",flamePath:"ui/health_bar.png", size:(128.0,32.0)  );///health_bar_cap.png
static const FileDataClass healthBarCap = 
(path:"assets/images/ui/health_bar_cap.png",flamePath:"ui/health_bar_cap.png", size:(8.0,8.0)  );///health_bar_mid.png
static const FileDataClass healthBarMid = 
(path:"assets/images/ui/health_bar_mid.png",flamePath:"ui/health_bar_mid.png", size:(8.0,8.0)  );///inf.png
static const FileDataClass inf = 
(path:"assets/images/ui/inf.png",flamePath:"ui/inf.png", size:(14.0,11.0)  );///level_indicator_gun_blue.png
static const FileDataClass levelIndicatorGunBlue = 
(path:"assets/images/ui/level_indicator_gun_blue.png",flamePath:"ui/level_indicator_gun_blue.png", size:(16.0,16.0)  );///level_indicator_gun_red.png
static const FileDataClass levelIndicatorGunRed = 
(path:"assets/images/ui/level_indicator_gun_red.png",flamePath:"ui/level_indicator_gun_red.png", size:(16.0,16.0)  );///level_indicator_magic_blue.png
static const FileDataClass levelIndicatorMagicBlue = 
(path:"assets/images/ui/level_indicator_magic_blue.png",flamePath:"ui/level_indicator_magic_blue.png", size:(16.0,16.0)  );///level_indicator_magic_red.png
static const FileDataClass levelIndicatorMagicRed = 
(path:"assets/images/ui/level_indicator_magic_red.png",flamePath:"ui/level_indicator_magic_red.png", size:(16.0,16.0)  );///level_indicator_sword_blue.png
static const FileDataClass levelIndicatorSwordBlue = 
(path:"assets/images/ui/level_indicator_sword_blue.png",flamePath:"ui/level_indicator_sword_blue.png", size:(16.0,16.0)  );///level_indicator_sword_red.png
static const FileDataClass levelIndicatorSwordRed = 
(path:"assets/images/ui/level_indicator_sword_red.png",flamePath:"ui/level_indicator_sword_red.png", size:(16.0,16.0)  );///magic_bar_cap.png
static const FileDataClass magicBarCap = 
(path:"assets/images/ui/magic_bar_cap.png",flamePath:"ui/magic_bar_cap.png", size:(8.0,8.0)  );///magic_bar_mid.png
static const FileDataClass magicBarMid = 
(path:"assets/images/ui/magic_bar_mid.png",flamePath:"ui/magic_bar_mid.png", size:(8.0,8.0)  );///magic_hand_L.png
static const FileDataClass magicHandL = 
(path:"assets/images/ui/magic_hand_L.png",flamePath:"ui/magic_hand_L.png", size:(64.0,128.0)  );///magic_hand_R.png
static const FileDataClass magicHandR = 
(path:"assets/images/ui/magic_hand_R.png",flamePath:"ui/magic_hand_R.png", size:(64.0,128.0)  );///magic_hand_small_L.png
static const FileDataClass magicHandSmallL = 
(path:"assets/images/ui/magic_hand_small_L.png",flamePath:"ui/magic_hand_small_L.png", size:(32.0,64.0)  );///magic_hand_small_R.png
static const FileDataClass magicHandSmallR = 
(path:"assets/images/ui/magic_hand_small_R.png",flamePath:"ui/magic_hand_small_R.png", size:(32.0,64.0)  );///magic_icon_small.png
static const FileDataClass magicIconSmall = 
(path:"assets/images/ui/magic_icon_small.png",flamePath:"ui/magic_icon_small.png", size:(48.0,16.0)  );///melee_icon_small.png
static const FileDataClass meleeIconSmall = 
(path:"assets/images/ui/melee_icon_small.png",flamePath:"ui/melee_icon_small.png", size:(48.0,16.0)  );///padlock.png
static const FileDataClass padlock = 
(path:"assets/images/ui/padlock.png",flamePath:"ui/padlock.png", size:(32.0,32.0)  );///placeholder_face.png
static const FileDataClass placeholderFace = 
(path:"assets/images/ui/placeholder_face.png",flamePath:"ui/placeholder_face.png", size:(16.0,20.0)  );///plus_blue.png
static const FileDataClass plusBlue = 
(path:"assets/images/ui/plus_blue.png",flamePath:"ui/plus_blue.png", size:(16.0,16.0)  );///plus_red.png
static const FileDataClass plusRed = 
(path:"assets/images/ui/plus_red.png",flamePath:"ui/plus_red.png", size:(16.0,16.0)  );///ranged_icon_small.png
static const FileDataClass rangedIconSmall = 
(path:"assets/images/ui/ranged_icon_small.png",flamePath:"ui/ranged_icon_small.png", size:(48.0,16.0)  );///stamina_bar_cap.png
static const FileDataClass staminaBarCap = 
(path:"assets/images/ui/stamina_bar_cap.png",flamePath:"ui/stamina_bar_cap.png", size:(8.0,8.0)  );///stamina_bar_mid.png
static const FileDataClass staminaBarMid = 
(path:"assets/images/ui/stamina_bar_mid.png",flamePath:"ui/stamina_bar_mid.png", size:(8.0,8.0)  );///studies_head_banner.png
static const FileDataClass studiesHeadBanner = 
(path:"assets/images/ui/studies_head_banner.png",flamePath:"ui/studies_head_banner.png", size:(128.0,48.0)  );///weapon_level_indicator.png
static const FileDataClass weaponLevelIndicator = 
(path:"assets/images/ui/weapon_level_indicator.png",flamePath:"ui/weapon_level_indicator.png", size:(32.0,32.0)  );///xp_bar_border.png
static const FileDataClass xpBarBorder = 
(path:"assets/images/ui/xp_bar_border.png",flamePath:"ui/xp_bar_border.png", size:(16.0,8.0)  );///xp_bar_center.png
static const FileDataClass xpBarCenter = 
(path:"assets/images/ui/xp_bar_center.png",flamePath:"ui/xp_bar_center.png", size:(16.0,8.0)  );///xp_bar_left.png
static const FileDataClass xpBarLeft = 
(path:"assets/images/ui/xp_bar_left.png",flamePath:"ui/xp_bar_left.png", size:(16.0,8.0)  );///xp_bar_right.png
static const FileDataClass xpBarRight = 
(path:"assets/images/ui/xp_bar_right.png",flamePath:"ui/xp_bar_right.png", size:(16.0,8.0)  );static  List<String> allFiles = [ammo.path,
ammoEmpty.path,
arrowBlack.path,
attributeBackground.path,
attributeBackgroundMask.path,
attributeBackgroundMaskSmall.path,
attributeBackgroundSmall.path,
attributeBorder.path,
attributeBorderBase.path,
attributeBorderBaseSmall.path,
attributeBorderMid.path,
attributeBorderMidSmall.path,
attributeBorderSmall.path,
bag.path,
banner.path,
book.path,
bossBarBorder.path,
bossBarCenter.path,
bossBarLeft.path,
bossBarRight.path,
elementalColumn.path,
healthBar.path,
healthBarCap.path,
healthBarMid.path,
inf.path,
levelIndicatorGunBlue.path,
levelIndicatorGunRed.path,
levelIndicatorMagicBlue.path,
levelIndicatorMagicRed.path,
levelIndicatorSwordBlue.path,
levelIndicatorSwordRed.path,
magicBarCap.path,
magicBarMid.path,
magicHandL.path,
magicHandR.path,
magicHandSmallL.path,
magicHandSmallR.path,
magicIconSmall.path,
meleeIconSmall.path,
padlock.path,
placeholderFace.path,
plusBlue.path,
plusRed.path,
rangedIconSmall.path,
staminaBarCap.path,
staminaBarMid.path,
studiesHeadBanner.path,
weaponLevelIndicator.path,
xpBarBorder.path,
xpBarCenter.path,
xpBarLeft.path,
xpBarRight.path,
];
static  List<String> allFilesFlame = [ammo.flamePath,
ammoEmpty.flamePath,
arrowBlack.flamePath,
attributeBackground.flamePath,
attributeBackgroundMask.flamePath,
attributeBackgroundMaskSmall.flamePath,
attributeBackgroundSmall.flamePath,
attributeBorder.flamePath,
attributeBorderBase.flamePath,
attributeBorderBaseSmall.flamePath,
attributeBorderMid.flamePath,
attributeBorderMidSmall.flamePath,
attributeBorderSmall.flamePath,
bag.flamePath,
banner.flamePath,
book.flamePath,
bossBarBorder.flamePath,
bossBarCenter.flamePath,
bossBarLeft.flamePath,
bossBarRight.flamePath,
elementalColumn.flamePath,
healthBar.flamePath,
healthBarCap.flamePath,
healthBarMid.flamePath,
inf.flamePath,
levelIndicatorGunBlue.flamePath,
levelIndicatorGunRed.flamePath,
levelIndicatorMagicBlue.flamePath,
levelIndicatorMagicRed.flamePath,
levelIndicatorSwordBlue.flamePath,
levelIndicatorSwordRed.flamePath,
magicBarCap.flamePath,
magicBarMid.flamePath,
magicHandL.flamePath,
magicHandR.flamePath,
magicHandSmallL.flamePath,
magicHandSmallR.flamePath,
magicIconSmall.flamePath,
meleeIconSmall.flamePath,
padlock.flamePath,
placeholderFace.flamePath,
plusBlue.flamePath,
plusRed.flamePath,
rangedIconSmall.flamePath,
staminaBarCap.flamePath,
staminaBarMid.flamePath,
studiesHeadBanner.flamePath,
weaponLevelIndicator.flamePath,
xpBarBorder.flamePath,
xpBarCenter.flamePath,
xpBarLeft.flamePath,
xpBarRight.flamePath,
];
}
class ImagesAssetsAmmo {
///ammo.png
static const FileDataClass ammo = 
(path:"assets/images/ui/ammo/ammo.png",flamePath:"ui/ammo/ammo.png", size:(8.0,8.0)  );///ammo_empty.png
static const FileDataClass ammoEmpty = 
(path:"assets/images/ui/ammo/ammo_empty.png",flamePath:"ui/ammo/ammo_empty.png", size:(8.0,8.0)  );static  List<String> allFiles = [ammo.path,
ammoEmpty.path,
];
static  List<String> allFilesFlame = [ammo.flamePath,
ammoEmpty.flamePath,
];
}
class ImagesAssetsPermanentAttributes {
///defence.png
static const FileDataClass defence = 
(path:"assets/images/ui/permanent_attributes/defence.png",flamePath:"ui/permanent_attributes/defence.png", size:(10.0,13.0)  );///elemental.png
static const FileDataClass elemental = 
(path:"assets/images/ui/permanent_attributes/elemental.png",flamePath:"ui/permanent_attributes/elemental.png", size:(16.0,16.0)  );///mobility.png
static const FileDataClass mobility = 
(path:"assets/images/ui/permanent_attributes/mobility.png",flamePath:"ui/permanent_attributes/mobility.png", size:(12.0,16.0)  );///offence.png
static const FileDataClass offence = 
(path:"assets/images/ui/permanent_attributes/offence.png",flamePath:"ui/permanent_attributes/offence.png", size:(13.0,12.0)  );///resistance.png
static const FileDataClass resistance = 
(path:"assets/images/ui/permanent_attributes/resistance.png",flamePath:"ui/permanent_attributes/resistance.png", size:(13.0,15.0)  );///rune.png
static const FileDataClass rune = 
(path:"assets/images/ui/permanent_attributes/rune.png",flamePath:"ui/permanent_attributes/rune.png", size:(11.0,13.0)  );///rune_locked.png
static const FileDataClass runeLocked = 
(path:"assets/images/ui/permanent_attributes/rune_locked.png",flamePath:"ui/permanent_attributes/rune_locked.png", size:(11.0,13.0)  );///utility.png
static const FileDataClass utility = 
(path:"assets/images/ui/permanent_attributes/utility.png",flamePath:"ui/permanent_attributes/utility.png", size:(11.0,14.0)  );static  List<String> allFiles = [defence.path,
elemental.path,
mobility.path,
offence.path,
resistance.path,
rune.path,
runeLocked.path,
utility.path,
];
static  List<String> allFilesFlame = [defence.flamePath,
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
static const FileDataClass arcaneBlaster = 
(path:"assets/images/weapons/arcane_blaster.png",flamePath:"weapons/arcane_blaster.png", size:(33.0,79.0)  );///book_fire.png
static const FileDataClass bookFire = 
(path:"assets/images/weapons/book_fire.png",flamePath:"weapons/book_fire.png", size:(63.0,32.0)  );///book_idle.png
static const FileDataClass bookIdle = 
(path:"assets/images/weapons/book_idle.png",flamePath:"weapons/book_idle.png", size:(62.0,41.0)  );///crystal_sword.png
static const FileDataClass crystalSword = 
(path:"assets/images/weapons/crystal_sword.png",flamePath:"weapons/crystal_sword.png", size:(35.0,114.0)  );///dagger.png
static const FileDataClass dagger = 
(path:"assets/images/weapons/dagger.png",flamePath:"weapons/dagger.png", size:(22.0,51.0)  );///eldritch_runner.png
static const FileDataClass eldritchRunner = 
(path:"assets/images/weapons/eldritch_runner.png",flamePath:"weapons/eldritch_runner.png", size:(43.0,86.0)  );///energy_sword.png
static const FileDataClass energySword = 
(path:"assets/images/weapons/energy_sword.png",flamePath:"weapons/energy_sword.png", size:(54.0,142.0)  );///fire_sword.png
static const FileDataClass fireSword = 
(path:"assets/images/weapons/fire_sword.png",flamePath:"weapons/fire_sword.png", size:(42.0,103.0)  );///frost_katana.png
static const FileDataClass frostKatana = 
(path:"assets/images/weapons/frost_katana.png",flamePath:"weapons/frost_katana.png", size:(28.0,152.0)  );///holy_sword_idle.png
static const FileDataClass holySwordIdle = 
(path:"assets/images/weapons/holy_sword_idle.png",flamePath:"weapons/holy_sword_idle.png", size:(162.0,142.0)  );///large_sword.png
static const FileDataClass largeSword = 
(path:"assets/images/weapons/large_sword.png",flamePath:"weapons/large_sword.png", size:(26.0,90.0)  );///long_rifle.png
static const FileDataClass longRifle = 
(path:"assets/images/weapons/long_rifle.png",flamePath:"weapons/long_rifle.png", size:(64.0,128.0)  );///long_rifle_attack.png
static const FileDataClass longRifleAttack = 
(path:"assets/images/weapons/long_rifle_attack.png",flamePath:"weapons/long_rifle_attack.png", size:(192.0,64.0)  );///long_rifle_idle.png
static const FileDataClass longRifleIdle = 
(path:"assets/images/weapons/long_rifle_idle.png",flamePath:"weapons/long_rifle_idle.png", size:(608.0,64.0)  );///muzzle_flash.png
static const FileDataClass muzzleFlash = 
(path:"assets/images/weapons/muzzle_flash.png",flamePath:"weapons/muzzle_flash.png", size:(32.0,32.0)  );///pistol.png
static const FileDataClass pistol = 
(path:"assets/images/weapons/pistol.png",flamePath:"weapons/pistol.png", size:(28.0,44.0)  );///prismatic_beam.png
static const FileDataClass prismaticBeam = 
(path:"assets/images/weapons/prismatic_beam.png",flamePath:"weapons/prismatic_beam.png", size:(32.0,74.0)  );///railspire.png
static const FileDataClass railspire = 
(path:"assets/images/weapons/railspire.png",flamePath:"weapons/railspire.png", size:(36.0,89.0)  );///scatter_vine.png
static const FileDataClass scatterVine = 
(path:"assets/images/weapons/scatter_vine.png",flamePath:"weapons/scatter_vine.png", size:(18.0,102.0)  );///shotgun.png
static const FileDataClass shotgun = 
(path:"assets/images/weapons/shotgun.png",flamePath:"weapons/shotgun.png", size:(189.0,365.0)  );///spear.png
static const FileDataClass spear = 
(path:"assets/images/weapons/spear.png",flamePath:"weapons/spear.png", size:(15.0,152.0)  );///sword_of_justice.png
static const FileDataClass swordOfJustice = 
(path:"assets/images/weapons/sword_of_justice.png",flamePath:"weapons/sword_of_justice.png", size:(46.0,135.0)  );static  List<String> allFiles = [arcaneBlaster.path,
bookFire.path,
bookIdle.path,
crystalSword.path,
dagger.path,
eldritchRunner.path,
energySword.path,
fireSword.path,
frostKatana.path,
holySwordIdle.path,
largeSword.path,
longRifle.path,
longRifleAttack.path,
longRifleIdle.path,
muzzleFlash.path,
pistol.path,
prismaticBeam.path,
railspire.path,
scatterVine.path,
shotgun.path,
spear.path,
swordOfJustice.path,
];
static  List<String> allFilesFlame = [arcaneBlaster.flamePath,
bookFire.flamePath,
bookIdle.flamePath,
crystalSword.flamePath,
dagger.flamePath,
eldritchRunner.flamePath,
energySword.flamePath,
fireSword.flamePath,
frostKatana.flamePath,
holySwordIdle.flamePath,
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
static const FileDataClass fireChargeCharged = 
(path:"assets/images/weapons/charge/fire_charge_charged.png",flamePath:"weapons/charge/fire_charge_charged.png", size:(192.0,32.0)  );///fire_charge_end.png
static const FileDataClass fireChargeEnd = 
(path:"assets/images/weapons/charge/fire_charge_end.png",flamePath:"weapons/charge/fire_charge_end.png", size:(64.0,16.0)  );///fire_charge_play.png
static const FileDataClass fireChargePlay = 
(path:"assets/images/weapons/charge/fire_charge_play.png",flamePath:"weapons/charge/fire_charge_play.png", size:(48.0,16.0)  );///fire_charge_spawn.png
static const FileDataClass fireChargeSpawn = 
(path:"assets/images/weapons/charge/fire_charge_spawn.png",flamePath:"weapons/charge/fire_charge_spawn.png", size:(80.0,16.0)  );static  List<String> allFiles = [fireChargeCharged.path,
fireChargeEnd.path,
fireChargePlay.path,
fireChargeSpawn.path,
];
static  List<String> allFilesFlame = [fireChargeCharged.flamePath,
fireChargeEnd.flamePath,
fireChargePlay.flamePath,
fireChargeSpawn.flamePath,
];
}
class ImagesAssetsMelee {
///scratch_1.png
static const FileDataClass scratch1 = 
(path:"assets/images/weapons/melee/scratch_1.png",flamePath:"weapons/melee/scratch_1.png", size:(96.0,16.0)  );///small_crush_effect.png
static const FileDataClass smallCrushEffect = 
(path:"assets/images/weapons/melee/small_crush_effect.png",flamePath:"weapons/melee/small_crush_effect.png", size:(104.0,53.0)  );///small_slash_effect.png
static const FileDataClass smallSlashEffect = 
(path:"assets/images/weapons/melee/small_slash_effect.png",flamePath:"weapons/melee/small_slash_effect.png", size:(154.0,16.0)  );///small_stab_effect.png
static const FileDataClass smallStabEffect = 
(path:"assets/images/weapons/melee/small_stab_effect.png",flamePath:"weapons/melee/small_stab_effect.png", size:(164.0,36.0)  );static  List<String> allFiles = [scratch1.path,
smallCrushEffect.path,
smallSlashEffect.path,
smallStabEffect.path,
];
static  List<String> allFilesFlame = [scratch1.flamePath,
smallCrushEffect.flamePath,
smallSlashEffect.flamePath,
smallStabEffect.flamePath,
];
}
class ImagesAssetsProjectiles {
///black_muzzle_flash.png
static const FileDataClass blackMuzzleFlash = 
(path:"assets/images/weapons/projectiles/black_muzzle_flash.png",flamePath:"weapons/projectiles/black_muzzle_flash.png", size:(80.0,48.0)  );///fire_muzzle_flash.png
static const FileDataClass fireMuzzleFlash = 
(path:"assets/images/weapons/projectiles/fire_muzzle_flash.png",flamePath:"weapons/projectiles/fire_muzzle_flash.png", size:(80.0,48.0)  );///magic_muzzle_flash.png
static const FileDataClass magicMuzzleFlash = 
(path:"assets/images/weapons/projectiles/magic_muzzle_flash.png",flamePath:"weapons/projectiles/magic_muzzle_flash.png", size:(80.0,48.0)  );static  List<String> allFiles = [blackMuzzleFlash.path,
fireMuzzleFlash.path,
magicMuzzleFlash.path,
];
static  List<String> allFilesFlame = [blackMuzzleFlash.flamePath,
fireMuzzleFlash.flamePath,
magicMuzzleFlash.flamePath,
];
}
class ImagesAssetsBlasts {
///fire_blast_end.png
static const FileDataClass fireBlastEnd = 
(path:"assets/images/weapons/projectiles/blasts/fire_blast_end.png",flamePath:"weapons/projectiles/blasts/fire_blast_end.png", size:(128.0,32.0)  );///fire_blast_play.png
static const FileDataClass fireBlastPlay = 
(path:"assets/images/weapons/projectiles/blasts/fire_blast_play.png",flamePath:"weapons/projectiles/blasts/fire_blast_play.png", size:(128.0,32.0)  );///fire_blast_play_alt.png
static const FileDataClass fireBlastPlayAlt = 
(path:"assets/images/weapons/projectiles/blasts/fire_blast_play_alt.png",flamePath:"weapons/projectiles/blasts/fire_blast_play_alt.png", size:(128.0,32.0)  );static  List<String> allFiles = [fireBlastEnd.path,
fireBlastPlay.path,
fireBlastPlayAlt.path,
];
static  List<String> allFilesFlame = [fireBlastEnd.flamePath,
fireBlastPlay.flamePath,
fireBlastPlayAlt.flamePath,
];
}
class ImagesAssetsBullets {
///black_bullet_end.png
static const FileDataClass blackBulletEnd = 
(path:"assets/images/weapons/projectiles/bullets/black_bullet_end.png",flamePath:"weapons/projectiles/bullets/black_bullet_end.png", size:(48.0,16.0)  );///black_bullet_hit.png
static const FileDataClass blackBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/black_bullet_hit.png",flamePath:"weapons/projectiles/bullets/black_bullet_hit.png", size:(246.0,36.0)  );///black_bullet_play.png
static const FileDataClass blackBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/black_bullet_play.png",flamePath:"weapons/projectiles/bullets/black_bullet_play.png", size:(64.0,16.0)  );///black_bullet_spawn.png
static const FileDataClass blackBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/black_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/black_bullet_spawn.png", size:(64.0,16.0)  );///energy_bullet_end.png
static const FileDataClass energyBulletEnd = 
(path:"assets/images/weapons/projectiles/bullets/energy_bullet_end.png",flamePath:"weapons/projectiles/bullets/energy_bullet_end.png", size:(48.0,16.0)  );///energy_bullet_hit.png
static const FileDataClass energyBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/energy_bullet_hit.png",flamePath:"weapons/projectiles/bullets/energy_bullet_hit.png", size:(96.0,16.0)  );///energy_bullet_play.png
static const FileDataClass energyBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/energy_bullet_play.png",flamePath:"weapons/projectiles/bullets/energy_bullet_play.png", size:(64.0,16.0)  );///energy_bullet_spawn.png
static const FileDataClass energyBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/energy_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/energy_bullet_spawn.png", size:(64.0,16.0)  );///fire_bullet_end.png
static const FileDataClass fireBulletEnd = 
(path:"assets/images/weapons/projectiles/bullets/fire_bullet_end.png",flamePath:"weapons/projectiles/bullets/fire_bullet_end.png", size:(48.0,16.0)  );///fire_bullet_hit.png
static const FileDataClass fireBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/fire_bullet_hit.png",flamePath:"weapons/projectiles/bullets/fire_bullet_hit.png", size:(96.0,16.0)  );///fire_bullet_play.png
static const FileDataClass fireBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/fire_bullet_play.png",flamePath:"weapons/projectiles/bullets/fire_bullet_play.png", size:(64.0,16.0)  );///fire_bullet_spawn.png
static const FileDataClass fireBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/fire_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/fire_bullet_spawn.png", size:(64.0,16.0)  );///frost_bullet_end.png
static const FileDataClass frostBulletEnd = 
(path:"assets/images/weapons/projectiles/bullets/frost_bullet_end.png",flamePath:"weapons/projectiles/bullets/frost_bullet_end.png", size:(48.0,16.0)  );///frost_bullet_hit.png
static const FileDataClass frostBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/frost_bullet_hit.png",flamePath:"weapons/projectiles/bullets/frost_bullet_hit.png", size:(96.0,16.0)  );///frost_bullet_play.png
static const FileDataClass frostBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/frost_bullet_play.png",flamePath:"weapons/projectiles/bullets/frost_bullet_play.png", size:(64.0,16.0)  );///frost_bullet_spawn.png
static const FileDataClass frostBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/frost_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/frost_bullet_spawn.png", size:(64.0,16.0)  );///healing_bullet_end.png
static const FileDataClass healingBulletEnd = 
(path:"assets/images/weapons/projectiles/bullets/healing_bullet_end.png",flamePath:"weapons/projectiles/bullets/healing_bullet_end.png", size:(48.0,16.0)  );///healing_bullet_hit.png
static const FileDataClass healingBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/healing_bullet_hit.png",flamePath:"weapons/projectiles/bullets/healing_bullet_hit.png", size:(96.0,16.0)  );///healing_bullet_play.png
static const FileDataClass healingBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/healing_bullet_play.png",flamePath:"weapons/projectiles/bullets/healing_bullet_play.png", size:(64.0,16.0)  );///healing_bullet_spawn.png
static const FileDataClass healingBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/healing_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/healing_bullet_spawn.png", size:(64.0,16.0)  );///holy_bullet_play.png
static const FileDataClass holyBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/holy_bullet_play.png",flamePath:"weapons/projectiles/bullets/holy_bullet_play.png", size:(45.0,101.0)  );///holy_bullet_spawn.png
static const FileDataClass holyBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/holy_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/holy_bullet_spawn.png", size:(45.0,101.0)  );///magic_bullet_end.png
static const FileDataClass magicBulletEnd = 
(path:"assets/images/weapons/projectiles/bullets/magic_bullet_end.png",flamePath:"weapons/projectiles/bullets/magic_bullet_end.png", size:(48.0,16.0)  );///magic_bullet_hit.png
static const FileDataClass magicBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/magic_bullet_hit.png",flamePath:"weapons/projectiles/bullets/magic_bullet_hit.png", size:(96.0,16.0)  );///magic_bullet_play.png
static const FileDataClass magicBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/magic_bullet_play.png",flamePath:"weapons/projectiles/bullets/magic_bullet_play.png", size:(64.0,16.0)  );///magic_bullet_spawn.png
static const FileDataClass magicBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/magic_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/magic_bullet_spawn.png", size:(64.0,16.0)  );///physical_bullet_end.png
static const FileDataClass physicalBulletEnd = 
(path:"assets/images/weapons/projectiles/bullets/physical_bullet_end.png",flamePath:"weapons/projectiles/bullets/physical_bullet_end.png", size:(48.0,16.0)  );///physical_bullet_hit.png
static const FileDataClass physicalBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/physical_bullet_hit.png",flamePath:"weapons/projectiles/bullets/physical_bullet_hit.png", size:(96.0,16.0)  );///physical_bullet_play.png
static const FileDataClass physicalBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/physical_bullet_play.png",flamePath:"weapons/projectiles/bullets/physical_bullet_play.png", size:(64.0,16.0)  );///physical_bullet_spawn.png
static const FileDataClass physicalBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/physical_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/physical_bullet_spawn.png", size:(64.0,16.0)  );///psychic_bullet_end.png
static const FileDataClass psychicBulletEnd = 
(path:"assets/images/weapons/projectiles/bullets/psychic_bullet_end.png",flamePath:"weapons/projectiles/bullets/psychic_bullet_end.png", size:(48.0,16.0)  );///psychic_bullet_hit.png
static const FileDataClass psychicBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/psychic_bullet_hit.png",flamePath:"weapons/projectiles/bullets/psychic_bullet_hit.png", size:(96.0,16.0)  );///psychic_bullet_play.png
static const FileDataClass psychicBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/psychic_bullet_play.png",flamePath:"weapons/projectiles/bullets/psychic_bullet_play.png", size:(64.0,16.0)  );///psychic_bullet_spawn.png
static const FileDataClass psychicBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/psychic_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/psychic_bullet_spawn.png", size:(64.0,16.0)  );static  List<String> allFiles = [blackBulletEnd.path,
blackBulletHit.path,
blackBulletPlay.path,
blackBulletSpawn.path,
energyBulletEnd.path,
energyBulletHit.path,
energyBulletPlay.path,
energyBulletSpawn.path,
fireBulletEnd.path,
fireBulletHit.path,
fireBulletPlay.path,
fireBulletSpawn.path,
frostBulletEnd.path,
frostBulletHit.path,
frostBulletPlay.path,
frostBulletSpawn.path,
healingBulletEnd.path,
healingBulletHit.path,
healingBulletPlay.path,
healingBulletSpawn.path,
holyBulletPlay.path,
holyBulletSpawn.path,
magicBulletEnd.path,
magicBulletHit.path,
magicBulletPlay.path,
magicBulletSpawn.path,
physicalBulletEnd.path,
physicalBulletHit.path,
physicalBulletPlay.path,
physicalBulletSpawn.path,
psychicBulletEnd.path,
psychicBulletHit.path,
psychicBulletPlay.path,
psychicBulletSpawn.path,
];
static  List<String> allFilesFlame = [blackBulletEnd.flamePath,
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
static const FileDataClass energyHit = 
(path:"assets/images/weapons/projectiles/magic/energy_hit.png",flamePath:"weapons/projectiles/magic/energy_hit.png", size:(128.0,32.0)  );///energy_play.png
static const FileDataClass energyPlay = 
(path:"assets/images/weapons/projectiles/magic/energy_play.png",flamePath:"weapons/projectiles/magic/energy_play.png", size:(288.0,71.0)  );///fire_hit.png
static const FileDataClass fireHit = 
(path:"assets/images/weapons/projectiles/magic/fire_hit.png",flamePath:"weapons/projectiles/magic/fire_hit.png", size:(128.0,32.0)  );///fire_play.png
static const FileDataClass firePlay = 
(path:"assets/images/weapons/projectiles/magic/fire_play.png",flamePath:"weapons/projectiles/magic/fire_play.png", size:(52.0,48.0)  );///fire_play_big.png
static const FileDataClass firePlayBig = 
(path:"assets/images/weapons/projectiles/magic/fire_play_big.png",flamePath:"weapons/projectiles/magic/fire_play_big.png", size:(64.0,32.0)  );///frost_hit.png
static const FileDataClass frostHit = 
(path:"assets/images/weapons/projectiles/magic/frost_hit.png",flamePath:"weapons/projectiles/magic/frost_hit.png", size:(576.0,96.0)  );///frost_play.png
static const FileDataClass frostPlay = 
(path:"assets/images/weapons/projectiles/magic/frost_play.png",flamePath:"weapons/projectiles/magic/frost_play.png", size:(48.0,32.0)  );///frost_play_big.png
static const FileDataClass frostPlayBig = 
(path:"assets/images/weapons/projectiles/magic/frost_play_big.png",flamePath:"weapons/projectiles/magic/frost_play_big.png", size:(48.0,32.0)  );///frost_spawn.png
static const FileDataClass frostSpawn = 
(path:"assets/images/weapons/projectiles/magic/frost_spawn.png",flamePath:"weapons/projectiles/magic/frost_spawn.png", size:(48.0,32.0)  );///frost_spawn_big.png
static const FileDataClass frostSpawnBig = 
(path:"assets/images/weapons/projectiles/magic/frost_spawn_big.png",flamePath:"weapons/projectiles/magic/frost_spawn_big.png", size:(48.0,32.0)  );///magic_play.png
static const FileDataClass magicPlay = 
(path:"assets/images/weapons/projectiles/magic/magic_play.png",flamePath:"weapons/projectiles/magic/magic_play.png", size:(288.0,32.0)  );///magic_play_big.png
static const FileDataClass magicPlayBig = 
(path:"assets/images/weapons/projectiles/magic/magic_play_big.png",flamePath:"weapons/projectiles/magic/magic_play_big.png", size:(1152.0,128.0)  );///psychic_hit.png
static const FileDataClass psychicHit = 
(path:"assets/images/weapons/projectiles/magic/psychic_hit.png",flamePath:"weapons/projectiles/magic/psychic_hit.png", size:(80.0,16.0)  );///psychic_play.png
static const FileDataClass psychicPlay = 
(path:"assets/images/weapons/projectiles/magic/psychic_play.png",flamePath:"weapons/projectiles/magic/psychic_play.png", size:(128.0,32.0)  );///psychic_play_big.png
static const FileDataClass psychicPlayBig = 
(path:"assets/images/weapons/projectiles/magic/psychic_play_big.png",flamePath:"weapons/projectiles/magic/psychic_play_big.png", size:(64.0,16.0)  );///psychic_spawn_big.png
static const FileDataClass psychicSpawnBig = 
(path:"assets/images/weapons/projectiles/magic/psychic_spawn_big.png",flamePath:"weapons/projectiles/magic/psychic_spawn_big.png", size:(96.0,16.0)  );static  List<String> allFiles = [energyHit.path,
energyPlay.path,
fireHit.path,
firePlay.path,
firePlayBig.path,
frostHit.path,
frostPlay.path,
frostPlayBig.path,
frostSpawn.path,
frostSpawnBig.path,
magicPlay.path,
magicPlayBig.path,
psychicHit.path,
psychicPlay.path,
psychicPlayBig.path,
psychicSpawnBig.path,
];
static  List<String> allFilesFlame = [energyHit.flamePath,
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
