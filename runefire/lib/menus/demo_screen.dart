import 'dart:async';
import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:recase/recase.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/main.dart';
import 'package:runefire/menus/pause_menu.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/constants/routes.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';

typedef DemoBuild = ({
  WeaponType weapon1,
  WeaponType weapon2,
  SecondaryType secondary1,
  SecondaryType secondary2,
  CharacterType characterType
});

Map<DamageType, DemoBuild> demoBuilds = {
  DamageType.fire: (
    weapon1: WeaponType.emberBow,
    weapon2: WeaponType.breathOfFire,
    secondary1: SecondaryType.surroundAttack,
    secondary2: SecondaryType.reloadAndRapidFire,
    characterType: CharacterType.runeKnight
  ),
  DamageType.psychic: (
    weapon1: WeaponType.mindStaff,
    weapon2: WeaponType.phaseDagger,
    secondary1: SecondaryType.surroundAttack,
    secondary2: SecondaryType.bloodlust,
    characterType: CharacterType.runeKnight
  ),
  DamageType.physical: (
    weapon1: WeaponType.arcaneBlaster,
    weapon2: WeaponType.crystalSword,
    secondary1: SecondaryType.reloadAndRapidFire,
    secondary2: SecondaryType.shadowBlink,
    characterType: CharacterType.runeKnight
  ),
  DamageType.energy: (
    weapon1: WeaponType.energyMagic,
    weapon2: WeaponType.sanctifiedEdge,
    secondary1: SecondaryType.reloadAndRapidFire,
    secondary2: SecondaryType.shadowBlink,
    characterType: CharacterType.runeKnight
  ),
  DamageType.magic: (
    weapon1: WeaponType.hexwoodMaim,
    weapon2: WeaponType.aethertideSpear,
    secondary1: SecondaryType.elementalBlast,
    secondary2: SecondaryType.shadowBlink,
    characterType: CharacterType.runeKnight
  ),
  DamageType.frost: (
    weapon1: WeaponType.shimmerRifle,
    weapon2: WeaponType.frostKatana,
    secondary1: SecondaryType.reloadAndRapidFire,
    secondary2: SecondaryType.shadowBlink,
    characterType: CharacterType.runeKnight
  ),
};

class DemoScreen extends StatefulWidget {
  const DemoScreen({required this.gameRef, super.key});
  final GameRouter gameRef;
  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  void setSelectedBuild(DamageType damageType) {
    final playerData = widget.gameRef.playerDataComponent.dataObject;
    final demoBuild = demoBuilds[damageType];
    if (demoBuild == null) {
      return;
    }
    playerData.selectWeapon(
      primaryOrSecondarySlot: 0,
      weaponType: demoBuild.weapon1,
    );
    playerData.selectWeapon(
      primaryOrSecondarySlot: 1,
      weaponType: demoBuild.weapon2,
    );

    playerData.selectSecondary(
      0,
      demoBuild.secondary1,
    );
    playerData.selectSecondary(
      1,
      demoBuild.secondary2,
    );
    playerData.setSelectedCharacter(demoBuild.characterType);

    GameState().toggleGameStart(gameplay);
  }

