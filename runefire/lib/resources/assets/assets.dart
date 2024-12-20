// ignore_for_file: library_private_types_in_public_api, unused_field 
import 'package:flame/components.dart';
extension Vector2Extension on (double, double)? {Vector2 get asVector2 => this == null ? Vector2.zero() : Vector2(this!.$1, this!.$2);}
typedef FileDataClass = ({  String path,  String flamePath,  (double, double)? size,int? potentialFrameCount} );
class AudioAssetsPowerWord {
///fall.wav
static const FileDataClass fall = 
(path:"assets/audio/sfx/magic/power_word/fall.wav",flamePath:"sfx/magic/power_word/fall.wav", size:null,
 potentialFrameCount:null   );static  List<String> allFiles = [fall.path,
];
static  List<String> allFilesFlame = [fall.flamePath,
];
}
class AudioAssetsProjectile {
///laser_sound_1.mp3
static const FileDataClass laserSound1 = 
(path:"assets/audio/sfx/projectile/laser_sound_1.mp3",flamePath:"sfx/projectile/laser_sound_1.mp3", size:null,
 potentialFrameCount:null   );static  List<String> allFiles = [laserSound1.path,
];
static  List<String> allFilesFlame = [laserSound1.flamePath,
];
}
class FontsAssetsFonts {
///alagard.ttf
static const FileDataClass alagard = 
(path:"assets/fonts/alagard.ttf",flamePath:"alagard.ttf", size:null,
 potentialFrameCount:null   );///hero-speak.ttf
static const FileDataClass heroSpeak = 
(path:"assets/fonts/hero-speak.ttf",flamePath:"hero-speak.ttf", size:null,
 potentialFrameCount:null   );///yusei-magic.ttf
static const FileDataClass yuseiMagic = 
(path:"assets/fonts/yusei-magic.ttf",flamePath:"yusei-magic.ttf", size:null,
 potentialFrameCount:null   );static  List<String> allFiles = [alagard.path,
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
(path:"assets/images/attributes/attackRate.png",flamePath:"attributes/attackRate.png", size:(32.0,32.0),
 potentialFrameCount:1   );///standard.png
static const FileDataClass standard = 
(path:"assets/images/attributes/standard.png",flamePath:"attributes/standard.png", size:(32.0,32.0),
 potentialFrameCount:1   );///topSpeed.png
static const FileDataClass topSpeed = 
(path:"assets/images/attributes/topSpeed.png",flamePath:"attributes/topSpeed.png", size:(14.0,14.0),
 potentialFrameCount:1   );static  List<String> allFiles = [attackRate.path,
standard.path,
topSpeed.path,
];
static  List<String> allFilesFlame = [attackRate.flamePath,
standard.flamePath,
topSpeed.flamePath,
];
}
class ImagesAssetsAttributeSprites {
///hovering_crystal_6.png
static const FileDataClass hoveringCrystal6 = 
(path:"assets/images/attribute_sprites/hovering_crystal_6.png",flamePath:"attribute_sprites/hovering_crystal_6.png", size:(768.0,128.0),
 potentialFrameCount:6   );///hovering_crystal_attack_6.png
static const FileDataClass hoveringCrystalAttack6 = 
(path:"assets/images/attribute_sprites/hovering_crystal_attack_6.png",flamePath:"attribute_sprites/hovering_crystal_attack_6.png", size:(768.0,128.0),
 potentialFrameCount:6   );///mark_enemy_4.png
static const FileDataClass markEnemy4 = 
(path:"assets/images/attribute_sprites/mark_enemy_4.png",flamePath:"attribute_sprites/mark_enemy_4.png", size:(96.0,24.0),
 potentialFrameCount:4   );///spark_child_1_7.png
static const FileDataClass sparkChild17 = 
(path:"assets/images/attribute_sprites/spark_child_1_7.png",flamePath:"attribute_sprites/spark_child_1_7.png", size:(224.0,32.0),
 potentialFrameCount:7   );static  List<String> allFiles = [hoveringCrystal6.path,
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
(path:"assets/images/background/blank.png",flamePath:"background/blank.png", size:(50.0,50.0),
 potentialFrameCount:1   );///cave.png
static const FileDataClass cave = 
(path:"assets/images/background/cave.png",flamePath:"background/cave.png", size:(720.0,405.0),
 potentialFrameCount:2   );///caveFront.png
static const FileDataClass caveFront = 
(path:"assets/images/background/caveFront.png",flamePath:"background/caveFront.png", size:(720.0,405.0),
 potentialFrameCount:2   );///caveFrontEffectMask.png
static const FileDataClass caveFrontEffectMask = 
(path:"assets/images/background/caveFrontEffectMask.png",flamePath:"background/caveFrontEffectMask.png", size:(720.0,405.0),
 potentialFrameCount:2   );///dungeon.png
static const FileDataClass dungeon = 
(path:"assets/images/background/dungeon.png",flamePath:"background/dungeon.png", size:(618.0,333.0),
 potentialFrameCount:2   );///graveyard.jpg
static const FileDataClass graveyard = 
(path:"assets/images/background/graveyard.jpg",flamePath:"background/graveyard.jpg", size:null,
 potentialFrameCount:null   );///hexed_forest_display.png
static const FileDataClass hexedForestDisplay = 
(path:"assets/images/background/hexed_forest_display.png",flamePath:"background/hexed_forest_display.png", size:(3600.0,3600.0),
 potentialFrameCount:1   );///mushroom_garden.png
static const FileDataClass mushroomGarden = 
(path:"assets/images/background/mushroom_garden.png",flamePath:"background/mushroom_garden.png", size:(3600.0,3600.0),
 potentialFrameCount:1   );///mushroom_spore.png
static const FileDataClass mushroomSpore = 
(path:"assets/images/background/mushroom_spore.png",flamePath:"background/mushroom_spore.png", size:(64.0,32.0),
 potentialFrameCount:2   );///outerRing.png
static const FileDataClass outerRing = 
(path:"assets/images/background/outerRing.png",flamePath:"background/outerRing.png", size:(128.0,128.0),
 potentialFrameCount:1   );///outerRingPatterns.png
static const FileDataClass outerRingPatterns = 
(path:"assets/images/background/outerRingPatterns.png",flamePath:"background/outerRingPatterns.png", size:(100.0,100.0),
 potentialFrameCount:1   );static  List<String> allFiles = [blank.path,
cave.path,
caveFront.path,
caveFrontEffectMask.path,
dungeon.path,
graveyard.path,
hexedForestDisplay.path,
mushroomGarden.path,
mushroomSpore.path,
outerRing.path,
outerRingPatterns.path,
];
static  List<String> allFilesFlame = [blank.flamePath,
cave.flamePath,
caveFront.flamePath,
caveFrontEffectMask.flamePath,
dungeon.flamePath,
graveyard.flamePath,
hexedForestDisplay.flamePath,
mushroomGarden.flamePath,
mushroomSpore.flamePath,
outerRing.flamePath,
outerRingPatterns.flamePath,
];
}
class ImagesAssetsRunes {
///rune1.png
static const FileDataClass rune1 = 
(path:"assets/images/background/runes/rune1.png",flamePath:"background/runes/rune1.png", size:(13.0,15.0),
 potentialFrameCount:1   );///rune2.png
static const FileDataClass rune2 = 
(path:"assets/images/background/runes/rune2.png",flamePath:"background/runes/rune2.png", size:(11.0,16.0),
 potentialFrameCount:1   );///rune3.png
static const FileDataClass rune3 = 
(path:"assets/images/background/runes/rune3.png",flamePath:"background/runes/rune3.png", size:(11.0,15.0),
 potentialFrameCount:1   );///rune4.png
static const FileDataClass rune4 = 
(path:"assets/images/background/runes/rune4.png",flamePath:"background/runes/rune4.png", size:(14.0,15.0),
 potentialFrameCount:1   );///rune5.png
static const FileDataClass rune5 = 
(path:"assets/images/background/runes/rune5.png",flamePath:"background/runes/rune5.png", size:(13.0,14.0),
 potentialFrameCount:1   );///rune6.png
static const FileDataClass rune6 = 
(path:"assets/images/background/runes/rune6.png",flamePath:"background/runes/rune6.png", size:(14.0,11.0),
 potentialFrameCount:1   );///rune7.png
static const FileDataClass rune7 = 
(path:"assets/images/background/runes/rune7.png",flamePath:"background/runes/rune7.png", size:(17.0,17.0),
 potentialFrameCount:1   );///rune8.png
static const FileDataClass rune8 = 
(path:"assets/images/background/runes/rune8.png",flamePath:"background/runes/rune8.png", size:(15.0,16.0),
 potentialFrameCount:1   );static  List<String> allFiles = [rune1.path,
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
///brown_default_area_effect_11.png
static const FileDataClass brownDefaultAreaEffect11 = 
(path:"assets/images/effects/brown_default_area_effect_11.png",flamePath:"effects/brown_default_area_effect_11.png", size:(1100.0,100.0),
 potentialFrameCount:11   );///default_area_effect_11.png
static const FileDataClass defaultAreaEffect11 = 
(path:"assets/images/effects/default_area_effect_11.png",flamePath:"effects/default_area_effect_11.png", size:(1100.0,100.0),
 potentialFrameCount:11   );///energy_1_10.png
static const FileDataClass energy110 = 
(path:"assets/images/effects/energy_1_10.png",flamePath:"effects/energy_1_10.png", size:(640.0,128.0),
 potentialFrameCount:5   );///energy_orb_1_18.png
static const FileDataClass energyOrb118 = 
(path:"assets/images/effects/energy_orb_1_18.png",flamePath:"effects/energy_orb_1_18.png", size:(864.0,48.0),
 potentialFrameCount:18   );///explosion_1_16.png
static const FileDataClass explosion116 = 
(path:"assets/images/effects/explosion_1_16.png",flamePath:"effects/explosion_1_16.png", size:(1024.0,64.0),
 potentialFrameCount:16   );///fire_orb_1_18.png
static const FileDataClass fireOrb118 = 
(path:"assets/images/effects/fire_orb_1_18.png",flamePath:"effects/fire_orb_1_18.png", size:(864.0,48.0),
 potentialFrameCount:18   );///frost_orb_1_18.png
static const FileDataClass frostOrb118 = 
(path:"assets/images/effects/frost_orb_1_18.png",flamePath:"effects/frost_orb_1_18.png", size:(864.0,48.0),
 potentialFrameCount:18   );///green_default_area_effect_11.png
static const FileDataClass greenDefaultAreaEffect11 = 
(path:"assets/images/effects/green_default_area_effect_11.png",flamePath:"effects/green_default_area_effect_11.png", size:(1100.0,100.0),
 potentialFrameCount:11   );///healing_orb_1_18.png
static const FileDataClass healingOrb118 = 
(path:"assets/images/effects/healing_orb_1_18.png",flamePath:"effects/healing_orb_1_18.png", size:(864.0,48.0),
 potentialFrameCount:18   );///magic_orb_1_18.png
static const FileDataClass magicOrb118 = 
(path:"assets/images/effects/magic_orb_1_18.png",flamePath:"effects/magic_orb_1_18.png", size:(864.0,48.0),
 potentialFrameCount:18   );///pheonix_revive_1_5.png
static const FileDataClass pheonixRevive15 = 
(path:"assets/images/effects/pheonix_revive_1_5.png",flamePath:"effects/pheonix_revive_1_5.png", size:(240.0,48.0),
 potentialFrameCount:5   );///physical_orb_1_18.png
static const FileDataClass physicalOrb118 = 
(path:"assets/images/effects/physical_orb_1_18.png",flamePath:"effects/physical_orb_1_18.png", size:(864.0,48.0),
 potentialFrameCount:18   );///psychic_orb_1_18.png
static const FileDataClass psychicOrb118 = 
(path:"assets/images/effects/psychic_orb_1_18.png",flamePath:"effects/psychic_orb_1_18.png", size:(864.0,48.0),
 potentialFrameCount:18   );///red_default_area_effect_11.png
static const FileDataClass redDefaultAreaEffect11 = 
(path:"assets/images/effects/red_default_area_effect_11.png",flamePath:"effects/red_default_area_effect_11.png", size:(1100.0,100.0),
 potentialFrameCount:11   );///star_5.png
static const FileDataClass star5 = 
(path:"assets/images/effects/star_5.png",flamePath:"effects/star_5.png", size:(80.0,16.0),
 potentialFrameCount:5   );static  List<String> allFiles = [brownDefaultAreaEffect11.path,
defaultAreaEffect11.path,
energy110.path,
energyOrb118.path,
explosion116.path,
fireOrb118.path,
frostOrb118.path,
greenDefaultAreaEffect11.path,
healingOrb118.path,
magicOrb118.path,
pheonixRevive15.path,
physicalOrb118.path,
psychicOrb118.path,
redDefaultAreaEffect11.path,
star5.path,
];
static  List<String> allFilesFlame = [brownDefaultAreaEffect11.flamePath,
defaultAreaEffect11.flamePath,
energy110.flamePath,
energyOrb118.flamePath,
explosion116.flamePath,
fireOrb118.flamePath,
frostOrb118.flamePath,
greenDefaultAreaEffect11.flamePath,
healingOrb118.flamePath,
magicOrb118.flamePath,
pheonixRevive15.flamePath,
physicalOrb118.flamePath,
psychicOrb118.flamePath,
redDefaultAreaEffect11.flamePath,
star5.flamePath,
];
}
class ImagesAssetsDamageEffects {
///energy.png
static const FileDataClass energy = 
(path:"assets/images/effects/damage_effects/energy.png",flamePath:"effects/damage_effects/energy.png", size:(24.0,8.0),
 potentialFrameCount:3   );///fire.png
static const FileDataClass fire = 
(path:"assets/images/effects/damage_effects/fire.png",flamePath:"effects/damage_effects/fire.png", size:(40.0,8.0),
 potentialFrameCount:5   );///frost.png
static const FileDataClass frost = 
(path:"assets/images/effects/damage_effects/frost.png",flamePath:"effects/damage_effects/frost.png", size:(16.0,8.0),
 potentialFrameCount:2   );///magic.png
static const FileDataClass magic = 
(path:"assets/images/effects/damage_effects/magic.png",flamePath:"effects/damage_effects/magic.png", size:(48.0,8.0),
 potentialFrameCount:6   );///physical.png
static const FileDataClass physical = 
(path:"assets/images/effects/damage_effects/physical.png",flamePath:"effects/damage_effects/physical.png", size:(32.0,8.0),
 potentialFrameCount:4   );///psychic.png
static const FileDataClass psychic = 
(path:"assets/images/effects/damage_effects/psychic.png",flamePath:"effects/damage_effects/psychic.png", size:(24.0,8.0),
 potentialFrameCount:3   );static  List<String> allFiles = [energy.path,
fire.path,
frost.path,
magic.path,
physical.path,
psychic.path,
];
static  List<String> allFilesFlame = [energy.flamePath,
fire.flamePath,
frost.flamePath,
magic.flamePath,
physical.flamePath,
psychic.flamePath,
];
}
class ImagesAssetsStatusEffects {
///bleed.png
static const FileDataClass bleed = 
(path:"assets/images/effects/status_effects/bleed.png",flamePath:"effects/status_effects/bleed.png", size:(32.0,16.0),
 potentialFrameCount:2   );///burning_end_1.png
static const FileDataClass burningEnd1 = 
(path:"assets/images/effects/status_effects/burning_end_1.png",flamePath:"effects/status_effects/burning_end_1.png", size:(120.0,32.0),
 potentialFrameCount:4   );///burning_loop_1.png
static const FileDataClass burningLoop1 = 
(path:"assets/images/effects/status_effects/burning_loop_1.png",flamePath:"effects/status_effects/burning_loop_1.png", size:(192.0,35.0),
 potentialFrameCount:5   );///burning_start_1.png
static const FileDataClass burningStart1 = 
(path:"assets/images/effects/status_effects/burning_start_1.png",flamePath:"effects/status_effects/burning_start_1.png", size:(96.0,32.0),
 potentialFrameCount:3   );///electrified.png
static const FileDataClass electrified = 
(path:"assets/images/effects/status_effects/electrified.png",flamePath:"effects/status_effects/electrified.png", size:(96.0,32.0),
 potentialFrameCount:3   );///empowered.png
static const FileDataClass empowered = 
(path:"assets/images/effects/status_effects/empowered.png",flamePath:"effects/status_effects/empowered.png", size:(16.0,8.0),
 potentialFrameCount:2   );///fear.png
static const FileDataClass fear = 
(path:"assets/images/effects/status_effects/fear.png",flamePath:"effects/status_effects/fear.png", size:(16.0,8.0),
 potentialFrameCount:2   );///frost.png
static const FileDataClass frost = 
(path:"assets/images/effects/status_effects/frost.png",flamePath:"effects/status_effects/frost.png", size:(16.0,8.0),
 potentialFrameCount:2   );///marked.png
static const FileDataClass marked = 
(path:"assets/images/effects/status_effects/marked.png",flamePath:"effects/status_effects/marked.png", size:(32.0,16.0),
 potentialFrameCount:2   );///slow.png
static const FileDataClass slow = 
(path:"assets/images/effects/status_effects/slow.png",flamePath:"effects/status_effects/slow.png", size:(64.0,8.0),
 potentialFrameCount:8   );///stun.png
static const FileDataClass stun = 
(path:"assets/images/effects/status_effects/stun.png",flamePath:"effects/status_effects/stun.png", size:(32.0,8.0),
 potentialFrameCount:4   );static  List<String> allFiles = [bleed.path,
burningEnd1.path,
burningLoop1.path,
burningStart1.path,
electrified.path,
empowered.path,
fear.path,
frost.path,
marked.path,
slow.path,
stun.path,
];
static  List<String> allFilesFlame = [bleed.flamePath,
burningEnd1.flamePath,
burningLoop1.flamePath,
burningStart1.flamePath,
electrified.flamePath,
empowered.flamePath,
fear.flamePath,
frost.flamePath,
marked.flamePath,
slow.flamePath,
stun.flamePath,
];
}
class ImagesAssetsEnemySprites {
///ghost_hand_attack_red.png
static const FileDataClass ghostHandAttackRed = 
(path:"assets/images/enemy_sprites/ghost_hand_attack_red.png",flamePath:"enemy_sprites/ghost_hand_attack_red.png", size:(960.0,48.0),
 potentialFrameCount:20   );static  List<String> allFiles = [ghostHandAttackRed.path,
];
static  List<String> allFilesFlame = [ghostHandAttackRed.flamePath,
];
}
class ImagesAssetsGhostHand {
///ghost_hand_attack_red.png
static const FileDataClass ghostHandAttackRed = 
(path:"assets/images/enemy_sprites/ghostHand/ghost_hand_attack_red.png",flamePath:"enemy_sprites/ghostHand/ghost_hand_attack_red.png", size:(960.0,48.0),
 potentialFrameCount:20   );static  List<String> allFiles = [ghostHandAttackRed.path,
];
static  List<String> allFilesFlame = [ghostHandAttackRed.flamePath,
];
}
class ImagesAssetsMushroomBoomer {
///death.png
static const FileDataClass death = 
(path:"assets/images/enemy_sprites/mushroomBoomer/death.png",flamePath:"enemy_sprites/mushroomBoomer/death.png", size:(336.0,48.0),
 potentialFrameCount:7   );///death2.png
static const FileDataClass death2 = 
(path:"assets/images/enemy_sprites/mushroomBoomer/death2.png",flamePath:"enemy_sprites/mushroomBoomer/death2.png", size:(336.0,48.0),
 potentialFrameCount:7   );///idle.png
static const FileDataClass idle = 
(path:"assets/images/enemy_sprites/mushroomBoomer/idle.png",flamePath:"enemy_sprites/mushroomBoomer/idle.png", size:(96.0,48.0),
 potentialFrameCount:2   );///idle2.png
static const FileDataClass idle2 = 
(path:"assets/images/enemy_sprites/mushroomBoomer/idle2.png",flamePath:"enemy_sprites/mushroomBoomer/idle2.png", size:(96.0,48.0),
 potentialFrameCount:2   );///run.png
static const FileDataClass run = 
(path:"assets/images/enemy_sprites/mushroomBoomer/run.png",flamePath:"enemy_sprites/mushroomBoomer/run.png", size:(192.0,48.0),
 potentialFrameCount:4   );///run2.png
static const FileDataClass run2 = 
(path:"assets/images/enemy_sprites/mushroomBoomer/run2.png",flamePath:"enemy_sprites/mushroomBoomer/run2.png", size:(192.0,48.0),
 potentialFrameCount:4   );static  List<String> allFiles = [death.path,
death2.path,
idle.path,
idle2.path,
run.path,
run2.path,
];
static  List<String> allFilesFlame = [death.flamePath,
death2.flamePath,
idle.flamePath,
idle2.flamePath,
run.flamePath,
run2.flamePath,
];
}
class ImagesAssetsMushroomBoss {
///die.png
static const FileDataClass die = 
(path:"assets/images/enemy_sprites/mushroomBoss/die.png",flamePath:"enemy_sprites/mushroomBoss/die.png", size:(2432.0,128.0),
 potentialFrameCount:19   );///eye_close.png
static const FileDataClass eyeClose = 
(path:"assets/images/enemy_sprites/mushroomBoss/eye_close.png",flamePath:"enemy_sprites/mushroomBoss/eye_close.png", size:(512.0,128.0),
 potentialFrameCount:4   );///eye_close_idle.png
static const FileDataClass eyeCloseIdle = 
(path:"assets/images/enemy_sprites/mushroomBoss/eye_close_idle.png",flamePath:"enemy_sprites/mushroomBoss/eye_close_idle.png", size:(256.0,128.0),
 potentialFrameCount:2   );///eye_open.png
static const FileDataClass eyeOpen = 
(path:"assets/images/enemy_sprites/mushroomBoss/eye_open.png",flamePath:"enemy_sprites/mushroomBoss/eye_open.png", size:(512.0,128.0),
 potentialFrameCount:4   );///idle.png
static const FileDataClass idle = 
(path:"assets/images/enemy_sprites/mushroomBoss/idle.png",flamePath:"enemy_sprites/mushroomBoss/idle.png", size:(2048.0,128.0),
 potentialFrameCount:16   );///spawn.png
static const FileDataClass spawn = 
(path:"assets/images/enemy_sprites/mushroomBoss/spawn.png",flamePath:"enemy_sprites/mushroomBoss/spawn.png", size:(896.0,128.0),
 potentialFrameCount:7   );///spin.png
static const FileDataClass spin = 
(path:"assets/images/enemy_sprites/mushroomBoss/spin.png",flamePath:"enemy_sprites/mushroomBoss/spin.png", size:(256.0,128.0),
 potentialFrameCount:2   );///spin_end.png
static const FileDataClass spinEnd = 
(path:"assets/images/enemy_sprites/mushroomBoss/spin_end.png",flamePath:"enemy_sprites/mushroomBoss/spin_end.png", size:(1024.0,128.0),
 potentialFrameCount:8   );///spin_start.png
static const FileDataClass spinStart = 
(path:"assets/images/enemy_sprites/mushroomBoss/spin_start.png",flamePath:"enemy_sprites/mushroomBoss/spin_start.png", size:(1024.0,128.0),
 potentialFrameCount:8   );static  List<String> allFiles = [die.path,
eyeClose.path,
eyeCloseIdle.path,
eyeOpen.path,
idle.path,
spawn.path,
spin.path,
spinEnd.path,
spinStart.path,
];
static  List<String> allFilesFlame = [die.flamePath,
eyeClose.flamePath,
eyeCloseIdle.flamePath,
eyeOpen.flamePath,
idle.flamePath,
spawn.flamePath,
spin.flamePath,
spinEnd.flamePath,
spinStart.flamePath,
];
}
class ImagesAssetsMushroomBurrower {
///burrow_in.png
static const FileDataClass burrowIn = 
(path:"assets/images/enemy_sprites/mushroomBurrower/burrow_in.png",flamePath:"enemy_sprites/mushroomBurrower/burrow_in.png", size:(192.0,48.0),
 potentialFrameCount:4   );///burrow_out.png
static const FileDataClass burrowOut = 
(path:"assets/images/enemy_sprites/mushroomBurrower/burrow_out.png",flamePath:"enemy_sprites/mushroomBurrower/burrow_out.png", size:(192.0,48.0),
 potentialFrameCount:4   );///idle.png
static const FileDataClass idle = 
(path:"assets/images/enemy_sprites/mushroomBurrower/idle.png",flamePath:"enemy_sprites/mushroomBurrower/idle.png", size:(96.0,48.0),
 potentialFrameCount:2   );///jump.png
static const FileDataClass jump = 
(path:"assets/images/enemy_sprites/mushroomBurrower/jump.png",flamePath:"enemy_sprites/mushroomBurrower/jump.png", size:(192.0,48.0),
 potentialFrameCount:4   );static  List<String> allFiles = [burrowIn.path,
burrowOut.path,
idle.path,
jump.path,
];
static  List<String> allFilesFlame = [burrowIn.flamePath,
burrowOut.flamePath,
idle.flamePath,
jump.flamePath,
];
}
class ImagesAssetsMushroomHopper {
///death.png
static const FileDataClass death = 
(path:"assets/images/enemy_sprites/mushroomHopper/death.png",flamePath:"enemy_sprites/mushroomHopper/death.png", size:(640.0,64.0),
 potentialFrameCount:10   );///idle.png
static const FileDataClass idle = 
(path:"assets/images/enemy_sprites/mushroomHopper/idle.png",flamePath:"enemy_sprites/mushroomHopper/idle.png", size:(480.0,48.0),
 potentialFrameCount:10   );///jump.png
static const FileDataClass jump = 
(path:"assets/images/enemy_sprites/mushroomHopper/jump.png",flamePath:"enemy_sprites/mushroomHopper/jump.png", size:(144.0,48.0),
 potentialFrameCount:3   );///land.png
static const FileDataClass land = 
(path:"assets/images/enemy_sprites/mushroomHopper/land.png",flamePath:"enemy_sprites/mushroomHopper/land.png", size:(432.0,48.0),
 potentialFrameCount:9   );///roll.png
static const FileDataClass roll = 
(path:"assets/images/enemy_sprites/mushroomHopper/roll.png",flamePath:"enemy_sprites/mushroomHopper/roll.png", size:(336.0,48.0),
 potentialFrameCount:7   );///run.png
static const FileDataClass run = 
(path:"assets/images/enemy_sprites/mushroomHopper/run.png",flamePath:"enemy_sprites/mushroomHopper/run.png", size:(384.0,48.0),
 potentialFrameCount:8   );///walk.png
static const FileDataClass walk = 
(path:"assets/images/enemy_sprites/mushroomHopper/walk.png",flamePath:"enemy_sprites/mushroomHopper/walk.png", size:(384.0,48.0),
 potentialFrameCount:8   );static  List<String> allFiles = [death.path,
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
(path:"assets/images/enemy_sprites/mushroomRunner/dead.png",flamePath:"enemy_sprites/mushroomRunner/dead.png", size:(128.0,32.0),
 potentialFrameCount:4   );///idle.png
static const FileDataClass idle = 
(path:"assets/images/enemy_sprites/mushroomRunner/idle.png",flamePath:"enemy_sprites/mushroomRunner/idle.png", size:(64.0,32.0),
 potentialFrameCount:2   );///run.png
static const FileDataClass run = 
(path:"assets/images/enemy_sprites/mushroomRunner/run.png",flamePath:"enemy_sprites/mushroomRunner/run.png", size:(64.0,32.0),
 potentialFrameCount:2   );static  List<String> allFiles = [dead.path,
idle.path,
run.path,
];
static  List<String> allFilesFlame = [dead.flamePath,
idle.flamePath,
run.flamePath,
];
}
class ImagesAssetsMushroomRunnerScared {
///dead.png
static const FileDataClass dead = 
(path:"assets/images/enemy_sprites/mushroomRunnerScared/dead.png",flamePath:"enemy_sprites/mushroomRunnerScared/dead.png", size:(128.0,32.0),
 potentialFrameCount:4   );///idle.png
static const FileDataClass idle = 
(path:"assets/images/enemy_sprites/mushroomRunnerScared/idle.png",flamePath:"enemy_sprites/mushroomRunnerScared/idle.png", size:(64.0,32.0),
 potentialFrameCount:2   );///run.png
static const FileDataClass run = 
(path:"assets/images/enemy_sprites/mushroomRunnerScared/run.png",flamePath:"enemy_sprites/mushroomRunnerScared/run.png", size:(64.0,32.0),
 potentialFrameCount:2   );static  List<String> allFiles = [dead.path,
idle.path,
run.path,
];
static  List<String> allFilesFlame = [dead.flamePath,
idle.flamePath,
run.flamePath,
];
}
class ImagesAssetsMushroomShooter {
///attack.png
static const FileDataClass attack = 
(path:"assets/images/enemy_sprites/mushroomShooter/attack.png",flamePath:"enemy_sprites/mushroomShooter/attack.png", size:(160.0,32.0),
 potentialFrameCount:5   );///death.png
static const FileDataClass death = 
(path:"assets/images/enemy_sprites/mushroomShooter/death.png",flamePath:"enemy_sprites/mushroomShooter/death.png", size:(128.0,32.0),
 potentialFrameCount:4   );///idle.png
static const FileDataClass idle = 
(path:"assets/images/enemy_sprites/mushroomShooter/idle.png",flamePath:"enemy_sprites/mushroomShooter/idle.png", size:(64.0,32.0),
 potentialFrameCount:2   );///run.png
static const FileDataClass run = 
(path:"assets/images/enemy_sprites/mushroomShooter/run.png",flamePath:"enemy_sprites/mushroomShooter/run.png", size:(64.0,32.0),
 potentialFrameCount:2   );static  List<String> allFiles = [attack.path,
death.path,
idle.path,
run.path,
];
static  List<String> allFilesFlame = [attack.flamePath,
death.flamePath,
idle.flamePath,
run.flamePath,
];
}
class ImagesAssetsMushroomSpinner {
///death.png
static const FileDataClass death = 
(path:"assets/images/enemy_sprites/mushroomSpinner/death.png",flamePath:"enemy_sprites/mushroomSpinner/death.png", size:(240.0,48.0),
 potentialFrameCount:5   );///idle.png
static const FileDataClass idle = 
(path:"assets/images/enemy_sprites/mushroomSpinner/idle.png",flamePath:"enemy_sprites/mushroomSpinner/idle.png", size:(96.0,48.0),
 potentialFrameCount:2   );///run.png
static const FileDataClass run = 
(path:"assets/images/enemy_sprites/mushroomSpinner/run.png",flamePath:"enemy_sprites/mushroomSpinner/run.png", size:(96.0,48.0),
 potentialFrameCount:2   );///spin.png
static const FileDataClass spin = 
(path:"assets/images/enemy_sprites/mushroomSpinner/spin.png",flamePath:"enemy_sprites/mushroomSpinner/spin.png", size:(192.0,48.0),
 potentialFrameCount:4   );///spin_end.png
static const FileDataClass spinEnd = 
(path:"assets/images/enemy_sprites/mushroomSpinner/spin_end.png",flamePath:"enemy_sprites/mushroomSpinner/spin_end.png", size:(432.0,48.0),
 potentialFrameCount:9   );///spin_start.png
static const FileDataClass spinStart = 
(path:"assets/images/enemy_sprites/mushroomSpinner/spin_start.png",flamePath:"enemy_sprites/mushroomSpinner/spin_start.png", size:(432.0,48.0),
 potentialFrameCount:9   );static  List<String> allFiles = [death.path,
idle.path,
run.path,
spin.path,
spinEnd.path,
spinStart.path,
];
static  List<String> allFilesFlame = [death.flamePath,
idle.flamePath,
run.flamePath,
spin.flamePath,
spinEnd.flamePath,
spinStart.flamePath,
];
}
class ImagesAssetsEntityEffects {
///dash_effect.png
static const FileDataClass dashEffect = 
(path:"assets/images/entity_effects/dash_effect.png",flamePath:"entity_effects/dash_effect.png", size:(448.0,32.0),
 potentialFrameCount:14   );///exit_arrow.png
static const FileDataClass exitArrow = 
(path:"assets/images/entity_effects/exit_arrow.png",flamePath:"entity_effects/exit_arrow.png", size:(1024.0,128.0),
 potentialFrameCount:8   );///exit_portal_blue.png
static const FileDataClass exitPortalBlue = 
(path:"assets/images/entity_effects/exit_portal_blue.png",flamePath:"entity_effects/exit_portal_blue.png", size:(512.0,128.0),
 potentialFrameCount:4   );///jump_effect.png
static const FileDataClass jumpEffect = 
(path:"assets/images/entity_effects/jump_effect.png",flamePath:"entity_effects/jump_effect.png", size:(450.0,23.0),
 potentialFrameCount:20   );static  List<String> allFiles = [dashEffect.path,
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
(path:"assets/images/expendables/blank.png",flamePath:"expendables/blank.png", size:(32.0,32.0),
 potentialFrameCount:1   );///blank_alt.png
static const FileDataClass blankAlt = 
(path:"assets/images/expendables/blank_alt.png",flamePath:"expendables/blank_alt.png", size:(32.0,32.0),
 potentialFrameCount:1   );///experience_attract.png
static const FileDataClass experienceAttract = 
(path:"assets/images/expendables/experience_attract.png",flamePath:"expendables/experience_attract.png", size:(32.0,32.0),
 potentialFrameCount:1   );///fear_enemies.png
static const FileDataClass fearEnemies = 
(path:"assets/images/expendables/fear_enemies.png",flamePath:"expendables/fear_enemies.png", size:(32.0,32.0),
 potentialFrameCount:1   );///healing.png
static const FileDataClass healing = 
(path:"assets/images/expendables/healing.png",flamePath:"expendables/healing.png", size:(32.0,32.0),
 potentialFrameCount:1   );///stun.png
static const FileDataClass stun = 
(path:"assets/images/expendables/stun.png",flamePath:"expendables/stun.png", size:(32.0,32.0),
 potentialFrameCount:1   );///teleport.png
static const FileDataClass teleport = 
(path:"assets/images/expendables/teleport.png",flamePath:"expendables/teleport.png", size:(32.0,32.0),
 potentialFrameCount:1   );static  List<String> allFiles = [blank.path,
blankAlt.path,
experienceAttract.path,
fearEnemies.path,
healing.path,
stun.path,
teleport.path,
];
static  List<String> allFilesFlame = [blank.flamePath,
blankAlt.flamePath,
experienceAttract.flamePath,
fearEnemies.flamePath,
healing.flamePath,
stun.flamePath,
teleport.flamePath,
];
}
class ImagesAssetsExperience {
///all.png
static const FileDataClass all = 
(path:"assets/images/experience/all.png",flamePath:"experience/all.png", size:(16.0,16.0),
 potentialFrameCount:1   );///large.png
static const FileDataClass large = 
(path:"assets/images/experience/large.png",flamePath:"experience/large.png", size:(8.0,8.0),
 potentialFrameCount:1   );///medium.png
static const FileDataClass medium = 
(path:"assets/images/experience/medium.png",flamePath:"experience/medium.png", size:(8.0,8.0),
 potentialFrameCount:1   );///small.png
static const FileDataClass small = 
(path:"assets/images/experience/small.png",flamePath:"experience/small.png", size:(8.0,8.0),
 potentialFrameCount:1   );static  List<String> allFiles = [all.path,
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
class ImagesAssetsSecondaryIcons {
///blank.png
static const FileDataClass blank = 
(path:"assets/images/secondary_icons/blank.png",flamePath:"secondary_icons/blank.png", size:(32.0,32.0),
 potentialFrameCount:1   );///explode_projectiles.png
static const FileDataClass explodeProjectiles = 
(path:"assets/images/secondary_icons/explode_projectiles.png",flamePath:"secondary_icons/explode_projectiles.png", size:(32.0,32.0),
 potentialFrameCount:1   );///rapid_fire.png
static const FileDataClass rapidFire = 
(path:"assets/images/secondary_icons/rapid_fire.png",flamePath:"secondary_icons/rapid_fire.png", size:(32.0,32.0),
 potentialFrameCount:1   );static  List<String> allFiles = [blank.path,
explodeProjectiles.path,
rapidFire.path,
];
static  List<String> allFilesFlame = [blank.flamePath,
explodeProjectiles.flamePath,
rapidFire.flamePath,
];
}
class ImagesAssetsRuneknight {
///runeknight_dash_1.png
static const FileDataClass runeknightDash1 = 
(path:"assets/images/sprites/runeknight/runeknight_dash_1.png",flamePath:"sprites/runeknight/runeknight_dash_1.png", size:(288.0,48.0),
 potentialFrameCount:6   );///runeknight_death_1.png
static const FileDataClass runeknightDeath1 = 
(path:"assets/images/sprites/runeknight/runeknight_death_1.png",flamePath:"sprites/runeknight/runeknight_death_1.png", size:(384.0,48.0),
 potentialFrameCount:8   );///runeknight_hit_1.png
static const FileDataClass runeknightHit1 = 
(path:"assets/images/sprites/runeknight/runeknight_hit_1.png",flamePath:"sprites/runeknight/runeknight_hit_1.png", size:(192.0,48.0),
 potentialFrameCount:4   );///runeknight_icon_1.png
static const FileDataClass runeknightIcon1 = 
(path:"assets/images/sprites/runeknight/runeknight_icon_1.png",flamePath:"sprites/runeknight/runeknight_icon_1.png", size:(48.0,48.0),
 potentialFrameCount:1   );///runeknight_idle_1.png
static const FileDataClass runeknightIdle1 = 
(path:"assets/images/sprites/runeknight/runeknight_idle_1.png",flamePath:"sprites/runeknight/runeknight_idle_1.png", size:(288.0,48.0),
 potentialFrameCount:6   );///runeknight_jump_1.png
static const FileDataClass runeknightJump1 = 
(path:"assets/images/sprites/runeknight/runeknight_jump_1.png",flamePath:"sprites/runeknight/runeknight_jump_1.png", size:(144.0,48.0),
 potentialFrameCount:3   );///runeknight_run_1.png
static const FileDataClass runeknightRun1 = 
(path:"assets/images/sprites/runeknight/runeknight_run_1.png",flamePath:"sprites/runeknight/runeknight_run_1.png", size:(384.0,48.0),
 potentialFrameCount:8   );static  List<String> allFiles = [runeknightDash1.path,
runeknightDeath1.path,
runeknightHit1.path,
runeknightIcon1.path,
runeknightIdle1.path,
runeknightJump1.path,
runeknightRun1.path,
];
static  List<String> allFilesFlame = [runeknightDash1.flamePath,
runeknightDeath1.flamePath,
runeknightHit1.flamePath,
runeknightIcon1.flamePath,
runeknightIdle1.flamePath,
runeknightJump1.flamePath,
runeknightRun1.flamePath,
];
}
class ImagesAssetsUi {
///ammo.png
static const FileDataClass ammo = 
(path:"assets/images/ui/ammo.png",flamePath:"ui/ammo.png", size:(8.0,8.0),
 potentialFrameCount:1   );///ammo_empty.png
static const FileDataClass ammoEmpty = 
(path:"assets/images/ui/ammo_empty.png",flamePath:"ui/ammo_empty.png", size:(8.0,8.0),
 potentialFrameCount:1   );///android_logo_down.png
static const FileDataClass androidLogoDown = 
(path:"assets/images/ui/android_logo_down.png",flamePath:"ui/android_logo_down.png", size:(160.0,32.0),
 potentialFrameCount:5   );///android_logo_up.png
static const FileDataClass androidLogoUp = 
(path:"assets/images/ui/android_logo_up.png",flamePath:"ui/android_logo_up.png", size:(160.0,32.0),
 potentialFrameCount:5   );///arrow_black.png
static const FileDataClass arrowBlack = 
(path:"assets/images/ui/arrow_black.png",flamePath:"ui/arrow_black.png", size:(12.0,8.0),
 potentialFrameCount:2   );///attribute_background.png
static const FileDataClass attributeBackground = 
(path:"assets/images/ui/attribute_background.png",flamePath:"ui/attribute_background.png", size:(128.0,96.0),
 potentialFrameCount:1   );///attribute_background_mask.png
static const FileDataClass attributeBackgroundMask = 
(path:"assets/images/ui/attribute_background_mask.png",flamePath:"ui/attribute_background_mask.png", size:(128.0,96.0),
 potentialFrameCount:1   );///attribute_background_mask_small.png
static const FileDataClass attributeBackgroundMaskSmall = 
(path:"assets/images/ui/attribute_background_mask_small.png",flamePath:"ui/attribute_background_mask_small.png", size:(128.0,48.0),
 potentialFrameCount:3   );///attribute_background_small.png
static const FileDataClass attributeBackgroundSmall = 
(path:"assets/images/ui/attribute_background_small.png",flamePath:"ui/attribute_background_small.png", size:(128.0,48.0),
 potentialFrameCount:3   );///attribute_border.png
static const FileDataClass attributeBorder = 
(path:"assets/images/ui/attribute_border.png",flamePath:"ui/attribute_border.png", size:(128.0,96.0),
 potentialFrameCount:1   );///attribute_border_base.png
static const FileDataClass attributeBorderBase = 
(path:"assets/images/ui/attribute_border_base.png",flamePath:"ui/attribute_border_base.png", size:(128.0,96.0),
 potentialFrameCount:1   );///attribute_border_base_small.png
static const FileDataClass attributeBorderBaseSmall = 
(path:"assets/images/ui/attribute_border_base_small.png",flamePath:"ui/attribute_border_base_small.png", size:(128.0,48.0),
 potentialFrameCount:3   );///attribute_border_energy.png
static const FileDataClass attributeBorderEnergy = 
(path:"assets/images/ui/attribute_border_energy.png",flamePath:"ui/attribute_border_energy.png", size:(128.0,96.0),
 potentialFrameCount:1   );///attribute_border_fire.png
static const FileDataClass attributeBorderFire = 
(path:"assets/images/ui/attribute_border_fire.png",flamePath:"ui/attribute_border_fire.png", size:(128.0,96.0),
 potentialFrameCount:1   );///attribute_border_frost.png
static const FileDataClass attributeBorderFrost = 
(path:"assets/images/ui/attribute_border_frost.png",flamePath:"ui/attribute_border_frost.png", size:(128.0,96.0),
 potentialFrameCount:1   );///attribute_border_magic.png
static const FileDataClass attributeBorderMagic = 
(path:"assets/images/ui/attribute_border_magic.png",flamePath:"ui/attribute_border_magic.png", size:(128.0,96.0),
 potentialFrameCount:1   );///attribute_border_mid.png
static const FileDataClass attributeBorderMid = 
(path:"assets/images/ui/attribute_border_mid.png",flamePath:"ui/attribute_border_mid.png", size:(128.0,96.0),
 potentialFrameCount:1   );///attribute_border_mid_small.png
static const FileDataClass attributeBorderMidSmall = 
(path:"assets/images/ui/attribute_border_mid_small.png",flamePath:"ui/attribute_border_mid_small.png", size:(128.0,48.0),
 potentialFrameCount:3   );///attribute_border_physical.png
static const FileDataClass attributeBorderPhysical = 
(path:"assets/images/ui/attribute_border_physical.png",flamePath:"ui/attribute_border_physical.png", size:(128.0,96.0),
 potentialFrameCount:1   );///attribute_border_psychic.png
static const FileDataClass attributeBorderPsychic = 
(path:"assets/images/ui/attribute_border_psychic.png",flamePath:"ui/attribute_border_psychic.png", size:(128.0,96.0),
 potentialFrameCount:1   );///attribute_border_small.png
static const FileDataClass attributeBorderSmall = 
(path:"assets/images/ui/attribute_border_small.png",flamePath:"ui/attribute_border_small.png", size:(128.0,48.0),
 potentialFrameCount:3   );///bag.png
static const FileDataClass bag = 
(path:"assets/images/ui/bag.png",flamePath:"ui/bag.png", size:(736.0,714.0),
 potentialFrameCount:1   );///banner.png
static const FileDataClass banner = 
(path:"assets/images/ui/banner.png",flamePath:"ui/banner.png", size:(128.0,36.0),
 potentialFrameCount:4   );///book.png
static const FileDataClass book = 
(path:"assets/images/ui/book.png",flamePath:"ui/book.png", size:(24.0,32.0),
 potentialFrameCount:1   );///boss_bar_border.png
static const FileDataClass bossBarBorder = 
(path:"assets/images/ui/boss_bar_border.png",flamePath:"ui/boss_bar_border.png", size:(16.0,8.0),
 potentialFrameCount:2   );///boss_bar_center.png
static const FileDataClass bossBarCenter = 
(path:"assets/images/ui/boss_bar_center.png",flamePath:"ui/boss_bar_center.png", size:(96.0,8.0),
 potentialFrameCount:12   );///boss_bar_left.png
static const FileDataClass bossBarLeft = 
(path:"assets/images/ui/boss_bar_left.png",flamePath:"ui/boss_bar_left.png", size:(32.0,8.0),
 potentialFrameCount:4   );///boss_bar_right.png
static const FileDataClass bossBarRight = 
(path:"assets/images/ui/boss_bar_right.png",flamePath:"ui/boss_bar_right.png", size:(32.0,8.0),
 potentialFrameCount:4   );///cursor_down.png
static const FileDataClass cursorDown = 
(path:"assets/images/ui/cursor_down.png",flamePath:"ui/cursor_down.png", size:(16.0,16.0),
 potentialFrameCount:1   );///cursor_up.png
static const FileDataClass cursorUp = 
(path:"assets/images/ui/cursor_up.png",flamePath:"ui/cursor_up.png", size:(16.0,16.0),
 potentialFrameCount:1   );///elemental_column.png
static const FileDataClass elementalColumn = 
(path:"assets/images/ui/elemental_column.png",flamePath:"ui/elemental_column.png", size:(32.0,96.0),
 potentialFrameCount:0   );///elemental_pie.png
static const FileDataClass elementalPie = 
(path:"assets/images/ui/elemental_pie.png",flamePath:"ui/elemental_pie.png", size:(32.0,32.0),
 potentialFrameCount:1   );///health_bar.png
static const FileDataClass healthBar = 
(path:"assets/images/ui/health_bar.png",flamePath:"ui/health_bar.png", size:(128.0,32.0),
 potentialFrameCount:4   );///health_bar_cap.png
static const FileDataClass healthBarCap = 
(path:"assets/images/ui/health_bar_cap.png",flamePath:"ui/health_bar_cap.png", size:(8.0,8.0),
 potentialFrameCount:1   );///health_bar_mid.png
static const FileDataClass healthBarMid = 
(path:"assets/images/ui/health_bar_mid.png",flamePath:"ui/health_bar_mid.png", size:(8.0,8.0),
 potentialFrameCount:1   );///heart.png
static const FileDataClass heart = 
(path:"assets/images/ui/heart.png",flamePath:"ui/heart.png", size:(40.0,8.0),
 potentialFrameCount:5   );///heart_blank.png
static const FileDataClass heartBlank = 
(path:"assets/images/ui/heart_blank.png",flamePath:"ui/heart_blank.png", size:(8.0,8.0),
 potentialFrameCount:1   );///inf.png
static const FileDataClass inf = 
(path:"assets/images/ui/inf.png",flamePath:"ui/inf.png", size:(14.0,11.0),
 potentialFrameCount:1   );///level_indicator_gun_blue.png
static const FileDataClass levelIndicatorGunBlue = 
(path:"assets/images/ui/level_indicator_gun_blue.png",flamePath:"ui/level_indicator_gun_blue.png", size:(16.0,16.0),
 potentialFrameCount:1   );///level_indicator_gun_red.png
static const FileDataClass levelIndicatorGunRed = 
(path:"assets/images/ui/level_indicator_gun_red.png",flamePath:"ui/level_indicator_gun_red.png", size:(16.0,16.0),
 potentialFrameCount:1   );///level_indicator_magic_blue.png
static const FileDataClass levelIndicatorMagicBlue = 
(path:"assets/images/ui/level_indicator_magic_blue.png",flamePath:"ui/level_indicator_magic_blue.png", size:(16.0,16.0),
 potentialFrameCount:1   );///level_indicator_magic_red.png
static const FileDataClass levelIndicatorMagicRed = 
(path:"assets/images/ui/level_indicator_magic_red.png",flamePath:"ui/level_indicator_magic_red.png", size:(16.0,16.0),
 potentialFrameCount:1   );///level_indicator_sword_blue.png
static const FileDataClass levelIndicatorSwordBlue = 
(path:"assets/images/ui/level_indicator_sword_blue.png",flamePath:"ui/level_indicator_sword_blue.png", size:(16.0,16.0),
 potentialFrameCount:1   );///level_indicator_sword_red.png
static const FileDataClass levelIndicatorSwordRed = 
(path:"assets/images/ui/level_indicator_sword_red.png",flamePath:"ui/level_indicator_sword_red.png", size:(16.0,16.0),
 potentialFrameCount:1   );///magic_bar_cap.png
static const FileDataClass magicBarCap = 
(path:"assets/images/ui/magic_bar_cap.png",flamePath:"ui/magic_bar_cap.png", size:(8.0,8.0),
 potentialFrameCount:1   );///magic_bar_mid.png
static const FileDataClass magicBarMid = 
(path:"assets/images/ui/magic_bar_mid.png",flamePath:"ui/magic_bar_mid.png", size:(8.0,8.0),
 potentialFrameCount:1   );///magic_hand_L.png
static const FileDataClass magicHandL = 
(path:"assets/images/ui/magic_hand_L.png",flamePath:"ui/magic_hand_L.png", size:(64.0,128.0),
 potentialFrameCount:1   );///magic_hand_R.png
static const FileDataClass magicHandR = 
(path:"assets/images/ui/magic_hand_R.png",flamePath:"ui/magic_hand_R.png", size:(64.0,128.0),
 potentialFrameCount:1   );///magic_hand_small_L.png
static const FileDataClass magicHandSmallL = 
(path:"assets/images/ui/magic_hand_small_L.png",flamePath:"ui/magic_hand_small_L.png", size:(32.0,64.0),
 potentialFrameCount:1   );///magic_hand_small_R.png
static const FileDataClass magicHandSmallR = 
(path:"assets/images/ui/magic_hand_small_R.png",flamePath:"ui/magic_hand_small_R.png", size:(32.0,64.0),
 potentialFrameCount:1   );///magic_icon_small.png
static const FileDataClass magicIconSmall = 
(path:"assets/images/ui/magic_icon_small.png",flamePath:"ui/magic_icon_small.png", size:(48.0,16.0),
 potentialFrameCount:3   );///melee_icon_small.png
static const FileDataClass meleeIconSmall = 
(path:"assets/images/ui/melee_icon_small.png",flamePath:"ui/melee_icon_small.png", size:(48.0,16.0),
 potentialFrameCount:3   );///padlock.png
static const FileDataClass padlock = 
(path:"assets/images/ui/padlock.png",flamePath:"ui/padlock.png", size:(32.0,32.0),
 potentialFrameCount:1   );///placeholder.png
static const FileDataClass placeholder = 
(path:"assets/images/ui/placeholder.png",flamePath:"ui/placeholder.png", size:(64.0,16.0),
 potentialFrameCount:4   );///placeholder_face.png
static const FileDataClass placeholderFace = 
(path:"assets/images/ui/placeholder_face.png",flamePath:"ui/placeholder_face.png", size:(16.0,20.0),
 potentialFrameCount:1   );///plus_blue.png
static const FileDataClass plusBlue = 
(path:"assets/images/ui/plus_blue.png",flamePath:"ui/plus_blue.png", size:(16.0,16.0),
 potentialFrameCount:1   );///plus_red.png
static const FileDataClass plusRed = 
(path:"assets/images/ui/plus_red.png",flamePath:"ui/plus_red.png", size:(16.0,16.0),
 potentialFrameCount:1   );///ranged_icon_small.png
static const FileDataClass rangedIconSmall = 
(path:"assets/images/ui/ranged_icon_small.png",flamePath:"ui/ranged_icon_small.png", size:(48.0,16.0),
 potentialFrameCount:3   );///stamina_bar_cap.png
static const FileDataClass staminaBarCap = 
(path:"assets/images/ui/stamina_bar_cap.png",flamePath:"ui/stamina_bar_cap.png", size:(8.0,8.0),
 potentialFrameCount:1   );///stamina_bar_mid.png
static const FileDataClass staminaBarMid = 
(path:"assets/images/ui/stamina_bar_mid.png",flamePath:"ui/stamina_bar_mid.png", size:(8.0,8.0),
 potentialFrameCount:1   );///steam_logo_down.png
static const FileDataClass steamLogoDown = 
(path:"assets/images/ui/steam_logo_down.png",flamePath:"ui/steam_logo_down.png", size:(160.0,32.0),
 potentialFrameCount:5   );///steam_logo_up.png
static const FileDataClass steamLogoUp = 
(path:"assets/images/ui/steam_logo_up.png",flamePath:"ui/steam_logo_up.png", size:(160.0,32.0),
 potentialFrameCount:5   );///studies_head_banner.png
static const FileDataClass studiesHeadBanner = 
(path:"assets/images/ui/studies_head_banner.png",flamePath:"ui/studies_head_banner.png", size:(128.0,48.0),
 potentialFrameCount:3   );///weapon_level_indicator.png
static const FileDataClass weaponLevelIndicator = 
(path:"assets/images/ui/weapon_level_indicator.png",flamePath:"ui/weapon_level_indicator.png", size:(32.0,32.0),
 potentialFrameCount:1   );///xp_bar_border.png
static const FileDataClass xpBarBorder = 
(path:"assets/images/ui/xp_bar_border.png",flamePath:"ui/xp_bar_border.png", size:(16.0,8.0),
 potentialFrameCount:2   );///xp_bar_center.png
static const FileDataClass xpBarCenter = 
(path:"assets/images/ui/xp_bar_center.png",flamePath:"ui/xp_bar_center.png", size:(16.0,8.0),
 potentialFrameCount:2   );///xp_bar_left.png
static const FileDataClass xpBarLeft = 
(path:"assets/images/ui/xp_bar_left.png",flamePath:"ui/xp_bar_left.png", size:(16.0,8.0),
 potentialFrameCount:2   );///xp_bar_right.png
static const FileDataClass xpBarRight = 
(path:"assets/images/ui/xp_bar_right.png",flamePath:"ui/xp_bar_right.png", size:(16.0,8.0),
 potentialFrameCount:2   );static  List<String> allFiles = [ammo.path,
ammoEmpty.path,
androidLogoDown.path,
androidLogoUp.path,
arrowBlack.path,
attributeBackground.path,
attributeBackgroundMask.path,
attributeBackgroundMaskSmall.path,
attributeBackgroundSmall.path,
attributeBorder.path,
attributeBorderBase.path,
attributeBorderBaseSmall.path,
attributeBorderEnergy.path,
attributeBorderFire.path,
attributeBorderFrost.path,
attributeBorderMagic.path,
attributeBorderMid.path,
attributeBorderMidSmall.path,
attributeBorderPhysical.path,
attributeBorderPsychic.path,
attributeBorderSmall.path,
bag.path,
banner.path,
book.path,
bossBarBorder.path,
bossBarCenter.path,
bossBarLeft.path,
bossBarRight.path,
cursorDown.path,
cursorUp.path,
elementalColumn.path,
elementalPie.path,
healthBar.path,
healthBarCap.path,
healthBarMid.path,
heart.path,
heartBlank.path,
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
placeholder.path,
placeholderFace.path,
plusBlue.path,
plusRed.path,
rangedIconSmall.path,
staminaBarCap.path,
staminaBarMid.path,
steamLogoDown.path,
steamLogoUp.path,
studiesHeadBanner.path,
weaponLevelIndicator.path,
xpBarBorder.path,
xpBarCenter.path,
xpBarLeft.path,
xpBarRight.path,
];
static  List<String> allFilesFlame = [ammo.flamePath,
ammoEmpty.flamePath,
androidLogoDown.flamePath,
androidLogoUp.flamePath,
arrowBlack.flamePath,
attributeBackground.flamePath,
attributeBackgroundMask.flamePath,
attributeBackgroundMaskSmall.flamePath,
attributeBackgroundSmall.flamePath,
attributeBorder.flamePath,
attributeBorderBase.flamePath,
attributeBorderBaseSmall.flamePath,
attributeBorderEnergy.flamePath,
attributeBorderFire.flamePath,
attributeBorderFrost.flamePath,
attributeBorderMagic.flamePath,
attributeBorderMid.flamePath,
attributeBorderMidSmall.flamePath,
attributeBorderPhysical.flamePath,
attributeBorderPsychic.flamePath,
attributeBorderSmall.flamePath,
bag.flamePath,
banner.flamePath,
book.flamePath,
bossBarBorder.flamePath,
bossBarCenter.flamePath,
bossBarLeft.flamePath,
bossBarRight.flamePath,
cursorDown.flamePath,
cursorUp.flamePath,
elementalColumn.flamePath,
elementalPie.flamePath,
healthBar.flamePath,
healthBarCap.flamePath,
healthBarMid.flamePath,
heart.flamePath,
heartBlank.flamePath,
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
placeholder.flamePath,
placeholderFace.flamePath,
plusBlue.flamePath,
plusRed.flamePath,
rangedIconSmall.flamePath,
staminaBarCap.flamePath,
staminaBarMid.flamePath,
steamLogoDown.flamePath,
steamLogoUp.flamePath,
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
(path:"assets/images/ui/ammo/ammo.png",flamePath:"ui/ammo/ammo.png", size:(8.0,8.0),
 potentialFrameCount:1   );///ammo_empty.png
static const FileDataClass ammoEmpty = 
(path:"assets/images/ui/ammo/ammo_empty.png",flamePath:"ui/ammo/ammo_empty.png", size:(8.0,8.0),
 potentialFrameCount:1   );static  List<String> allFiles = [ammo.path,
ammoEmpty.path,
];
static  List<String> allFilesFlame = [ammo.flamePath,
ammoEmpty.flamePath,
];
}
class ImagesAssetsPermanentAttributes {
///defence.png
static const FileDataClass defence = 
(path:"assets/images/ui/permanent_attributes/defence.png",flamePath:"ui/permanent_attributes/defence.png", size:(10.0,13.0),
 potentialFrameCount:1   );///elemental.png
static const FileDataClass elemental = 
(path:"assets/images/ui/permanent_attributes/elemental.png",flamePath:"ui/permanent_attributes/elemental.png", size:(16.0,16.0),
 potentialFrameCount:1   );///mobility.png
static const FileDataClass mobility = 
(path:"assets/images/ui/permanent_attributes/mobility.png",flamePath:"ui/permanent_attributes/mobility.png", size:(12.0,16.0),
 potentialFrameCount:1   );///offence.png
static const FileDataClass offence = 
(path:"assets/images/ui/permanent_attributes/offence.png",flamePath:"ui/permanent_attributes/offence.png", size:(13.0,12.0),
 potentialFrameCount:1   );///resistance.png
static const FileDataClass resistance = 
(path:"assets/images/ui/permanent_attributes/resistance.png",flamePath:"ui/permanent_attributes/resistance.png", size:(13.0,15.0),
 potentialFrameCount:1   );///rune.png
static const FileDataClass rune = 
(path:"assets/images/ui/permanent_attributes/rune.png",flamePath:"ui/permanent_attributes/rune.png", size:(11.0,13.0),
 potentialFrameCount:1   );///rune_locked.png
static const FileDataClass runeLocked = 
(path:"assets/images/ui/permanent_attributes/rune_locked.png",flamePath:"ui/permanent_attributes/rune_locked.png", size:(11.0,13.0),
 potentialFrameCount:1   );///utility.png
static const FileDataClass utility = 
(path:"assets/images/ui/permanent_attributes/utility.png",flamePath:"ui/permanent_attributes/utility.png", size:(11.0,14.0),
 potentialFrameCount:1   );static  List<String> allFiles = [defence.path,
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
class ImagesAssetsTitle {
///energy_title_sprite_sheet_35.png
static const FileDataClass energyTitleSpriteSheet35 = 
(path:"assets/images/ui/title/energy_title_sprite_sheet_35.png",flamePath:"ui/title/energy_title_sprite_sheet_35.png", size:(6720.0,192.0),
 potentialFrameCount:35   );///fire_title_sprite_sheet_35.png
static const FileDataClass fireTitleSpriteSheet35 = 
(path:"assets/images/ui/title/fire_title_sprite_sheet_35.png",flamePath:"ui/title/fire_title_sprite_sheet_35.png", size:(6720.0,192.0),
 potentialFrameCount:35   );///frost_title_sprite_sheet_35.png
static const FileDataClass frostTitleSpriteSheet35 = 
(path:"assets/images/ui/title/frost_title_sprite_sheet_35.png",flamePath:"ui/title/frost_title_sprite_sheet_35.png", size:(6720.0,192.0),
 potentialFrameCount:35   );///healing_title_sprite_sheet_35.png
static const FileDataClass healingTitleSpriteSheet35 = 
(path:"assets/images/ui/title/healing_title_sprite_sheet_35.png",flamePath:"ui/title/healing_title_sprite_sheet_35.png", size:(6720.0,192.0),
 potentialFrameCount:35   );///magic_title_sprite_sheet_35.png
static const FileDataClass magicTitleSpriteSheet35 = 
(path:"assets/images/ui/title/magic_title_sprite_sheet_35.png",flamePath:"ui/title/magic_title_sprite_sheet_35.png", size:(6720.0,192.0),
 potentialFrameCount:35   );///physical_title_sprite_sheet_35.png
static const FileDataClass physicalTitleSpriteSheet35 = 
(path:"assets/images/ui/title/physical_title_sprite_sheet_35.png",flamePath:"ui/title/physical_title_sprite_sheet_35.png", size:(6720.0,192.0),
 potentialFrameCount:35   );///psychic_title_sprite_sheet_35.png
static const FileDataClass psychicTitleSpriteSheet35 = 
(path:"assets/images/ui/title/psychic_title_sprite_sheet_35.png",flamePath:"ui/title/psychic_title_sprite_sheet_35.png", size:(6720.0,192.0),
 potentialFrameCount:35   );static  List<String> allFiles = [energyTitleSpriteSheet35.path,
fireTitleSpriteSheet35.path,
frostTitleSpriteSheet35.path,
healingTitleSpriteSheet35.path,
magicTitleSpriteSheet35.path,
physicalTitleSpriteSheet35.path,
psychicTitleSpriteSheet35.path,
];
static  List<String> allFilesFlame = [energyTitleSpriteSheet35.flamePath,
fireTitleSpriteSheet35.flamePath,
frostTitleSpriteSheet35.flamePath,
healingTitleSpriteSheet35.flamePath,
magicTitleSpriteSheet35.flamePath,
physicalTitleSpriteSheet35.flamePath,
psychicTitleSpriteSheet35.flamePath,
];
}
class ImagesAssetsWeapons {
///muzzle_flash.png
static const FileDataClass muzzleFlash = 
(path:"assets/images/weapons/muzzle_flash.png",flamePath:"weapons/muzzle_flash.png", size:(32.0,32.0),
 potentialFrameCount:1   );static  List<String> allFiles = [muzzleFlash.path,
];
static  List<String> allFilesFlame = [muzzleFlash.flamePath,
];
}
class ImagesAssetsAethertideSpear {
///aethertide_spear.png
static const FileDataClass aethertideSpear = 
(path:"assets/images/weapons/aethertide_spear/aethertide_spear.png",flamePath:"weapons/aethertide_spear/aethertide_spear.png", size:(15.0,152.0),
 potentialFrameCount:0   );///icon.png
static const FileDataClass icon = 
(path:"assets/images/weapons/aethertide_spear/icon.png",flamePath:"weapons/aethertide_spear/icon.png", size:(64.0,15.0),
 potentialFrameCount:4   );static  List<String> allFiles = [aethertideSpear.path,
icon.path,
];
static  List<String> allFilesFlame = [aethertideSpear.flamePath,
icon.flamePath,
];
}
class ImagesAssetsArcaneBlaster {
///arcane_blaster.png
static const FileDataClass arcaneBlaster = 
(path:"assets/images/weapons/arcane_blaster/arcane_blaster.png",flamePath:"weapons/arcane_blaster/arcane_blaster.png", size:(33.0,79.0),
 potentialFrameCount:0   );///icon.png
static const FileDataClass icon = 
(path:"assets/images/weapons/arcane_blaster/icon.png",flamePath:"weapons/arcane_blaster/icon.png", size:(64.0,32.0),
 potentialFrameCount:2   );static  List<String> allFiles = [arcaneBlaster.path,
icon.path,
];
static  List<String> allFilesFlame = [arcaneBlaster.flamePath,
icon.flamePath,
];
}
class ImagesAssetsCharge {
///energy_charge_charged.png
static const FileDataClass energyChargeCharged = 
(path:"assets/images/weapons/charge/energy_charge_charged.png",flamePath:"weapons/charge/energy_charge_charged.png", size:(192.0,32.0),
 potentialFrameCount:6   );///energy_charge_end.png
static const FileDataClass energyChargeEnd = 
(path:"assets/images/weapons/charge/energy_charge_end.png",flamePath:"weapons/charge/energy_charge_end.png", size:(64.0,16.0),
 potentialFrameCount:4   );///energy_charge_play.png
static const FileDataClass energyChargePlay = 
(path:"assets/images/weapons/charge/energy_charge_play.png",flamePath:"weapons/charge/energy_charge_play.png", size:(48.0,16.0),
 potentialFrameCount:3   );///energy_charge_spawn.png
static const FileDataClass energyChargeSpawn = 
(path:"assets/images/weapons/charge/energy_charge_spawn.png",flamePath:"weapons/charge/energy_charge_spawn.png", size:(80.0,16.0),
 potentialFrameCount:5   );///fire_charge_charged.png
static const FileDataClass fireChargeCharged = 
(path:"assets/images/weapons/charge/fire_charge_charged.png",flamePath:"weapons/charge/fire_charge_charged.png", size:(192.0,32.0),
 potentialFrameCount:6   );///fire_charge_end.png
static const FileDataClass fireChargeEnd = 
(path:"assets/images/weapons/charge/fire_charge_end.png",flamePath:"weapons/charge/fire_charge_end.png", size:(64.0,16.0),
 potentialFrameCount:4   );///fire_charge_play.png
static const FileDataClass fireChargePlay = 
(path:"assets/images/weapons/charge/fire_charge_play.png",flamePath:"weapons/charge/fire_charge_play.png", size:(48.0,16.0),
 potentialFrameCount:3   );///fire_charge_spawn.png
static const FileDataClass fireChargeSpawn = 
(path:"assets/images/weapons/charge/fire_charge_spawn.png",flamePath:"weapons/charge/fire_charge_spawn.png", size:(80.0,16.0),
 potentialFrameCount:5   );///frost_charge_charged.png
static const FileDataClass frostChargeCharged = 
(path:"assets/images/weapons/charge/frost_charge_charged.png",flamePath:"weapons/charge/frost_charge_charged.png", size:(192.0,32.0),
 potentialFrameCount:6   );///frost_charge_end.png
static const FileDataClass frostChargeEnd = 
(path:"assets/images/weapons/charge/frost_charge_end.png",flamePath:"weapons/charge/frost_charge_end.png", size:(64.0,16.0),
 potentialFrameCount:4   );///frost_charge_play.png
static const FileDataClass frostChargePlay = 
(path:"assets/images/weapons/charge/frost_charge_play.png",flamePath:"weapons/charge/frost_charge_play.png", size:(48.0,16.0),
 potentialFrameCount:3   );///frost_charge_spawn.png
static const FileDataClass frostChargeSpawn = 
(path:"assets/images/weapons/charge/frost_charge_spawn.png",flamePath:"weapons/charge/frost_charge_spawn.png", size:(80.0,16.0),
 potentialFrameCount:5   );///magic_charge_charged.png
static const FileDataClass magicChargeCharged = 
(path:"assets/images/weapons/charge/magic_charge_charged.png",flamePath:"weapons/charge/magic_charge_charged.png", size:(192.0,32.0),
 potentialFrameCount:6   );///magic_charge_end.png
static const FileDataClass magicChargeEnd = 
(path:"assets/images/weapons/charge/magic_charge_end.png",flamePath:"weapons/charge/magic_charge_end.png", size:(64.0,16.0),
 potentialFrameCount:4   );///magic_charge_play.png
static const FileDataClass magicChargePlay = 
(path:"assets/images/weapons/charge/magic_charge_play.png",flamePath:"weapons/charge/magic_charge_play.png", size:(48.0,16.0),
 potentialFrameCount:3   );///magic_charge_spawn.png
static const FileDataClass magicChargeSpawn = 
(path:"assets/images/weapons/charge/magic_charge_spawn.png",flamePath:"weapons/charge/magic_charge_spawn.png", size:(80.0,16.0),
 potentialFrameCount:5   );///physical_charge_charged.png
static const FileDataClass physicalChargeCharged = 
(path:"assets/images/weapons/charge/physical_charge_charged.png",flamePath:"weapons/charge/physical_charge_charged.png", size:(192.0,32.0),
 potentialFrameCount:6   );///physical_charge_end.png
static const FileDataClass physicalChargeEnd = 
(path:"assets/images/weapons/charge/physical_charge_end.png",flamePath:"weapons/charge/physical_charge_end.png", size:(64.0,16.0),
 potentialFrameCount:4   );///physical_charge_play.png
static const FileDataClass physicalChargePlay = 
(path:"assets/images/weapons/charge/physical_charge_play.png",flamePath:"weapons/charge/physical_charge_play.png", size:(48.0,16.0),
 potentialFrameCount:3   );///physical_charge_spawn.png
static const FileDataClass physicalChargeSpawn = 
(path:"assets/images/weapons/charge/physical_charge_spawn.png",flamePath:"weapons/charge/physical_charge_spawn.png", size:(80.0,16.0),
 potentialFrameCount:5   );///psychic_charge_charged.png
static const FileDataClass psychicChargeCharged = 
(path:"assets/images/weapons/charge/psychic_charge_charged.png",flamePath:"weapons/charge/psychic_charge_charged.png", size:(192.0,32.0),
 potentialFrameCount:6   );///psychic_charge_end.png
static const FileDataClass psychicChargeEnd = 
(path:"assets/images/weapons/charge/psychic_charge_end.png",flamePath:"weapons/charge/psychic_charge_end.png", size:(64.0,16.0),
 potentialFrameCount:4   );///psychic_charge_play.png
static const FileDataClass psychicChargePlay = 
(path:"assets/images/weapons/charge/psychic_charge_play.png",flamePath:"weapons/charge/psychic_charge_play.png", size:(48.0,16.0),
 potentialFrameCount:3   );///psychic_charge_spawn.png
static const FileDataClass psychicChargeSpawn = 
(path:"assets/images/weapons/charge/psychic_charge_spawn.png",flamePath:"weapons/charge/psychic_charge_spawn.png", size:(80.0,16.0),
 potentialFrameCount:5   );static  List<String> allFiles = [energyChargeCharged.path,
energyChargeEnd.path,
energyChargePlay.path,
energyChargeSpawn.path,
fireChargeCharged.path,
fireChargeEnd.path,
fireChargePlay.path,
fireChargeSpawn.path,
frostChargeCharged.path,
frostChargeEnd.path,
frostChargePlay.path,
frostChargeSpawn.path,
magicChargeCharged.path,
magicChargeEnd.path,
magicChargePlay.path,
magicChargeSpawn.path,
physicalChargeCharged.path,
physicalChargeEnd.path,
physicalChargePlay.path,
physicalChargeSpawn.path,
psychicChargeCharged.path,
psychicChargeEnd.path,
psychicChargePlay.path,
psychicChargeSpawn.path,
];
static  List<String> allFilesFlame = [energyChargeCharged.flamePath,
energyChargeEnd.flamePath,
energyChargePlay.flamePath,
energyChargeSpawn.flamePath,
fireChargeCharged.flamePath,
fireChargeEnd.flamePath,
fireChargePlay.flamePath,
fireChargeSpawn.flamePath,
frostChargeCharged.flamePath,
frostChargeEnd.flamePath,
frostChargePlay.flamePath,
frostChargeSpawn.flamePath,
magicChargeCharged.flamePath,
magicChargeEnd.flamePath,
magicChargePlay.flamePath,
magicChargeSpawn.flamePath,
physicalChargeCharged.flamePath,
physicalChargeEnd.flamePath,
physicalChargePlay.flamePath,
physicalChargeSpawn.flamePath,
psychicChargeCharged.flamePath,
psychicChargeEnd.flamePath,
psychicChargePlay.flamePath,
psychicChargeSpawn.flamePath,
];
}
class ImagesAssetsCrystalPistol {
///crystal_pistol.png
static const FileDataClass crystalPistol = 
(path:"assets/images/weapons/crystal_pistol/crystal_pistol.png",flamePath:"weapons/crystal_pistol/crystal_pistol.png", size:(28.0,44.0),
 potentialFrameCount:1   );///icon.png
static const FileDataClass icon = 
(path:"assets/images/weapons/crystal_pistol/icon.png",flamePath:"weapons/crystal_pistol/icon.png", size:(44.0,28.0),
 potentialFrameCount:2   );static  List<String> allFiles = [crystalPistol.path,
icon.path,
];
static  List<String> allFilesFlame = [crystalPistol.flamePath,
icon.flamePath,
];
}
class ImagesAssetsCrystalSword {
///crystal_sword.png
static const FileDataClass crystalSword = 
(path:"assets/images/weapons/crystal_sword/crystal_sword.png",flamePath:"weapons/crystal_sword/crystal_sword.png", size:(35.0,114.0),
 potentialFrameCount:0   );///icon.png
static const FileDataClass icon = 
(path:"assets/images/weapons/crystal_sword/icon.png",flamePath:"weapons/crystal_sword/icon.png", size:(64.0,33.0),
 potentialFrameCount:2   );static  List<String> allFiles = [crystalSword.path,
icon.path,
];
static  List<String> allFilesFlame = [crystalSword.flamePath,
icon.flamePath,
];
}
class ImagesAssetsDefaultBook {
///book_fire.png
static const FileDataClass bookFire = 
(path:"assets/images/weapons/default_book/book_fire.png",flamePath:"weapons/default_book/book_fire.png", size:(63.0,32.0),
 potentialFrameCount:2   );///book_idle.png
static const FileDataClass bookIdle = 
(path:"assets/images/weapons/default_book/book_idle.png",flamePath:"weapons/default_book/book_idle.png", size:(62.0,41.0),
 potentialFrameCount:2   );static  List<String> allFiles = [bookFire.path,
bookIdle.path,
];
static  List<String> allFilesFlame = [bookFire.flamePath,
bookIdle.flamePath,
];
}
class ImagesAssetsDefaultWand {
///icon.png
static const FileDataClass icon = 
(path:"assets/images/weapons/default_wand/icon.png",flamePath:"weapons/default_wand/icon.png", size:(64.0,16.0),
 potentialFrameCount:4   );///wand_idle.png
static const FileDataClass wandIdle = 
(path:"assets/images/weapons/default_wand/wand_idle.png",flamePath:"weapons/default_wand/wand_idle.png", size:(16.0,64.0),
 potentialFrameCount:0   );static  List<String> allFiles = [icon.path,
wandIdle.path,
];
static  List<String> allFilesFlame = [icon.flamePath,
wandIdle.flamePath,
];
}
class ImagesAssetsEldritchRunner {
///eldritch_runner.png
static const FileDataClass eldritchRunner = 
(path:"assets/images/weapons/eldritch_runner/eldritch_runner.png",flamePath:"weapons/eldritch_runner/eldritch_runner.png", size:(43.0,86.0),
 potentialFrameCount:1   );static  List<String> allFiles = [eldritchRunner.path,
];
static  List<String> allFilesFlame = [eldritchRunner.flamePath,
];
}
class ImagesAssetsEmberBow {
///ember_bow.png
static const FileDataClass emberBow = 
(path:"assets/images/weapons/ember_bow/ember_bow.png",flamePath:"weapons/ember_bow/ember_bow.png", size:(96.0,32.0),
 potentialFrameCount:3   );static  List<String> allFiles = [emberBow.path,
];
static  List<String> allFilesFlame = [emberBow.flamePath,
];
}
class ImagesAssetsFlameSword {
///flame_sword.png
static const FileDataClass flameSword = 
(path:"assets/images/weapons/flame_sword/flame_sword.png",flamePath:"weapons/flame_sword/flame_sword.png", size:(42.0,103.0),
 potentialFrameCount:0   );///icon.png
static const FileDataClass icon = 
(path:"assets/images/weapons/flame_sword/icon.png",flamePath:"weapons/flame_sword/icon.png", size:(48.0,33.0),
 potentialFrameCount:1   );static  List<String> allFiles = [flameSword.path,
icon.path,
];
static  List<String> allFilesFlame = [flameSword.flamePath,
icon.flamePath,
];
}
class ImagesAssetsFrostKatana {
///frost_katana.png
static const FileDataClass frostKatana = 
(path:"assets/images/weapons/frost_katana/frost_katana.png",flamePath:"weapons/frost_katana/frost_katana.png", size:(28.0,152.0),
 potentialFrameCount:0   );///icon.png
static const FileDataClass icon = 
(path:"assets/images/weapons/frost_katana/icon.png",flamePath:"weapons/frost_katana/icon.png", size:(73.0,28.0),
 potentialFrameCount:3   );static  List<String> allFiles = [frostKatana.path,
icon.path,
];
static  List<String> allFilesFlame = [frostKatana.flamePath,
icon.flamePath,
];
}
class ImagesAssetsHexwoodMaim {
///hexwood_maim.png
static const FileDataClass hexwoodMaim = 
(path:"assets/images/weapons/hexwood_maim/hexwood_maim.png",flamePath:"weapons/hexwood_maim/hexwood_maim.png", size:(817.0,48.0),
 potentialFrameCount:17   );static  List<String> allFiles = [hexwoodMaim.path,
];
static  List<String> allFilesFlame = [hexwoodMaim.flamePath,
];
}
class ImagesAssetsLargeSword {
///large_sword.png
static const FileDataClass largeSword = 
(path:"assets/images/weapons/large_sword/large_sword.png",flamePath:"weapons/large_sword/large_sword.png", size:(26.0,90.0),
 potentialFrameCount:0   );static  List<String> allFiles = [largeSword.path,
];
static  List<String> allFilesFlame = [largeSword.flamePath,
];
}
class ImagesAssetsMelee {
///scratch_1.png
static const FileDataClass scratch1 = 
(path:"assets/images/weapons/melee/scratch_1.png",flamePath:"weapons/melee/scratch_1.png", size:(96.0,16.0),
 potentialFrameCount:6   );///small_crush_effect.png
static const FileDataClass smallCrushEffect = 
(path:"assets/images/weapons/melee/small_crush_effect.png",flamePath:"weapons/melee/small_crush_effect.png", size:(104.0,53.0),
 potentialFrameCount:2   );///small_slash_effect.png
static const FileDataClass smallSlashEffect = 
(path:"assets/images/weapons/melee/small_slash_effect.png",flamePath:"weapons/melee/small_slash_effect.png", size:(154.0,16.0),
 potentialFrameCount:10   );///small_stab_effect.png
static const FileDataClass smallStabEffect = 
(path:"assets/images/weapons/melee/small_stab_effect.png",flamePath:"weapons/melee/small_stab_effect.png", size:(164.0,36.0),
 potentialFrameCount:5   );static  List<String> allFiles = [scratch1.path,
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
class ImagesAssetsMindStaff {
///icon.png
static const FileDataClass icon = 
(path:"assets/images/weapons/mind_staff/icon.png",flamePath:"weapons/mind_staff/icon.png", size:(62.0,27.0),
 potentialFrameCount:2   );///mind_staff.png
static const FileDataClass mindStaff = 
(path:"assets/images/weapons/mind_staff/mind_staff.png",flamePath:"weapons/mind_staff/mind_staff.png", size:(32.0,96.0),
 potentialFrameCount:0   );static  List<String> allFiles = [icon.path,
mindStaff.path,
];
static  List<String> allFilesFlame = [icon.flamePath,
mindStaff.flamePath,
];
}
class ImagesAssetsPhaseDagger {
///icon.png
static const FileDataClass icon = 
(path:"assets/images/weapons/phase_dagger/icon.png",flamePath:"weapons/phase_dagger/icon.png", size:(51.0,22.0),
 potentialFrameCount:2   );///phase_dagger.png
static const FileDataClass phaseDagger = 
(path:"assets/images/weapons/phase_dagger/phase_dagger.png",flamePath:"weapons/phase_dagger/phase_dagger.png", size:(22.0,51.0),
 potentialFrameCount:0   );static  List<String> allFiles = [icon.path,
phaseDagger.path,
];
static  List<String> allFilesFlame = [icon.flamePath,
phaseDagger.flamePath,
];
}
class ImagesAssetsPowerWord {
///icon.png
static const FileDataClass icon = 
(path:"assets/images/weapons/power_word/icon.png",flamePath:"weapons/power_word/icon.png", size:(32.0,32.0),
 potentialFrameCount:1   );///idle.png
static const FileDataClass idle = 
(path:"assets/images/weapons/power_word/idle.png",flamePath:"weapons/power_word/idle.png", size:(32.0,32.0),
 potentialFrameCount:1   );static  List<String> allFiles = [icon.path,
idle.path,
];
static  List<String> allFilesFlame = [icon.flamePath,
idle.flamePath,
];
}
class ImagesAssetsPrismaticBeam {
///prismatic_beam.png
static const FileDataClass prismaticBeam = 
(path:"assets/images/weapons/prismatic_beam/prismatic_beam.png",flamePath:"weapons/prismatic_beam/prismatic_beam.png", size:(32.0,74.0),
 potentialFrameCount:0   );static  List<String> allFiles = [prismaticBeam.path,
];
static  List<String> allFilesFlame = [prismaticBeam.flamePath,
];
}
class ImagesAssetsProjectiles {
///black_muzzle_flash.png
static const FileDataClass blackMuzzleFlash = 
(path:"assets/images/weapons/projectiles/black_muzzle_flash.png",flamePath:"weapons/projectiles/black_muzzle_flash.png", size:(80.0,48.0),
 potentialFrameCount:2   );///fire_muzzle_flash.png
static const FileDataClass fireMuzzleFlash = 
(path:"assets/images/weapons/projectiles/fire_muzzle_flash.png",flamePath:"weapons/projectiles/fire_muzzle_flash.png", size:(80.0,48.0),
 potentialFrameCount:2   );///magic_muzzle_flash.png
static const FileDataClass magicMuzzleFlash = 
(path:"assets/images/weapons/projectiles/magic_muzzle_flash.png",flamePath:"weapons/projectiles/magic_muzzle_flash.png", size:(80.0,48.0),
 potentialFrameCount:2   );static  List<String> allFiles = [blackMuzzleFlash.path,
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
(path:"assets/images/weapons/projectiles/blasts/fire_blast_end.png",flamePath:"weapons/projectiles/blasts/fire_blast_end.png", size:(128.0,32.0),
 potentialFrameCount:4   );///fire_blast_play.png
static const FileDataClass fireBlastPlay = 
(path:"assets/images/weapons/projectiles/blasts/fire_blast_play.png",flamePath:"weapons/projectiles/blasts/fire_blast_play.png", size:(128.0,32.0),
 potentialFrameCount:4   );///fire_blast_play_alt.png
static const FileDataClass fireBlastPlayAlt = 
(path:"assets/images/weapons/projectiles/blasts/fire_blast_play_alt.png",flamePath:"weapons/projectiles/blasts/fire_blast_play_alt.png", size:(128.0,32.0),
 potentialFrameCount:4   );static  List<String> allFiles = [fireBlastEnd.path,
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
(path:"assets/images/weapons/projectiles/bullets/black_bullet_end.png",flamePath:"weapons/projectiles/bullets/black_bullet_end.png", size:(48.0,16.0),
 potentialFrameCount:3   );///black_bullet_hit.png
static const FileDataClass blackBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/black_bullet_hit.png",flamePath:"weapons/projectiles/bullets/black_bullet_hit.png", size:(246.0,36.0),
 potentialFrameCount:7   );///black_bullet_play.png
static const FileDataClass blackBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/black_bullet_play.png",flamePath:"weapons/projectiles/bullets/black_bullet_play.png", size:(64.0,16.0),
 potentialFrameCount:4   );///black_bullet_spawn.png
static const FileDataClass blackBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/black_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/black_bullet_spawn.png", size:(64.0,16.0),
 potentialFrameCount:4   );///energy_bullet_end.png
static const FileDataClass energyBulletEnd = 
(path:"assets/images/weapons/projectiles/bullets/energy_bullet_end.png",flamePath:"weapons/projectiles/bullets/energy_bullet_end.png", size:(48.0,16.0),
 potentialFrameCount:3   );///energy_bullet_hit.png
static const FileDataClass energyBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/energy_bullet_hit.png",flamePath:"weapons/projectiles/bullets/energy_bullet_hit.png", size:(96.0,16.0),
 potentialFrameCount:6   );///energy_bullet_play.png
static const FileDataClass energyBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/energy_bullet_play.png",flamePath:"weapons/projectiles/bullets/energy_bullet_play.png", size:(64.0,16.0),
 potentialFrameCount:4   );///energy_bullet_spawn.png
static const FileDataClass energyBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/energy_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/energy_bullet_spawn.png", size:(64.0,16.0),
 potentialFrameCount:4   );///fire_bullet_end.png
static const FileDataClass fireBulletEnd = 
(path:"assets/images/weapons/projectiles/bullets/fire_bullet_end.png",flamePath:"weapons/projectiles/bullets/fire_bullet_end.png", size:(48.0,16.0),
 potentialFrameCount:3   );///fire_bullet_hit.png
static const FileDataClass fireBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/fire_bullet_hit.png",flamePath:"weapons/projectiles/bullets/fire_bullet_hit.png", size:(96.0,16.0),
 potentialFrameCount:6   );///fire_bullet_play.png
static const FileDataClass fireBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/fire_bullet_play.png",flamePath:"weapons/projectiles/bullets/fire_bullet_play.png", size:(64.0,16.0),
 potentialFrameCount:4   );///fire_bullet_spawn.png
static const FileDataClass fireBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/fire_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/fire_bullet_spawn.png", size:(64.0,16.0),
 potentialFrameCount:4   );///frost_bullet_end.png
static const FileDataClass frostBulletEnd = 
(path:"assets/images/weapons/projectiles/bullets/frost_bullet_end.png",flamePath:"weapons/projectiles/bullets/frost_bullet_end.png", size:(48.0,16.0),
 potentialFrameCount:3   );///frost_bullet_hit.png
static const FileDataClass frostBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/frost_bullet_hit.png",flamePath:"weapons/projectiles/bullets/frost_bullet_hit.png", size:(96.0,16.0),
 potentialFrameCount:6   );///frost_bullet_play.png
static const FileDataClass frostBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/frost_bullet_play.png",flamePath:"weapons/projectiles/bullets/frost_bullet_play.png", size:(64.0,16.0),
 potentialFrameCount:4   );///frost_bullet_spawn.png
static const FileDataClass frostBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/frost_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/frost_bullet_spawn.png", size:(64.0,16.0),
 potentialFrameCount:4   );///healing_bullet_end.png
static const FileDataClass healingBulletEnd = 
(path:"assets/images/weapons/projectiles/bullets/healing_bullet_end.png",flamePath:"weapons/projectiles/bullets/healing_bullet_end.png", size:(48.0,16.0),
 potentialFrameCount:3   );///healing_bullet_hit.png
static const FileDataClass healingBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/healing_bullet_hit.png",flamePath:"weapons/projectiles/bullets/healing_bullet_hit.png", size:(96.0,16.0),
 potentialFrameCount:6   );///healing_bullet_play.png
static const FileDataClass healingBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/healing_bullet_play.png",flamePath:"weapons/projectiles/bullets/healing_bullet_play.png", size:(64.0,16.0),
 potentialFrameCount:4   );///healing_bullet_spawn.png
static const FileDataClass healingBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/healing_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/healing_bullet_spawn.png", size:(64.0,16.0),
 potentialFrameCount:4   );///holy_bullet_play.png
