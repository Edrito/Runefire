import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:recase/recase.dart';

import '../main.dart';
import '../resources/data_classes/player_data.dart';
import '../resources/enums.dart';
import '../resources/visuals.dart';
import '../weapons/secondary_abilities.dart';
import '../weapons/weapon_class.dart';
import '../weapons/weapon_mixin.dart';

class WeaponSelectorTab extends StatefulWidget {
  const WeaponSelectorTab({
    required this.gameRef,
    this.animateLeft,
    this.weaponType,
    this.secondaryType,
    required this.weaponChange,
    required this.isPrimary,
    super.key,
    // required this.onSelect
  });
  final Function(bool isLeftPress, AttackType? attackType) weaponChange;
  final GameRouter gameRef;
  final bool isPrimary;
  final bool? animateLeft;
  final WeaponType? weaponType;
  final SecondaryType? secondaryType;
  // final Function(dynamic) onSelect;

  @override
  State<WeaponSelectorTab> createState() => _WeaponSelectorTabState();
}

class _WeaponSelectorTabState extends State<WeaponSelectorTab> {
  bool isLevelHover = false;
  bool isMainHover = false;

  late ComponentsNotifier<PlayerDataComponent> playerDataNotifier;
  late PlayerDataComponent playerDataComponent;
  late PlayerData playerData;

  void onPlayerDataNotification() {
    setState(() {});
  }

  @override
  void dispose() {
    playerDataNotifier.removeListener(onPlayerDataNotification);
    super.dispose();
  }

  late bool isSecondaryAbility;

  @override
  void initState() {
    super.initState();
    playerDataComponent = widget.gameRef.playerDataComponent;
    playerDataNotifier =
        widget.gameRef.componentsNotifier<PlayerDataComponent>();

    playerDataNotifier.addListener(onPlayerDataNotification);
    playerData = playerDataComponent.dataObject;
    isSecondaryAbility = widget.secondaryType != null;
  }

