import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:recase/recase.dart';
import 'package:runefire/game/hud.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/main.dart';

import 'package:runefire/game/enviroment.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/data_classes/base.dart';
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

  final Map<GameAction, Set<LogicalKeyboardKey>> constantKeyboardMappings = {
    GameAction.pause: {LogicalKeyboardKey.escape},
  };

  @HiveField(100)
  Map<GameAction, (LogicalKeyboardKey?, LogicalKeyboardKey?)> keyboardMappings =
      {
    GameAction.moveUp: (LogicalKeyboardKey.keyW, LogicalKeyboardKey.arrowUp),
    GameAction.moveLeft: (
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.arrowLeft
    ),
    GameAction.moveDown: (
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.arrowDown
    ),
    GameAction.moveRight: (
      LogicalKeyboardKey.keyD,
      LogicalKeyboardKey.arrowRight
    ),
    GameAction.reload: (LogicalKeyboardKey.keyR, null),
    GameAction.interact: (LogicalKeyboardKey.keyE, null),
    GameAction.useExpendable: (LogicalKeyboardKey.keyQ, null),
    GameAction.jump: (LogicalKeyboardKey.space, null),
    GameAction.swapWeapon: (LogicalKeyboardKey.tab, null),
    GameAction.dash: (LogicalKeyboardKey.shiftLeft, null),
    GameAction.pause: (LogicalKeyboardKey.keyP, null),
  };

  @HiveField(105)
  Map<GameAction, (int?, int?)> mouseButtonMappings = {
    GameAction.primary: (1, null),
    GameAction.secondary: (2, null),
  };

  @HiveField(110)
  Map<GameAction, (GamepadButtons?, GamepadButtons?)> gamePadMappings = {
    GameAction.moveUp: (GamepadButtons.dpadUp, null),
    GameAction.moveLeft: (GamepadButtons.dpadLeft, null),
    GameAction.moveDown: (GamepadButtons.dpadDown, null),
    GameAction.moveRight: (GamepadButtons.dpadRight, null),
    GameAction.reload: (GamepadButtons.rightShoulder, null),
    GameAction.interact: (GamepadButtons.buttonX, null),
    GameAction.useExpendable: (
      GamepadButtons.leftShoulder,
      GamepadButtons.rightThumb
    ),
    GameAction.jump: (GamepadButtons.buttonA, null),
    GameAction.swapWeapon: (GamepadButtons.buttonY, null),
    GameAction.dash: (GamepadButtons.buttonB, null),
    GameAction.pause: (GamepadButtons.buttonStart, null),
    GameAction.primary: (GamepadButtons.rightTrigger, null),
    GameAction.secondary: (GamepadButtons.leftTrigger, null),
  };

  @HiveField(120)
  AimAssistStrength aimAssistStrength = AimAssistStrength.none;

  List<GameDifficulty> availableDifficulties = [
    GameDifficulty.regular,
    GameDifficulty.quick,
  ];

  List<GameLevel> availableLevels = [GameLevel.hexedForest];
  Map<GameAction, GamepadButtons> constantGamePadMappings = {
    GameAction.pause: GamepadButtons.buttonStart,
  };

  //Move is right, aim is left, if true
  @HiveField(116)
  bool flipJoystickControl = false;

  @HiveField(117)
  bool gamepadVibrationEnabled = true;

  @HiveField(20)
  HudScale hudScale = HudScale.medium;

  @HiveField(115)
  bool invertYAxis = false;

  @HiveField(0)
  double musicVolume;

  @HiveField(1)
  double sfxVolume;

  @HiveField(12)
  bool showDamageText = true;

  @HiveField(10)
  bool showFPS = false;

  @HiveField(12)
  bool showStaminaHealthText = false;

  @HiveField(11)
  bool showTimer = false;

  set setAimAssist(AimAssistStrength value) {
    aimAssistStrength = value;
    parentComponent?.notifyListeners();
    // save();
  }

  set setFlipJoystickControl(bool value) {
    flipJoystickControl = value;
    parentComponent?.notifyListeners();
    // save();
  }

  void setGamepadMapping(
    GameAction action,
    GamepadButtons? button,
    bool isPrimary,
  ) {
    var newGamepadMapping = gamePadMappings[action];

    if (newGamepadMapping != null) {
      if (isPrimary) {
        newGamepadMapping = (button, newGamepadMapping.$2);
      } else {
        newGamepadMapping = (newGamepadMapping.$1, button);
      }
    } else {
      newGamepadMapping = (
        isPrimary ? button : null,
        isPrimary ? null : button,
      );
    }

    gamePadMappings[action] = newGamepadMapping;
    parentComponent?.notifyListeners();
    // save();
  }

  set setHudScale(HudScale value) {
    hudScale = value;
    parentComponent?.notifyListeners();
    // save();
  }

  void setKeyboardMapping(
    GameAction action,
    LogicalKeyboardKey? key,
    bool isPrimary,
  ) {
    var newKeyboardMapping = keyboardMappings[action];

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
    // save();
  }

  void setMouseButtonMapping(
    GameAction action,
    int? listenerButtonId,
    bool isPrimary,
  ) {
    var newMouseButtonMapping = mouseButtonMappings[action];

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
    // save();
  }

  set setMusicVolume(double value) {
    musicVolume = value;
    parentComponent?.notifyListeners();
    // save();
  }

  set setSFXVolume(double value) {
    sfxVolume = value;
    parentComponent?.notifyListeners();
    // save();
  }

  set setShowDamageText(bool value) {
    showDamageText = value;
    parentComponent?.notifyListeners();
    // save();
  }

  set setShowFPS(bool value) {
    showFPS = value;
    parentComponent?.notifyListeners();
    // save();
  }
}

