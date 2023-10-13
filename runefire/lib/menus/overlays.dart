import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/menus/custom_button.dart';
import 'package:runefire/menus/custom_widgets.dart';
import 'package:runefire/menus/level_up_screen.dart';
import 'package:runefire/menus/menus.dart';
import 'package:runefire/menus/pause_menu.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:recase/recase.dart';

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
              child: InGameMenu(
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
