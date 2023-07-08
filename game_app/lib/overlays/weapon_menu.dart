import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/visuals.dart';
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
            dimension: 225,
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
                .animate(
                  onPlay: randomBegin,
                  onComplete: onComplete,
                )
                .moveY(
                    begin: 5,
                    end: -5,
                    duration: 1.seconds,
                    curve: Curves.easeInOut)
                .animate(
                  target: isHover ? 1 : 0,
                )
                .moveY(
                    end: -15,
                    begin: 0,
                    duration: .5.seconds,
                    curve: Curves.easeInCubic),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Transform(
                  alignment: Alignment.center,
                  transform:
                      isPrimary ? Matrix4.rotationY(pi) : Matrix4.rotationX(0),
                  child: Image.asset(
                    'assets/images/decorations/under_item.png',
                    filterQuality: FilterQuality.none,
                    width: 150,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
          ).animate(
            target: isHover ? 1 : 0,
          )
          // .rotate(
          //     end: isPrimary ? 1 : -1,
          //     begin: 0,
          //     duration: .5.seconds,
          //     curve: Curves.decelerate),
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
                child: Transform(
                  alignment: Alignment.center,
                  transform:
                      isPrimary ? Matrix4.rotationY(pi) : Matrix4.rotationX(0),
                  child: Image.asset(
                    'assets/images/decorations/under_item.png',
                    filterQuality: FilterQuality.none,
                    width: 150,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
          ),
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
      required this.gameRef,
      super.key});

  final Function(dynamic) onSelect;
  final Function onBack;

  final GameRouter gameRef;
  final bool isPrimary;
  final bool isSecondaryAbility;

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

  Widget buildUnlockIndicator(bool isPointUnlocked) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            color: isPointUnlocked ? Colors.white : lockedColor,
          ),
          width: 10,
          height: 50,
        ),
      ),
    );
  }

  AttackType weaponTab = AttackType.projectile;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final playerData = playerDataComponent.dataObject;
    final borderColor = backgroundColor2.brighten(.1);
    const borderWidth = 5.0;
    List<Widget> entries = [];

    if (!widget.isSecondaryAbility) {
      Iterable<WeaponType> shownWeapons =
          WeaponType.values.where((element) => element.attackType == weaponTab);

      for (var weaponType in shownWeapons) {
        bool isEquiped = playerData.selectedWeapons.values.contains(weaponType);
        bool isUnlocked = playerData.unlockedWeapons.keys.contains(weaponType);
        int unlockedLevel = playerData.unlockedWeapons[weaponType] ?? 0;

        entries.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
                color: (isEquiped
                        ? equippedColor
                        : isUnlocked
                            ? unlockedColor
                            : lockedColor)
                    .withOpacity(.85),
                border: Border.all(width: borderWidth / 2)),
            child: InkWell(
              onTap: isUnlocked ? () => widget.onSelect(weaponType) : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: Image.asset(
                                  weaponType.icon,
                                  fit: BoxFit.fitWidth,
                                  filterQuality: FilterQuality.low,
                                  isAntiAlias: true,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                weaponType.name.titleCase,
                                style: defaultStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            ...[
                              for (var i = 0; i < unlockedLevel; i++)
                                buildUnlockIndicator(true)
                            ],
                            ...[
                              for (var i = 0;
                                  i < (weaponType.maxLevel - unlockedLevel);
                                  i++)
                                buildUnlockIndicator(false)
                            ]
                          ],
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                        onTap: () {
                          playerData.unlockedWeapons[weaponType] ??= 0;
                          playerData.unlockedWeapons[weaponType] =
                              playerData.unlockedWeapons[weaponType]! + 1;
                          playerDataComponent.notifyListeners();
                        },
                        child: SizedBox.square(
                          dimension: 50,
                          child: Container(
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: backgroundColor1),
                              child: Icon(
                                isUnlocked ? Icons.add : Icons.lock_open,
                                color: Colors.white,
                              )),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ));
      }
    } else {
      Iterable<SecondaryType> shownSecondaries = SecondaryType.values.where(
          (element) => element.compatibilityCheck(playerData
              .selectedWeapons[widget.isPrimary ? 0 : 1]!
              .createFunction(null, null)));

      for (var secondaryType in shownSecondaries) {
        bool isEquiped =
            playerData.selectedSecondaries[widget.isPrimary ? 0 : 1] ==
                (secondaryType);
        bool isUnlocked =
            playerData.unlockedSecondarys.keys.contains(secondaryType);
        int unlockedLevel = (playerData.unlockedSecondarys[secondaryType] ?? 0)
            .clamp(0, secondaryType.maxLevel);

        entries.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                color: isEquiped
                    ? equippedColor
                    : isUnlocked
                        ? unlockedColor
                        : lockedColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow()]),
            width: 10,
            child: InkWell(
              onTap: isUnlocked ? () => widget.onSelect(secondaryType) : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              secondaryType.name.titleCase,
                              style: defaultStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            ...[
                              for (var i = 0; i < unlockedLevel; i++)
                                buildUnlockIndicator(true)
                            ],
                            ...[
                              for (var i = 0;
                                  i < (secondaryType.maxLevel - unlockedLevel);
                                  i++)
                                buildUnlockIndicator(false)
                            ]
                          ],
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                        onTap: () {
                          playerData.unlockedSecondarys[secondaryType] ??= 0;
                          playerData.unlockedSecondarys[secondaryType] =
                              playerData.unlockedSecondarys[secondaryType]! + 1;
                          playerDataComponent.notifyListeners();
                        },
                        child: SizedBox.square(
                          dimension: 50,
                          child: Container(
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: backgroundColor1),
                              child: Icon(
                                isUnlocked ? Icons.add : Icons.lock_open,
                                color: Colors.white,
                              )),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ));
      }
    }

    return ClipRRect(
      child: Container(
        color: backgroundColor1.brighten(.1).withOpacity(.5),
        child: Center(
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
                              setState(() {
                                weaponTab = AttackType.values[i];
                              });
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomButton(
                    "Back",
                    gameRef: widget.gameRef,
                    onTap: () => widget.onBack(),
                  ),
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

  Widget? weaponSelector;

  Widget buildWeaponTile(Widget weapon, Widget ability, bool isPrimary) {
    return Column(
      crossAxisAlignment:
          isPrimary ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isPrimary) weapon,
            Padding(
              padding: const EdgeInsets.all(12),
              child: ability,
            ),
            if (isPrimary) weapon
          ],
        ),
      ],
    );
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
            isSecondaryAbility: false,
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
            isSecondaryAbility: false,
            onSelect: (weaponType) {
              if (playerDataComponent.dataObject.selectedWeapons.values
                  .contains(weaponType)) return;
              setState(() {
                playerDataComponent.dataObject.selectedWeapons[1] = weaponType;
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

    Widget secondarySecondaryTile = SecondaryTile(
      isPrimary: false,
      level: playerDataComponent
              .dataObject.unlockedSecondarys[secondaryEntries.last.value] ??
          0,
      secondaryType: secondaryEntries.last.value,
      onTap: () {
        setState(() {
          weaponSelector = WeaponSecondarySelector(
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
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Select your weapons",
                style: defaultStyle,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // const Spacer(),
                buildWeaponTile(primaryWeaponTile, primarySecondaryTile, true),
                const Spacer(
                  flex: 4,
                ),
                buildWeaponTile(
                    secondaryWeaponTile, secondarySecondaryTile, false),
                // const Spacer(),
              ],
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
                      changeMainMenuPage(MenuPages.startMenuPage);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: CustomButton(
                    "Choose Level",
                    gameRef: widget.gameRef,
                    onTap: () {
                      changeMainMenuPage(MenuPages.levelMenu);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        if (weaponSelector != null) weaponSelector!,
      ],
    );
  }
}