static const FileDataClass holyBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/holy_bullet_play.png",flamePath:"weapons/projectiles/bullets/holy_bullet_play.png", size:(45.0,101.0),
 potentialFrameCount:0   );///holy_bullet_spawn.png
static const FileDataClass holyBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/holy_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/holy_bullet_spawn.png", size:(45.0,101.0),
 potentialFrameCount:0   );///magic_bullet_end.png
static const FileDataClass magicBulletEnd = 
(path:"assets/images/weapons/projectiles/bullets/magic_bullet_end.png",flamePath:"weapons/projectiles/bullets/magic_bullet_end.png", size:(48.0,16.0),
 potentialFrameCount:3   );///magic_bullet_hit.png
static const FileDataClass magicBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/magic_bullet_hit.png",flamePath:"weapons/projectiles/bullets/magic_bullet_hit.png", size:(96.0,16.0),
 potentialFrameCount:6   );///magic_bullet_play.png
static const FileDataClass magicBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/magic_bullet_play.png",flamePath:"weapons/projectiles/bullets/magic_bullet_play.png", size:(64.0,16.0),
 potentialFrameCount:4   );///magic_bullet_spawn.png
static const FileDataClass magicBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/magic_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/magic_bullet_spawn.png", size:(64.0,16.0),
 potentialFrameCount:4   );///physical_bullet_end.png
