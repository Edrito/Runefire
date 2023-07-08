import 'dart:math';
import 'package:flutter/material.dart';
import 'package:game_app/main.dart';
import 'package:game_app/overlays/start_menu.dart';
import 'package:game_app/overlays/weapon_menu.dart';

import 'level_menu.dart';
import 'options.dart';

enum MenuPages { startMenuPage, options, weaponMenu, levelMenu }

extension MainMenuPagesExtension on MenuPages {
  Widget buildPage(GameRouter gameRef) {
    Random rng = Random();

    switch (this) {
      case MenuPages.options:
        return OptionsMenu(
          gameRef: gameRef,
          key: Key(rng.nextDouble().toString()),
        );
      case MenuPages.startMenuPage:
        return StartMenu(
          key: Key(rng.nextDouble().toString()),
          gameRef: gameRef,
        );
      case MenuPages.weaponMenu:
        return WeaponMenu(
          key: Key(rng.nextDouble().toString()),
          gameRef: gameRef,
        );
      case MenuPages.levelMenu:
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
