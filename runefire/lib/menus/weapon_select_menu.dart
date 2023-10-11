import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/menus/permanent_attribute_menu.dart';
import 'package:runefire/menus/weapon_selector_tile.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:simple_shadow/simple_shadow.dart';

import '../resources/data_classes/player_data.dart';
import '../resources/functions/functions.dart';
import 'custom_button.dart';
import 'character_switcher.dart';
import 'menus.dart';

class WeaponSecondaryTile extends StatelessWidget {
  const WeaponSecondaryTile(
      {required this.onTap,
      this.weaponType,
      this.secondaryType,
      required this.level,
      required this.isPrimary,
      super.key});
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
              child: buildImageAsset(weaponType!.icon,
                  fit: BoxFit.scaleDown, scale: 1 / 3))
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
                    randomBegin(controller,
                        forward: boolBegin, value: valueBegin);
                  },
                  onComplete: onComplete,
                )
                .moveY(
                    begin: 5,
                    end: -5,
                    duration: 2.seconds,
                    curve: Curves.easeInOut)
            : floatingIcon);

    final mainStack = Stack(children: [
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
                BlendMode.srcIn),
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
                        blendMode: BlendMode.modulate,
                        shaderCallback: (bounds) {
                          return LinearGradient(
                                  colors: [
                                Colors.blue.shade600
                                    .mergeWith(Colors.white, value),
                                Colors.white,
                              ],
                                  stops: const [
                                0,
                                .6
                              ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter)
                              .createShader(bounds);
                        },
                        child: hand,
                      );
                    },
                  )
                : hand),
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
                BlendMode.srcIn),
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
    ]);

    return mainStack;
  }

  @override
  Widget build(BuildContext context) {
    assert(weaponType != null || secondaryType != null);
    bool isWeapon = weaponType != null;

    bool isHover = false;

    return StatefulBuilder(builder: (context, setState) {
      final size = MediaQuery.of(context).size;
      // final increase = (size.width / 1500).clamp(.5, 1);

      return SizedBox(
        width: isWeapon ? 192 : 144,
        child: CustomInputWatcher(
            groupId: 20,
            groupOrientation: Axis.horizontal,
            onPrimary: () {
              onTap();
            },
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
                        begin: -size.height / 2)
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
                        curve: Curves.easeInOut)
              ],
            )
                .animate(
                  target: isHover ? 1 : 0,
                )
                .scaleXY(
                    end: 1.05, curve: Curves.linear, duration: .1.seconds)),
      );
    });
  }
}

void randomBegin(AnimationController controller,
        {bool? forward, double? value}) =>
    (forward ?? rng.nextBool())
        ? controller
            .reverse(from: (value ?? rng.nextDouble()))
            .then((value) => controller.forward(from: 0))
        : controller.forward(from: (value ?? rng.nextDouble()));

void onComplete(AnimationController controller) =>
    controller.reverse().then((value) => controller.forward(from: 0));

class WeaponSecondarySelector extends StatefulWidget {
  const WeaponSecondarySelector(
      {
      // required this.onSelect,
      required this.onBack,
      required this.isPrimary,
      required this.isSecondaryAbility,
      required this.gameRef,
      super.key});

  // final Function(dynamic) onSelect;
  final Function onBack;

  final GameRouter gameRef;
  final bool isPrimary;
  final bool isSecondaryAbility;

  @override
  State<WeaponSecondarySelector> createState() =>
      _WeaponSecondarySelectorState();
}

class _WeaponSecondarySelectorState extends State<WeaponSecondarySelector> {
  late PlayerDataComponent playerDataComponent;

  @override
  void initState() {
    super.initState();

    playerDataComponent = widget.gameRef.playerDataComponent;

    // playerDataNotifier =
    //     widget.gameRef.componentsNotifier<PlayerDataComponent>();

    // playerDataNotifier.addListener(onPlayerDataNotification);

    playerData = playerDataComponent.dataObject;

    WeaponType? selectedWeapon =
        playerData.selectedWeapons[widget.isPrimary ? 0 : 1];
    for (var element in AttackType.values) {
      if (selectedWeapon?.attackType == element) {
        selectedWeapons[element] = (selectedWeapon!);
      } else {
        selectedWeapons[element] = (WeaponType.values.firstWhere(
            (elementD) => elementD.attackType == element && !elementD.hidden));
      }
    }

    selectedSecondary =
        playerData.selectedSecondaries[widget.isPrimary ? 0 : 1];
  }

