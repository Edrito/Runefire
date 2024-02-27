import 'dart:math';
import 'package:flutter/material.dart';
import 'package:runefire/main.dart';
import 'package:runefire/menus/achievements_menu.dart';
import 'package:runefire/menus/demo_screen.dart';
import 'package:runefire/menus/start_menu.dart';
import 'package:runefire/menus/weapon_select_menu.dart';

import 'package:runefire/menus/level_select_menu.dart';
import 'package:runefire/menus/options.dart';

enum MenuPageType {
  startMenuPage,
  options,
  weaponMenu,
  demoScreen,
  achievementsMenu,
  levelMenu
}

extension MainMenuPagesExtension on MenuPageType {
  Widget buildPage(GameRouter gameRef) {
    final rng = Random();

    switch (this) {
      case MenuPageType.options:
        return OptionsMenu(
          gameRef: gameRef,
          // key: Key(rng.nextDouble().toString()),
        );
      case MenuPageType.startMenuPage:
        return StartMenu(
          // key: Key(rng.nextDouble().toString()),
          gameRef: gameRef,
        );
      case MenuPageType.demoScreen:
        return DemoScreen(gameRef: gameRef);
      case MenuPageType.achievementsMenu:
        return AchievementsMenu(
          // key: Key(rng.nextDouble().toString()),
          gameRef: gameRef,
        );
      case MenuPageType.weaponMenu:
        return WeaponMenu(
          // key: Key(rng.nextDouble().toString()),
          gameRef: gameRef,
        );
      case MenuPageType.levelMenu:
        return LevelMenu(
          // key: Key(rng.nextDouble().toString()),
          gameRef: gameRef,
        );
      default:
        return StartMenu(
          // key: Key(rng.nextDouble().toString()),
          gameRef: gameRef,
        );
    }
  }
}
