import 'dart:io';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/assets/sprite_animations.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/menus/custom_button.dart';

import 'package:runefire/menus/menus.dart';

class StartMenu extends StatefulWidget {
  const StartMenu({
    required this.gameRef,
    super.key,
  });
  final GameRouter gameRef;

  @override
  State<StartMenu> createState() => _StartMenuState();
}

class _StartMenuState extends State<StartMenu> {
  late CustomButton startButtonComponent;
  late CustomButton exitButtonComponent;
  late CustomButton optionsButtonComponent;
  late CustomButton demoScreenButtonComponent;

  @override
  void initState() {
    super.initState();
    startButtonComponent = CustomButton(
      'Start Game',
      gameRef: widget.gameRef,
      onPrimary: () {
        widget.gameRef.gameStateComponent.gameState
            .changeMainMenuPage(MenuPageType.weaponMenu);
      },
    );
    optionsButtonComponent = CustomButton(
      'Options',
      gameRef: widget.gameRef,
      rowId: 1,
      onPrimary: () {
        widget.gameRef.gameStateComponent.gameState
            .changeMainMenuPage(MenuPageType.options);
      },
    );
    demoScreenButtonComponent = CustomButton(
      'Wireframe Demo Screen',
      gameRef: widget.gameRef,
      rowId: 2,
      onPrimary: () {
        widget.gameRef.gameStateComponent.gameState
            .changeMainMenuPage(MenuPageType.demoScreen);
      },
    );
    exitButtonComponent = CustomButton(
      'Exit',
      gameRef: widget.gameRef,
      rowId: 3,
      onPrimary: () {
        exit(0);
      },
    );
  }

  SpriteAnimationTicker? titleTicker;
  bool isCompleted = false;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final titleSize = screenSize.shortestSide * .8;
    return Stack(
      children: [
        Center(
          child: SizedBox.square(
            dimension: titleSize,
            child: FutureBuilder<SpriteAnimation>(
              future: loadSpriteAnimation(
                35,
                'ui/title/${DamageType.values.random().name}_title_sprite_sheet_35.png',
                titleIntroTickRate,
                false,
              ),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data is! SpriteAnimation || isCompleted) {
                  return const SizedBox();
                }
                return SpriteAnimationWidget(
                  onComplete: () {
                    setState(() {
                      isCompleted = true;
                    });
                  },
                  animation: snapshot.data as SpriteAnimation,
                  animationTicker: titleTicker ??= SpriteAnimationTicker(
                    snapshot.data as SpriteAnimation,
                  ),
                );
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                startButtonComponent,
                demoScreenButtonComponent,
                optionsButtonComponent,
                exitButtonComponent,
              ]
                  .animate(
                    interval: AnimateList.defaultInterval,
                  )
                  .fadeIn(),
            ),
          ),
        ),
      ],
    );
  }
}