static const FileDataClass physicalBulletEnd = 
(path:"assets/images/weapons/projectiles/bullets/physical_bullet_end.png",flamePath:"weapons/projectiles/bullets/physical_bullet_end.png", size:(48.0,16.0),
 potentialFrameCount:3   );///physical_bullet_hit.png
static const FileDataClass physicalBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/physical_bullet_hit.png",flamePath:"weapons/projectiles/bullets/physical_bullet_hit.png", size:(96.0,16.0),
 potentialFrameCount:6   );///physical_bullet_play.png
static const FileDataClass physicalBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/physical_bullet_play.png",flamePath:"weapons/projectiles/bullets/physical_bullet_play.png", size:(64.0,16.0),
 potentialFrameCount:4   );///physical_bullet_spawn.png
static const FileDataClass physicalBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/physical_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/physical_bullet_spawn.png", size:(64.0,16.0),
 potentialFrameCount:4   );///psychic_bullet_end.png
static const FileDataClass psychicBulletEnd = 
(path:"assets/images/weapons/projectiles/bullets/psychic_bullet_end.png",flamePath:"weapons/projectiles/bullets/psychic_bullet_end.png", size:(48.0,16.0),
 potentialFrameCount:3   );///psychic_bullet_hit.png
static const FileDataClass psychicBulletHit = 
(path:"assets/images/weapons/projectiles/bullets/psychic_bullet_hit.png",flamePath:"weapons/projectiles/bullets/psychic_bullet_hit.png", size:(96.0,16.0),
 potentialFrameCount:6   );///psychic_bullet_play.png
