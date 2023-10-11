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

  final Map<GameAction, Set<PhysicalKeyboardKey>> constantKeyboardMappings = {
    GameAction.pause: {PhysicalKeyboardKey.escape},
  };

  @HiveField(100)
  Map<GameAction, (PhysicalKeyboardKey?, PhysicalKeyboardKey?)>
      keyboardMappings = {
    GameAction.moveUp: (PhysicalKeyboardKey.keyW, null),
    GameAction.moveLeft: (PhysicalKeyboardKey.keyA, null),
    GameAction.moveDown: (PhysicalKeyboardKey.keyS, null),
    GameAction.moveRight: (PhysicalKeyboardKey.keyD, null),
    GameAction.reload: (PhysicalKeyboardKey.keyR, null),
    GameAction.interact: (PhysicalKeyboardKey.keyE, null),
    GameAction.useExpendable: (PhysicalKeyboardKey.keyQ, null),
    GameAction.jump: (PhysicalKeyboardKey.space, null),
    GameAction.swapWeapon: (PhysicalKeyboardKey.tab, null),
    GameAction.dash: (PhysicalKeyboardKey.shiftLeft, null),
    GameAction.pause: (PhysicalKeyboardKey.keyP, null),
  };

  @HiveField(105)
  Map<GameAction, (int?, int?)> mouseButtonMappings = {
    GameAction.primary: (1, null),
    GameAction.secondary: (2, null)
  };

  @HiveField(110)
  Map<GameAction, (String?, String?)> gamePadMappings = {};

  set setMusicVolume(double value) {
    musicVolume = value;
    parentComponent?.notifyListeners();
    save();
  }

  set setHudScale(HudScale value) {
    hudScale = value;
    parentComponent?.notifyListeners();
    save();
  }

  set setSFXVolume(double value) {
    sfxVolume = value;
    parentComponent?.notifyListeners();
    save();
  }
}

enum MouseButtons { primaryClick, scrollClick, secondaryClick, misc }

MouseButtons getMouseButton(int listenerButtonId) {
  if (listenerButtonId == 1) {
    return MouseButtons.primaryClick;
  } else if (listenerButtonId == 4) {
    return MouseButtons.scrollClick;
  } else if (listenerButtonId == 2) {
    return MouseButtons.secondaryClick;
  } else {
    return MouseButtons.misc;
  }
}

extension AnyFunctionHelper on (PhysicalKeyboardKey?, PhysicalKeyboardKey?) {
  bool any(PhysicalKeyboardKey? key) => this.$1 == key || this.$2 == key;
}
