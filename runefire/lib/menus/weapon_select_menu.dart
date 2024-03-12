import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/menus/custom_widgets.dart';
import 'package:runefire/menus/options.dart';
import 'package:runefire/menus/permanent_attribute_menu.dart';
import 'package:runefire/menus/weapon_selector_tile.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
// import 'package:simple_shadow/simple_shadow.dart';

import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/menus/custom_button.dart';
import 'package:runefire/menus/character_switcher.dart';
import 'package:runefire/menus/menus.dart';

class WeaponSecondaryTile extends StatelessWidget {
  const WeaponSecondaryTile({
    required this.onTap,
    required this.level,
    required this.isPrimary,
    this.weaponType,
    this.secondaryType,
    super.key,
  });
  final Function onTap;
  final WeaponType? weaponType;
  final SecondaryType? secondaryType;
  final int level;
  final radius = 20.0;
  final bool isPrimary;

  Widget buildMainStack(bool animate, bool isHover, bool isWeapon) {
    final hand = buildImageAsset(
      isPrimary
          ?
          // (isWeapon
          //     ?
          ImagesAssetsUi.magicHandL.path
          // :
          // ImagesAssetsUi.magicHandSmallL
          // )
          :
          // (isWeapon
          //     ?
          ImagesAssetsUi.magicHandR.path
      // : ImagesAssetsUi.magicHandSmallR
      // )
      ,
      fit: BoxFit.fitWidth,
    );
    final floatingIcon = SizedBox(
      height: isWeapon ? 250 : 150,
      child: isWeapon
          ? RotatedBox(
              quarterTurns: 2,
              child: buildImageAsset(
                weaponType!.path,
                fit: BoxFit.scaleDown,
                scale: 1 / 3,
              ),
            )
          : buildImageAsset(
              secondaryType!.icon.path,
              fit: BoxFit.contain,
            ), // Default: 2
    );
    final valueBegin = rng.nextDouble();
    final boolBegin = rng.nextBool();

    final floatingIconAnimated = Center(
      child: animate
          ? floatingIcon
              .animate(
                onPlay: (controller) {
                  randomBegin(
                    controller,
                    forward: boolBegin,
                    value: valueBegin,
                  );
                },
                onComplete: onComplete,
              )
              .moveY(
                begin: 5,
                end: -5,
                duration: 2.seconds,
                curve: Curves.easeInOut,
              )
          : floatingIcon,
    );

    final mainStack = Stack(
      children: [
        Positioned(
          top: 0,
          bottom: -200,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.only(right: 8, top: 8),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                ApolloColorPalette.darkestBlue.color.withOpacity(.5),
                BlendMode.srcIn,
              ),
              child: hand,
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: -200,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: animate
                ? Animate(
                    target: isHover ? 1 : 0,
                  ).custom(
                    curve: Curves.fastEaseInToSlowEaseOut,
                    builder: (context, value, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              Colors.blue.shade600
                                  .mergeWith(Colors.white, value),
                              Colors.white,
                            ],
                            stops: const [
                              0,
                              .6,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds);
                        },
                        child: hand,
                      );
                    },
                  )
                : hand,
          ),
        ),
        Positioned(
          top: -200,
          bottom: isWeapon ? 100 : -25,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 16),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                ApolloColorPalette.darkestGray.color.withOpacity(.5),
                BlendMode.srcIn,
              ),
              child: floatingIconAnimated,
            ),
          ),
        ),
        Positioned(
          top: -200,
          bottom: isWeapon ? 100 : -25,
          // bottom: 100,
          left: 0,
          right: 0,
          child: floatingIconAnimated,
        ),
      ],
    );

    return mainStack;
  }

  @override
  Widget build(BuildContext context) {
    assert(weaponType != null || secondaryType != null);
    final isWeapon = weaponType != null;

    var isHover = false;

    return StatefulBuilder(
      builder: (context, setState) {
        final size = MediaQuery.of(context).size;

        return SizedBox(
          width: isWeapon ? 192 : 144,
          child: CustomInputWatcher(
            rowId: 2,
            onPrimary: () => onTap.call(),
            onHover: (value) {
              setState(() {
                isHover = value;
              });
            },
            child: Stack(
              children: [
                Opacity(
                  opacity: .3,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 500),
                    child: buildMainStack(false, false, isWeapon),
                  ),
                ),
                buildMainStack(true, isHover, isWeapon)
                    .animate()
                    .moveY(
                      duration: 1.5.seconds,
                      curve: Curves.fastEaseInToSlowEaseOut,
                      begin: -size.height / 2,
                    )
                    .fade(
                      begin: 0,
                      end: .9,
                      duration: 1.5.seconds,
                      curve: Curves.fastEaseInToSlowEaseOut,
                    )
                    .animate(
                      onPlay: randomBegin,
                      onComplete: onComplete,
                    )
                    .moveY(
                      begin: 10,
                      end: -10,
                      duration: 1.4.seconds,
                      curve: Curves.easeInOut,
                    ),
              ],
            )
                .animate(
                  target: isHover ? 1 : 0,
                )
                .scaleXY(
                  end: 1.125,
                  curve: Curves.linear,
                  duration: .1.seconds,
                ),
          ),
        );
      },
    );
  }
}

