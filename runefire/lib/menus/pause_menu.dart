import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/attributes/attributes_regular.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/menus/elemental_power_level.dart';
import 'package:runefire/menus/options.dart';
import 'package:runefire/menus/overlays.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:numerus/numerus.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/menus/custom_button.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = largeCardSize.aspectRatio;
        final maxHeightOfAttributes = constraints.maxWidth / ratio;

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
                      height: maxHeightOfAttributes,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomBorderBox extends StatelessWidget {
  const CustomBorderBox({
    this.child,
    this.small = false,
    this.hideBackground = false,
    this.hideBaseBorder = false,
    this.lightColor = false,
    this.attributeType,
    this.damageType,
    super.key,
  });
  final Widget? child;
  final bool small;
  final bool hideBackground;
  final bool hideBaseBorder;
  final bool lightColor;
  final AttributeType? attributeType;
  final DamageType? damageType;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ApolloColorPalette.mediumGray.color;
    final borderColorBase = ApolloColorPalette.darkestGray.color;
    final borderColorMid = ApolloColorPalette.lightGray.color;
    final borderColorTop = ApolloColorPalette.veryLightGray.color;

    final backgroundImage = small
        ? ImagesAssetsUi.attributeBackgroundMaskSmall.path
        : ImagesAssetsUi.attributeBackgroundMask.path;
    final borderImage = <String>[
      if (small)
        ImagesAssetsUi.attributeBorderSmall.path
      else
        ImagesAssetsUi.attributeBorder.path,
    ];

    final elementalPowerBorder = attributeType?.elementalRequirement ?? [];

    void addDamageTypeImage(DamageType type) {
      switch (type) {
        case DamageType.energy:
          borderImage.add(
            ImagesAssetsUi.attributeBorderEnergy.path,
          );
          break;
        case DamageType.fire:
          borderImage.add(
            ImagesAssetsUi.attributeBorderFire.path,
          );
          break;
        case DamageType.frost:
          borderImage.add(
            ImagesAssetsUi.attributeBorderFrost.path,
          );
          break;
        case DamageType.psychic:
          borderImage.add(
            ImagesAssetsUi.attributeBorderPsychic.path,
          );
          break;
        case DamageType.magic:
          borderImage.add(
            ImagesAssetsUi.attributeBorderMagic.path,
          );
          break;
        case DamageType.physical:
          borderImage.add(
            ImagesAssetsUi.attributeBorderPhysical.path,
          );
          break;
        default:
      }
    }

    if (damageType != null) {
      borderImage.clear();
      addDamageTypeImage(damageType!);
    } else if (elementalPowerBorder.isNotEmpty) {
      borderImage.clear();
      for (final element in elementalPowerBorder) {
        addDamageTypeImage(element);
      }
    }
    final cardSize = small ? smallCardSize : largeCardSize;

    final borderMidImage = small
        ? ImagesAssetsUi.attributeBorderMidSmall.path
        : ImagesAssetsUi.attributeBorderMid.path;
    final borderBaseImage = small
        ? ImagesAssetsUi.attributeBorderBaseSmall.path
        : ImagesAssetsUi.attributeBorderBase.path;
    final Widget background = Positioned.fill(
      child: Image.asset(
        backgroundImage,
        fit: BoxFit.fitWidth,
        color: backgroundColor,
        filterQuality: FilterQuality.none,
      ),
    );

    final count = borderImage.length;
    final Widget border = Positioned.fill(
      child: LayoutBuilder(
        builder: (context, straints) {
          return Stack(
            children: [
              for (int i = 0; i < count; i++)
                Positioned.fill(
                  child: ClipRect(
                    clipper: CustomRectClipper(i / count, (i + 1) / count),
                    child: buildImageAsset(
                      borderImage[i],
                      fit: BoxFit.fitWidth,
                      color: elementalPowerBorder.isEmpty && damageType == null
                          ? borderColorTop
                          : null,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    final Widget borderMid = Positioned.fill(
      child: buildImageAsset(
        borderMidImage,
        color: borderColorMid,
        fit: BoxFit.fitWidth,
      ),
    );
    final Widget borderBase = Positioned.fill(
      child: buildImageAsset(
        borderBaseImage,
        color: borderColorBase,
        fit: BoxFit.fitWidth,
      ),
    );

    return SizedBox(
      // width: cardSize.width,
      // height: cardSize.height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (!hideBackground) background,
          if (!hideBaseBorder) borderBase,
          borderMid,
          border,
          if (child != null) Positioned.fill(child: child!),
        ],
      ),
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

    final color = colorPalette.secondaryColor;

    final Widget title = Positioned.fill(
      bottom: null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          widget.title,
          textAlign: TextAlign.center,
          style: defaultStyle.copyWith(
            color: color,
            shadows: [colorPalette.buildShadow(ShadowStyle.light)],
          ),
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
          title,
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
    final tempChecker = (element.attributeType.territory ==
                AttributeTerritory.statusEffect &&
            isTemp) ||
        (element.attributeType.territory != AttributeTerritory.statusEffect &&
            !isTemp);

    final permanentChecker =
        element.attributeType.territory != AttributeTerritory.permanent;

    final passiveChecker =
        element.attributeType.territory != AttributeTerritory.passive;
    return tempChecker && permanentChecker && passiveChecker;
  }

  @override
  void initState() {
    super.initState();
    node.requestFocus();
    gameRouter = widget.gameRef;
    gameState = gameRouter.gameStateComponent.gameState;
    env = gameState.currentEnviroment! as GameEnviroment;
    InputManager().addCommonlyUsedBackButtonListener(onBackEvent);
  }

  @override
  void dispose() {
    InputManager().removeCommonlyUsedBackButtonListener(onBackEvent);
    super.dispose();
  }

  void onBackEvent() {
    gameState.resumeGame();
  }

  final Size cardSize = const Size(128, 96);
  bool testHoverTest = false;
  bool optionsEnabled = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final entries = env.player?.currentAttributes;

    final nonTempEntries = entries
            ?.where((element) => fetchAttributeLogicChecker(element, false))
            .toList() ??
        [];

    nonTempEntries.sort(
      (a, b) =>
          a.attributeType.rarity.index.compareTo(b.attributeType.rarity.index),
    );

    nonTempEntries.sort((b, a) => a.upgradeLevel.compareTo(b.upgradeLevel));

    final bottomPaddingAmount = 200.0 * ((size.height - 300) / 900).clamp(0, 1);
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
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: OverlayWidgetDisplay(
                                    gameRouter,
                                    child: StatsDisplay(
                                      gameRef: gameRouter,
                                      statStrings:
                                          env.player?.buildStatStrings(false),
                                    ),
                                  ),
                                ),
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
                                    'Resume',
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
                                  CustomButton(
                                    'Options',
                                    gameRef: widget.gameRef,
                                    rowId: 3,
                                    onPrimary: () {
                                      setState(
                                        () {
                                          optionsEnabled = true;
                                        },
                                      );
                                    },
                                  ),
                                  CustomButton(
                                    'Give up',
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
                                          sourceAttack: this,
                                        ),
                                        EndGameState.quit,
                                      );
                                    },
                                  ),
                                ],
                                'Pause Menu',
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 700),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: OverlayWidgetDisplay(
                                    gameRouter,
                                    child: AttributeDisplay(
                                      gameRef: gameRouter,
                                      attributes: nonTempEntries,
                                    ),
                                  ),
                                ),
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
                ),
              ],
            ),
    ).animate().fadeIn();
  }
}