  final borderWidth = 5.0;
  final borderColor = ApolloColorPalette.deepBlue.color.brighten(.1);

  Map<AttackType, WeaponType> selectedWeapons = {};
  SecondaryType? selectedSecondary;
  bool? previousPressLeft;

  void changeWeapon(bool isLeftPress, AttackType? attackType) {
    bool isSecondary = attackType == null;
    int currentIndex = -1;
    final attackTypeWeapons = WeaponType.values
        .where((element) => element.attackType == attackType && !element.hidden)
        .toList();
    if (isSecondary) {
      currentIndex = SecondaryType.values.indexOf(selectedSecondary!);
    } else {
      currentIndex = attackTypeWeapons.indexOf(selectedWeapons[attackType]!);
    }
    if (isLeftPress) {
      currentIndex--;
    } else {
      currentIndex++;
    }
    if (currentIndex < 0) {
      currentIndex = (isSecondary
              ? SecondaryType.values.length
              : attackTypeWeapons.length) -
          1;
    } else if (currentIndex >=
        (isSecondary
            ? SecondaryType.values.length
            : attackTypeWeapons.length)) {
      currentIndex = 0;
    }

    setState(() {
      previousPressLeft = isLeftPress;
      if (isSecondary) {
        selectedSecondary = SecondaryType.values[currentIndex];
      } else {
        selectedWeapons[attackType] = attackTypeWeapons[currentIndex];
      }
    });
  }

  late PlayerData playerData;
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<Widget> entries = [];
    if (!widget.isSecondaryAbility) {
      for (var entry in selectedWeapons.entries) {
        entries.add(WeaponSelectorTab(
            gameRef: widget.gameRef,
            weaponChange: changeWeapon,
            scrollController: scrollController,
            isPrimary: widget.isPrimary,
            key: Key(entry.value.name),
            animateLeft: previousPressLeft,
            weaponType: entry.value));
      }
    } else {
      // List<SecondaryType> shownSecondaries = SecondaryType.values
      //     .where((element) => element.compatibilityCheck(playerData
      //         .selectedWeapons[widget.isPrimary ? 0 : 1]!
      //         .createFunction(null, null)))
      //     .toList();
      // shownSecondaries.sort((a, b) => a.baseCost.compareTo(b.baseCost));

      // for (var secondaryType in shownSecondaries) {
      entries.add(WeaponSelectorTab(
          gameRef: widget.gameRef,
          weaponChange: changeWeapon,
          scrollController: scrollController,
          key: Key(selectedSecondary?.name ?? ""),
          animateLeft: previousPressLeft,
          isPrimary: widget.isPrimary,
          // onSelect: widget.onSelect,
          secondaryType: selectedSecondary));
      // }
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
                          child: Image.asset('assets/images/ui/bag.png'))
                      .animate()
                      .rotate()
                      .fadeIn(),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: ScrollConfiguration(
                        behavior: scrollConfiguration(context),
                        child: ListView(
                          controller: scrollController,
                          shrinkWrap: true,
                          children: entries
                              .animate(interval: .15.seconds)
                              .fadeIn()
                              .moveX(begin: -200, curve: Curves.easeOutCirc),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
            SizedBox(
              height: menuBaseBarHeight,
              child: Row(
                children: [
                  const SizedBox(
                    width: menuBaseBarWidthPadding,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CustomButton(
                          "Back",
                          zHeight: 1,
                          zIndex: 1,
                          groupId: 15,
                          groupOrientation: Axis.vertical,
                          gameRef: widget.gameRef,
                          onPrimary: () => widget.onBack(),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(),
                          Center(
                            child: Text(
                              "${playerData.experiencePoints}",
                              style: defaultStyle,
                            ),
                          ),
                          buildImageAsset(ImagesAssetsExperience.all.path,
                              fit: BoxFit.fitHeight)
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: menuBaseBarWidthPadding,
                  )
                ],
              ),
            )
          ],
        ),
      ).animate().fadeIn(),
    );
  }
}

