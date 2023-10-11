import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recase/recase.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/menus/custom_widgets.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/functions/functions.dart';

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
    this.scrollController,
    required this.weaponChange,
    required this.isPrimary,
    super.key,
    // required this.onSelect
  });

  final bool? animateLeft;
  final GameRouter gameRef;
  final ScrollController? scrollController;
  final bool isPrimary;
  final SecondaryType? secondaryType;
  final Function(bool isLeftPress, AttackType? attackType) weaponChange;
  final WeaponType? weaponType;

  // final Function(dynamic) onSelect;

  @override
  State<WeaponSelectorTab> createState() => _WeaponSelectorTabState();
}

class _WeaponSelectorTabState extends State<WeaponSelectorTab> {
  final borderWidth = 5.0;

  bool isLevelHover = false;
  bool isMainHover = false;
  late bool isSecondaryAbility;
  late PlayerData playerData;
  late PlayerDataComponent playerDataComponent;
  late ComponentsNotifier<PlayerDataComponent> playerDataNotifier;

  Widget buildDescriptionText(bool isNext, String string, Color equippedColor) {
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
                color: isNext ? equippedColor.brighten(.4) : equippedColor),
          ),
          const SizedBox(
            width: 15,
          )
        ],
      ),
    );
  }

  Widget buildLevelIndicator(bool isPointUnlocked, bool isEquipped,
      {SecondaryType? secondaryType, WeaponType? weaponType}) {
    final color = isPointUnlocked ? null : ApolloColorPalette.deepGray.color;

    String image;

    if (secondaryType != null) {
      image = isEquipped
          ? ImagesAssetsUi.levelIndicatorMagicRed.path
          : ImagesAssetsUi.levelIndicatorMagicBlue.path;
    } else {
      switch (weaponType!.attackType) {
        case AttackType.melee:
          image = isEquipped
              ? ImagesAssetsUi.levelIndicatorSwordRed.path
              : ImagesAssetsUi.levelIndicatorSwordBlue.path;
          break;
        case AttackType.magic:
          image = isEquipped
              ? ImagesAssetsUi.levelIndicatorMagicRed.path
              : ImagesAssetsUi.levelIndicatorMagicBlue.path;
          break;
        case AttackType.guns:
          image = isEquipped
              ? ImagesAssetsUi.levelIndicatorGunRed.path
              : ImagesAssetsUi.levelIndicatorGunBlue.path;
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox.square(
          dimension: 32,
          child: buildImageAsset(image, color: color, fit: BoxFit.contain)),
    );
  }

  void onPlayerDataNotification() {
    setState(() {});
  }

  @override
  void dispose() {
    playerDataNotifier.removeListener(onPlayerDataNotification);
    super.dispose();
  }

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

  bool colorPulse = false;
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

    bool isAvailable = true;

    if (isWeapon) {
      isEquipped = playerData.selectedWeapons.values.contains(weaponType);
      isUnlocked = playerData.unlockedWeapons.keys.contains(weaponType);
      unlockedLevel = playerData.unlockedWeapons[weaponType] ?? 0;
      maxLevel = weaponType.maxLevel;
      icon = weaponType.icon;
      isAvailable = playerData.availableWeapons.contains(weaponType);
      onLevelTap = () {
        if (isMaxLevel) return;
        if (playerData.unlockedWeapons.containsKey(weaponType)) {
          playerData.unlockedWeapons[weaponType] =
              playerData.unlockedWeapons[weaponType]! + 1;
        } else {
          playerData.unlockedWeapons[weaponType] ??= 0;
        }
        playerDataComponent.notifyListeners();
        setState(() {
          colorPulse = true;
        });
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
      icon = secondaryType.icon.path;
      onLevelTap = () {
        if (isMaxLevel) return;
        if (playerData.unlockedSecondarys.containsKey(secondaryType)) {
          playerData.unlockedSecondarys[secondaryType] =
              playerData.unlockedSecondarys[secondaryType]! + 1;
        } else {
          playerData.unlockedSecondarys[secondaryType] ??= 0;
        }

        setState(() {
          colorPulse = true;
        });
        playerDataComponent.notifyListeners();
      };
      // onSelect = () => widget.onSelect(secondaryType);
      currentCost = secondaryType.baseCost;
    }
    isMaxLevel = unlockedLevel == maxLevel;
    currentCost = (currentCost * (unlockedLevel + 1))
        .clamp(currentCost, currentCost * maxLevel);

    String titleString =
        (isWeapon ? weaponType.name.titleCase : secondaryType!.name.titleCase);

    List<(String, String, String)> weaponDescriptions = [];
    late dynamic secondaryWeapon;
    Color equippedColor = isEquipped
        ? ApolloColorPalette.lightRed.color
        : colorPalette.primaryColor;
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

    const levelAndUnlockHeight = 50.0;
    const unlockButtonWidth = 100.0;
    final levelIndicator = SizedBox(
      height: levelAndUnlockHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isUnlocked)
            ...[
              ...[
                for (var i = 0; i < unlockedLevel; i++)
                  buildLevelIndicator(true, isEquipped,
                      weaponType: weaponType, secondaryType: secondaryType)
              ].animate(interval: .1.seconds).fadeIn(begin: .5),
              ...[
                for (var i = 0; i < (maxLevel - unlockedLevel); i++)
                  buildLevelIndicator(false, isEquipped,
                      weaponType: weaponType, secondaryType: secondaryType)
              ],
            ].animate().fadeIn()
        ],
      ),
    );
    final imageDisplay = CustomInputWatcher(
      onHover: (value) {
        setState(() {
          isMainHover = value;
        });
      },
      groupId: 15,
      zIndex: 1,
      groupOrientation: Axis.vertical,
      scrollController: widget.scrollController,
      onPrimary: isUnlocked
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
                  quarterTurns: !isWeapon ? 0 : 1,
                  child: Image.asset(
                    icon,
                    color: isUnlocked ? null : Colors.black,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
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
                .moveY(
                    curve: Curves.fastEaseInToSlowEaseOut,
                    begin: widget.animateLeft == null
                        ? 0
                        : widget.animateLeft == true
                            ? -100
                            : 100)
                .fadeIn(),
          ),
          if (isMainHover)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  isUnlocked ? (isEquipped ? "Equipped" : "Equip?") : "Locked",
                  style: defaultStyle,
                ),
              ).animate().fade(),
            )
        ],
      ),
    );

    Widget unlockWidget = Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomInputWatcher(
        onHover: (value) {
          setState(() {
            isLevelHover = value;
          });
        },
        zIndex: 1,
        groupId: 15,
        groupOrientation: Axis.vertical,
        scrollController: widget.scrollController,
        onPrimary: isMaxLevel || !isAvailable
            ? null
            : () {
                onLevelTap();
              },
        child: Container(
          height: unlockButtonWidth,
          width: unlockButtonWidth,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (isAvailable && !isMaxLevel) ...[
                Expanded(
                  child: (!isUnlocked
                          ? buildImageAsset(
                              ImagesAssetsUi.padlock.path,
                              fit: BoxFit.fitWidth,
                            )
                          : buildImageAsset(
                              isEquipped
                                  ? ImagesAssetsUi.plusRed.path
                                  : ImagesAssetsUi.plusBlue.path,
                              fit: BoxFit.fitWidth,
                            ))
                      .animate(target: isLevelHover ? 1 : 0)
                      .scaleXY(
                          begin: 1,
                          end: 1.05,
                          curve: Curves.easeIn,
                          duration: .1.seconds),
                ),
                // Icon(
                //   isUnlocked ? Icons.add : Icons.lock_open,
                //   size: 24,
                //   color: ApolloColorPalette.offWhite.color,
                // ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "$currentCost",
                  style:
                      defaultStyle.copyWith(fontSize: 24, color: equippedColor),
                ),
              ] else if (isAvailable)
                Text(
                  "MAX",
                  style:
                      defaultStyle.copyWith(fontSize: 24, color: equippedColor),
                ).animate().fadeIn()
            ],
          ),
        )
            .animate(
              target: colorPulse ? 1 : 0,
              onComplete: (controller) {
                // controller.reverse(from: 0);
                setState(() {
                  colorPulse = false;
                });
              },
            )
            .scaleXY(
                curve: Curves.easeIn, begin: 1, end: 1.1, duration: .1.seconds),
      ),
    );

    final informationDisplay = Row(children: [
      SizedBox(
        width: 350,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        height: 25,
                        child: ArrowButtonCustom(
                          quaterTurns: 0,
                          groupId: 15,
                          zIndex: 1,
                          onHoverColor: equippedColor.brighten(.4),
                          groupOrientation: Axis.vertical,
                          scrollController: widget.scrollController,
                          offHoverColor: equippedColor,
                          onPrimary: () {
                            if (isWeapon) {
                              widget.weaponChange(true, weaponType.attackType);
                            } else {
                              widget.weaponChange(true, null);
                            }
                          },
                        )),
                  ),
                  Expanded(child: imageDisplay),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        height: 25,
                        child: ArrowButtonCustom(
                          quaterTurns: 2,
                          groupId: 15,
                          zIndex: 1,
                          onHoverColor: equippedColor.brighten(.4),
                          groupOrientation: Axis.vertical,
                          scrollController: widget.scrollController,
                          offHoverColor: equippedColor,
                          onPrimary: () {
                            if (isWeapon) {
                              widget.weaponChange(false, weaponType.attackType);
                            } else {
                              widget.weaponChange(false, null);
                            }
                          },
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      unlockWidget,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isAvailable
                            ? titleString
                            : titleString.split('').fold("",
                                (previousValue, element) => "$previousValue?"),
                        style: defaultStyle.copyWith(color: equippedColor),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      levelIndicator,
                    ],
                  ),
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: scrollConfiguration(context),
                      child: SingleChildScrollView(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Wrap(children: [
                            if (weaponDescriptions.isNotEmpty)
                              for (var i = 0;
                                  i < weaponDescriptions.length;
                                  i++)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildDescriptionText(
                                        false,
                                        weaponDescriptions[i].$1,
                                        equippedColor),
                                    buildDescriptionText(
                                        false,
                                        weaponDescriptions[i].$2,
                                        equippedColor),
                                    buildDescriptionText(
                                        true,
                                        weaponDescriptions[i].$3,
                                        equippedColor),
                                  ],
                                )
                          ]),
                        ),
                      ),
                    ),
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
        ));
  }
}
