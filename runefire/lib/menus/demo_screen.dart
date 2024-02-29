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
import 'package:runefire/resources/functions/extensions.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';

enum DemoBuilds {
  starter,
  mage,
  glassCannon,
  flameWarrior,
  warlock,
  frostWizard;
}

typedef DemoBuild = ({
  WeaponType weapon1,
  WeaponType weapon2,
  SecondaryType secondary1,
  SecondaryType secondary2,
  CharacterType characterType,
  DamageType damageType,
});

extension DemoBuildsExtension on DemoBuilds {
  DemoBuild get getBuild {
    switch (this) {
      case DemoBuilds.starter:
        return (
          weapon1: WeaponType.crystalPistol,
          weapon2: WeaponType.crystalSword,
          secondary1: SecondaryType.rapidFire,
          secondary2: SecondaryType.surroundAttack,
          characterType: CharacterType.runeKnight,
          damageType: DamageType.physical,
        );
      case DemoBuilds.mage:
        return (
          weapon1: WeaponType.hexwoodMaim,
          weapon2: WeaponType.aethertideSpear,
          secondary1: SecondaryType.elementalBlast,
          secondary2: SecondaryType.shadowBlink,
          characterType: CharacterType.runeKnight,
          damageType: DamageType.magic,
        );
      case DemoBuilds.glassCannon:
        return (
          weapon1: WeaponType.scatterBlast,
          weapon2: WeaponType.powerWord,
          secondary1: SecondaryType.rapidFire,
          secondary2: SecondaryType.elementalBlast,
          characterType: CharacterType.runeKnight,
          damageType: DamageType.magic,
        );
      case DemoBuilds.flameWarrior:
        return (
          weapon1: WeaponType.fireSword,
          weapon2: WeaponType.fireballMagic,
          secondary1: SecondaryType.surroundAttack,
          secondary2: SecondaryType.instantReload,
          characterType: CharacterType.runeKnight,
          damageType: DamageType.fire,
        );
      case DemoBuilds.warlock:
        return (
          weapon1: WeaponType.swordKladenets,
          weapon2: WeaponType.elementalChannel,
          secondary1: SecondaryType.shadowBlink,
          secondary2: SecondaryType.rapidFire,
          characterType: CharacterType.runeKnight,
          damageType: DamageType.energy,
        );
      case DemoBuilds.frostWizard:
        return (
          weapon1: WeaponType.shimmerRifle,
          weapon2: WeaponType.frostKatana,
          secondary1: SecondaryType.rapidFire,
          secondary2: SecondaryType.shadowBlink,
          characterType: CharacterType.runeKnight,
          damageType: DamageType.frost,
        );
    }
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({required this.gameRef, super.key});
  final GameRouter gameRef;
  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  void setSelectedBuild(DemoBuilds demoBuildSelected) {
    final playerData = widget.gameRef.playerDataComponent.dataObject;
    final demoBuild = demoBuildSelected.getBuild;

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

  Widget buildPairWidget({
    required WeaponType weaponType,
    required SecondaryType secondaryType,
    required DamageType damageType,
  }) {
    final headerStyle = defaultStyle.copyWith(
      fontSize: 18,
      color: damageType.color,
      shadows: [
        BoxShadow(
          color: damageType.color.darken(.45),
          // blurRadius: 2,
          offset: const Offset(1, 1),
          // spreadRadius: 2,
        ),
      ],
    );
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Text(
                  weaponType.name.titleCase,
                  style: headerStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Text(
                  secondaryType.name.titleCase,
                  style: headerStyle,
                ),
              ),
            ].mapExpanded(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                  color: damageType.color.withOpacity(.5),
                  border: Border(
                    bottom: BorderSide(
                      color: damageType.color,
                      width: 3,
                    ),
                    left: BorderSide(
                      color: damageType.color,
                      width: 3,
                    ),
                    right: BorderSide(
                      color: damageType.color,
                      width: 3,
                    ),
                    top: BorderSide(
                      color: damageType.color,
                      width: 3,
                    ),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: damageType.color.darken(.5),
                      width: 3,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Builder(
                    builder: (context) {
                      return Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                  top: 5,
                                ),
                                child: buildImageAsset(
                                  weaponType.path,
                                  fit: BoxFit.contain,
                                  color: damageType.color
                                      .darken(.85)
                                      .withOpacity(.5),
                                ),
                              ),
                              buildImageAsset(
                                weaponType.path,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 5,
                                    top: 5,
                                  ),
                                  child: buildImageAsset(
                                    secondaryType.icon.path,
                                    fit: BoxFit.contain,
                                    color: damageType.color
                                        .darken(.85)
                                        .withOpacity(.5),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: buildImageAsset(
                                  secondaryType.icon.path,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ].mapExpanded(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWidget(DemoBuilds demoBuildSelected) {
    var hovering = false;
    var selected = false;

    final demoBuild = demoBuildSelected.getBuild;
    final damageType = demoBuild.damageType;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StatefulBuilder(
        builder: (context, ss) {
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
                  setSelectedBuild(demoBuildSelected);
                });
              });
            },
            child: Column(
              children: [
                Text(
                  demoBuildSelected.name.titleCase,
                  style: defaultStyle.copyWith(color: damageType.color),
                ),
                const SizedBox(
                  height: 7.5,
                ),
                Container(
                  height: 400 / largeCardSize.aspectRatio,
                  width: 400,
                  child: CustomBorderBox(
                    damageType: damageType,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 24,
                        left: 24,
                        right: 24,
                        bottom: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          buildPairWidget(
                            weaponType: demoBuild.weapon1,
                            secondaryType: demoBuild.secondary1,
                            damageType: damageType,
                          ),
                          buildPairWidget(
                            weaponType: demoBuild.weapon2,
                            secondaryType: demoBuild.secondary2,
                            damageType: damageType,
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
                      'Wireframe Demo',
                      style: defaultStyle,
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      children: [
                        for (var i = 0; i < DemoBuilds.values.length; i++)
                          Builder(
                            builder: (context) {
                              return buildWidget(
                                DemoBuilds.values.elementAt(i),
                              );
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
