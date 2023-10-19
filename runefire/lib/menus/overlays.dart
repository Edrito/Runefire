import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:numerus/numerus.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/menus/custom_button.dart';
import 'package:runefire/menus/custom_widgets.dart';
import 'package:runefire/menus/game_win_screen.dart';
import 'package:runefire/menus/level_up_screen.dart';
import 'package:runefire/menus/menus.dart';
import 'package:runefire/menus/pause_menu.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/resources/data_classes/system_data.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:recase/recase.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import '../attributes/attributes_structure.dart';
import '../main.dart';
import '../resources/functions/functions.dart';
import 'attribute_card.dart';
import 'components_notifier_builder.dart';

class DisplayTextWidget extends StatefulWidget {
  const DisplayTextWidget({super.key});

  @override
  State<DisplayTextWidget> createState() => _DisplayTextWidgetState();
}

class _DisplayTextWidgetState extends State<DisplayTextWidget> {
  late final OverlayMessage message = GameState().textToDisplay!;
  late final double duration = message.duration;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned.fill(
            top: 200,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                GameState().textToDisplay!.text,
                style: defaultStyle,
                textAlign: TextAlign.center,
              ),
            ))
      ],
    )
        .animate()
        .fadeIn(duration: .3.seconds)
        .moveY(duration: .3.seconds)
        .animate(delay: (duration - .3).seconds)
        .fadeOut(duration: .3.seconds)
        .moveY(duration: .3.seconds);
  }
}

MapEntry<String, Widget Function(BuildContext, GameRouter)> textDisplay =
    MapEntry('TextDisplay', (context, gameRouter) {
  return const DisplayTextWidget();
});

MapEntry<String, Widget Function(BuildContext, GameRouter)>
    gamepadCursorDisplay =
    MapEntry('GamepadCursorDisplay', (context, gameRouter) {
  return GamepadCursorDisplay(gameRouter);
});
MapEntry<String, Widget Function(BuildContext, GameRouter)> gameWinDisplay =
    MapEntry('GameWinDisplay', (context, gameRouter) {
  return GameWinDisplay(gameRouter);
});

class GamepadCursorDisplay extends StatefulWidget {
  const GamepadCursorDisplay(this.gameRef, {super.key});
  final GameRouter gameRef;
  @override
  State<GamepadCursorDisplay> createState() => _GamepadCursorDisplayState();
}

class _GamepadCursorDisplayState extends State<GamepadCursorDisplay> {
  void onGamepadCursorChange(ExternalInputType type, Offset position) {
    checkOverlayPosition();
    setState(() {
      this.position = type != ExternalInputType.gamepad ? null : (position);
    });
  }

  Offset? position;

  @override
  void initState() {
    InputManager().onPointerMoveList.add(onGamepadCursorChange);
    super.initState();
  }

  @override
  void dispose() {
    InputManager().onPointerMoveList.remove(onGamepadCursorChange);

    super.dispose();
  }

  void checkOverlayPosition() {
    final overlaysList = widget.gameRef.overlays.activeOverlays;
    if (overlaysList.indexOf(gamepadCursorDisplay.key) !=
        overlaysList.length - 1) {
      widget.gameRef.overlays.remove(gamepadCursorDisplay.key);
      widget.gameRef.overlays.add(gamepadCursorDisplay.key);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double radius = 10;
    if (GameState().gameIsPlaying || position == null) {
      return const SizedBox();
    }

    return Transform(
        transform: Matrix4.translationValues(
            position!.dx - (radius / 2), position!.dy - (radius / 2), 0.0),
        child: const CircleAvatar(
          radius: radius,
        ));
  }
}

MapEntry<String, Widget Function(BuildContext, GameRouter)> pauseMenu =
    MapEntry('PauseMenu', (context, gameRouter) {
  return PauseMenu(gameRouter);
});

MapEntry<String, Widget Function(BuildContext, GameRouter)> deathScreen =
    MapEntry('DeathScreen', (context, gameRouter) {
  FocusNode node = FocusNode();

  node.requestFocus();

  return Material(
    color: Colors.transparent,
    child: KeyboardListener(
      focusNode: node,
      onKeyEvent: (value) {
        if (value is! KeyDownEvent) return;
      },
      child: Center(
        child: StatefulBuilder(builder: (context, setState) {
          return ConstrainedBox(
              constraints: const BoxConstraints(
                  maxWidth: 400, minHeight: 200, maxHeight: 500, minWidth: 250),
              child: OverlayWidgetList(
                  gameRouter,
                  [
                    CustomButton(
                      "Try again",
                      gameRef: gameRouter,
                      onPrimary: () {
                        gameRouter.gameStateComponent.gameState
                            .endGame(GameEndState.death, true);
                      },
                    ),
                    CustomButton(
                      "Give up",
                      gameRef: gameRouter,
                      onPrimary: () {
                        gameRouter.gameStateComponent.gameState
                            .endGame(GameEndState.death);
                      },
                    )
                  ],
                  "You Died :'("));
        }),
      ),
    ),
  );
});

MapEntry<String, Widget Function(BuildContext, GameRouter)> mainMenu =
    MapEntry('MainMenu', (context, gameRouter) {
  return ComponentsNotifierBuilder<GameStateComponent>(
      notifier: gameRouter.componentsNotifier<GameStateComponent>(),
      builder: (context, notifier) =>
          notifier.single?.gameState.currentMenuPage.buildPage(gameRouter) ??
          const SizedBox());
});

MapEntry<String, Widget Function(BuildContext, GameRouter)> caveFront =
    MapEntry('CaveFront', (context, gameRouter) {
  final gameState = gameRouter.gameStateComponent.gameState;
  return Stack(
    children: [
      Positioned.fill(
        child: buildImageAsset(
          'assets/images/background/caveFront.png',
        ),
      ),
      Positioned.fill(
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return RadialGradient(
              radius: 1.2,
              colors: [
                gameState.portalColor(true).withOpacity(.2),
                Colors.transparent,
              ],
              stops: const [.3, 1],
            ).createShader(bounds);
          },
          child: buildImageAsset(
            'assets/images/background/caveFrontEffectMask.png',
          ),
        ),
      ),
      // Positioned.fill(
      //   child: buildImageAsset(
      //     'assets/images/background/caveFrontEffectMask.png',
      //   ),
      // ),
    ],
  );
});

