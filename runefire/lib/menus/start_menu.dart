import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
import 'buttons.dart';

import 'menus.dart';

class StartMenu extends StatefulWidget {
  const StartMenu({
    super.key,
    required this.gameRef,
  });
  final GameRouter gameRef;

  @override
  State<StartMenu> createState() => _StartMenuState();
}

class _StartMenuState extends State<StartMenu> {
  late CustomButton startButtonComponent;
  late CustomButton exitButtonComponent;
  late CustomButton optionsButtonComponent;

  @override
  void initState() {
    super.initState();
    startButtonComponent = CustomButton(
      "Start Game",
      gameRef: widget.gameRef,
      onTap: () {
        widget.gameRef.gameStateComponent.gameState
            .changeMainMenuPage(MenuPageType.weaponMenu);
      },
    );
    optionsButtonComponent =
        CustomButton("Options", gameRef: widget.gameRef, onTap: () {
      widget.gameRef.gameStateComponent.gameState
          .changeMainMenuPage(MenuPageType.options);
    });
    exitButtonComponent =
        CustomButton("Exit", gameRef: widget.gameRef, onTap: () {
      exit(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text("RuneFire",
                            style: defaultStyle.copyWith(
                                fontSize: size.shortestSide / 7,
                                color: ApolloColorPalette.blue.color,
                                shadows: [])),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3),
                        child: Text("RuneFire",
                            style: defaultStyle.copyWith(
                                fontSize: size.shortestSide / 7,
                                color: ApolloColorPalette.lightBlue.color,
                                shadows: [])),
                      ),
                      Text("RuneFire",
                          style: defaultStyle.copyWith(
                              fontSize: size.shortestSide / 7,
                              color: ApolloColorPalette.lightCyan.color,
                              shadows: [])),
                    ],
                  ),
                ],
              ),
            )
                .animate(delay: .5.seconds)
                .moveY(duration: .75.seconds)
                .fadeIn(duration: .75.seconds),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: DisplayButtons(
              alignment: Alignment.centerLeft,
              buttons: [
                startButtonComponent,
                optionsButtonComponent,
                exitButtonComponent
              ],
            ),
          ),
        ),
      ],
    );
  }
}
