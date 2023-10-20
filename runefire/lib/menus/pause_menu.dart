import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/menus/elemental_power_level.dart';
import 'package:runefire/menus/options.dart';
import 'package:runefire/menus/overlays.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:numerus/numerus.dart';
import '../game/enviroment.dart';
import '../main.dart';
import '../resources/visuals.dart';
import 'custom_button.dart';

class OverlayWidgetDisplay extends StatefulWidget {
  const OverlayWidgetDisplay(this.gameRef, {required this.child, super.key});
  final GameRouter gameRef;
  final Widget child;

  @override
  State<OverlayWidgetDisplay> createState() => _OverlayWidgetDisplayState();
}

class _OverlayWidgetDisplayState extends State<OverlayWidgetDisplay> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final ratio = largeCardSize.aspectRatio;
      final double maxHeightOfAttributes = constraints.maxWidth / ratio;

      return SizedBox(
        height: maxHeightOfAttributes,
        child: Stack(
          children: [
            const CustomBorderBox(),
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0 * maxHeightOfAttributes / 100),
                  child: SizedBox(
                      height: maxHeightOfAttributes, child: widget.child),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class CustomBorderBox extends StatelessWidget {
  const CustomBorderBox(
      {this.child,
      this.small = false,
      this.hideBackground = false,
      this.hideBaseBorder = false,
      this.lightColor = false,
      super.key});
  final Widget? child;
  final bool small;
  final bool hideBackground;
  final bool hideBaseBorder;
  final bool lightColor;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = ApolloColorPalette.mediumGray.color;
    Color borderColorBase = ApolloColorPalette.darkestGray.color;
    Color borderColorMid = ApolloColorPalette.lightGray.color;
    Color borderColorTop = ApolloColorPalette.veryLightGray.color;

    String backgroundImage = small
        ? ImagesAssetsUi.attributeBackgroundMaskSmall.path
        : ImagesAssetsUi.attributeBackgroundMask.path;
    String borderImage = small
        ? ImagesAssetsUi.attributeBorderSmall.path
        : ImagesAssetsUi.attributeBorder.path;
    String borderMidImage = small
        ? ImagesAssetsUi.attributeBorderMidSmall.path
        : ImagesAssetsUi.attributeBorderMid.path;
    String borderBaseImage = small
        ? ImagesAssetsUi.attributeBorderBaseSmall.path
        : ImagesAssetsUi.attributeBorderBase.path;
    Widget background = Positioned.fill(
        child: Image.asset(
      backgroundImage,
      fit: BoxFit.fitWidth,
      color: backgroundColor,
      filterQuality: FilterQuality.none,
    ));
    Widget border = Positioned.fill(
        child: buildImageAsset(
      borderImage,
      color: borderColorTop,
      fit: BoxFit.fitWidth,
    ));
    Widget borderMid = Positioned.fill(
        child: buildImageAsset(
      borderMidImage,
      color: borderColorMid,
      fit: BoxFit.fitWidth,
    ));
    Widget borderBase = Positioned.fill(
        child: buildImageAsset(
      borderBaseImage,
      color: borderColorBase,
      fit: BoxFit.fitWidth,
    ));
    final Size cardSize = small ? smallCardSize : largeCardSize;

    return SizedBox(
      // width: cardSize.width,
      // height: cardSize.height,
      child: Stack(alignment: Alignment.topCenter, children: [
        if (!hideBackground) background,
        if (!hideBaseBorder) borderBase,
        borderMid,
        border,
        if (child != null) Positioned.fill(child: child!)
      ]),
    );
  }
}

class OverlayWidgetList extends StatefulWidget {
  const OverlayWidgetList(this.gameRef, this.buttons, this.title, {super.key});
  final String title;
  final List<Widget> buttons;
  final GameRouter gameRef;
  @override
  State<OverlayWidgetList> createState() => _OverlayWidgetListState();
}

class _OverlayWidgetListState extends State<OverlayWidgetList> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Color color = colorPalette.secondaryColor;

    Widget title = Positioned.fill(
      bottom: null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          widget.title,
          textAlign: TextAlign.center,
          style: defaultStyle.copyWith(
              color: color,
              shadows: [colorPalette.buildShadow(ShadowStyle.light)]),
        ).animate().fadeIn(),
      ),
    );
    return SizedBox.expand(
      child: Stack(
        children: [
          const CustomBorderBox(),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.buttons,
              ),
            ),
          ),
          title
        ],
      ),
    );
  }
}

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
  bool testHoverTest = false;
  bool optionsEnabled = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var entries = env.player?.currentAttributes;

    var nonTempEntries = entries?.values
            .where((element) => fetchAttributeLogicChecker(element, false))
            .toList() ??
        [];

    nonTempEntries.sort((a, b) =>
        a.attributeType.rarity.index.compareTo(b.attributeType.rarity.index));

    nonTempEntries.sort((b, a) => a.upgradeLevel.compareTo(b.upgradeLevel));

    double bottomPaddingAmount = 200 * ((size.height - 300) / 900).clamp(0, 1);
    return Container(
      color: ApolloColorPalette.darkestGray.color.withOpacity(.8),
      child: optionsEnabled
          ? OptionsMenu(
              gameRef: gameRouter,
              backFunction: () {
                setState(
                  () {
                    optionsEnabled = false;
                  },
                );
              },
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  bottom: bottomPaddingAmount,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 900),
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 700),
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    child: OverlayWidgetDisplay(
                                      gameRouter,
                                      child: StatsDisplay(
                                        gameRef: gameRouter,
                                        statStrings:
                                            env.player?.buildStatStrings(false),
                                      ),
                                    )),
                              ),
                            ),
                          ),
                          Center(
                            child: SizedBox(
                              width: 450,
                              child: OverlayWidgetList(
                                  gameRouter,
                                  [
                                    CustomButton(
                                      "Resume",
                                      upDownColor: (
                                        colorPalette.primaryColor.brighten(.5),
                                        colorPalette.primaryColor
                                      ),
                                      rowId: 1,
                                      gameRef: widget.gameRef,
                                      onPrimary: () {
                                        gameState.resumeGame();
                                      },
                                    ),
                                    CustomButton("Options",
                                        gameRef: widget.gameRef,
                                        rowId: 3, onPrimary: () {
                                      setState(
                                        () {
                                          optionsEnabled = true;
                                        },
                                      );
                                    }),
                                    CustomButton(
                                      "Give up",
                                      gameRef: gameRouter,
                                      upDownColor: (
                                        colorPalette.primaryColor.brighten(.5),
                                        colorPalette.primaryColor
                                      ),
                                      rowId: 5,
                                      onPrimary: () {
                                        gameState.resumeGame();
                                        gameState.currentPlayer?.die(
                                            DamageInstance(
                                                damageMap: {},
                                                source: env.player!,
                                                victim: env.player!,
                                                sourceAttack: this),
                                            EndGameState.quit);
                                      },
                                    )
                                  ],
                                  "Pause Menu"),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 700),
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    child: OverlayWidgetDisplay(
                                      gameRouter,
                                      child: AttributeDisplay(
                                          gameRef: gameRouter,
                                          attributes: nonTempEntries),
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: TotalPowerGraph(
                    player: env.player!,
                  ),
                )
              ],
            ),
    ).animate().fadeIn();
  }
}
