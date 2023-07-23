import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/resources/functions/custom_mixins.dart';
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
    this.weaponType,
    this.secondaryType,
    required this.isPrimary,
    super.key,
    required this.weaponTab,
    // required this.onSelect
  });

  final GameRouter gameRef;
  final AttackType weaponTab;
  final bool isPrimary;
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
            ? isSecondaryAbility
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

  final borderWidth = 5.0;

  @override
  Widget build(BuildContext context) {
    Widget unlockWidget;
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
                  setState(() {
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
                setState(() {
                  isMainHover = value;
                });
              },
              // onTap: isUnlocked ? () => onSelect() : null,
              onTap: isUnlocked
                  ? () {
                      if (isSecondaryAbility) {
                        setState(() {
                          playerDataComponent.dataObject.selectedSecondaries[
                              widget.isPrimary ? 0 : 1] = secondaryType!;
                          playerDataComponent.notifyListeners();
                        });
                      } else {
                        if (playerDataComponent
                            .dataObject.selectedWeapons.values
                            .contains(weaponType)) return;
                        setState(() {
                          playerDataComponent.dataObject
                                  .selectedWeapons[widget.isPrimary ? 0 : 1] =
                              weaponType!;
                          playerDataComponent.notifyListeners();
                        });
                      }
                    }
                  : null,
              child: Stack(
                children: [
                  Table(columnWidths: const {
                    // 0: FixedColumnWidth(25),
                    0: FlexColumnWidth(),
                    1: FixedColumnWidth(50)
                  }, children: [
                    TableRow(
                      children: [
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
                                              filterQuality: FilterQuality.low,
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
                                                : secondaryType!.name.titleCase,
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
                                      mainAxisAlignment: MainAxisAlignment.end,
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
                                                i < (maxLevel - unlockedLevel);
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
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                    Expanded(
                                      child: Wrap(children: [
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
                                                buildDescriptionText(true,
                                                    weaponDescriptions[i].$3),
                                              ],
                                            )
                                      ]),
                                    ),
                                    const SizedBox(
                                      width: 50,
                                    )
                                  ],
                                ),
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
  }
}
