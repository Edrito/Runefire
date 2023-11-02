import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recase/recase.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/menus/custom_widgets.dart';
import 'package:runefire/menus/options.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/functions/functions.dart';

import 'package:runefire/main.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/weapons/secondary_abilities.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

class WeaponSelectorTab extends StatefulWidget {
  const WeaponSelectorTab({
    required this.gameRef,
    required this.isPrimarySlot,
    this.scrollController,
    this.attackType,
    super.key,
    // required this.onSelect
  });

  final AttackType? attackType;
  final GameRouter gameRef;
  final bool isPrimarySlot;
  final ScrollController? scrollController;

  // final Function(dynamic) onSelect;

  @override
  State<WeaponSelectorTab> createState() => _WeaponSelectorTabState();
}

class _WeaponSelectorTabState extends State<WeaponSelectorTab>
    with PlayerDataNotifier {
  final borderWidth = 5.0;
  late final int slotIndex = widget.isPrimarySlot ? 0 : 1;

  bool colorPulse = false;
  late int currentCost;
  late List<SecondaryType> goodSecondaries;
  late List<WeaponType> goodWeapons;
  late String icon;
  bool isAvailable = true;
  bool isEquipped = false;
  bool isLevelHover = false;
  bool isMainHover = false;
  bool isMaxLevel = false;
  late bool isSecondaryAbility;
  bool isUnlocked = false;
  int maxLevel = 0;
  int unlockedLevel = 0;

  SecondaryType? secondaryType;
  WeaponType? weaponType;

  bool get isWeapon => weaponType != null;

  Widget buildLevelIndicator(
    bool isPointUnlocked,
    bool isEquipped, {
    SecondaryType? secondaryType,
    WeaponType? weaponType,
  }) {
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
        child: buildImageAsset(image, color: color, fit: BoxFit.contain),
      ),
    );
  }

  void changeWeapon(bool isUp) {
    if (isSecondaryAbility) {
      final currentIndex = goodSecondaries.indexOf(secondaryType!);
      var newIndex = currentIndex + (isUp ? 1 : -1);
      if (newIndex > goodSecondaries.length - 1) {
        newIndex = 0;
      }
      if (newIndex < 0) {
        newIndex = goodSecondaries.length - 1;
      }
      secondaryType = goodSecondaries[newIndex];
    } else {
      final currentIndex = goodWeapons.indexOf(weaponType!);
      var newIndex = currentIndex + (isUp ? 1 : -1);
      if (newIndex > goodWeapons.length - 1) {
        newIndex = 0;
      }
      if (newIndex < 0) {
        newIndex = goodWeapons.length - 1;
      }
      weaponType = goodWeapons[newIndex];
    }
    setState(() {
      rebuildWeapons();
      doUpAnimation = isUp;
    });
  }

  bool doUpAnimation = true;

  void onEquipWeapon() {
    if (isSecondaryAbility) {
      playerData.selectSecondary(slotIndex, secondaryType!);
    } else {
      playerData.selectWeapon(slotIndex, weaponType!);
    }
  }

  void onLevelPress(WeaponType? weaponType, SecondaryType? secondaryType) {
    if (!playerData.enoughMoney(currentCost)) {
      return;
    }
    if (weaponType != null) {
      setState(() {
        playerData.upgradeWeapon(weaponType);
        colorPulse = true;
      });
    } else if (secondaryType != null) {
      setState(() {
        playerData.upgradeSecondary(secondaryType);
        colorPulse = true;
      });
    }
  }

  void rebuildWeapons() {
    var baseCost = 0;
    if (isWeapon) {
      isEquipped = playerData.selectedWeapons.values.contains(weaponType);
      isUnlocked = playerData.unlockedWeapons.keys.contains(weaponType);
      isAvailable = playerData.availableWeapons.contains(weaponType);
      unlockedLevel = playerData.unlockedWeapons[weaponType] ?? 0;
      maxLevel = weaponType!.maxLevel;
      icon = weaponType!.icon;
      baseCost = weaponType!.baseCost;
    } else {
      isEquipped =
          playerData.selectedSecondaries[widget.isPrimarySlot ? 0 : 1] ==
              secondaryType;
      isUnlocked = playerData.unlockedSecondarys.keys.contains(secondaryType);
      unlockedLevel = (playerData.unlockedSecondarys[secondaryType] ?? 0)
          .clamp(0, secondaryType!.maxLevel);
      maxLevel = secondaryType!.maxLevel;
      icon = secondaryType!.icon.path;
      baseCost = secondaryType!.baseCost;
    }
    isMaxLevel = unlockedLevel == maxLevel;
    currentCost =
        (baseCost * (unlockedLevel + 1)).clamp(baseCost, baseCost * maxLevel);
  }

  @override
  GameRouter get gameRef => widget.gameRef;

  @override
  void initState() {
    super.initState();
    if (widget.attackType == null) {
      final tempSecondaryType = playerData.selectedSecondaries[slotIndex];
      goodSecondaries = SecondaryType.values
          .where((element) => element.isPlayerOnly)
          .toList();
      secondaryType = goodSecondaries.contains(tempSecondaryType)
          ? tempSecondaryType
          : goodSecondaries.first;
    } else {
      final selectedWeapon = playerData.selectedWeapons[slotIndex];
      goodWeapons = WeaponType.values
          .where(
            (element) =>
                element.attackType == widget.attackType &&
                element.isPlayerWeapon,
          )
          .toList();
      weaponType = selectedWeapon?.attackType == widget.attackType
          ? selectedWeapon ?? goodWeapons.first
          : goodWeapons.first;
    }
    isSecondaryAbility = widget.attackType == null;
    rebuildWeapons();
  }

  @override
  void onPlayerDataNotification() {
    setState(rebuildWeapons);
  }

  late final rowIdIncrease = ((widget.attackType?.index ?? 0) + 1) * 3;
  @override
  Widget build(BuildContext context) {
    final titleString =
        (isWeapon ? weaponType!.name.titleCase : secondaryType!.name.titleCase);
    final equippedColor = isEquipped
        ? ApolloColorPalette.lightRed.color
        : colorPalette.primaryColor;

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
                  buildLevelIndicator(
                    true,
                    isEquipped,
                    weaponType: weaponType,
                    secondaryType: secondaryType,
                  ),
              ].animate(interval: .1.seconds).fadeIn(begin: .5),
              ...[
                for (var i = 0; i < (maxLevel - unlockedLevel); i++)
                  buildLevelIndicator(
                    false,
                    isEquipped,
                    weaponType: weaponType,
                    secondaryType: secondaryType,
                  ),
              ],
            ].animate().fadeIn(),
        ],
      ),
    );
    final imageDisplay = CustomInputWatcher(
      onHover: (value) {
        setState(() {
          isMainHover = value;
        });
      },
      rowId: 2 + rowIdIncrease,
      zIndex: 1,
      scrollController: widget.scrollController,
      onPrimary: isUnlocked && !isEquipped ? onEquipWeapon : null,
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
                ),
              ),
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
                  curve: Curves.easeInOut,
                )
                .animate(
                  key: ValueKey(secondaryType ?? weaponType),
                )
                .moveY(
                  curve: Curves.fastEaseInToSlowEaseOut,
                  begin: !doUpAnimation ? 100 : -100,
                  end: 0,
                )
                .fadeIn(),
          ),
          if (isMainHover)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  isUnlocked ? (isEquipped ? 'Equipped' : 'Equip?') : 'Locked',
                  style: defaultStyle,
                ),
              ).animate().fade(),
            ),
        ],
      ),
    );

    final Widget unlockWidget = Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomInputWatcher(
        onHover: (value) {
          setState(() {
            isLevelHover = value;
          });
        },
        zIndex: 1,
        rowId: 2 + rowIdIncrease,
        // scrollController: widget.scrollController,
        onPrimary: isMaxLevel || !isAvailable
            ? null
            : () {
                onLevelPress(weaponType, secondaryType);
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
                        )),
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
                  '$currentCost',
                  style:
                      defaultStyle.copyWith(fontSize: 24, color: equippedColor),
                ),
              ] else if (isAvailable)
                Text(
                  'MAX',
                  style:
                      defaultStyle.copyWith(fontSize: 24, color: equippedColor),
                ).animate().fadeIn(),
            ],
          )
              .animate(target: isLevelHover ? 1 : 0)
              .color(
                begin: Colors.transparent,
                end: (isEquipped
                        ? ApolloColorPalette.lightRed.color
                        : colorPalette.primaryColor)
                    .withOpacity(.5),
                blendMode: BlendMode.srcATop,
                curve: Curves.easeIn,
                duration: .1.seconds,
              )
              .scaleXY(
                begin: 1,
                end: 1.05,
                curve: Curves.easeIn,
                duration: .1.seconds,
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
              curve: Curves.easeIn,
              begin: 1,
              end: 1.1,
              duration: .1.seconds,
            ),
      ),
    );

    final informationDisplay = Row(
      children: [
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
                          rowId: 1 + rowIdIncrease,
                          zIndex: 1,
                          onHoverColor: equippedColor.brighten(.4),
                          scrollController: widget.scrollController,
                          offHoverColor: equippedColor,
                          onPrimary: () {
                            changeWeapon(true);
                          },
                        ),
                      ),
                    ),
                    Expanded(child: imageDisplay),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 25,
                        child: ArrowButtonCustom(
                          quaterTurns: 2,
                          rowId: 3 + rowIdIncrease,
                          zIndex: 1,
                          onHoverColor: equippedColor.brighten(.4),
                          scrollController: widget.scrollController,
                          offHoverColor: equippedColor,
                          onPrimary: () {
                            changeWeapon(false);
                          },
                        ),
                      ),
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
          child: WeaponDescriptionWidget(
            isAvailable: isAvailable,
            titleString: titleString,
            equippedColor: equippedColor,
            levelIndicator: levelIndicator,
            weaponType: weaponType,
            secondaryType: secondaryType,
            unlockedLevel: unlockedLevel,
            isUnlocked: isUnlocked,
            isMaxLevel: isMaxLevel,
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
        child: SizedBox(height: 250, child: informationDisplay),
      ),
    );
  }
}