void randomBegin(
  AnimationController controller, {
  bool? forward,
  double? value,
}) =>
    (forward ?? rng.nextBool())
        ? controller
            .reverse(from: value ?? rng.nextDouble())
            .then((value) => controller.forward(from: 0))
        : controller.forward(from: value ?? rng.nextDouble());

void onComplete(AnimationController controller) =>
    controller.reverse().then((value) => controller.forward(from: 0));

class WeaponSecondarySelector extends StatefulWidget {
  const WeaponSecondarySelector({
    // required this.onSelect,
    required this.onBack,
    required this.isPrimarySlot,
    required this.isPrimaryAttack,
    required this.gameRef,
    super.key,
  });

  // final Function(dynamic) onSelect;
  final Function() onBack;

  final GameRouter gameRef;
  final bool isPrimarySlot;
  final bool isPrimaryAttack;

  @override
  State<WeaponSecondarySelector> createState() =>
      _WeaponSecondarySelectorState();
}

class _WeaponSecondarySelectorState extends State<WeaponSecondarySelector> {
  // @override
  // GameRouter get gameRef => widget.gameRef;

  // @override
  // void onPlayerDataNotification() {
  //   setState(() {});
  // }

  final borderWidth = 5.0;
  final borderColor = ApolloColorPalette.deepBlue.color.brighten(.1);

  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final entries = <Widget>[];
    if (!widget.isPrimaryAttack) {
      for (final element in AttackType.values) {
        entries.add(
          WeaponSelectorTab(
            gameRef: widget.gameRef,
            scrollController: scrollController,
            isPrimarySlot: widget.isPrimarySlot,
            attackType: element,
          ),
        );
      }
    } else {
      entries.add(
        WeaponSelectorTab(
          gameRef: widget.gameRef,
          scrollController: scrollController,
          isPrimarySlot: widget.isPrimarySlot,
        ),
      );
    }

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: ApolloColorPalette.darkestGray.color.withOpacity(.95),
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Image.asset('assets/images/ui/bag.png'),
                    ).animate().rotate().fadeIn(),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        child: ScrollConfiguration(
                          behavior: scrollConfiguration(context),
                          child: ListView(
                            controller: scrollController,
                            shrinkWrap: true,
                            children: entries
                                .animate(
                                  interval: .15.seconds,
                                  onComplete: (controller) {
                                    InputManager()
                                        .customInputWatcherManager
                                        .updateCustomInputWatcherRectangles();
                                  },
                                )
                                .fadeIn()
                                .moveX(begin: -200, curve: Curves.easeOutCirc),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: menuBaseBarHeight,
              child: Row(
                children: [
                  const SizedBox(
                    width: menuBaseBarWidthPadding,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CustomButton(
                        'Back',
                        zHeight: 1,
                        zIndex: 1,
                        rowId: 999,
                        gameRef: widget.gameRef,
                        onPrimary: () => widget.onBack.call(),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExperiencePointsIndicator(widget.gameRef),
                  ),
                  const SizedBox(
                    width: menuBaseBarWidthPadding,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(),
    );
  }
}

class WeaponMenu extends StatefulWidget {
  const WeaponMenu({
    required this.gameRef,
    super.key,
  });
  final GameRouter gameRef;

  @override
  State<WeaponMenu> createState() => _WeaponMenuState();
}

class _WeaponMenuState extends State<WeaponMenu> {
  late ComponentsNotifier<PlayerDataComponent> playerDataNotifier;
  late PlayerDataComponent playerDataComponent;

  @override
  void dispose() {
    playerDataNotifier.removeListener(onPlayerDataNotification);
    super.dispose();
  }

  void onPlayerDataNotification() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    playerDataComponent = widget.gameRef.playerDataComponent;
    playerDataNotifier =
        widget.gameRef.componentsNotifier<PlayerDataComponent>();

    playerDataNotifier.addListener(onPlayerDataNotification);
  }

  Widget? _weaponSelector;

  void clearOverlays() {
    _weaponSelector = null;
    _attributeUpgrader = null;
  }

  Widget? _attributeUpgrader;

  set weaponSelector(Widget? value) {
    setState(() {
      clearOverlays();
      _weaponSelector = value;
    });
  }

  set attributeUpgrader(Widget? value) {
    setState(() {
      clearOverlays();
      _attributeUpgrader = value;
    });
  }

  Function? exitFunction;

  void onExit() {
    if (exitFunction != null) {
      exitFunction!();
    }
  }

  bool studiesButtonHover = false;
  @override
  Widget build(BuildContext context) {
    final weaponMap = playerDataComponent.dataObject.selectedWeapons;
    final secondaryMap = playerDataComponent.dataObject.selectedSecondaries;

    final size = MediaQuery.of(context).size;
    const studyPanelDropAmount = -menuBaseBarHeight;

    Widget buildStudyPanel(double value) => Stack(
          alignment: Alignment.topRight,
          children: [
            Positioned(
              // left: 0,
              right: 0,
              top: studyPanelDropAmount * (1 - value),
              height: menuBaseBarHeight * 2,

              child: CustomInputWatcher(
                rowId: -5,
                zHeight: 1,
                onHover: (value) {
                  setState(() {
                    studiesButtonHover = value;
                  });
                },
                onPrimary: () {
                  attributeUpgrader = AttributeUpgrader(
                    onBack: () {
                      attributeUpgrader = null;
                    },
                    gameRef: widget.gameRef,
                  );
                },
                child: buildImageAsset(
                  ImagesAssetsUi.studiesHeadBanner.path,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            Positioned(
              // left: 0,
              width: 400,
              right: 0,
              top: (studyPanelDropAmount * -value) - menuBaseBarHeight,
              height: menuBaseBarHeight * 2,
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Expanded(
                        child: ExperiencePointsIndicator(widget.gameRef),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: Text(
                          'Runic Studies',
                          style: defaultStyle,
                        ),
                      ),
                      // const SizedBox(
                      //   height: 20,
                      // )
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

    final studiesButton = Animate(
      target: studiesButtonHover ? 1 : 0,
      effects: [
        CustomEffect(
          curve: Curves.easeOut,
          duration: .2.seconds,
          builder: (context, value, child) {
            return buildStudyPanel(value);
          },
        ),
      ],
    );

    final Widget primaryWeaponTile = WeaponSecondaryTile(
      level: playerDataComponent.dataObject.unlockedWeapons[weaponMap[0]] ?? 0,
      isPrimary: true,
      weaponType: weaponMap[0],
      onTap: () {
        weaponSelector = WeaponSecondarySelector(
          key: UniqueKey(),
          isPrimaryAttack: false,
          isPrimarySlot: true,
          gameRef: widget.gameRef,
          onBack: () {
            setState(() {
              weaponSelector = null;
            });
          },
        );
      },
    );

    final Widget primarySecondaryTile = WeaponSecondaryTile(
      isPrimary: true,
      level:
          playerDataComponent.dataObject.unlockedSecondarys[secondaryMap[0]] ??
              0,
      secondaryType: secondaryMap[0],
      onTap: () {
        weaponSelector = WeaponSecondarySelector(
          key: UniqueKey(),
          isPrimaryAttack: true,
          isPrimarySlot: true,
          gameRef: widget.gameRef,
          onBack: () {
            setState(() {
              weaponSelector = null;
            });
          },
        );
      },
    );
    final Widget secondaryWeaponTile = WeaponSecondaryTile(
      level: playerDataComponent.dataObject.unlockedWeapons[weaponMap[1]] ?? 0,
      isPrimary: false,
      weaponType: weaponMap[1],
      onTap: () {
        weaponSelector = WeaponSecondarySelector(
          key: UniqueKey(),
          isPrimaryAttack: false,
          // onSelect: (weaponType) {
          //   if (playerDataComponent.dataObject.selectedWeapons.values
          //       .contains(weaponType)) return;
          //   setState(() {
          //     playerDataComponent.dataObject.selectedWeapons[1] = weaponType;
          //     playerDataComponent.notifyListeners();
          //   });
          // },
          isPrimarySlot: false,
          gameRef: widget.gameRef,
          onBack: () {
            setState(() {
              weaponSelector = null;
            });
          },
        );
      },
    );

    final Widget secondarySecondaryTile = WeaponSecondaryTile(
      isPrimary: false,
      level:
          playerDataComponent.dataObject.unlockedSecondarys[secondaryMap[1]] ??
              0,
      secondaryType: secondaryMap[1],
      onTap: () {
        weaponSelector = WeaponSecondarySelector(
          key: UniqueKey(),
          isPrimaryAttack: true,
          isPrimarySlot: false,
          gameRef: widget.gameRef,
          onBack: () {
            setState(() {
              weaponSelector = null;
            });
          },
        );
      },
    );
    return Stack(
      children: [
        Positioned.fill(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: uiWidthMax),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // const Spacer(),
                // Expanded(child:
                primarySecondaryTile,
                // ),
                // const Spacer(),

                // Expanded(child:
                primaryWeaponTile,
                // ),

                // const Spacer(
                // flex: 5,
                // ),
                SizedBox(
                  width: size.width / 3,
                ),
                // Expanded(child:
                secondaryWeaponTile,
                // ),
                // const Spacer(),
                // Expanded(child:
                secondarySecondaryTile,
                //  ),

                // const Spacer(),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(
                width: menuBaseBarWidthPadding,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CustomButton(
                      'Back',
                      gameRef: widget.gameRef,
                      zHeight: 1,
                      rowId: 5,
                      onPrimary: () {
                        setState(() {
                          exitFunction = () {
                            widget.gameRef.gameStateComponent.gameState
                                .changeMainMenuPage(MenuPageType.startMenuPage);
                          };
                        });
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: 500,
                  child: CharacterSwitcher(
                    gameRef: widget.gameRef,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CustomButton(
                      'Choose Level',
                      rowId: 5,
                      zHeight: 1,
                      gameRef: widget.gameRef,
                      onPrimary: () {
                        if (!playerDataComponent.dataObject
                            .characterUnlocked()) {
                          return;
                        }
                        setState(() {
                          exitFunction = () {
                            widget.gameRef.gameStateComponent.gameState
                                .changeMainMenuPage(MenuPageType.levelMenu);
                          };
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: menuBaseBarWidthPadding,
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(
                width: menuBaseBarWidthPadding,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CustomButton(
                      'Achievements',
                      gameRef: widget.gameRef,
                      zHeight: 1,
                      rowId: 5,
                      onPrimary: () {
                        setState(() {
                          exitFunction = () {
                            widget.gameRef.gameStateComponent.gameState
                                .changeMainMenuPage(
                              MenuPageType.achievementsMenu,
                            );
                          };
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        studiesButton,
        // Positioned.fill(left: 0, child: ),
        if (_weaponSelector != null) _weaponSelector!,
        if (_attributeUpgrader != null) _attributeUpgrader!,
      ],
    )
        .animate(
          target: exitFunction != null ? 1 : 0,
          onComplete: (controller) {
            onExit();
          },
        )
        .fadeOut();
  }
}
