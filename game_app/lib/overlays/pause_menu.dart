import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/attributes/attributes_enum.dart';

import '../game/enviroment.dart';
import '../game/enviroment_mixin.dart';
import '../main.dart';
import '../resources/visuals.dart';
import 'buttons.dart';

class PauseMenu extends StatefulWidget {
  const PauseMenu(this.gameReference, {super.key});
  final GameRouter gameReference;
  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  FocusNode node = FocusNode();
  late final GameEnviroment env;
  @override
  void initState() {
    super.initState();
    node.requestFocus();
    env = getEnviromentFromRouter(widget.gameReference) as GameEnviroment;
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
          resumeGame();
        }
      },
      child: Center(
        child: StatefulBuilder(builder: (context, setState) {
          var entries = env.player?.currentAttributes.entries.toList();
          var tempEntries = entries?.where(
              (element) => element.key.category == AttributeCategory.temporary);
          var nonTempEntries = entries?.where(
              (element) => element.key.category != AttributeCategory.temporary);
          entries?.sort(
              (a, b) => a.key.rarity.index.compareTo(b.key.rarity.index));
          entries?.sort(
              (b, a) => a.value.upgradeLevel.compareTo(b.value.upgradeLevel));
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
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 55,
                                  child: Text(
                                    "${currentAttrib?.value.upgradeLevel} : ",
                                    style: defaultStyle.copyWith(
                                        color: currentAttrib?.key.rarity.color),
                                  ),
                                ),
                                Text(
                                  "${currentAttrib?.value.title}",
                                  style: defaultStyle.copyWith(
                                      color: currentAttrib?.key.rarity.color),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
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
                      child: ListView.builder(
                        itemCount: nonTempEntries?.length ?? 0,
                        itemBuilder: (context, index) {
                          final currentAttrib =
                              nonTempEntries?.elementAt(index);

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 55,
                                  child: Text(
                                    "${currentAttrib?.value.upgradeLevel} : ",
                                    style: defaultStyle.copyWith(
                                        color: currentAttrib?.key.rarity.color),
                                  ),
                                ),
                                Text(
                                  "${currentAttrib?.value.title}",
                                  style: defaultStyle.copyWith(
                                      color: currentAttrib?.key.rarity.color),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
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
                                              resumeGame();
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
                                              final gameEnviroment =
                                                  currentEnviroment;
                                              if (gameEnviroment
                                                  is PlayerFunctionality) {
                                                resumeGame();
                                                (currentEnviroment
                                                        as PlayerFunctionality)
                                                    .player
                                                    ?.killPlayer(false);
                                              } else {
                                                endGame(false);
                                              }
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