class WeaponDescriptionWidget extends StatelessWidget {
  const WeaponDescriptionWidget({
    required this.isAvailable,
    required this.titleString,
    required this.equippedColor,
    required this.levelIndicator,
    required this.unlockedLevel,
    required this.isUnlocked,
    required this.isMaxLevel,
    super.key,
    this.weaponType,
    this.secondaryType,
  });

  final Color equippedColor;
  final bool isAvailable;
  final bool isMaxLevel;
  final bool isUnlocked;
  final Widget levelIndicator;
  final SecondaryType? secondaryType;
  final String titleString;
  final int unlockedLevel;
  final WeaponType? weaponType;

  Widget buildDescriptionText(bool isNext, String string, Color equippedColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            string,
            style: defaultStyle.copyWith(
              shadows: [],
              fontSize: 18,
              color: isNext ? equippedColor.brighten(.4) : equippedColor,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weaponDescriptions = <(String, String, String)>[];
    late dynamic secondaryWeapon;

    if (weaponType != null) {
      for (final element in WeaponDescription.values) {
        final currentString = buildWeaponDescription(
          element,
          weaponType!,
          unlockedLevel,
          isUnlocked,
        );

        final nextString = buildWeaponDescription(
          element,
          weaponType!,
          unlockedLevel,
          !isMaxLevel,
        );

        if (nextString.isEmpty && currentString.isEmpty ||
            (currentString == ' - ' && nextString.isEmpty) ||
            (nextString == ' - ' && currentString.isEmpty)) {
          continue;
        }

        weaponDescriptions
            .add((element.name.titleCase, currentString, nextString));
      }
    } else if ((secondaryWeapon = secondaryType?.build(null, unlockedLevel))
        is Weapon) {
      final secondaryWeaponType = (secondaryWeapon as Weapon).weaponType;
      for (final element in WeaponDescription.values) {
        final currentString = buildWeaponDescription(
          element,
          secondaryWeaponType,
          unlockedLevel,
          isUnlocked,
        );

        final nextString = buildWeaponDescription(
          element,
          secondaryWeaponType,
          unlockedLevel,
          !isMaxLevel,
        );

        if (nextString.isEmpty && currentString.isEmpty ||
            (currentString == ' - ' && nextString.isEmpty)) {
          continue;
        }

        weaponDescriptions
            .add((element.name.titleCase, currentString, nextString));
      }
    } else if (secondaryWeapon is SecondaryWeaponAbility) {
      weaponDescriptions.add(
        (
          '',
          secondaryWeapon.abilityDescription,
          isMaxLevel ? ' - ' : secondaryWeapon.nextLevelStringDescription
        ),
      );
    }
    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              // mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isAvailable
                      ? titleString
                      : titleString.split('').fold(
                            '',
                            (previousValue, element) => '$previousValue?',
                          ),
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
                    child: Wrap(
                      children: [
                        if (weaponDescriptions.isNotEmpty)
                          for (var i = 0; i < weaponDescriptions.length; i++)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildDescriptionText(
                                  false,
                                  weaponDescriptions[i].$1,
                                  equippedColor,
                                ),
                                buildDescriptionText(
                                  false,
                                  weaponDescriptions[i].$2,
                                  equippedColor,
                                ),
                                buildDescriptionText(
                                  true,
                                  weaponDescriptions[i].$3,
                                  equippedColor,
                                ),
                              ],
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