static const FileDataClass psychicBulletPlay = 
(path:"assets/images/weapons/projectiles/bullets/psychic_bullet_play.png",flamePath:"weapons/projectiles/bullets/psychic_bullet_play.png", size:(64.0,16.0),
 potentialFrameCount:4   );///psychic_bullet_spawn.png
static const FileDataClass psychicBulletSpawn = 
(path:"assets/images/weapons/projectiles/bullets/psychic_bullet_spawn.png",flamePath:"weapons/projectiles/bullets/psychic_bullet_spawn.png", size:(64.0,16.0),
 potentialFrameCount:4   );static  List<String> allFiles = [blackBulletEnd.path,
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
(path:"assets/images/weapons/projectiles/magic/energy_hit.png",flamePath:"weapons/projectiles/magic/energy_hit.png", size:(128.0,32.0),
 potentialFrameCount:4   );///energy_play.png
static const FileDataClass energyPlay = 
(path:"assets/images/weapons/projectiles/magic/energy_play.png",flamePath:"weapons/projectiles/magic/energy_play.png", size:(288.0,71.0),
 potentialFrameCount:4   );///fire_hit.png
static const FileDataClass fireHit = 
(path:"assets/images/weapons/projectiles/magic/fire_hit.png",flamePath:"weapons/projectiles/magic/fire_hit.png", size:(128.0,32.0),
 potentialFrameCount:4   );///fire_play.png
static const FileDataClass firePlay = 
(path:"assets/images/weapons/projectiles/magic/fire_play.png",flamePath:"weapons/projectiles/magic/fire_play.png", size:(52.0,48.0),
 potentialFrameCount:1   );///fire_play_big.png
static const FileDataClass firePlayBig = 
(path:"assets/images/weapons/projectiles/magic/fire_play_big.png",flamePath:"weapons/projectiles/magic/fire_play_big.png", size:(64.0,32.0),
 potentialFrameCount:2   );///frost_hit.png
static const FileDataClass frostHit = 
(path:"assets/images/weapons/projectiles/magic/frost_hit.png",flamePath:"weapons/projectiles/magic/frost_hit.png", size:(144.0,24.0),
 potentialFrameCount:6   );///frost_play.png
static const FileDataClass frostPlay = 
(path:"assets/images/weapons/projectiles/magic/frost_play.png",flamePath:"weapons/projectiles/magic/frost_play.png", size:(48.0,32.0),
 potentialFrameCount:2   );///frost_play_big.png
static const FileDataClass frostPlayBig = 
(path:"assets/images/weapons/projectiles/magic/frost_play_big.png",flamePath:"weapons/projectiles/magic/frost_play_big.png", size:(48.0,32.0),
 potentialFrameCount:2   );///frost_spawn.png
static const FileDataClass frostSpawn = 
(path:"assets/images/weapons/projectiles/magic/frost_spawn.png",flamePath:"weapons/projectiles/magic/frost_spawn.png", size:(48.0,32.0),
 potentialFrameCount:2   );///frost_spawn_big.png
static const FileDataClass frostSpawnBig = 
(path:"assets/images/weapons/projectiles/magic/frost_spawn_big.png",flamePath:"weapons/projectiles/magic/frost_spawn_big.png", size:(48.0,32.0),
 potentialFrameCount:2   );///magic_play.png
static const FileDataClass magicPlay = 
(path:"assets/images/weapons/projectiles/magic/magic_play.png",flamePath:"weapons/projectiles/magic/magic_play.png", size:(288.0,32.0),
 potentialFrameCount:9   );///magic_play_big.png
static const FileDataClass magicPlayBig = 
(path:"assets/images/weapons/projectiles/magic/magic_play_big.png",flamePath:"weapons/projectiles/magic/magic_play_big.png", size:(1152.0,128.0),
 potentialFrameCount:9   );///psychic_hit.png
static const FileDataClass psychicHit = 
(path:"assets/images/weapons/projectiles/magic/psychic_hit.png",flamePath:"weapons/projectiles/magic/psychic_hit.png", size:(80.0,16.0),
 potentialFrameCount:5   );///psychic_play.png
static const FileDataClass psychicPlay = 
(path:"assets/images/weapons/projectiles/magic/psychic_play.png",flamePath:"weapons/projectiles/magic/psychic_play.png", size:(128.0,32.0),
 potentialFrameCount:4   );///psychic_play_big.png
static const FileDataClass psychicPlayBig = 
(path:"assets/images/weapons/projectiles/magic/psychic_play_big.png",flamePath:"weapons/projectiles/magic/psychic_play_big.png", size:(64.0,16.0),
 potentialFrameCount:4   );///psychic_spawn_big.png
static const FileDataClass psychicSpawnBig = 
(path:"assets/images/weapons/projectiles/magic/psychic_spawn_big.png",flamePath:"weapons/projectiles/magic/psychic_spawn_big.png", size:(96.0,16.0),
 potentialFrameCount:6   );static  List<String> allFiles = [energyHit.path,
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
class ImagesAssetsRailspire {
///railspire.png
static const FileDataClass railspire = 
(path:"assets/images/weapons/railspire/railspire.png",flamePath:"weapons/railspire/railspire.png", size:(36.0,89.0),
 potentialFrameCount:0   );static  List<String> allFiles = [railspire.path,
];
static  List<String> allFilesFlame = [railspire.flamePath,
];
}
class ImagesAssetsSanctifiedEdge {
///icon.png
static const FileDataClass icon = 
(path:"assets/images/weapons/sanctified_edge/icon.png",flamePath:"weapons/sanctified_edge/icon.png", size:(58.0,42.0),
 potentialFrameCount:1   );///sanctified_edge.png
static const FileDataClass sanctifiedEdge = 
(path:"assets/images/weapons/sanctified_edge/sanctified_edge.png",flamePath:"weapons/sanctified_edge/sanctified_edge.png", size:(54.0,142.0),
 potentialFrameCount:0   );///sanctified_edge_idle.png
static const FileDataClass sanctifiedEdgeIdle = 
(path:"assets/images/weapons/sanctified_edge/sanctified_edge_idle.png",flamePath:"weapons/sanctified_edge/sanctified_edge_idle.png", size:(162.0,142.0),
 potentialFrameCount:1   );static  List<String> allFiles = [icon.path,
sanctifiedEdge.path,
sanctifiedEdgeIdle.path,
];
static  List<String> allFilesFlame = [icon.flamePath,
sanctifiedEdge.flamePath,
sanctifiedEdgeIdle.flamePath,
];
}
class ImagesAssetsScatterBlast {
///icon.png
static const FileDataClass icon = 
(path:"assets/images/weapons/scatter_blast/icon.png",flamePath:"weapons/scatter_blast/icon.png", size:(59.0,18.0),
 potentialFrameCount:3   );///scatter_blast.png
static const FileDataClass scatterBlast = 
(path:"assets/images/weapons/scatter_blast/scatter_blast.png",flamePath:"weapons/scatter_blast/scatter_blast.png", size:(18.0,102.0),
 potentialFrameCount:0   );static  List<String> allFiles = [icon.path,
scatterBlast.path,
];
static  List<String> allFilesFlame = [icon.flamePath,
scatterBlast.flamePath,
];
}
class ImagesAssetsScryshot {
///icon.png
static const FileDataClass icon = 
(path:"assets/images/weapons/scryshot/icon.png",flamePath:"weapons/scryshot/icon.png", size:(41.0,20.0),
 potentialFrameCount:2   );///scryshot.png
static const FileDataClass scryshot = 
(path:"assets/images/weapons/scryshot/scryshot.png",flamePath:"weapons/scryshot/scryshot.png", size:(64.0,128.0),
 potentialFrameCount:1   );///scryshot_attack.png
static const FileDataClass scryshotAttack = 
(path:"assets/images/weapons/scryshot/scryshot_attack.png",flamePath:"weapons/scryshot/scryshot_attack.png", size:(192.0,64.0),
 potentialFrameCount:3   );///scryshot_idle.png
static const FileDataClass scryshotIdle = 
(path:"assets/images/weapons/scryshot/scryshot_idle.png",flamePath:"weapons/scryshot/scryshot_idle.png", size:(608.0,64.0),
 potentialFrameCount:10   );static  List<String> allFiles = [icon.path,
scryshot.path,
scryshotAttack.path,
scryshotIdle.path,
];
static  List<String> allFilesFlame = [icon.flamePath,
scryshot.flamePath,
scryshotAttack.flamePath,
scryshotIdle.flamePath,
];
}
class ImagesAssetsBloodlust {
///bloodlust_6.png
static const FileDataClass bloodlust6 = 
(path:"assets/images/weapons/secondaries/bloodlust/bloodlust_6.png",flamePath:"weapons/secondaries/bloodlust/bloodlust_6.png", size:(48.0,8.0),
 potentialFrameCount:6   );static  List<String> allFiles = [bloodlust6.path,
];
static  List<String> allFilesFlame = [bloodlust6.flamePath,
];
}
class ImagesAssetsShadowBlink {
///ready.png
static const FileDataClass ready = 
(path:"assets/images/weapons/secondaries/shadow_blink/ready.png",flamePath:"weapons/secondaries/shadow_blink/ready.png", size:(8.0,8.0),
 potentialFrameCount:1   );///waiting.png
static const FileDataClass waiting = 
(path:"assets/images/weapons/secondaries/shadow_blink/waiting.png",flamePath:"weapons/secondaries/shadow_blink/waiting.png", size:(16.0,8.0),
 potentialFrameCount:2   );static  List<String> allFiles = [ready.path,
waiting.path,
];
static  List<String> allFilesFlame = [ready.flamePath,
waiting.flamePath,
];
}
class ImagesAssetsSwordKladenets {
///sword_kladenets.png
static const FileDataClass swordKladenets = 
(path:"assets/images/weapons/sword_kladenets/sword_kladenets.png",flamePath:"weapons/sword_kladenets/sword_kladenets.png", size:(35.0,114.0),
 potentialFrameCount:0   );static  List<String> allFiles = [swordKladenets.path,
];
static  List<String> allFilesFlame = [swordKladenets.flamePath,
];
}
class ImagesAssetsSwordOfJustice {
///icon.png
static const FileDataClass icon = 
(path:"assets/images/weapons/sword_of_justice/icon.png",flamePath:"weapons/sword_of_justice/icon.png", size:(68.0,46.0),
 potentialFrameCount:1   );///sword_of_justice.png
static const FileDataClass swordOfJustice = 
(path:"assets/images/weapons/sword_of_justice/sword_of_justice.png",flamePath:"weapons/sword_of_justice/sword_of_justice.png", size:(46.0,135.0),
 potentialFrameCount:0   );static  List<String> allFiles = [icon.path,
swordOfJustice.path,
];
static  List<String> allFilesFlame = [icon.flamePath,
swordOfJustice.flamePath,
];
}
class ImagesAssetsTuiCamai {
///tui_camai.png
static const FileDataClass tuiCamai = 
(path:"assets/images/weapons/tui_camai/tui_camai.png",flamePath:"weapons/tui_camai/tui_camai.png", size:(35.0,114.0),
 potentialFrameCount:0   );static  List<String> allFiles = [tuiCamai.path,
];
static  List<String> allFilesFlame = [tuiCamai.flamePath,
];
}
class JsonsAssetsAudioMappings {
///weapons.json
static const FileDataClass weapons = 
(path:"assets/jsons/audio_mappings/weapons.json",flamePath:"audio_mappings/weapons.json", size:null,
 potentialFrameCount:null   );static  List<String> allFiles = [weapons.path,
];
static  List<String> allFilesFlame = [weapons.flamePath,
];
}
