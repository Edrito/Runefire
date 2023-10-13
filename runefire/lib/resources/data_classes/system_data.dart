import 'dart:collection';

import 'package:flame/components.dart';
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

  void setKeyboardMapping(
      GameAction action, PhysicalKeyboardKey? key, bool isPrimary) {
    (PhysicalKeyboardKey?, PhysicalKeyboardKey?)? newKeyboardMapping =
        keyboardMappings[action];

    if (newKeyboardMapping != null) {
      if (isPrimary) {
        newKeyboardMapping = (key, newKeyboardMapping.$2);
      } else {
        newKeyboardMapping = (newKeyboardMapping.$1, key);
      }
    } else {
      newKeyboardMapping = (isPrimary ? key : null, isPrimary ? null : key);
    }

    var oldMouseMapping = mouseButtonMappings[action];
    if (oldMouseMapping != null) {
      if (newKeyboardMapping.$1 != null) {
        oldMouseMapping = (null, oldMouseMapping.$2);
      }
      if (newKeyboardMapping.$2 != null) {
        oldMouseMapping = (oldMouseMapping.$1, null);
      }

      mouseButtonMappings[action] = oldMouseMapping;
    }

    keyboardMappings[action] = newKeyboardMapping;
    parentComponent?.notifyListeners();
    save();
  }

  void setMouseButtonMapping(
      GameAction action, int? listenerButtonId, bool isPrimary) {
    (int?, int?)? newMouseButtonMapping = mouseButtonMappings[action];

    if (newMouseButtonMapping != null) {
      if (isPrimary) {
        newMouseButtonMapping = (listenerButtonId, newMouseButtonMapping.$2);
      } else {
        newMouseButtonMapping = (newMouseButtonMapping.$1, listenerButtonId);
      }
    } else {
      newMouseButtonMapping = (
        isPrimary ? listenerButtonId : null,
        isPrimary ? null : listenerButtonId,
      );
    }

    var oldKeyboardMapping = keyboardMappings[action];
    if (oldKeyboardMapping != null) {
      if (newMouseButtonMapping.$1 != null) {
        oldKeyboardMapping = (null, oldKeyboardMapping.$2);
      }
      if (newMouseButtonMapping.$2 != null) {
        oldKeyboardMapping = (oldKeyboardMapping.$1, null);
      }

      keyboardMappings[action] = oldKeyboardMapping;
    }

    mouseButtonMappings[action] = newMouseButtonMapping;
    parentComponent?.notifyListeners();
    save();
  }

  void setGamepadMapping(
      GameAction action, String? buttonName, bool isPrimary) {
    (String?, String?)? newGamepadMapping = gamePadMappings[action];

    if (newGamepadMapping != null) {
      if (isPrimary) {
        newGamepadMapping = (buttonName, newGamepadMapping.$2);
      } else {
        newGamepadMapping = (newGamepadMapping.$1, buttonName);
      }
    } else {
      newGamepadMapping = (
        isPrimary ? buttonName : null,
        isPrimary ? null : buttonName,
      );
    }

    gamePadMappings[action] = newGamepadMapping;
    parentComponent?.notifyListeners();
    save();
  }

  final Map<GameAction, Set<PhysicalKeyboardKey>> constantKeyboardMappings = {
    GameAction.pause: {PhysicalKeyboardKey.escape},
  };

  @HiveField(100)
  Map<GameAction, (PhysicalKeyboardKey?, PhysicalKeyboardKey?)>
      keyboardMappings = {
    GameAction.moveUp: (PhysicalKeyboardKey.keyW, PhysicalKeyboardKey.arrowUp),
    GameAction.moveLeft: (
      PhysicalKeyboardKey.keyA,
      PhysicalKeyboardKey.arrowLeft
    ),
    GameAction.moveDown: (
      PhysicalKeyboardKey.keyS,
      PhysicalKeyboardKey.arrowDown
    ),
    GameAction.moveRight: (
      PhysicalKeyboardKey.keyD,
      PhysicalKeyboardKey.arrowRight
    ),
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

  Map<GameAction, String> constantGamePadMappings = {GameAction.pause: "Start"};

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

enum GamepadButtons {
  dpadUp,
  dpadDown,
  dpadLeft,
  dpadRight,
  buttonStart,
  buttonBack,
  leftThumb,
  rightThumb,
  leftShoulder,
  rightShoulder,
  leftTrigger,
  rightTrigger,
  buttonA,
  buttonB,
  buttonX,
  buttonY,
  leftJoy,
  rightJoy,
}

class GamepadEvent {
  GamepadEvent(this.button, this.xyValue, this.singleValue, this.isPressed);
  GamepadButtons button;
  Vector2 xyValue;
  double singleValue;
  bool isPressed;
  bool get isAnalog => !xyValue.isZero();

  @override
  String toString() =>
      "GamepadEvent(button: $button, xyValue: $xyValue, value: $singleValue, isPressed: $isPressed)";
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamepadEvent &&
          button == other.button &&
          singleValue == other.singleValue &&
          xyValue == other.xyValue &&
          isPressed == other.isPressed;

  @override
  int get hashCode =>
      button.hashCode ^
      xyValue.hashCode ^
      singleValue.hashCode ^
      isPressed.hashCode;
}

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

extension AnyFunctionHelper on (dynamic, dynamic) {
  bool any(dynamic key) => this.$1 == key || this.$2 == key;
}
