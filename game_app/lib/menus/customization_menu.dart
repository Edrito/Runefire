import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/menus/attribute_menu.dart';
import 'package:game_app/menus/weapon_selector_tile.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/functions/custom_mixins.dart';
import 'package:game_app/resources/game_state_class.dart';
import 'package:game_app/resources/visuals.dart';

import '../resources/data_classes/player_data.dart';
import '../resources/functions/functions.dart';
import 'buttons.dart';
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

  @override
  Widget build(BuildContext context) {
    assert(weaponType != null || secondaryType != null);
    bool isWeapon = weaponType != null;

    bool isHover = false;

    return StatefulBuilder(builder: (context, setState) {
      final size = MediaQuery.of(context).size;
      final increase = (size.width / 1500).clamp(.5, 1);

      return SizedBox(
        width: (isWeapon ? 225 : 160) * increase.toDouble(),
        child: InkWell(
          radius: radius,
          onTap: () {
            onTap();
          },
          onHover: (value) {
            setState(() {
              isHover = value;
            });
          },
          child: Stack(children: [
            Positioned(
              // bottom: -200,
              top: 0,
              bottom: -200,
              left: 0,
              right: 0,
              child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Animate(
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
                            child: buildImageAsset(
                              'assets/images/ui/magic_hand_${isWeapon ? '' : 'small_'}${isPrimary ? 'L' : 'R'}.png',
                              fit: BoxFit.fitWidth,
                            ),
                          );
                        },
                      ))
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
                      curve: Curves.easeInOut),
            ),
            Positioned(
              top: -200,
              bottom: isWeapon ? 100 : -25,
              // bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                    height: isWeapon ? 200 : 150,
                    child: buildImageAsset(
                      isWeapon ? weaponType!.icon : secondaryType!.icon,
                      // fit: BoxFit.fitWidth,
                    )
                        .animate(
                          target: isHover ? 1 : 0,
                        )
                        .rotate(
                            end: !isPrimary ? .5 : -.5,
                            curve: Curves.fastLinearToSlowEaseIn,
                            duration: 1.seconds)
                        .animate()
                        .moveY(
                            duration: 1.5.seconds,
                            curve: Curves.fastEaseInToSlowEaseOut,
                            begin: -size.height / 2)
                        .fadeIn(
                          duration: 1.5.seconds,
                          curve: Curves.fastEaseInToSlowEaseOut,
                        )
                        .animate(
                          onPlay: randomBegin,
                          onComplete: onComplete,
                        )
                        .moveY(
                            begin: 5,
                            end: -5,
                            duration: 1.seconds,
                            curve: Curves.easeInOut)),
              ),
            ),
          ]),
        ),
      );
    });
  }
}

void randomBegin(AnimationController controller) => rng.nextBool()
    ? controller
        .reverse(from: rng.nextDouble())
        .then((value) => controller.forward(from: 0))
    : controller.forward(from: rng.nextDouble());

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
        selectedWeapons[element] = (WeaponType.values
            .firstWhere((elementD) => elementD.attackType == element));
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
        .where((element) => element.attackType == attackType)
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
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<Widget> entries = [];
    if (!widget.isSecondaryAbility) {
      for (var entry in selectedWeapons.entries) {
        entries.add(WeaponSelectorTab(
            gameRef: widget.gameRef,
            weaponChange: changeWeapon,
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
          color: Colors.black.brighten(.1).withOpacity(.95),
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
                      child: ListView(
                        shrinkWrap: true,
                        children: entries,
                      ),
                    ),
                  ),
                ),
              ],
            )),
            Row(
              children: [
                const Spacer(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: CustomButton(
                        "Back",
                        gameRef: widget.gameRef,
                        onTap: () => widget.onBack(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        "${playerData.experiencePoints} 🟦",
                        style: defaultStyle,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
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

  Widget buildWeaponTile(Widget weapon, Widget ability, bool isPrimary) {
    Widget weaponWidget = weapon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isPrimary)
          const SizedBox(
            width: 20,
          ),
        if (!isPrimary) weaponWidget,
        Padding(
          padding: const EdgeInsets.all(0),
          child: ability,
        ),
        if (!isPrimary)
          const SizedBox(
            width: 20,
          ),
        if (isPrimary) weaponWidget
      ],
    );
  }

  Function? exitFunction;

  void onExit() {
    if (exitFunction != null) {
      exitFunction!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = playerDataComponent.dataObject.selectedWeapons.entries;
    final secondaryEntries =
        playerDataComponent.dataObject.selectedSecondaries.entries;

    Widget primaryWeaponTile = WeaponSecondaryTile(
      level:
          playerDataComponent.dataObject.unlockedWeapons[entries.first.value] ??
              0,
      isPrimary: true,
      weaponType: entries.first.value,
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
      level: playerDataComponent
              .dataObject.unlockedSecondarys[secondaryEntries.first.value] ??
          0,
      secondaryType: secondaryEntries.first.value,
      onTap: () {
        weaponSelector = WeaponSecondarySelector(
          key: UniqueKey(),
          isSecondaryAbility: true,
          // onSelect: (secondaryType) {
          //   setState(() {
          //     playerDataComponent.dataObject.selectedSecondaries[0] =
          //         secondaryType;
          //     playerDataComponent.notifyListeners();
          //   });
          // },
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
      level:
          playerDataComponent.dataObject.unlockedWeapons[entries.last.value] ??
              0,
      isPrimary: false,
      weaponType: entries.last.value,
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
      level: playerDataComponent
              .dataObject.unlockedSecondarys[secondaryEntries.last.value] ??
          0,
      secondaryType: secondaryEntries.last.value,
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
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: CustomButton(
                "Return to your studies",
                gameRef: widget.gameRef,
                onTap: () {
                  attributeUpgrader = AttributeUpgrader(
                      onBack: () {
                        attributeUpgrader = null;
                      },
                      gameRef: widget.gameRef);
                },
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: uiWidthMax),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Spacer(),
                buildWeaponTile(primaryWeaponTile, primarySecondaryTile, true),
                const Spacer(
                  flex: 8,
                ),
                buildWeaponTile(
                    secondaryWeaponTile, secondarySecondaryTile, false),
                const Spacer(),
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
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CustomButton(
                      "Back",
                      gameRef: widget.gameRef,
                      onTap: () {
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
              Expanded(
                flex: 2,
                child: CharacterSwitcher(
                  gameRef: widget.gameRef,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CustomButton(
                      "Choose Level",
                      gameRef: widget.gameRef,
                      onTap: () {
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
