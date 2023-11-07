import 'dart:async';

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

import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/menus/attribute_card.dart';
import 'package:runefire/menus/components_notifier_builder.dart';

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
          ),
        ),
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

MapEntry<String, Widget Function(BuildContext, GameRouter)> gameWinDisplay =
    MapEntry('GameWinDisplay', (context, gameRouter) {
  return GameWinDisplay(gameRouter);
});

MapEntry<String, Widget Function(BuildContext, GameRouter)> pauseMenu =
    MapEntry('PauseMenu', (context, gameRouter) {
  return PauseMenu(gameRouter);
});

MapEntry<String, Widget Function(BuildContext, GameRouter)> deathScreen =
    MapEntry('DeathScreen', (context, gameRouter) {
  final node = FocusNode();

  node.requestFocus();

  return Material(
    color: Colors.transparent,
    child: KeyboardListener(
      focusNode: node,
      onKeyEvent: (value) {
        if (value is! KeyDownEvent) return;
      },
      child: Center(
        child: StatefulBuilder(
          builder: (context, setState) {
            return ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
                minHeight: 200,
                maxHeight: 500,
                minWidth: 250,
              ),
              child: OverlayWidgetList(
                gameRouter,
                [
                  CustomButton(
                    'Try again',
                    gameRef: gameRouter,
                    onPrimary: () {
                      gameRouter.gameStateComponent.gameState
                          .endGame(EndGameState.playerDeath, true);
                    },
                  ),
                  CustomButton(
                    'Give up',
                    gameRef: gameRouter,
                    onPrimary: () {
                      gameRouter.gameStateComponent.gameState
                          .endGame(EndGameState.playerDeath);
                    },
                  ),
                ],
                "You Died :'(",
              ),
            );
          },
        ),
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
        const SizedBox(),
  );
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
  const DamageTypeSelector(
    this.damageTypes,
    this.selectDamageType, {
    this.scrollController,
    super.key,
  });
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
        for (final damageType in widget.damageTypes)
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
                          : damageType.color.brighten(.7),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class StatsDisplay extends StatefulWidget {
  const StatsDisplay({
    required this.gameRef,
    required this.statStrings,
    super.key,
  });
  final GameRouter gameRef;
  final List<(String, String)>? statStrings;

  @override
  State<StatsDisplay> createState() => _StatsDisplayState();
}

class _StatsDisplayState extends State<StatsDisplay> {
  @override
  Widget build(BuildContext context) {
    final Widget title = Text(
      'Current Stats',
      textAlign: TextAlign.center,
      style: defaultStyle.copyWith(
        color: colorPalette.secondaryColor,
        shadows: [colorPalette.buildShadow(ShadowStyle.light)],
      ),
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
                    ),
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
  const AttributeDisplay({
    required this.gameRef,
    required this.attributes,
    super.key,
  });
  final GameRouter gameRef;
  final List<Attribute> attributes;
  @override
  State<AttributeDisplay> createState() => _AttributeDisplayState();
}

class _AttributeDisplayState extends State<AttributeDisplay> {
  Map<AttributeType, GlobalKey> builtKeys = {};

  @override
  void initState() {
    super.initState();
    widget.attributes.sort((b, a) => a.upgradeLevel.compareTo(b.upgradeLevel));
    widget.attributes.sort(
      (a, b) =>
          a.attributeType.rarity.index.compareTo(b.attributeType.rarity.index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = colorPalette.secondaryColor;

    final Widget title = Text(
      'Unlocked Attributes',
      textAlign: TextAlign.center,
      style: defaultStyle.copyWith(
        color: color,
        shadows: [colorPalette.buildShadow(ShadowStyle.light)],
      ),
    ).animate().fadeIn();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        var isHovered = false;
                        return StatefulBuilder(
                          builder: (context, ss) {
                            builtKeys[currentAttrib.attributeType] ??=
                                GlobalKey<CustomInputWatcherState>();
                            return CustomInputWatcher(
                              onHover: (isHover) => ss(() {
                                isHovered = isHover;
                              }),
                              hoverWidget: CustomCard(
                                currentAttrib,
                                gameRef: widget.gameRef,
                                key: builtKeys[currentAttrib.attributeType],
                                disableTouch: true,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 96,
                                  width: 60,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: buildImageAsset(
                                          'assets/images/${currentAttrib.icon}',
                                          fit: BoxFit.fitHeight,
                                          color: isHovered
                                              ? currentAttrib
                                                  .attributeType.rarity.color
                                              : null,
                                        ),
                                      ),
                                      Text(
                                        currentAttrib.upgradeLevel
                                                .toRomanNumeralString() ??
                                            '',
                                        style: defaultStyle.copyWith(
                                          color: currentAttrib
                                              .attributeType.rarity.color,
                                          fontSize: 32,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GamepadCursorDisplay extends StatefulWidget {
  const GamepadCursorDisplay(this.gameRef, {super.key});
  final GameRouter gameRef;
  @override
  State<GamepadCursorDisplay> createState() => _GamepadCursorDisplayState();
}

class _GamepadCursorDisplayState extends State<GamepadCursorDisplay> {
  late final StreamSubscription<CustomInputWatcherEvents>
      eventStreamSubscription;
  late final StreamSubscription<(Offset, Widget)?>
      widgetOverlayStreamSubscription;

  void _updateHoverWidgetSize() {
    final renderBoxRed =
        hoveredWidgetKey?.currentContext?.findRenderObject() as RenderBox?;
    final newSize = renderBoxRed?.size;

    sizeOfHoveredWidget = newSize;
  }

  void onGamepadCursorChange(ExternalInputType type, Offset position) {
    setState(() {
      this.position = position;
      latestEventWasKeyboard = false;
      _updateHoverWidgetSize();
    });
  }

  void onPrimary(_) {
    setState(() {
      targetClick = true;
    });
  }

  Offset? position;

  void gameWidgetEvents(CustomInputWatcherEvents event) {
    switch (event) {
      case CustomInputWatcherEvents.onPrimary:
        setState(() {
          targetClick = true;
        });
        break;
      case CustomInputWatcherEvents.onPrimaryUp:
        setState(() {
          targetClick = false;
        });
        break;
      default:
    }
  }

  void newHoveredWidget((Offset, Widget)? event) {
    hoveredWidgetKey = event?.$2.key as GlobalKey<CustomInputWatcherState>?;
    setState(() {
      hoveredWidget = event;
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateHoverWidgetSize();
      setState(() {});
    });
  }

  GlobalKey<CustomInputWatcherState>? hoveredWidgetKey;
  Size? sizeOfHoveredWidget;

  (Offset, Widget)? hoveredWidget;

  void onKeyEvent(_) {
    setState(() {
      latestEventWasKeyboard = true;
    });
  }

  bool latestEventWasKeyboard = false;
  @override
  void initState() {
    InputManager().onPointerMoveList.add(onGamepadCursorChange);
    InputManager().keyEventList.add(onKeyEvent);
    final controllerTuple =
        InputManager().customInputWatcherManager.addHoverOverlay(this);
    eventStreamSubscription =
        controllerTuple.$1.stream.listen(gameWidgetEvents);
    widgetOverlayStreamSubscription =
        controllerTuple.$2.stream.listen(newHoveredWidget);
    super.initState();
  }

  @override
  void dispose() {
    InputManager().onPointerMoveList.remove(onGamepadCursorChange);
    InputManager().customInputWatcherManager.removeHoverOverlay();
    InputManager().keyEventList.remove(onKeyEvent);
    eventStreamSubscription.cancel();
    widgetOverlayStreamSubscription.cancel();

    super.dispose();
  }

  static const double radius = 10;

  bool targetClick = false;
  late final Widget cachedCursor = Container(
    decoration: BoxDecoration(
      color: colorPalette.randomBrightColor,
      shape: BoxShape.circle,
    ),
    height: radius,
    width: radius,
  );
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Text(
              'Pre-Alpha Development Build',
              style: defaultStyle.copyWith(fontSize: 32),
            ),
          ),
          Positioned.fill(
            child: Stack(
              children: [
                if (position != null) ...[
                  Transform(
                    transform: Matrix4.translationValues(
                      position!.dx - (radius / 2),
                      position!.dy - (radius / 2),
                      0.0,
                    ),
                    child: cachedCursor,
                  ),
                  if (hoveredWidget != null)
                    Builder(
                      builder: (context) {
                        var xPositionOfHover = latestEventWasKeyboard
                            ? hoveredWidget!.$1.dx
                            : position?.dx ?? hoveredWidget!.$1.dx;

                        var yPositionOfHover = latestEventWasKeyboard
                            ? hoveredWidget!.$1.dy
                            : position?.dy ?? hoveredWidget!.$1.dy;
                        if (xPositionOfHover +
                                (sizeOfHoveredWidget?.width ?? 0) >
                            screenSize.width) {
                          xPositionOfHover = screenSize.width -
                              (sizeOfHoveredWidget?.width ?? 0);
                        }
                        if (yPositionOfHover +
                                (sizeOfHoveredWidget?.height ?? 0) >
                            screenSize.height) {
                          yPositionOfHover = screenSize.height -
                              (sizeOfHoveredWidget?.height ?? 0);
                        }

                        return Transform(
                          transform: Matrix4.translationValues(
                            xPositionOfHover,
                            yPositionOfHover,
                            0.0,
                          ),
                          child: hoveredWidget!.$2,
                        )
                            .animate(key: ValueKey(hoveredWidget?.$1))
                            .fadeIn(duration: .15.seconds);
                      },
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