MapEntry<String, Widget Function(BuildContext, GameRouter)> attributeSelection =
    MapEntry('AttributeSelection', (context, gameRouter) {
  return AttributeSelection(gameRouter);
});

class DamageTypeSelector extends StatefulWidget {
  const DamageTypeSelector(this.damageTypes, this.selectDamageType,
      {this.scrollController, super.key});
  final Set<DamageType> damageTypes;
  final Function(DamageType) selectDamageType;
  final ScrollController? scrollController;
  @override
  State<DamageTypeSelector> createState() => _DamageTypeSelectorState();
}

class _DamageTypeSelectorState extends State<DamageTypeSelector> {
  Map<DamageType, bool> hoveredDamageTypes = {};

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var damageType in widget.damageTypes)
          Expanded(
            child: CustomInputWatcher(
              zHeight: 1,
              scrollController: widget.scrollController,
              onHover: (value) {
                setState(() {
                  hoveredDamageTypes[damageType] = value;
                });
              },
              rowId: 2,
              onPrimary: () {
                widget.selectDamageType(damageType);
              },
              child: Container(
                color: hoveredDamageTypes[damageType] ?? false
                    ? damageType.color.darken(.7)
                    : damageType.color.darken(.3),
                child: Center(
                    child: Text(
                  damageType.name.titleCase,
                  style: defaultStyle.copyWith(
                      fontSize: 18,
                      color: hoveredDamageTypes[damageType] ?? false
                          ? damageType.color.brighten(1)
                          : damageType.color.brighten(.7)),
                )),
              ),
            ),
          )
      ],
    );
  }
}

class StatsDisplay extends StatefulWidget {
  const StatsDisplay(
      {required this.gameRef, required this.statStrings, super.key});
  final GameRouter gameRef;
  final List<(String, String)>? statStrings;

  @override
  State<StatsDisplay> createState() => _StatsDisplayState();
}

class _StatsDisplayState extends State<StatsDisplay> {
  @override
  Widget build(BuildContext context) {
    Widget title = Text(
      "Current Stats",
      textAlign: TextAlign.center,
      style: defaultStyle.copyWith(
          color: colorPalette.secondaryColor,
          shadows: [colorPalette.buildShadow(ShadowStyle.light)]),
    ).animate().fadeIn();

    return Column(
      children: [
        title,
        Expanded(
          child: ScrollConfiguration(
            behavior: scrollConfiguration(context),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < (widget.statStrings?.length ?? 0); i++)
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AttributeDisplay extends StatefulWidget {
  const AttributeDisplay(
      {required this.gameRef, required this.attributes, super.key});
  final GameRouter gameRef;
  final List<Attribute> attributes;
  @override
  State<AttributeDisplay> createState() => _AttributeDisplayState();
}

class _AttributeDisplayState extends State<AttributeDisplay> {
  @override
  Widget build(BuildContext context) {
    Color color = colorPalette.secondaryColor;

    Widget title = Text(
      "Unlocked Attributes",
      textAlign: TextAlign.center,
      style: defaultStyle.copyWith(
          color: color, shadows: [colorPalette.buildShadow(ShadowStyle.light)]),
    ).animate().fadeIn();

    return Column(
      children: [
        title,
        Expanded(
          child: ScrollConfiguration(
            behavior: scrollConfiguration(context),
            child: SingleChildScrollView(
              child: Wrap(
                children: [
                  for (int i = 0; i < (widget.attributes.length); i++)
                    Builder(
                      builder: (context) {
                        final currentAttrib = widget.attributes.elementAt(i);

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
                                    'assets/images/${currentAttrib.icon}',
                                    color: currentAttrib
                                        .attributeType.rarity.color),
                                SizedBox(
                                  width: 55,
                                  child: Text(
                                    currentAttrib.upgradeLevel
                                            .toRomanNumeralString() ??
                                        "",
                                    style: defaultStyle.copyWith(
                                        color: currentAttrib
                                            .attributeType.rarity.color,
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
      ],
    );
  }
}
