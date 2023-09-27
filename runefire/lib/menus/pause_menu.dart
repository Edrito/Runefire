import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:numerus/numerus.dart';
import '../game/enviroment.dart';
import '../main.dart';
import '../resources/visuals.dart';
import 'buttons.dart';

class AttributeDisplay extends StatefulWidget {
  const AttributeDisplay(
      this.gameRef, this.attributes, this.statStrings, this.title,
      {super.key});
  final String title;
  final List<Attribute>? attributes;
  final List<(String, String)>? statStrings;
  final GameRouter gameRef;

  @override
  State<AttributeDisplay> createState() => _AttributeDisplayState();
}

class _AttributeDisplayState extends State<AttributeDisplay> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Color backgroundColor = ApolloColorPalette.mediumGray.color;
    Color color = colorPalette.secondaryColor;
    Widget background = Positioned.fill(
        // bottom: null,
        child: Image.asset(
      'assets/images/ui/attribute_background_mask.png',
      fit: BoxFit.fitWidth,
      color: backgroundColor.withOpacity(1),
      filterQuality: FilterQuality.none,
    ));

    Widget border = Positioned.fill(
        // bottom: null,
        child: Image.asset(
      'assets/images/ui/attribute_border.png',
      filterQuality: FilterQuality.none,
      color: backgroundColor.brighten(.4),
      fit: BoxFit.fitWidth,
    ));
    Widget borderInner = Positioned.fill(
        // bottom: null,
        child: Padding(
      padding: const EdgeInsets.all(3),
      child: Image.asset(
        'assets/images/ui/attribute_border.png',
        filterQuality: FilterQuality.none,
        color: backgroundColor.brighten(.1),
        fit: BoxFit.fitWidth,
      ),
    ));
    Widget borderInnerInner = Positioned.fill(
        // bottom: null,
        child: Padding(
      padding: const EdgeInsets.all(6),
      child: Image.asset(
        'assets/images/ui/attribute_border.png',
        filterQuality: FilterQuality.none,
        color: backgroundColor.darken(.7),
        fit: BoxFit.fitWidth,
      ),
    ));

    Widget title = Positioned.fill(
      bottom: null,
      child: Text(
        widget.title,
        textAlign: TextAlign.center,
        style: defaultStyle.copyWith(
            color: color,
            shadows: [colorPalette.buildShadow(ShadowStyle.light)]),
      ).animate().fadeIn(),
    );

    Widget displayWidget = const SizedBox();
    if (widget.attributes != null) {
      displayWidget = Wrap(
        children: [
          for (int i = 0; i < (widget.attributes!.length); i++)
            Builder(
              builder: (context) {
                final currentAttrib = widget.attributes!.elementAt(i);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    // color: Colors.blue,
                    height: 100,
                    width: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/${currentAttrib.icon}',
                            color: currentAttrib.attributeType.rarity.color),
                        SizedBox(
                          width: 55,
                          child: Text(
                            currentAttrib.upgradeLevel.toRomanNumeralString() ??
                                "",
                            style: defaultStyle.copyWith(
                                color: currentAttrib.attributeType.rarity.color,
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
      );
    } else if (widget.statStrings != null) {
      displayWidget = Column(
        children: [
          for (int i = 0; i < (widget.statStrings!.length); i++)
            Builder(
              builder: (context) {
                final currentStr = widget.statStrings!.elementAt(i);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    // color: Colors.blue,
                    // height: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentStr.$1,
                          style: defaultStyle.copyWith(fontSize: 20),
                        ),
                        Text(
                          currentStr.$2,
                          style: defaultStyle.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
        ],
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      final ratio = largeCardSize.aspectRatio;
      final double maxHeightOfAttributes = constraints.maxWidth / ratio;

      return SizedBox.expand(
        child: Stack(
          children: [
            background,
            borderInnerInner,
            borderInner,
            border,
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  height: maxHeightOfAttributes,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 16),
                      child: ScrollConfiguration(
                        behavior: scrollConfiguration(context),
                        child: SingleChildScrollView(
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: displayWidget),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            title
          ],
        ),
      );
    });
  }
}

class InGameMenu extends StatefulWidget {
  const InGameMenu(this.gameRef, this.buttons, this.title, {super.key});
  final String title;
  final List<CustomButton> buttons;
  final GameRouter gameRef;
  @override
  State<InGameMenu> createState() => _InGameMenuState();
}

class _InGameMenuState extends State<InGameMenu> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Color backgroundColor = ApolloColorPalette.mediumGray.color;
    Color color = colorPalette.secondaryColor;

    Widget background = Positioned.fill(
        // bottom: null,
        child: Image.asset(
      'assets/images/ui/attribute_background_mask.png',
      fit: BoxFit.fitWidth,
      color: backgroundColor.withOpacity(1),
      filterQuality: FilterQuality.none,
    ));

    Widget border = Positioned.fill(
        // bottom: null,
        child: Image.asset(
      'assets/images/ui/attribute_border.png',
      filterQuality: FilterQuality.none,
      color: backgroundColor.brighten(.4),
      fit: BoxFit.fitWidth,
    ));
    Widget borderInner = Positioned.fill(
        // bottom: null,
        child: Padding(
      padding: const EdgeInsets.all(3),
      child: Image.asset(
        'assets/images/ui/attribute_border.png',
        filterQuality: FilterQuality.none,
        color: backgroundColor.brighten(.1),
        fit: BoxFit.fitWidth,
      ),
    ));
    Widget borderInnerInner = Positioned.fill(
        // bottom: null,
        child: Padding(
      padding: const EdgeInsets.all(6),
      child: Image.asset(
        'assets/images/ui/attribute_border.png',
        filterQuality: FilterQuality.none,
        color: backgroundColor.darken(.7),
        fit: BoxFit.fitWidth,
      ),
    ));

    Widget title = Positioned.fill(
      bottom: null,
      child: Text(
        widget.title,
        textAlign: TextAlign.center,
        style: defaultStyle.copyWith(
            color: color,
            shadows: [colorPalette.buildShadow(ShadowStyle.light)]),
      ).animate().fadeIn(),
    );
    return SizedBox.expand(
      child: Stack(
        children: [
          background,
          borderInnerInner,
          borderInner,
          border,
          Positioned.fill(
            // top: 50,
            // right: 0,
            // left: 0,
            child: Center(
              child: DisplayButtons(
                buttons: List<CustomButton>.from(widget.buttons),
              ),
            ),
          ),
          title
        ],
      ),
    );
  }
}

// class InGameMenu extends StatefulWidget {
//   const InGameMenu(this.gameRef, this.buttons, this.title, {super.key});
//   final String title;
//   final List<CustomButton> buttons;
//   final GameRouter gameRef;
//   @override
//   State<InGameMenu> createState() => _InGameMenuState();
// }

// class _InGameMenuState extends State<InGameMenu> {
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     Color backgroundColor = ApolloColorPalette.mediumGray.color;
//     Color color = colorPalette.secondaryColor;

//     Widget background = Positioned.fill(
//         // bottom: null,
//         child: Image.asset(
//       'assets/images/ui/attribute_background_mask.png',
//       fit: BoxFit.fitWidth,
//       color: backgroundColor.withOpacity(1),
//       filterQuality: FilterQuality.none,
//     ));

//     Widget border = Positioned.fill(
//         // bottom: null,
//         child: Image.asset(
//       'assets/images/ui/attribute_border.png',
//       filterQuality: FilterQuality.none,
//       color: backgroundColor.brighten(.4),
//       fit: BoxFit.fitWidth,
//     ));
//     Widget borderInner = Positioned.fill(
//         // bottom: null,
//         child: Padding(
//       padding: const EdgeInsets.all(3),
//       child: Image.asset(
//         'assets/images/ui/attribute_border.png',
//         filterQuality: FilterQuality.none,
//         color: backgroundColor.brighten(.1),
//         fit: BoxFit.fitWidth,
//       ),
//     ));
//     Widget borderInnerInner = Positioned.fill(
//         // bottom: null,
//         child: Padding(
//       padding: const EdgeInsets.all(6),
//       child: Image.asset(
//         'assets/images/ui/attribute_border.png',
//         filterQuality: FilterQuality.none,
//         color: backgroundColor.darken(.7),
//         fit: BoxFit.fitWidth,
//       ),
//     ));

//     Widget title = Positioned.fill(
//       bottom: null,
//       child: Text(
//         widget.title,
//         textAlign: TextAlign.center,
//         style: defaultStyle.copyWith(
//             color: color,
//             shadows: [colorPalette.buildShadow(ShadowStyle.light)]),
//       ).animate().fadeIn(),
//     );
//     return SizedBox.expand(
//       child: Stack(
//         children: [
//           background,
//           borderInnerInner,
//           borderInner,
//           border,
//           Positioned.fill(
//             // top: 50,
//             // right: 0,
//             // left: 0,
//             child: Center(
//               child: DisplayButtons(
//                 buttons: List<CustomButton>.from(widget.buttons),
//               ),
//             ),
//           ),
//           title
//         ],
//       ),
//     );
//   }
// }

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

  bool fetchAttributeLogicChecker(Attribute element, bool isTemp) {
    final tempChecker =
        ((element.attributeType.territory == AttributeTerritory.temporary &&
                isTemp) ||
            (element.attributeType.territory != AttributeTerritory.temporary &&
                !isTemp));

    final permanentChecker =
        element.attributeType.territory != AttributeTerritory.permanent;
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

    return KeyboardListener(
      focusNode: node,
      onKeyEvent: (value) {
        if (value is! KeyDownEvent) return;
        if (value.logicalKey == LogicalKeyboardKey.escape ||
            value.logicalKey == LogicalKeyboardKey.keyP) {
          gameState.resumeGame();
        }
      },
      child: Container(
        color: ApolloColorPalette.darkestGray.color.withOpacity(.8),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 900),
            child: StatefulBuilder(builder: (context, setState) {
              var entries = env.player?.currentAttributes;
              var tempEntries = entries?.values
                      .where((element) =>
                          fetchAttributeLogicChecker(element, true))
                      .toList() ??
                  [];
              var nonTempEntries = entries?.values
                      .where((element) =>
                          fetchAttributeLogicChecker(element, false))
                      .toList() ??
                  [];

              nonTempEntries.sort((a, b) => a.attributeType.rarity.index
                  .compareTo(b.attributeType.rarity.index));

              nonTempEntries
                  .sort((b, a) => a.upgradeLevel.compareTo(b.upgradeLevel));

              // final paddingIncrease =
              //     ((size.width - 1200) / size.width).clamp(0.0, 1.0);

              // print(paddingIncrease);

              return Row(
                children: [
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: AttributeDisplay(
                              gameRouter,
                              null,
                              env.player?.buildStatStrings(false),
                              "Current Stats"),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: 400,
                          minHeight: 200,
                          maxHeight: 500,
                          minWidth: 250),
                      child: InGameMenu(
                          gameRouter,
                          [
                            CustomButton(
                              "Resume",
                              upDownColor: (
                                colorPalette.primaryColor.brighten(.5),
                                colorPalette.primaryColor
                              ),
                              gameRef: widget.gameRef,
                              onTap: () {
                                gameState.resumeGame();
                              },
                            ),
                            CustomButton(
                              "Give up",
                              gameRef: gameRouter,
                              upDownColor: (
                                colorPalette.primaryColor.brighten(.5),
                                colorPalette.primaryColor
                              ),
                              onTap: () {
                                gameState.resumeGame();
                                gameState.killPlayer(
                                    GameEndState.quit,
                                    env.player!,
                                    DamageInstance(
                                        damageMap: {},
                                        source: env.player!,
                                        victim: env.player!,
                                        sourceAttack: this));
                              },
                            )
                          ],
                          "Pause Menu"),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: AttributeDisplay(gameRouter, nonTempEntries,
                              null, "Unlocked Attributes"),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ).animate().fadeIn(),
    );
  }
}
