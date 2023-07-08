import 'dart:io';
import 'dart:math';
import 'dart:async' as async;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_app/main.dart';
import 'package:game_app/overlays/weapon_menu.dart';
import '../resources/data_classes/system_data.dart';
import 'buttons.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    return DisplayButtons(
      buttons: [
        startButtonComponent,
        optionsButtonComponent,
        exitButtonComponent
      ],
    );
  }
}
