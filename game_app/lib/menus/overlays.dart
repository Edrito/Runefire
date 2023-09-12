import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/game/enviroment.dart';
import 'package:game_app/menus/buttons.dart';
import 'package:game_app/menus/custom_widgets.dart';
import 'package:game_app/menus/menus.dart';
import 'package:game_app/menus/pause_menu.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/game_state_class.dart';
import 'package:game_app/resources/visuals.dart';
import 'package:recase/recase.dart';

import '../attributes/attributes_structure.dart';
import '../main.dart';
import '../resources/functions/functions.dart';
import 'cards.dart';
import 'components_notifier_builder.dart';

MapEntry<String, Widget Function(BuildContext, GameRouter)> pauseMenu =
    MapEntry('PauseMenu', (context, gameRouter) {
  return PauseMenu(gameRouter);
});

MapEntry<String, Widget Function(BuildContext, GameRouter)> deathScreen =
    MapEntry('DeathScreen', (context, gameRouter) {
  final size = MediaQuery.of(context).size;
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
            child: Container(
              width: size.width / 3,
              height: size.height / 4,
              decoration: BoxDecoration(
                  color: ApolloColorPalette.deepBlue.color.darken(.1),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "You Died :'(",
                      style: defaultStyle,
                    ),
                  ),
                  DisplayButtons(
                    buttons: List<CustomButton>.from([
                      CustomButton(
                        "Try again",
                        gameRef: gameRouter,
                        onTap: () {
                          gameRouter.gameStateComponent.gameState.endGame(true);
                        },
                      ),
                      CustomButton(
                        "Give up",
                        gameRef: gameRouter,
                        onTap: () {
                          gameRouter.gameStateComponent.gameState.endGame();
                        },
                      )
                    ]),
                  ),
                ],
              ),
            ),
          );
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

List<Attribute>? currentSelection;
AnimationController? widgetController;

MapEntry<String, Widget Function(BuildContext, GameRouter)> attributeSelection =
    MapEntry('AttributeSelection', (context, gameRouter) {
  FocusNode node = FocusNode();
  bool ignoring = false;
  node.requestFocus();
  late Function setState;
  final size = MediaQuery.of(context).size;
  final player =
      (gameRouter.router.currentRoute.children.whereType<GameEnviroment>())
          .first
          .player;
  const double loadInDuration = .2;
  currentSelection ??= player?.buildAttributeSelection(player);

  List<CustomCard> selection = [];
  late CustomCard xpCard;
  const exitAnimationDuration = .2;

  for (var element in currentSelection ?? List<Attribute>.from([])) {
    CustomCard card = element.buildWidget(onTap: (damageType) {
      setState(() {
        ignoring = true;
        player?.addAttribute(element.attributeType, damageType: damageType);
      });
    }, onTapComplete: () {
      gameRouter.resumeEngine();

      Future.delayed(exitAnimationDuration.seconds).then((value) => {
            gameRouter.gameStateComponent.gameState.resumeGame(),
            currentSelection = null
          });
      widgetController?.forward(from: 0);
    });
    selection.add(card);
  }
  final xpAttribute = player!.buildXpAttribute();

  xpCard = xpAttribute.buildWidget(
      onTap: (damageType) {
        setState(() {
          player.addAttribute(xpAttribute.attributeType,
              damageType: damageType);
          ignoring = true;
        });
      },
      onTapComplete: () {
        gameRouter.resumeEngine();

        Future.delayed(exitAnimationDuration.seconds).then((value) => {
              gameRouter.gameStateComponent.gameState.resumeGame(),
              currentSelection = null
            });
        widgetController?.forward(from: 0);
      },
      small: true);

  return Animate(
    effects: [
      FadeEffect(
          duration: exitAnimationDuration.seconds,
          begin: 1,
          end: 0,
          curve: Curves.easeInOut),
    ],
    autoPlay: false,
    onInit: (con) => widgetController = con,
    child: Material(
      color: Colors.transparent,
      child: KeyboardListener(
        focusNode: node,
        onKeyEvent: (value) {
          if (value is! KeyDownEvent) return;
        },
        child: Center(
          child: StatefulBuilder(builder: (context, setstate) {
            setState = setstate;
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                    right: 0,
                    left: 0,
                    height: size.height * .6,
                    child: const StarBackstripe(
                      percentOfHeight: .6,
                    )),
                Positioned.fill(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text(
                            "Choose an attribute",
                            style: defaultStyle.copyWith(
                                fontSize: 60,
                                color: ApolloColorPalette.offWhite.color),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        ignoring: ignoring,
                        child: DisplayCards(
                          cards: selection,
                          ending: ignoring,
                          loadInDuration: loadInDuration,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      xpCard,
                      const Spacer()
                    ]
                        .animate(interval: (loadInDuration / 3).seconds)
                        .fadeIn(
                          duration: loadInDuration.seconds,
                          curve: Curves.decelerate,
                        )
                        .moveY(
                            duration: loadInDuration.seconds,
                            curve: Curves.decelerate,
                            begin: 50,
                            end: 0),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    ),
  );
});

class DamageTypeSelector extends StatefulWidget {
  const DamageTypeSelector(this.damageTypes, this.selectDamageType,
      {super.key});
  final Set<DamageType> damageTypes;
  final Function(DamageType) selectDamageType;
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
            child: InkWell(
              onHover: (value) {
                setState(() {
                  hoveredDamageTypes[damageType] = value;
                });
              },
              onTap: () {
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
