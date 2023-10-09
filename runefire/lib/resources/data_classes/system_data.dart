import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:runefire/game/hud.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/main.dart';

import '../../game/enviroment.dart';
import '../enums.dart';
import 'base.dart';
import 'package:hive/hive.dart';

part 'system_data.g.dart';

class SystemDataComponent extends DataComponent {
  SystemDataComponent(super.dataObject);

  @override
  SystemData get dataObject => super.dataObject as SystemData;
}

@HiveType(typeId: 0)
class SystemData extends DataClass {
  SystemData({this.musicVolume = 0, this.sfxVolume = 0});

  @HiveField(0)
  double musicVolume;

  @HiveField(1)
  double sfxVolume;

  @HiveField(10)
  bool showFPS = false;

  @HiveField(11)
  bool showTimer = false;

  @HiveField(12)
  bool showStaminaHealthText = false;

  @HiveField(20)
  HudScale hudScale = HudScale.medium;

  @HiveField(100)
  Map<PhysicalKeyboardKey, GameAction> keyboardMappings = {
    PhysicalKeyboardKey.keyW: GameAction.moveUp,
    PhysicalKeyboardKey.keyA: GameAction.moveLeft,
    PhysicalKeyboardKey.keyS: GameAction.moveDown,
    PhysicalKeyboardKey.keyD: GameAction.moveRight,
    PhysicalKeyboardKey.keyR: GameAction.reload,
    PhysicalKeyboardKey.keyE: GameAction.interact,
    PhysicalKeyboardKey.keyQ: GameAction.useExpendable,
    PhysicalKeyboardKey.space: GameAction.jump,
    PhysicalKeyboardKey.tab: GameAction.swapWeapon,
    PhysicalKeyboardKey.shiftLeft: GameAction.dash,
    PhysicalKeyboardKey.keyP: GameAction.pause,
    PhysicalKeyboardKey.escape: GameAction.pause,
    // PhysicalKeyboardKey.keyW: GameAction.moveUp,
    // PhysicalKeyboardKey.keyW: GameAction.moveUp,
  };
  @HiveField(105)
  Map<int, GameAction> mouseButtonMappings = {
    1: GameAction.primary,
    2: GameAction.secondary,
  };

  @HiveField(110)
  Map<String, GameAction> gamePadMappings = {};

  set setMusicVolume(double value) {
    musicVolume = value;
    parentComponent?.notifyListeners();
    save();
  }

  set setSFXVolume(double value) {
    sfxVolume = value;
    parentComponent?.notifyListeners();
    save();
  }
}

enum MouseButtons { primary, scrollClick, secondary, misc }

extension MouseButtonsExtension on MouseButtons {
  bool isKnown(int listenerButtonId) {
    if (listenerButtonId == 1 && this == MouseButtons.primary) {
      return true;
    } else if (listenerButtonId == 4 && this == MouseButtons.scrollClick) {
      return true;
    } else if (listenerButtonId == 2 && this == MouseButtons.secondary) {
      return true;
    } else {
      return false;
    }
  }
}
