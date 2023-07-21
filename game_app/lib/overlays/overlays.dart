import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/game/enviroment.dart';
import 'package:game_app/overlays/buttons.dart';
import 'package:game_app/overlays/menus.dart';
import 'package:game_app/attributes/attributes.dart';
import 'package:game_app/overlays/pause_menu.dart';
import 'package:game_app/resources/visuals.dart';

import '../main.dart';
import 'cards.dart';

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
                  color: backgroundColor1.darken(.1),
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
                          endGame(true);
                        },
                      ),
                      CustomButton(
                        "Give up",
                        gameRef: gameRouter,
                        onTap: () {
                          endGame();
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
  return Center(
    child: StatefulBuilder(builder: (context, setState) {
      setStateMainMenu = setState;
      return menuPage.buildPage(gameRouter);
    }),
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
  currentSelection ??= player?.buildAttributeSelection();

  List<CustomCard> selection = [];
  late CustomCard xpCard;
  const exitAnimationDuration = .2;

  for (var element in currentSelection ?? List<Attribute>.from([])) {
    CustomCard card = element.buildWidget(onTap: () {
      setState(() {
        ignoring = true;
      });
    }, onTapComplete: () {
      gameRouter.resumeEngine();
      player?.addAttribute(element);
      Future.delayed(exitAnimationDuration.seconds)
          .then((value) => {resumeGame(), currentSelection = null});
      widgetController?.forward(from: 0);
    });
    selection.add(card);
  }
  final xpAttribute = player!.buildXpAttribute();

  xpCard = xpAttribute.buildWidget(
      onTap: () {
        setState(() {
          ignoring = true;
        });
      },
      onTapComplete: () {
        gameRouter.resumeEngine();
        player.addAttribute(xpAttribute);
        Future.delayed(exitAnimationDuration.seconds)
            .then((value) => {resumeGame(), currentSelection = null});
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
            return ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: size.width * .95,
                  minHeight: 200,
                  maxHeight: size.height * .9,
                  minWidth: 250),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "Choose an attribute",
                      style: defaultStyle,
                    ),
                  ),
                  Expanded(
                      child: IgnorePointer(
                    ignoring: ignoring,
                    child: DisplayCards(
                      cards: selection,
                      ending: ignoring,
                      loadInDuration: loadInDuration,
                    ),
                  )),
                  const SizedBox(
                    height: 10,
                  ),
                  xpCard
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
            );
          }),
        ),
      ),
    ),
  );
});
