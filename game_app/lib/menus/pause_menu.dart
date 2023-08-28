import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/attributes/attributes_structure.dart';
import 'package:game_app/resources/game_state_class.dart';
import 'package:numerus/numerus.dart';
import '../game/enviroment.dart';
import '../main.dart';
import '../resources/visuals.dart';
import 'buttons.dart';

class PauseMenu extends StatefulWidget {
  const PauseMenu(this.gameRef, {super.key});
  final GameRouter gameRef;
  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  FocusNode node = FocusNode();
  late final GameEnviroment env;
  late final GameState gameState;
  late final GameRouter gameRouter;

  bool fetchAttributeLogicChecker(
      MapEntry<AttributeType, Attribute> element, bool isTemp) {
    final tempChecker =
        ((element.key.territory == AttributeTerritory.temporary && isTemp) ||
            (element.key.territory != AttributeTerritory.temporary && !isTemp));

    final permanentChecker =
        element.key.territory != AttributeTerritory.permanent;
    return tempChecker && permanentChecker;
  }

  @override
  void initState() {
    super.initState();
    node.requestFocus();
    gameRouter = widget.gameRef;
    gameState = gameRouter.gameStateComponent.gameState;
    env = gameState.currentEnviroment as GameEnviroment;
  }

  final Size cardSize = const Size(128, 96);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Color highlightColor = Colors.grey.shade800;

    Widget background = Positioned.fill(
        bottom: null,
        child: Image.asset(
          'assets/images/ui/attribute_background_mask.png',
          fit: BoxFit.fitWidth,
          color: highlightColor.withOpacity(.6),
          filterQuality: FilterQuality.none,
        ));

    Widget border = Positioned.fill(
        bottom: null,
        child: Image.asset(
          'assets/images/ui/attribute_border.png',
          filterQuality: FilterQuality.none,
          color: highlightColor,
          fit: BoxFit.fitWidth,
        ));

    return KeyboardListener(
      focusNode: node,
      onKeyEvent: (value) {
        if (value is! KeyDownEvent) return;
        if (value.logicalKey == LogicalKeyboardKey.escape ||
            value.logicalKey == LogicalKeyboardKey.keyP) {
          gameState.resumeGame();
        }
      },
      child: Center(
        child: StatefulBuilder(builder: (context, setState) {
          var entries = env.player?.currentAttributes.entries.toList();
          var tempEntries = entries
              ?.where((element) => fetchAttributeLogicChecker(element, true));
          var nonTempEntries = entries
              ?.where((element) => fetchAttributeLogicChecker(element, false));

          entries?.sort(
              (a, b) => a.key.rarity.index.compareTo(b.key.rarity.index));

          entries?.sort(
              (b, a) => a.value.upgradeLevel.compareTo(b.value.upgradeLevel));
          // nonTempEntries = [
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          //   ...nonTempEntries ?? [],
          // ];
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Temporary Effects",
                        style: defaultStyle,
                      ),
                    ),
                    Container(
                      height: 5,
                      color: defaultStyle.color,
                    ),
                    Flexible(
                      child: ListView.builder(
                        itemCount: tempEntries?.length ?? 0,
                        itemBuilder: (context, index) {
                          final currentAttrib = tempEntries?.elementAt(index);

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              // color: Colors.blue,
                              height: 100,
                              width: 60,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                      'assets/images/${currentAttrib?.value.icon}',
                                      color: currentAttrib?.key.rarity.color),
                                  SizedBox(
                                    width: 55,
                                    child: Text(
                                      currentAttrib?.value.upgradeLevel
                                              .toRomanNumeralString() ??
                                          "",
                                      style: defaultStyle.copyWith(
                                          color:
                                              currentAttrib?.key.rarity.color,
                                          fontSize: 20),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Permanent Effects",
                        style: defaultStyle,
                      ),
                    ),
                    Container(
                      height: 5,
                      color: defaultStyle.color,
                    ),
                    Flexible(
                      flex: 2,
                      child: ScrollConfiguration(
                        behavior: scrollConfiguration(context),
                        child: SingleChildScrollView(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              children: [
                                for (int i = 0;
                                    i < (nonTempEntries?.length ?? 0);
                                    i++)
                                  Builder(
                                    builder: (context) {
                                      final currentAttrib =
                                          nonTempEntries?.elementAt(i);

                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          // color: Colors.blue,
                                          height: 100,
                                          width: 60,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                  'assets/images/${currentAttrib?.value.icon}',
                                                  color: currentAttrib
                                                      ?.key.rarity.color),
                                              SizedBox(
                                                width: 55,
                                                child: Text(
                                                  currentAttrib
                                                          ?.value.upgradeLevel
                                                          .toRomanNumeralString() ??
                                                      "",
                                                  style: defaultStyle.copyWith(
                                                      color: currentAttrib
                                                          ?.key.rarity.color,
                                                      fontSize: 20),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: 350, minWidth: 250),
                    child: Column(
                      children: [
                        const Spacer(),
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Taking a break?",
                                  style: defaultStyle.copyWith(
                                      color: highlightColor),
                                ),
                              ).animate().fadeIn(),
                              const SizedBox(
                                height: 50,
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    background,
                                    border,
                                    Positioned(
                                      top: 50,
                                      right: 0,
                                      left: 0,
                                      child: DisplayButtons(
                                        buttons: List<CustomButton>.from([
                                          CustomButton(
                                            "Resume",
                                            upDownColor: (
                                              highlightColor.brighten(.5),
                                              highlightColor
                                            ),
                                            gameRef: gameRouter,
                                            onTap: () {
                                              gameState.resumeGame();
                                            },
                                          ),
                                          CustomButton(
                                            "Give up",
                                            gameRef: gameRouter,
                                            upDownColor: (
                                              highlightColor.brighten(.5),
                                              highlightColor
                                            ),
                                            onTap: () {
                                              gameState.resumeGame();
                                              gameState.killPlayer(
                                                  false, env.player!);
                                            },
                                          )
                                        ]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer()
            ],
          );
        }),
      ),
    );
  }
}