enum MouseButtons { primaryClick, scrollClick, secondaryClick, misc }

enum ButtonType { button, trigger, joy }

enum AimAssistStrength { none, low, medium, lockOn }

extension AimAssistStrengthThreshold on AimAssistStrength {
  double get threshold {
    switch (this) {
      case AimAssistStrength.none:
        return 0;
      case AimAssistStrength.low:
        return 1;
      case AimAssistStrength.medium:
        return 3;
      case AimAssistStrength.lockOn:
        return double.infinity;
    }
  }
}

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

  buttonA,
  buttonB,
  buttonX,
  buttonY,
  leftTrigger(buttonType: ButtonType.trigger),
  rightTrigger(buttonType: ButtonType.trigger),
  //Cant change binding, as unique input type
  leftJoy(buttonType: ButtonType.joy),
  rightJoy(buttonType: ButtonType.joy);

  const GamepadButtons({this.buttonType = ButtonType.button});
  final ButtonType buttonType;
}

enum PressState { pressed, released, held }

class GamepadEvent {
  GamepadEvent(this.button, this.xyValue, this.singleValue, this.pressState);

  GamepadButtons button;
  PressState pressState;
  double singleValue;
  Offset xyValue;

  bool get isAnalog => xyValue.distance != 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamepadEvent &&
          button == other.button &&
          singleValue == other.singleValue &&
          xyValue == other.xyValue &&
          pressState == other.pressState;

  @override
  int get hashCode =>
      button.hashCode ^
      xyValue.hashCode ^
      singleValue.hashCode ^
      pressState.hashCode;

  @override
  String toString() =>
      'GamepadEvent(button: $button, xyValue: $xyValue, value: $singleValue, isPressed: $pressState)';
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
  bool either(dynamic key) => this.$1 == key || this.$2 == key;
}

extension HelperFunctionsSystemData on SystemData {
  String? getBinding(GameAction gameAction, InputManager inputManager) {
    switch (inputManager.externalInputType) {
      case ExternalInputType.gamepad:
        final gamepadMapping = gamePadMappings[gameAction];
        if (gamepadMapping != null) {
          if (gamepadMapping.$1 != null) {
            return gamepadMapping.$1!.name.titleCase;
          } else if (gamepadMapping.$2 != null) {
            return gamepadMapping.$2!.name.titleCase;
          }
        }
      case ExternalInputType.mouseKeyboard:
        final keyboardMapping = keyboardMappings[gameAction];
        final mouseMapping = mouseButtonMappings[gameAction];
        if (keyboardMapping != null) {
          if (keyboardMapping.$1 != null) {
            return keyboardMapping.$1!.stringKeyLabel.titleCase;
          }
        }
        if (mouseMapping != null) {
          if (mouseMapping.$1 != null) {
            final mouseButton = getMouseButton(mouseMapping.$1!);
            return mouseButton == MouseButtons.misc
                ? 'Mouse Button ${mouseMapping.$1}'
                : mouseButton.name.titleCase;
          } else if (mouseMapping.$2 != null) {
            final mouseButton = getMouseButton(mouseMapping.$2!);
            return mouseButton == MouseButtons.misc
                ? 'Mouse Button ${mouseMapping.$2}'
                : mouseButton.name.titleCase;
          }
        } else if (keyboardMapping != null) {
          if (keyboardMapping.$2 != null) {
            return keyboardMapping.$2!.stringKeyLabel.titleCase;
          }
        }
        break;

      default:
    }
    return null;
  }
}
