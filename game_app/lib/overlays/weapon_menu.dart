import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/functions/custom_mixins.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/visuals.dart';
import 'package:game_app/weapons/secondary_abilities.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';
import 'package:recase/recase.dart';
import '../resources/data_classes/player_data.dart';
import 'buttons.dart';
import 'menus.dart';

class WeaponTile extends StatelessWidget {
  const WeaponTile(
      {required this.onTap,
      required this.weaponType,
      required this.level,
      required this.isPrimary,
      super.key});
  final Function onTap;
  final WeaponType weaponType;
  final int level;
  final radius = 20.0;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    bool isHover = false;

    return StatefulBuilder(builder: (context, setState) {
      final size = MediaQuery.of(context).size;
      return InkWell(
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
          SizedBox.square(
            dimension: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    weaponType.icon,
                    filterQuality: FilterQuality.none,
                    height: 100,
                  ),
                ),
              ],
            )
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
                    duration: isHover ? 20.seconds : 1.seconds,
                    curve: Curves.easeInOut)
                .animate(
                  target: isHover ? 1 : 0,
                )
                .moveY(
                    end: -20,
                    begin: 0,
                    duration: .5.seconds,
                    curve: Curves.easeInCubic),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Animate(
                    target: isHover ? 1 : 0,
                  ).custom(
                    builder: (context, value, child) {
                      return Container(
                        height: 25,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(.5)
                                .mergeWith(Colors.pink, value),
                            border: const Border(
                                top: BorderSide(
                                    width: 4, color: secondaryColor))),
                        transform: Matrix4.skewX(isPrimary ? -.75 : .75),
                      );
                    },
                  )),
            ),
          ).animate().fadeIn()
        ]),
      );
    });
  }
}

class SecondaryTile extends StatelessWidget {
  const SecondaryTile(
      {required this.onTap,
      required this.secondaryType,
      required this.isPrimary,
      required this.level,
      super.key});
  final Function onTap;
  final SecondaryType secondaryType;
  final int level;
  final radius = 20.0;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    bool isHover = false;

    return StatefulBuilder(builder: (context, setState) {
      final size = MediaQuery.of(context).size;
      return InkWell(
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
          SizedBox.square(
            dimension: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    secondaryType.icon,
                    height: 50,
                  ),
                ),
              ],
            ),
          )
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
                  curve: Curves.easeInOut),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Animate(
                    target: isHover ? 1 : 0,
                  ).custom(
                    builder: (context, value, child) {
                      return Container(
                          height: 15,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(.5)
                                  .mergeWith(Colors.pink, value),
                              border: const Border(
                                  top: BorderSide(
                                      width: 4,
                                      color: secondaryEquippedColor))),
                          transform: Matrix4.skewX(isPrimary ? -.75 : .75));
                    },
                  )),
            ),
          ).animate().fadeIn()
        ]),
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
      {required this.onSelect,
      required this.onBack,
      required this.isPrimary,
      required this.isSecondaryAbility,
      this.weaponTab = AttackType.special,
      required this.gameRef,
      super.key});

  final Function(dynamic) onSelect;
  final Function onBack;

  final GameRouter gameRef;
  final bool isPrimary;
  final bool isSecondaryAbility;
  final AttackType weaponTab;

  @override
  State<WeaponSecondarySelector> createState() =>
      _WeaponSecondarySelectorState();
}

class _WeaponSecondarySelectorState extends State<WeaponSecondarySelector> {
  late ComponentsNotifier<PlayerDataComponent> playerDataNotifier;
  late PlayerDataComponent playerDataComponent;

  @override
  void dispose() {
    playerDataNotifier.removeListener(onPlayerDataNotification);
    setstateFunctions.clear();
    super.dispose();
  }

  void onPlayerDataNotification() {
    if (!mounted) setstateFunctions.clear();
    for (Function setstate in setstateFunctions) {
      setstate(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    weaponTab = widget.weaponTab;
    playerDataComponent = widget.gameRef.playerDataComponent;
    playerDataNotifier =
        widget.gameRef.componentsNotifier<PlayerDataComponent>();

    playerDataNotifier.addListener(onPlayerDataNotification);
    playerData = playerDataComponent.dataObject;
  }

  Set<Function> setstateFunctions = {};

  Widget buildDescriptionText(bool isNext, String string) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Text(
        string,
        style: defaultStyle.copyWith(
            shadows: [],
            fontSize: 20,
            color: isNext ? secondaryColor : primaryColor),
      ),
    );
  }

