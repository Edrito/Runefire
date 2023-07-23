import 'dart:io';
import 'package:flutter/material.dart';
import 'package:game_app/main.dart';
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
        changeMainMenuPage(MenuPages.weaponMenu);
      },
    );
    optionsButtonComponent =
        CustomButton("Options", gameRef: widget.gameRef, onTap: () {
      changeMainMenuPage(MenuPages.options);
    });
    exitButtonComponent =
        CustomButton("Exit", gameRef: widget.gameRef, onTap: () {
      exit(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
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
    );
  }
}
