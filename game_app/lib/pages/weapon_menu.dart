import 'package:flame/components.dart';
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
                  onComplete: (controller) => controller
                      .reverse()
                      .then((value) => controller.forward(from: 0)),
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
            child: const Column(
              // mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Image.asset(
                //     secondaryType.icon,
                //     height: 100,
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.abc,
                    size: 30,
                  ),
                )
              ],
            )
                .animate(
                  onComplete: (controller) => controller
                      .reverse()
                      .then((value) => controller.forward(from: 0)),
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

class WeaponSelector extends StatefulWidget {
  const WeaponSelector(
      {required this.onSelect,
      required this.onBack,
      required this.isPrimary,
      required this.gameRef,
      super.key});

  final Function(WeaponType) onSelect;
  final Function onBack;

  final GameRouter gameRef;
  final bool isPrimary;

  @override
  State<WeaponSelector> createState() => _WeaponSelectorState();
}

class _WeaponSelectorState extends State<WeaponSelector> {
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
              color: isPointUnlocked ? Colors.green : Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow()]),
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

    Iterable<WeaponType> shownWeapons =
        WeaponType.values.where((element) => element.attackType == weaponTab);

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: size.width * .8,
          height: size.height * .8,
          decoration: const BoxDecoration(
            color: Colors.grey,
          ),
          child: Tab(
            child: Column(
              children: [
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
                                ? Colors.green
                                : Colors.grey,
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
                      )
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: shownWeapons.length,
                    itemBuilder: (context, index) {
                      WeaponType weaponType = shownWeapons.elementAt(index);
                      bool isEquiped = playerData.selectedWeapons.values
                          .contains(weaponType);
                      bool isUnlocked =
                          playerData.unlockedWeapons.keys.contains(weaponType);
                      int unlockedLevel =
                          playerData.unlockedWeapons[weaponType] ?? 0;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: isEquiped
                                  ? Colors.green.shade200
                                  : isUnlocked
                                      ? Colors.grey.shade200
                                      : Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [BoxShadow()]),
                          width: 10,
                          child: InkWell(
                            onTap: isUnlocked
                                ? () => widget.onSelect(weaponType)
                                : null,
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
                                          child: Image.asset(
                                            weaponType.icon,
                                            filterQuality: FilterQuality.none,
                                            height: 50,
                                            width: 110,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            weaponType.name.titleCase,
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
                                            for (var i = 0;
                                                i < unlockedLevel;
                                                i++)
                                              buildUnlockIndicator(true)
                                          ],
                                          ...[
                                            for (var i = 0;
                                                i <
                                                    (weaponType.maxLevel -
                                                        unlockedLevel);
                                                i++)
                                              buildUnlockIndicator(false)
                                          ]
                                        ],
                                      )),
                                  IconButton(
                                      onPressed: () {
                                        playerData
                                            .unlockedWeapons[weaponType] ??= 0;
                                        playerData.unlockedWeapons[weaponType] =
                                            playerData.unlockedWeapons[
                                                    weaponType]! +
                                                1;
                                        playerDataComponent.notifyListeners();
                                      },
                                      icon: isUnlocked
                                          ? const Icon(Icons.add)
                                          : const Icon(Icons.lock_open)),
                                  IconButton(
                                      onPressed: () {
                                        playerData
                                            .unlockedWeapons[weaponType] ??= 0;
                                        playerData.unlockedWeapons[weaponType] =
                                            playerData.unlockedWeapons[
                                                    weaponType]! -
                                                1;
                                        playerDataComponent.notifyListeners();
                                      },
                                      icon: const Icon(Icons.remove)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
            weapon,
            Padding(
              padding: const EdgeInsets.all(12),
              child: ability,
            ),
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
          weaponSelector = WeaponSelector(
            onSelect: (weaponType) {
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
          weaponSelector = WeaponSelector(
            onSelect: (secondaryType) {
              setState(() {
                // playerDataComponent.dataObject.selectedSecondaries[0] =
                //     secondaryType;
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
          weaponSelector = WeaponSelector(
            onSelect: (weaponType) {
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
          weaponSelector = WeaponSelector(
            onSelect: (secondaryType) {
              setState(() {
                // playerDataComponent.dataObject.selectedSecondaries[1] =
                //     secondaryType;
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
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Spacer(),
                buildWeaponTile(primaryWeaponTile, primarySecondaryTile, true),
                const Spacer(),
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
                    "Chose Level",
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