  Widget buildLevelIndicator(bool isPointUnlocked, bool isEquipped) {
    final color = isPointUnlocked
        ? isEquipped
            ? widget.isSecondaryAbility
                ? secondaryEquippedColor
                : secondaryColor
            : levelUnlockedUnequipped
        : lockedColor;
    return Flexible(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 50, minWidth: 25),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            transform: Matrix4.skewX(-.25),
            decoration: BoxDecoration(
              border:
                  Border(right: BorderSide(color: color.darken(.4), width: 6)),
              gradient: LinearGradient(colors: [color, color.brighten(.2)]),
            ),
            height: 50,
            // width: 10,
          ),
        ),
      ),
    );
  }

  late AttackType weaponTab;

  void changeTab(AttackType newWeaponTab) {
    setState(() {
      setstateFunctions.clear();
      weaponTab = newWeaponTab;
    });
  }

  Widget buildSelectableTab(
      {WeaponType? weaponType, SecondaryType? secondaryType}) {
    bool isLevelHover = false;
    bool isMainHover = false;

    return StatefulBuilder(builder: (context, setstate) {
      setstateFunctions.add(setstate);

      Widget unlockWidget;
      bool isEquipped = false;
      bool isUnlocked = false;
      int unlockedLevel = 0;
      int maxLevel = 0;
      bool isWeapon = weaponType != null;
      Function onLevelTap;
      Function onSelect;
      String icon;
      int currentCost;
      bool isMaxLevel = false;

      if (isWeapon) {
        isEquipped = playerData.selectedWeapons.values.contains(weaponType);
        isUnlocked = playerData.unlockedWeapons.keys.contains(weaponType);
        unlockedLevel = playerData.unlockedWeapons[weaponType] ?? 0;
        maxLevel = weaponType.maxLevel;
        icon = weaponType.icon;
        onLevelTap = () {
          if (isMaxLevel) return;
          if (playerData.unlockedWeapons.containsKey(weaponType)) {
            playerData.unlockedWeapons[weaponType] =
                playerData.unlockedWeapons[weaponType]! + 1;
          } else {
            playerData.unlockedWeapons[weaponType] ??= 0;
          }

          playerDataComponent.notifyListeners();
        };
        onSelect = () => widget.onSelect(weaponType);
        currentCost = weaponType.baseCost;
      } else {
        isEquipped = playerData.selectedSecondaries[widget.isPrimary ? 0 : 1] ==
            (secondaryType);
        isUnlocked = playerData.unlockedSecondarys.keys.contains(secondaryType);
        unlockedLevel = (playerData.unlockedSecondarys[secondaryType] ?? 0)
            .clamp(0, secondaryType!.maxLevel);
        maxLevel = secondaryType.maxLevel;
        icon = secondaryType.icon;
        onLevelTap = () {
          if (isMaxLevel) return;
          if (playerData.unlockedSecondarys.containsKey(secondaryType)) {
            playerData.unlockedSecondarys[secondaryType] =
                playerData.unlockedSecondarys[secondaryType]! + 1;
          } else {
            playerData.unlockedSecondarys[secondaryType] ??= 0;
          }

          playerDataComponent.notifyListeners();
        };
        onSelect = () => widget.onSelect(secondaryType);
        currentCost = secondaryType.baseCost;
      }
      isMaxLevel = unlockedLevel == maxLevel;
      currentCost = (currentCost * (unlockedLevel + 1))
          .clamp(currentCost, currentCost * maxLevel);

      List<(String, String, String)> weaponDescriptions = [];
      late dynamic secondaryWeapon;
      if (isWeapon) {
        for (var element in WeaponDescription.values) {
          final currentString = buildWeaponDescription(
              element, weaponType, unlockedLevel, isUnlocked);

          final nextString = buildWeaponDescription(
              element, weaponType, unlockedLevel, !isMaxLevel);

          if (nextString.isEmpty && currentString.isEmpty ||
              (currentString == " - " && nextString.isEmpty)) continue;

          weaponDescriptions
              .add((element.name.titleCase, currentString, nextString));
        }
      } else if ((secondaryWeapon = secondaryType?.build(null, unlockedLevel))
          is Weapon) {
        final secondaryWeaponType = secondaryWeapon.weaponType;
        for (var element in WeaponDescription.values) {
          final currentString = buildWeaponDescription(
              element, secondaryWeaponType!, unlockedLevel, isUnlocked);

          final nextString = buildWeaponDescription(
              element, secondaryWeaponType!, unlockedLevel, !isMaxLevel);

          if (nextString.isEmpty && currentString.isEmpty ||
              (currentString == " - " && nextString.isEmpty)) continue;

          weaponDescriptions
              .add((element.name.titleCase, currentString, nextString));
        }
      } else if (secondaryWeapon is SecondaryWeaponAbility) {
        weaponDescriptions.add((
          "",
          isUnlocked ? " - " : secondaryWeapon.abilityDescription,
          isMaxLevel ? " - " : secondaryWeapon.nextLevelStringDescription
        ));
      }
      const endButtonWidth = 125.0;
      unlockWidget = Stack(
        children: [
          Positioned.fill(
            left: endButtonWidth / 2,
            child: Container(
              alignment: Alignment.centerRight,
              color: isLevelHover ? secondaryColor : unlockedColor,
              // width: endButtonWidth/2,
            ),
          ),
          Container(
            color: isLevelHover ? secondaryColor : unlockedColor,
            transform: Matrix4.skewX(-.25)..translate(35.0),
            child: Padding(
              padding: const EdgeInsets.only(right: 0),
              child: InkWell(
                  onHover: (value) {
                    setstate(() {
                      isLevelHover = value;
                    });
                  },
                  onTap: () {
                    onLevelTap();
                  },
                  child: SizedBox(
                    width: endButtonWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!isMaxLevel) ...[
                          Icon(
                            isUnlocked ? Icons.add : Icons.lock_open,
                            size: 30,
                            color: Colors.white,
                          ),
                          Text(
                            "$currentCost",
                            style: defaultStyle,
                          ),
                        ] else
                          Text(
                            "MAX",
                            style: defaultStyle,
                          ).animate().fadeIn()
                      ],
                    ),
                  )),
            ),
          ),
        ],
      );
      final backgroundColor = (isMainHover
          ? hoverColor
          : (isUnlocked ? unlockedColor : lockedColor).withOpacity(1));
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
          child: Container(
            // height: 150,
            decoration: BoxDecoration(
                color: backgroundColor.mergeWith(
                    secondaryColor, isEquipped ? .4 : 0),
                border: Border.all(width: borderWidth * .7)),
            child: ClipRect(
              child: InkWell(
                onHover: (value) {
                  setstate(() {
                    isMainHover = value;
                  });
                },
                onTap: isUnlocked ? () => onSelect() : null,
                child: Stack(
                  children: [
                    Table(columnWidths: const {
                      // 0: FixedColumnWidth(25),
                      0: FlexColumnWidth(),
                      1: FixedColumnWidth(50)
                    }, children: [
                      TableRow(
                        children: [
                          // TableCell(
                          //   verticalAlignment: TableCellVerticalAlignment.fill,
                          //   child: SizedBox(
                          //     child: isEquipped
                          //         ? Container(
                          //             color: widget.isSecondaryAbility
                          //                 ? secondaryEquippedColor
                          //                 : secondaryColor,
                          //           )
                          //         : null,
                          //   ),
                          // ),
                          Column(children: [
                            SizedBox(
                              height: 100,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: RotatedBox(
                                              quarterTurns: 1,
                                              child: Image.asset(
                                                icon,
                                                fit: BoxFit.fitWidth,
                                                filterQuality:
                                                    FilterQuality.low,
                                                isAntiAlias: true,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 250,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              isWeapon
                                                  ? weaponType.name.titleCase
                                                  : secondaryType!
                                                      .name.titleCase,
                                              style: defaultStyle.copyWith(
                                                  color: isEquipped
                                                      ? secondaryColor
                                                      : primaryColor),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      flex: 3,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (isUnlocked) ...[
                                            ...[
                                              for (var i = 0;
                                                  i < unlockedLevel;
                                                  i++)
                                                buildLevelIndicator(
                                                    true, isEquipped)
                                            ]
                                                .animate(interval: .1.seconds)
                                                .fadeIn(begin: .5),
                                            ...[
                                              for (var i = 0;
                                                  i <
                                                      (maxLevel -
                                                          unlockedLevel);
                                                  i++)
                                                buildLevelIndicator(
                                                    false, isEquipped)
                                            ],
                                            const SizedBox(
                                              width: 65,
                                            )
                                          ] else
                                            const Spacer(),
                                        ],
                                      )),
                                ],
                              ),
                            ),
                            Container(
                                alignment: Alignment.centerLeft,
                                color: backgroundColor.darken(.5),
                                // height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Wrap(children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildDescriptionText(false, ""),
                                        buildDescriptionText(
                                            false, "Current: "),
                                        buildDescriptionText(
                                            true, "Next Level: "),
                                      ],
                                    ),
                                    if (weaponDescriptions.isNotEmpty)
                                      for (var i = 0;
                                          i < weaponDescriptions.length;
                                          i++)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            buildDescriptionText(false,
                                                weaponDescriptions[i].$1),
                                            buildDescriptionText(false,
                                                weaponDescriptions[i].$2),
                                            buildDescriptionText(
                                                true, weaponDescriptions[i].$3),
                                          ],
                                        )
                                  ]),
                                ))
                          ]),
                          const SizedBox()
                        ],
                      ),
                    ]),
                    Positioned(top: 0, right: 0, bottom: 0, child: unlockWidget)
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  final borderWidth = 5.0;
  final borderColor = backgroundColor2.brighten(.1);

  late PlayerData playerData;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<Widget> entries = [];
    print('rebuild');
    if (!widget.isSecondaryAbility) {
      List<WeaponType> shownWeapons = WeaponType.values
          .where((element) => element.attackType == weaponTab)
          .toList();
      shownWeapons.sort((a, b) => a.baseCost.compareTo(b.baseCost));
      for (var weaponType in shownWeapons) {
        entries.add(buildSelectableTab(weaponType: weaponType));
      }
    } else {
      List<SecondaryType> shownSecondaries = SecondaryType.values
          .where((element) => element.compatibilityCheck(playerData
              .selectedWeapons[widget.isPrimary ? 0 : 1]!
              .createFunction(null, null)))
          .toList();
      shownSecondaries.sort((a, b) => a.baseCost.compareTo(b.baseCost));

      for (var secondaryType in shownSecondaries) {
        entries.add(buildSelectableTab(secondaryType: secondaryType));
      }
    }

    return Animate(
      effects: [
        CustomEffect(builder: (context, value, child) {
          return Container(
            color: backgroundColor1.brighten(.1).withOpacity(.6 * value),
            child: child,
          );
        })
      ],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: uiWidthMax),
          child: Container(
            width: size.width * .8,
            height: size.height * .8,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: borderWidth),
              color: backgroundColor2.brighten(.1).withOpacity(.35),
            ),
            child: Column(
              children: [
                if (!widget.isSecondaryAbility) ...[
                  Row(
                    children: [
                      for (var i = 0; i < AttackType.values.length; i++)
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              changeTab(AttackType.values[i]);
                            },
                            child: Container(
                              color: AttackType.values[i] == weaponTab
                                  ? unlockedColor
                                  : backgroundColor1.brighten(.15),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  AttackType.values[i].name.titleCase,
                                  style: defaultStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                  Container(
                    height: borderWidth,
                    color: borderColor,
                  )
                ],
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: entries
                        .animate(interval: .1.seconds)
                        .moveX(begin: -50, end: 0, curve: Curves.easeIn)
                        .fadeIn(curve: Curves.easeIn),
                  ),
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

  set weaponSelector(Widget? value) {
    setState(() {
      _weaponSelector = value;
    });
  }

  Widget buildWeaponTile(Widget weapon, Widget ability, bool isPrimary) {
    Widget weaponWidget = Padding(
      padding: const EdgeInsets.all(12),
      child: weapon,
    );

    return Column(
      crossAxisAlignment:
          isPrimary ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
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
        ),
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

    Widget primaryWeaponTile = WeaponTile(
      level:
          playerDataComponent.dataObject.unlockedWeapons[entries.first.value] ??
              0,
      isPrimary: true,
      weaponType: entries.first.value,
      onTap: () {
        setState(() {
          weaponSelector = WeaponSecondarySelector(
            key: UniqueKey(),
            isSecondaryAbility: false,
            weaponTab: entries.first.value.attackType,
            onSelect: (weaponType) {
              if (playerDataComponent.dataObject.selectedWeapons.values
                  .contains(weaponType)) return;
              setState(() {
                playerDataComponent.dataObject.selectedWeapons[0] = weaponType;
                playerDataComponent.notifyListeners();
              });
            },
            isPrimary: true,
            gameRef: widget.gameRef,
            onBack: () {
              setState(() {
                weaponSelector = null;
              });
            },
          );
        });
      },
    );
    Widget primarySecondaryTile = SecondaryTile(
      isPrimary: true,
      level: playerDataComponent
              .dataObject.unlockedSecondarys[secondaryEntries.first.value] ??
          0,
      secondaryType: secondaryEntries.first.value,
      onTap: () {
        setState(() {
          weaponSelector = WeaponSecondarySelector(
            key: UniqueKey(),
            isSecondaryAbility: true,
            onSelect: (secondaryType) {
              setState(() {
                playerDataComponent.dataObject.selectedSecondaries[0] =
                    secondaryType;
                playerDataComponent.notifyListeners();
              });
            },
            isPrimary: true,
            gameRef: widget.gameRef,
            onBack: () {
              setState(() {
                weaponSelector = null;
              });
            },
          );
        });
      },
    );
    Widget secondaryWeaponTile = WeaponTile(
      level:
          playerDataComponent.dataObject.unlockedWeapons[entries.last.value] ??
              0,
      isPrimary: false,
      weaponType: entries.last.value,
      onTap: () {
        setState(() {
          weaponSelector = WeaponSecondarySelector(
            key: UniqueKey(),
            weaponTab: entries.last.value.attackType,
            isSecondaryAbility: false,
            onSelect: (weaponType) {
              if (playerDataComponent.dataObject.selectedWeapons.values
                  .contains(weaponType)) return;
              setState(() {
                playerDataComponent.dataObject.selectedWeapons[1] = weaponType;
                playerDataComponent.notifyListeners();
              });
            },
            isPrimary: false,
            gameRef: widget.gameRef,
            onBack: () {
              setState(() {
                weaponSelector = null;
              });
            },
          );
        });
      },
    );

    Widget secondarySecondaryTile = SecondaryTile(
      isPrimary: false,
      level: playerDataComponent
              .dataObject.unlockedSecondarys[secondaryEntries.last.value] ??
          0,
      secondaryType: secondaryEntries.last.value,
      onTap: () {
        setState(() {
          weaponSelector = WeaponSecondarySelector(
            key: UniqueKey(),
            isSecondaryAbility: true,
            onSelect: (secondaryType) {
              setState(() {
                playerDataComponent.dataObject.selectedSecondaries[1] =
                    secondaryType;
                playerDataComponent.notifyListeners();
              });
            },
            isPrimary: false,
            gameRef: widget.gameRef,
            onBack: () {
              setState(() {
                weaponSelector = null;
              });
            },
          );
        });
      },
    );
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Select your weapons",
                style: defaultStyle,
              ),
            ),
            const Spacer(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: uiWidthMax),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Spacer(),
                  buildWeaponTile(
                      primaryWeaponTile, primarySecondaryTile, true),
                  const Spacer(
                    flex: 6,
                  ),
                  buildWeaponTile(
                      secondaryWeaponTile, secondarySecondaryTile, false),
                  const Spacer(),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: CustomButton(
                    "Back",
                    gameRef: widget.gameRef,
                    onTap: () {
                      setState(() {
                        exitFunction = () {
                          changeMainMenuPage(MenuPages.startMenuPage);
                        };
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: CustomButton(
                    "Choose Level",
                    gameRef: widget.gameRef,
                    onTap: () {
                      setState(() {
                        exitFunction = () {
                          changeMainMenuPage(MenuPages.levelMenu);
                        };
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        )
            .animate(
              target: exitFunction != null ? 1 : 0,
              onComplete: (controller) {
                onExit();
              },
            )
            .fadeOut(),
        if (_weaponSelector != null) _weaponSelector!,
      ],
    );
  }
}
