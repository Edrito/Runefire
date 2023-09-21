import 'dart:math';
import 'package:flutter/material.dart';
import 'package:runefire/main.dart';
import 'package:runefire/menus/start_menu.dart';
import 'package:runefire/menus/customization_menu.dart';

import 'level_menu.dart';
import 'options.dart';

enum MenuPageType { startMenuPage, options, weaponMenu, levelMenu }

extension MainMenuPagesExtension on MenuPageType {
  Widget buildPage(GameRouter gameRef) {
    Random rng = Random();

    switch (this) {
      case MenuPageType.options:
        return OptionsMenu(
          gameRef: gameRef,
          key: Key(rng.nextDouble().toString()),
        );
      case MenuPageType.startMenuPage:
        return StartMenu(
          key: Key(rng.nextDouble().toString()),
          gameRef: gameRef,
        );
      case MenuPageType.weaponMenu:
        return WeaponMenu(
          key: Key(rng.nextDouble().toString()),
          gameRef: gameRef,
        );
      case MenuPageType.levelMenu:
        return LevelMenu(
          key: Key(rng.nextDouble().toString()),
          gameRef: gameRef,
        );
      default:
        return StartMenu(
          key: Key(rng.nextDouble().toString()),
          gameRef: gameRef,
        );
    }
  }
}
