import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/game/enviroment.dart';
import 'package:game_app/pages/buttons.dart';
import 'package:game_app/pages/menu.dart';
import 'package:game_app/resources/visuals.dart';
import '/resources/routes.dart' as routes;

import '../main.dart';

MapEntry<String, Widget Function(BuildContext, GameRouter)> pauseMenu =
    MapEntry('PauseMenu', (context, gameRouter) {
  final size = MediaQuery.of(context).size;
  FocusNode node = FocusNode();
  node.requestFocus();

  return Material(
    color: Colors.transparent,
    child: KeyboardListener(
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
          return ConstrainedBox(
            constraints: const BoxConstraints(
                maxWidth: 400, minHeight: 200, maxHeight: 500, minWidth: 250),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Taking a break little bro?",
                    style: defaultStyle,
                  ),
                ).animate().fadeIn(),
                const SizedBox(
                  height: 50,
                ),
                Container(
                  width: size.width / 3,
                  height: size.height / 4,
                  decoration: BoxDecoration(
                      color: backgroundColor.darken(.1),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: DisplayButtons(
                    buttons: List<CustomButton>.from([
                      CustomButton(
                        "Resume",
                        gameRef: gameRouter,
                        onTap: () {
                          resumeGame();
                        },
                      ),
                      CustomButton(
                        "Give up",
                        gameRef: gameRouter,
                        onTap: () {
                          resumeGame();
                          final gameEnv = currentGameEnviroment;
                          if (gameEnv != null) {
                            currentGameEnviroment?.player.killPlayer(false);
                          } else {
                            changeMainMenuPage(MenuPages.startMenuPage, false);
                          }
                        },
                      )
                    ]),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    ),
  );
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
                  color: backgroundColor.darken(.1),
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
                          toggleGameStart(routes.gameplay);
                          resumeGame();
                        },
                      ),
                      CustomButton(
                        "Give up",
                        gameRef: gameRouter,
                        onTap: () {
                          changeMainMenuPage(MenuPages.startMenuPage, false);
                          resumeGame();
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

MapEntry<String, Widget Function(BuildContext, GameRouter)> attributeSelection =
    MapEntry('AttributeSelection', (context, gameRouter) {
  late AnimationController widgetController;
  FocusNode node = FocusNode();
  bool ignoring = false;
  node.requestFocus();
  late Function setState;
  final size = MediaQuery.of(context).size;
  final player =
      (gameRouter.router.currentRoute.children.whereType<GameEnviroment>())
          .first
          .player;
  var list = player.buildAttributeSelection();

  List<CustomCard> selection = [];

  for (var element in list) {
    CustomCard card = element.buildWidget(onTap: () {
      setState(() {
        ignoring = true;
      });
    }, onTapComplete: () {
      gameRouter.resumeEngine();
      player.addAttribute(element);
      widgetController.forward(from: 0).then((value) => resumeGame());
    });
    selection.add(card);
  }

  return Animate(
    effects: [
      FadeEffect(
          duration: .2.seconds, begin: 1, end: 0, curve: Curves.easeInOut),
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
                  maxWidth: size.width * .9,
                  minHeight: 200,
                  maxHeight: size.height * .8,
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
                              cards: selection, ending: ignoring))),
                ],
              ),
            );
          }),
        ),
      ),
    ),
  );
});