  Widget buildDescriptionText(bool isNext, String string) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            string,
            style: defaultStyle.copyWith(
                shadows: [],
                fontSize: 18,
                color: isNext ? secondaryColor : primaryColor),
          ),
          const SizedBox(
            width: 15,
          )
        ],
      ),
    );
  }

  Widget buildLevelIndicator(bool isPointUnlocked, bool isEquipped) {
    final color = isPointUnlocked
        ? isEquipped
            ? isSecondaryAbility
                ? secondaryEquippedColor
                : secondaryColor
            : levelUnlockedUnequipped
        : lockedColor;
    return Flexible(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 25, minWidth: 15),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            // transform: Matrix4.skewX(-.25),
            decoration: BoxDecoration(
              border:
                  Border(right: BorderSide(color: color.darken(.4), width: 6)),
              gradient: LinearGradient(colors: [color, color.brighten(.2)]),
            ),
            // width: 10,
          ),
        ),
      ),
    );
  }

  final borderWidth = 5.0;

  @override
  Widget build(BuildContext context) {
    final weaponType = widget.weaponType;
    final secondaryType = widget.secondaryType;
    bool isEquipped = false;
    bool isUnlocked = false;
    int unlockedLevel = 0;
    int maxLevel = 0;
    bool isWeapon = weaponType != null;
    Function onLevelTap;
    // Function onSelect;
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
      // onSelect = () => widget.onSelect(weaponType);
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
      // onSelect = () => widget.onSelect(secondaryType);
      currentCost = secondaryType.baseCost;
    }
    isMaxLevel = unlockedLevel == maxLevel;
    currentCost = (currentCost * (unlockedLevel + 1))
        .clamp(currentCost, currentCost * maxLevel);
    // final backgroundColor = (isMainHover
    //     ? hoverColor
    //     : (isUnlocked ? unlockedColor : lockedColor).withOpacity(1));

    List<(String, String, String)> weaponDescriptions = [];
    late dynamic secondaryWeapon;

    if (isWeapon) {
      for (var element in WeaponDescription.values) {
        final currentString = buildWeaponDescription(
            element, weaponType, unlockedLevel, isUnlocked);

        final nextString = buildWeaponDescription(
            element, weaponType, unlockedLevel, !isMaxLevel);

        if (nextString.isEmpty && currentString.isEmpty ||
            (currentString == " - " && nextString.isEmpty) ||
            (nextString == " - " && currentString.isEmpty)) continue;

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
        secondaryWeapon.abilityDescription,
        isMaxLevel ? " - " : secondaryWeapon.nextLevelStringDescription
      ));
    }

    Color equippedColor = isEquipped ? Colors.red : primaryColor;
    const levelAndUnlockHeight = 50.0;
    const unlockButtonWidth = 100.0;
    final levelIndicator = SizedBox(
      height: levelAndUnlockHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isUnlocked) ...[
            ...[
              for (var i = 0; i < unlockedLevel; i++)
                buildLevelIndicator(true, isEquipped)
            ].animate(interval: .1.seconds).fadeIn(begin: .5),
            ...[
              for (var i = 0; i < (maxLevel - unlockedLevel); i++)
                buildLevelIndicator(false, isEquipped)
            ],
            // const SizedBox(
            //   width: 65,
            // )
          ] else
            const Spacer(),
        ],
      ),
    );
    final imageDisplay = InkWell(
      onHover: (value) {
        setState(() {
          isMainHover = value;
        });
      },
      onTap: isUnlocked
          ? () {
              if (isSecondaryAbility) {
                setState(() {
                  playerDataComponent.dataObject
                          .selectedSecondaries[widget.isPrimary ? 0 : 1] =
                      secondaryType!;
                  playerDataComponent.notifyListeners();
                });
              } else {
                if (playerDataComponent.dataObject.selectedWeapons.values
                    .contains(weaponType)) return;
                setState(() {
                  playerDataComponent.dataObject
                      .selectedWeapons[widget.isPrimary ? 0 : 1] = weaponType!;
                  playerDataComponent.notifyListeners();
                });
              }
            }
          : null,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: RotatedBox(
                  quarterTurns: 2,
                  child: Image.asset(
                    icon,
                    color: isUnlocked ? null : Colors.black,
                    fit: BoxFit.fitHeight,
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                  )),
            )
                .animate(
                  onPlay: (controller) => rng.nextBool()
                      ? controller
                          .reverse(from: rng.nextDouble())
                          .then((_) => controller.forward())
                      : controller.forward(from: rng.nextDouble()),
                  onComplete: (controller) =>
                      controller.reverse().then((_) => controller.forward()),
                )
                .moveY(
                    begin: 5,
                    end: -5,
                    duration: 3.seconds,
                    curve: Curves.easeInOut)
                .animate()
                .rotate(
                    begin: widget.animateLeft == null
                        ? 0
                        : widget.animateLeft == true
                            ? -.1
                            : .1,
                    curve: Curves.fastEaseInToSlowEaseOut)
                .moveX(
                    curve: Curves.fastEaseInToSlowEaseOut,
                    begin: widget.animateLeft == null
                        ? 0
                        : widget.animateLeft == true
                            ? -100
                            : 100)
                .fadeIn(),
          ),
          const Center(
              child: Icon(
            Icons.lock,
            size: 80,
          )).animate(target: isUnlocked ? 0 : 1).fade()
        ],
      ),
    );

    Widget unlockWidget = InkWell(
      onHover: (value) {
        setState(() {
          isLevelHover = value;
        });
      },
      onTap: isMaxLevel
          ? null
          : () {
              onLevelTap();
            },
      child: Container(
        height: levelAndUnlockHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: !isLevelHover ? secondaryColor : unlockedColor,
              width: borderWidth),
          color: isLevelHover ? secondaryColor : unlockedColor,
        ),
        child: SizedBox(
          width: unlockButtonWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!isMaxLevel) ...[
                Icon(
                  isUnlocked ? Icons.add : Icons.lock_open,
                  size: 24,
                  color: Colors.white,
                ),
                Text(
                  "$currentCost",
                  style: defaultStyle.copyWith(fontSize: 20),
                ),
              ] else
                Text(
                  "MAX",
                  style: defaultStyle.copyWith(fontSize: 20),
                ).animate().fadeIn()
            ],
          ),
        ),
      ),
    );

    final informationDisplay = Row(children: [
      SizedBox(
        width: 300,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        if (isWeapon) {
                          widget.weaponChange(true, weaponType.attackType);
                        } else {
                          widget.weaponChange(true, null);
                        }
                      },
                      child: Icon(
                        Icons.arrow_left,
                        color: equippedColor,
                        size: 100,
                      )),
                  Expanded(child: imageDisplay),
                  InkWell(
                      onTap: () {
                        if (isWeapon) {
                          widget.weaponChange(false, weaponType.attackType);
                        } else {
                          widget.weaponChange(false, null);
                        }
                      },
                      child: Icon(
                        Icons.arrow_right,
                        color: equippedColor,
                        size: 100,
                      )),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                unlockWidget,
                Expanded(child: levelIndicator),
              ],
            )
          ],
        ),
      ),
      Expanded(
        flex: 3,
        child: Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isWeapon
                        ? weaponType.name.titleCase
                        : secondaryType!.name.titleCase,
                    style: defaultStyle.copyWith(color: equippedColor),
                    textAlign: TextAlign.left,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Wrap(children: [
                          if (weaponDescriptions.isNotEmpty)
                            for (var i = 0; i < weaponDescriptions.length; i++)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildDescriptionText(
                                      false, weaponDescriptions[i].$1),
                                  buildDescriptionText(
                                      false, weaponDescriptions[i].$2),
                                  buildDescriptionText(
                                      true, weaponDescriptions[i].$3),
                                ],
                              )
                        ]),
                      ),
                      const SizedBox(
                        width: 50,
                      )
                    ],
                  ),
                ],
              ),
            )),
      )
    ]);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
        child: SizedBox(height: 250, child: informationDisplay),
      ),
    );
  }
}
