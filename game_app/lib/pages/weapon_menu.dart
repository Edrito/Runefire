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
import '/resources/routes.dart' as routes;
import 'menu.dart';

class DisplayEquipedWeapon extends StatelessWidget {
  const DisplayEquipedWeapon(
      {required this.onTap,
      required this.weaponType,
      required this.level,
      super.key});
  final Function onTap;
  final WeaponType weaponType;
  final int level;
  final radius = 20.0;
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
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color:
                  (isHover ? buttonDownColor : buttonUpColor).withOpacity(.4),
              borderRadius: BorderRadius.circular(radius)),
          child: SizedBox.square(
            dimension: 225,
            child: Column(
              // mainAxisSize: MainAxisSize.min,
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Level $level",
                    style: defaultStyle.copyWith(
                        color: isHover ? buttonDownColor : buttonUpColor),
                  ),
                )
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
                    curve: Curves.easeInOut),
          ),
        ),
      );
    });
  }
}

final rng = Random();

class DisplayEquipedAbility extends StatelessWidget {
  const DisplayEquipedAbility(
      {required this.onTap,
      required this.secondaryType,
      required this.level,
      super.key});
  final Function onTap;
  final SecondaryType secondaryType;
  final int level;
  final radius = 20.0;

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
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color:
                  (isHover ? buttonDownColor : buttonUpColor).withOpacity(.4),
              borderRadius: BorderRadius.circular(radius)),
          child: SizedBox.square(
            dimension: 100,
            child: Column(
              // mainAxisSize: MainAxisSize.min,
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
            )
                .animate(
                  onPlay: randomBegin,
                  onComplete: onComplete,
                )
                .moveY(
                    begin: 3,
                    end: -3,
                    duration: 1.seconds,
                    curve: Curves.easeInOut),
          ),
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
                color: isEquiped
                    ? equippedColor
                    : isUnlocked
                        ? unlockedColor
                        : lockedColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow()]),
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
                                  color: backgroundColor),
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
            .clamp(1, secondaryType.maxLevel);

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
                                  color: backgroundColor),
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

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: size.width * .8,
          height: size.height * .8,
          decoration: BoxDecoration(
            color: backgroundColor.brighten(.1),
          ),
          child: Tab(
            child: Column(
              children: [
                if (!widget.isSecondaryAbility)
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
                                  : backgroundColor.brighten(.15),
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
                Expanded(
                    child: ListView(
                  children: entries
                      .animate(interval: .1.seconds)
                      .moveX(begin: -50, end: 0, curve: Curves.easeIn)
                      .fadeIn(curve: Curves.easeIn),
                )),
                CustomButton(
                  "Back",
                  gameRef: widget.gameRef,
                  onTap: () => widget.onBack(),
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
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            isPrimary ? "Primary" : "Secondary",
            style: defaultStyle,
          ),
        ),
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

    Widget primaryWeaponTile = DisplayEquipedWeapon(
      level:
          playerDataComponent.dataObject.unlockedWeapons[entries.first.value] ??
              0,
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
    Widget primarySecondaryTile = DisplayEquipedAbility(
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
    Widget secondaryWeaponTile = DisplayEquipedWeapon(
      level:
          playerDataComponent.dataObject.unlockedWeapons[entries.last.value] ??
              0,
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

    Widget secondarySecondaryTile = DisplayEquipedAbility(
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
                const Spacer(),
                buildWeaponTile(primaryWeaponTile, primarySecondaryTile, true),
                const Spacer(
                  flex: 3,
                ),
                buildWeaponTile(
                    secondaryWeaponTile, secondarySecondaryTile, false),
                const Spacer(),
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

class LevelMenu extends StatefulWidget {
  const LevelMenu({
    super.key,
    required this.gameRef,
  });
  final GameRouter gameRef;

  @override
  State<LevelMenu> createState() => _LevelMenuState();
}

class _LevelMenuState extends State<LevelMenu> {
  GameLevel? selectedLevel;

  Widget buildTile(GameLevel level) {
    bool isHovering = false;
    return StatefulBuilder(builder: (context, setstate) {
      bool isSelected = level == selectedLevel;
      return SizedBox.square(
        dimension: 200,
        child: InkWell(
          radius: 10,
          onHover: (value) {
            setstate(
              () {
                isHovering = value;
              },
            );
          },
          onTap: () {
            setState(() {
              selectedLevel = level;
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: isHovering
                    ? Colors.green
                    : isSelected
                        ? Colors.blue
                        : Colors.white,
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                level.name.titleCase,
                style: defaultStyle,
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> levels = [];

    for (var element in GameLevel.values) {
      levels.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: buildTile(element),
      ));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: levels,
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
                  changeMainMenuPage(MenuPages.weaponMenu);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: CustomButton(
                "Begin",
                gameRef: widget.gameRef,
                onTap: () {
                  toggleGameStart(routes.gameplay);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