  Widget buildWidget(DamageType damageType) {
    var hovering = false;
    var selected = false;

    final demoBuild = demoBuilds[damageType];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StatefulBuilder(
        builder: (context, ss) {
          final headerStyle =
              defaultStyle.copyWith(fontSize: 18, color: damageType.color);
          return CustomInputWatcher(
            onHover: (isHover) {
              ss(() {
                hovering = isHover;
              });
            },
            onPrimary: () {
              ss(() {
                selected = true;
                Future.delayed(.3.seconds).then((value) {
                  setSelectedBuild(damageType);
                });
              });
            },
            child: Column(
              children: [
                Text(
                  damageType.name.titleCase,
                  style: defaultStyle.copyWith(color: damageType.color),
                ),
                Container(
                  height: 400 / largeCardSize.aspectRatio,
                  width: 400,
                  child: CustomBorderBox(
                    damageType: damageType,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 24,
                        left: 32,
                        right: 24,
                        bottom: 35,
                      ),
                      child: Column(
                        children: [
                          if (demoBuild != null)
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Expanded(
                                  // child: Row(
                                  //   children: [
                                  Column(
                                    children: [
                                      Text(
                                        demoBuild.weapon1.name.titleCase,
                                        style: headerStyle,
                                      ),
                                      Container(
                                        //Transform to rotate it 90 deg clockwise
                                        //and to flip it horizontally
                                        transform: Matrix4.rotationZ(pi / 2)
                                          ..translate(
                                            0.0,
                                            -80.0,
                                          ),
                                        width: 80,
                                        height: 80,
                                        child: buildImageAsset(
                                          demoBuild.weapon1.path,
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                      Text(
                                        demoBuild.weapon2.name.titleCase,
                                        style: headerStyle,
                                      ),
                                      Container(
                                        //Transform to rotate it 90 deg clockwise
                                        //and to flip it horizontally
                                        transform: Matrix4.rotationZ(pi / 2)
                                          ..translate(
                                            0.0,
                                            -80.0,
                                          ),
                                        width: 80,
                                        height: 80,
                                        child: buildImageAsset(
                                          demoBuild.weapon2.path,
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    // crossAxisAlignment:
                                    //     CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        demoBuild.secondary1.name.titleCase,
                                        style: headerStyle,
                                      ),
                                      Container(
                                        //Transform to rotate it 90 deg clockwise
                                        //and to flip it horizontally

                                        width: 80,
                                        height: 80,
                                        child: buildImageAsset(
                                          demoBuild.secondary1.icon.path,
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                      Text(
                                        demoBuild.secondary2.name.titleCase,
                                        style: headerStyle,
                                      ),
                                      Container(
                                        //Transform to rotate it 90 deg clockwise
                                        //and to flip it horizontally

                                        width: 80,
                                        height: 80,
                                        child: buildImageAsset(
                                          demoBuild.secondary2.icon.path,
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  //   ],
                                  // ),
                                  // ),
                                  // Expanded(
                                  //   child: buildImageAsset(
                                  //     demoBuild.characterType.assetObject.path,
                                  //     fit: BoxFit.fitHeight,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
                .animate(target: hovering ? 1 : 0)
                .scaleXY(
                  duration: 0.1.seconds,
                  begin: 1,
                  end: 1.05,
                )
                .animate(
                  target: selected ? 1 : 0,
                )
                .scaleXY(
                  begin: 1,
                  end: 1.3,
                )
                .fadeOut(
                  duration: .3.seconds,
                ),
          );
        },
      ),
    );
  }

  Completer beginCards = Completer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: FutureBuilder(
            future: beginCards.future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox();
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Demo Builds',
                      style: defaultStyle,
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      children: [
                        for (var i = 0;
                            i < DamageType.getValuesWithoutHealing.length;
                            i++)
                          Builder(
                            builder: (context) {
                              final damageType = DamageType
                                  .getValuesWithoutHealing
                                  .elementAt(i);
                              return buildWidget(damageType);
                            },
                          ),
                      ].animate(interval: .05.seconds).moveY().fadeIn(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Stack(
              children: [
                Text(
                  'Runefire',
                  style: defaultStyle.copyWith(
                    fontSize: 128,
                    color: DamageType.values.random().color,
                    shadows: [],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3, top: 3),
                  child: Text(
                    'Runefire',
                    style: defaultStyle.copyWith(
                      fontSize: 128,
                      color: Colors.white,
                      shadows: [],
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .moveY(
                begin: -20,
                end: 20,
                curve: Curves.easeInOut,
                duration: 3.seconds,
              )
              .fadeIn(
                duration: .3.seconds,
              )
              .animate(
                delay: 2.seconds,
                onComplete: (controller) {
                  if (beginCards.isCompleted) {
                    return;
                  }
                  beginCards.complete();
                },
              )
              .fadeOut(
                duration: .3.seconds,
              ),
        ),
      ],
    );
  }
}