class WeaponMenu extends StatefulWidget {
  const WeaponMenu({
    super.key,
    required this.gameRef,
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
    Map<int, WeaponType> weaponMap =
        playerDataComponent.dataObject.selectedWeapons;
    Map<int, SecondaryType> secondaryMap =
        playerDataComponent.dataObject.selectedSecondaries;

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
              child: InkWell(
                onHover: (value) {
                  setState(() {
                    studiesButtonHover = value;
                  });
                },
                onTap: () {
                  attributeUpgrader = AttributeUpgrader(
                      onBack: () {
                        attributeUpgrader = null;
                      },
                      gameRef: widget.gameRef);
                },
                child: buildImageAsset(ImagesAssetsUi.studiesHeadBanner.path,
                    fit: BoxFit.fitHeight),
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
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Text(
                                "${playerDataComponent.dataObject.experiencePoints}",
                                style: defaultStyle.copyWith(
                                    color: colorPalette.secondaryColor),
                              ),
                            ),
                            buildImageAsset(ImagesAssetsExperience.all.path,
                                fit: BoxFit.fitHeight),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: Text(
                          "Runic Studies",
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
        )
      ],
    );

    Widget primaryWeaponTile = WeaponSecondaryTile(
      level: playerDataComponent.dataObject.unlockedWeapons[weaponMap[0]] ?? 0,
      isPrimary: true,
      weaponType: weaponMap[0],
      onTap: () {
        weaponSelector = WeaponSecondarySelector(
          key: UniqueKey(),
          isSecondaryAbility: false,
          isPrimary: true,
          gameRef: widget.gameRef,
          onBack: () {
            setState(() {
              weaponSelector = null;
            });
          },
        );
      },
    );

    Widget primarySecondaryTile = WeaponSecondaryTile(
      isPrimary: true,
      level:
          playerDataComponent.dataObject.unlockedSecondarys[secondaryMap[0]] ??
              0,
      secondaryType: secondaryMap[0],
      onTap: () {
        weaponSelector = WeaponSecondarySelector(
          key: UniqueKey(),
          isSecondaryAbility: true,
          isPrimary: true,
          gameRef: widget.gameRef,
          onBack: () {
            setState(() {
              weaponSelector = null;
            });
          },
        );
      },
    );
    Widget secondaryWeaponTile = WeaponSecondaryTile(
      level: playerDataComponent.dataObject.unlockedWeapons[weaponMap[1]] ?? 0,
      isPrimary: false,
      weaponType: weaponMap[1],
      onTap: () {
        weaponSelector = WeaponSecondarySelector(
          key: UniqueKey(),
          isSecondaryAbility: false,
          // onSelect: (weaponType) {
          //   if (playerDataComponent.dataObject.selectedWeapons.values
          //       .contains(weaponType)) return;
          //   setState(() {
          //     playerDataComponent.dataObject.selectedWeapons[1] = weaponType;
          //     playerDataComponent.notifyListeners();
          //   });
          // },
          isPrimary: false,
          gameRef: widget.gameRef,
          onBack: () {
            setState(() {
              weaponSelector = null;
            });
          },
        );
      },
    );

    Widget secondarySecondaryTile = WeaponSecondaryTile(
      isPrimary: false,
      level:
          playerDataComponent.dataObject.unlockedSecondarys[secondaryMap[1]] ??
              0,
      secondaryType: secondaryMap[1],
      onTap: () {
        weaponSelector = WeaponSecondarySelector(
          key: UniqueKey(),
          isSecondaryAbility: true,
          isPrimary: false,
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                secondarySecondaryTile
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CustomButton(
                      "Back",
                      gameRef: widget.gameRef,
                      groupOrientation: Axis.horizontal,
                      zHeight: 1,
                      groupId: 5,
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
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CustomButton(
                      "Choose Level",
                      groupOrientation: Axis.horizontal,
                      groupId: 5,
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
