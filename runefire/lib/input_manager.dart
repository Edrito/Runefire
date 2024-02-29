import 'dart:async';
import 'dart:async' as ac;
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart' hide World;
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
// import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
// import 'package:gamepads/gamepads.dart';
// import 'package:gamepads/gamepads.dart';
import 'package:runefire/game/background.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:runefire/main.dart';
import 'package:runefire/menus/menus.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/assets/sprite_animations.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/resources/data_classes/system_data.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:uuid/uuid.dart';
// import 'package:win32_gamepad/win32_gamepad.dart';
import 'package:runefire/game/menu_game.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:runefire/menus/overlays.dart';
import 'package:runefire/resources/constants/routes.dart' as routes;
import 'package:runefire/menus/overlays.dart' as overlay;
import 'package:win32_gamepad/win32_gamepad.dart';

typedef GameActionEvent = ({
  GameAction gameAction,
  PressState pressState,
});

typedef GameActionCallback = Function(
  GameActionEvent gameAction,
  Set<GameAction> activeGameActions,
);

enum CustomInputWatcherEvents {
  hoverOn,
  hoverOff,
  onPrimary,
  onPrimaryHold,
  onPrimaryUp,
  updateOnPostFrameCallback,
  onSecondary,
  onSecondaryHold,
  onSecondaryUp,
}

class EventDetectedException implements Exception {}

// class GamepadEvent {
//   GamepadEvent(this.gamepadId, this.timestamp, this.key, this.value);

//   /// The id of the gamepad controller that fired the event.
//   final String gamepadId;

//   bool isDownEvent = false;

//   /// The timestamp in which the event was fired, in milliseconds since epoch.
//   final int timestamp;

//   // /// The [KeyType] of the key that was triggered.
//   // final KeyType type;

//   /// A platform-dependant identifier for the key that was triggered.
//   final String key;

//   /// The current value of the key.
//   final double value;
// }

class GamepadInputManager {
  GamepadInputManager(
    this.parentInputManager,
    this.onGamepadEvent,
    this._gameRouterReference,
  ) {
    _initCheckGamepadTimer();
  }

  static const Duration _updateGamepadTimerDuration =
      Duration(milliseconds: 10);

  final GameRouter _gameRouterReference;

  ///
  final Map<GamepadButtons, GamepadEvent> _gamepadEvents = {};

  ac.Timer? _checkGamepadTimer;
  ac.Timer? _updateGamepadTimer;

  final gamepad = Gamepad(0); // primary controller
  final Function(GamepadEvent event) onGamepadEvent;
  final InputManager parentInputManager;

  GamepadButtons tempGamepadButton = GamepadButtons.buttonBack;
  PressState tempPressState = PressState.released;
  double tempSingleValue = 0;

  ///dont need to make new variables each tick
  Offset tempXyValue = Offset.zero;

  void createEvent() {
    late final GamepadEvent gamepadEvent;
    if (_gamepadEvents.containsKey(tempGamepadButton)) {
      gamepadEvent = _gamepadEvents[tempGamepadButton]!
        ..pressState = tempPressState
        ..singleValue = tempSingleValue
        ..xyValue = tempXyValue;
    } else {
      gamepadEvent = GamepadEvent(
        tempGamepadButton,
        tempXyValue,
        tempSingleValue,
        tempPressState,
      );
      if (tempPressState != PressState.released) {
        _gamepadEvents[tempGamepadButton] = gamepadEvent;
      }
    }
    //each event should only be processed once per tick
    onGamepadEvent(gamepadEvent);
  }

  Offset? fetchJoyState(GamepadButtons joy) {
    switch (joy) {
      case GamepadButtons.leftJoy:
        return _gamepadEvents[GamepadButtons.leftJoy]?.xyValue;

      case GamepadButtons.rightJoy:
        return _gamepadEvents[GamepadButtons.rightJoy]?.xyValue;

      default:
        return null;
    }
  }

  void parseGameState() {
    final event = gamepad.state;
    if (_gamepadEvents.isEmpty && !event.isConnected) {
      _updateGamepadTimer?.cancel();
      _updateGamepadTimer = null;
      _initCheckGamepadTimer();
      return;
    } else {
      _checkGamepadTimer?.cancel();
      _checkGamepadTimer = null;
      _initGamepadTimer();
    }

    var shouldCreateEvent = false;
    for (final element in GamepadButtons.values) {
      shouldCreateEvent = false; // Initialize to false
      tempXyValue = Offset.zero;
      tempSingleValue = 0;
      tempPressState = PressState.released;
      tempGamepadButton = element;
      switch (element) {
        case GamepadButtons.dpadUp:
          shouldCreateEvent =
              _checkSimpleButton(event.dpadUp, GamepadButtons.dpadUp);
          break;
        case GamepadButtons.dpadDown:
          shouldCreateEvent =
              _checkSimpleButton(event.dpadDown, GamepadButtons.dpadDown);
          break;
        case GamepadButtons.dpadLeft:
          shouldCreateEvent =
              _checkSimpleButton(event.dpadLeft, GamepadButtons.dpadLeft);
          break;
        case GamepadButtons.dpadRight:
          shouldCreateEvent =
              _checkSimpleButton(event.dpadRight, GamepadButtons.dpadRight);
          break;
        case GamepadButtons.buttonA:
          shouldCreateEvent =
              _checkSimpleButton(event.buttonA, GamepadButtons.buttonA);
          break;
        case GamepadButtons.buttonB:
          shouldCreateEvent =
              _checkSimpleButton(event.buttonB, GamepadButtons.buttonB);
          break;
        case GamepadButtons.buttonX:
          shouldCreateEvent =
              _checkSimpleButton(event.buttonX, GamepadButtons.buttonX);
          break;
        case GamepadButtons.buttonY:
          shouldCreateEvent =
              _checkSimpleButton(event.buttonY, GamepadButtons.buttonY);
          break;
        case GamepadButtons.leftShoulder:
          shouldCreateEvent = _checkSimpleButton(
            event.leftShoulder,
            GamepadButtons.leftShoulder,
          );
          break;
        case GamepadButtons.rightShoulder:
          shouldCreateEvent = _checkSimpleButton(
            event.rightShoulder,
            GamepadButtons.rightShoulder,
          );
          break;
        case GamepadButtons.leftThumb:
          shouldCreateEvent =
              _checkSimpleButton(event.leftThumb, GamepadButtons.leftThumb);
          break;
        case GamepadButtons.rightThumb:
          shouldCreateEvent =
              _checkSimpleButton(event.rightThumb, GamepadButtons.rightThumb);
          break;
        case GamepadButtons.buttonStart:
          shouldCreateEvent =
              _checkSimpleButton(event.buttonStart, GamepadButtons.buttonStart);
          break;
        case GamepadButtons.buttonBack:
          shouldCreateEvent =
              _checkSimpleButton(event.buttonBack, GamepadButtons.buttonBack);
          break;
        case GamepadButtons.leftJoy:
          shouldCreateEvent = _checkAnalogStick(
            event.leftThumbstickX,
            event.leftThumbstickY,
            GamepadButtons.leftJoy,
          );
          break;
        case GamepadButtons.rightJoy:
          shouldCreateEvent = _checkAnalogStick(
            event.rightThumbstickX,
            event.rightThumbstickY,
            GamepadButtons.rightJoy,
          );
          break;
        case GamepadButtons.leftTrigger:
          shouldCreateEvent =
              _checkTrigger(event.leftTrigger, GamepadButtons.leftTrigger);
          break;
        case GamepadButtons.rightTrigger:
          shouldCreateEvent =
              _checkTrigger(event.rightTrigger, GamepadButtons.rightTrigger);
          break;
      }
      if (shouldCreateEvent) {
        createEvent();
      }
    }

// checkSimpleButton(event.leftTrigger, GamepadButtons.leftTrigger);
// checkSimpleButton(event.rightTrigger, GamepadButtons.rightTrigger );
  }

  void updateState() {
    if (_gameRouterReference.paused) {
      gamepad.updateState();
      parseGameState();
    }
  }

  bool _checkAnalogStick(int x, int y, GamepadButtons stickToCheck) {
    final capabilities = GamepadCapabilities(0);
    int deadzone;
    if (stickToCheck == GamepadButtons.leftJoy) {
      deadzone = capabilities.leftThumbDeadzone;
    } else {
      deadzone = capabilities.rightThumbDeadzone;
    }
    // deadzone = 20000;
    final isInDeadZone = x.abs() < deadzone && y.abs() < deadzone;
    final eventActive = _gamepadEvents.containsKey(stickToCheck);

    if (eventActive && isInDeadZone) {
      _gamepadEvents.remove(stickToCheck);
      tempPressState = PressState.released;
      tempGamepadButton = stickToCheck;
      return true;
    } else if (!isInDeadZone) {
      final xClamped = (x / 32777).clamp(-1, 1).toDouble();
      var yClamped = (y / 32777).clamp(-1, 1).toDouble();
      if (!parentInputManager._systemDataReference.invertYAxis) {
        yClamped *= -1;
      }
      tempXyValue = Offset(xClamped, yClamped);

      tempPressState = eventActive ? PressState.held : PressState.pressed;
      tempGamepadButton = stickToCheck;
      return true;
    }
    return false;
  }

  bool _checkSimpleButton(bool state, GamepadButtons buttonToCheck) {
    if (_gamepadEvents.containsKey(buttonToCheck)) {
      if (!state) {
        _gamepadEvents.remove(buttonToCheck);
        tempPressState = PressState.released;

        tempGamepadButton = buttonToCheck;
        return true;
      } else {
        tempPressState = PressState.held;

        tempGamepadButton = buttonToCheck;
        return true;
      }
    } else if (state) {
      tempPressState = PressState.pressed;

      tempGamepadButton = buttonToCheck;
      return true;
    }
    return false;
  }

  bool _checkTrigger(int value, GamepadButtons triggerToCheck) {
    final capabilities = GamepadCapabilities(0);

    final isInDeadZone = value < capabilities.triggerThreshold;
    final eventActive = _gamepadEvents.containsKey(triggerToCheck);
    if (eventActive && isInDeadZone) {
      _gamepadEvents.remove(triggerToCheck);
      tempSingleValue = 0;
      tempPressState = PressState.released;

      tempGamepadButton = triggerToCheck;
      return true;
    } else if (!isInDeadZone) {
      final valueClamped = (value / 255).clamp(0, 1);
      tempSingleValue = valueClamped.toDouble();
      tempPressState = eventActive ? PressState.held : PressState.pressed;

      tempGamepadButton = triggerToCheck;
      return true;
    }
    return false;
  }

  void _initCheckGamepadTimer() {
    _checkGamepadTimer ??=
        ac.Timer.periodic(_updateGamepadTimerDuration * 20, (timer) {
      updateState();
    });
  }

  void _initGamepadTimer() {
    _updateGamepadTimer ??=
        ac.Timer.periodic(_updateGamepadTimerDuration, (timer) {
      updateState();
    });
  }
}

class InputManager with WindowListener {
  //singleton goodies
  factory InputManager() {
    return _instance;
  }

  InputManager._internal() {
    if (!kIsWeb && Platform.isWindows) {
      windowManager.addListener(this);
    }
    buildTimer();
  }

  void buildTimer() {
    timeoutTimer?.cancel();
    timeoutTimer = ac.Timer(
      const Duration(seconds: 15),
      () {
        _onTimeoutList.forEach((element) => element.call());
      },
    );
  }

  ac.Timer? timeoutTimer;

  void addOnTimeoutListener(Function() onTimeout) {
    _onTimeoutList.add(onTimeout);
  }

  void removeOnTimeoutListener(Function() onTimeout) {
    _onTimeoutList.remove(onTimeout);
  }

  final List<Function()> _onTimeoutList = [];

  void _setVibrationZero() => gamepadInputManager.gamepad.vibrate();

  //singleton
  static final InputManager _instance = InputManager._internal();

  late final GameRouter _gameRouterReference;
  late final SystemData _systemDataReference;

  //for icons
  ExternalInputType _externalInputType = ExternalInputType.touch;

  //callbacks
  final Map<GameAction, Set<GameActionCallback>> _onGameActionMap = {};

  Offset? _gamepadCursorPosition;

  late final CustomInputWatcherManager customInputWatcherManager;
  late final GamepadInputManager gamepadInputManager;

  //Keyboard
  final List<Function(KeyEvent event)> _keyEventList = [];

  // Keyboard
  final List<Function(GamepadEvent event)> _gamepadEventList = [];

  List<Function(PointerDownEvent event)> pointerDownList = [];
  // Callbacks for pointer moving
  List<Function(ExternalInputType type, Offset position)> onPointerMoveList =
      [];

  //Window events (windows only I think)
  List<Function(String windowEvent)> onWindowEventList = [];

  //Currently active game actions, passed into game callbacks
  Set<GameAction> activeGameActions = {};

  //for secondary pointer if using mobile
  Set<int> activePointers = {};

  //tick rate faker for primary and secondary mouse/pointer holding
  ac.Timer? holdCallTimer;

  //if true then the holdcalltimer is for primary click, if false then for secondary
  //if null then not active
  bool? isPrimaryTimerActive;

  //easy access to pointer locations
  Map<int, Offset> pointerLocalPositions = {};

  //You can only determine if a input click is a secondary click on the pointer down event
  //so we use this to determine what pointer is the secondary when the various "pointer down" etc functions are called
  int? secondaryPointerId;

  Offset? latestPointerPosition;
  String? vibrationId;

  //Const duration for the primary and secondary hold tick rate
  static const Duration incrementDuration = Duration(milliseconds: 50);

  ExternalInputType get externalInputType => _externalInputType;
  Offset? get getGamepadCursorPosition => _gamepadCursorPosition;

  //Game components use this to add new callbacks
  void addGameActionListener(
    GameAction gameAction,
    GameActionCallback callback,
  ) {
    _onGameActionMap[gameAction] ??= {};
    _onGameActionMap[gameAction]!.add(callback);
  }

  void addGamepadEventListener(Function(GamepadEvent event) newListener) {
    _gamepadEventList.add(newListener);
  }

  void addKeyListener(Function(KeyEvent event) newListener) {
    _keyEventList.add(newListener);
  }

  Future<void> applyVibration(
    double? duration,
    double intensity, {
    bool? leftOnly,
  }) async {
    if (kIsWeb || !Platform.isWindows) {
      return;
    }
    if (!_systemDataReference.gamepadVibrationEnabled ||
        !gamepadInputManager.gamepad.isConnected) {
      return;
    }

    final mappedIntensity = (65535 * intensity).clamp(0, 65535).toInt();
    final id = const Uuid().v1();
    vibrationId = id;
    gamepadInputManager.gamepad.vibrate(
      leftMotorSpeed: leftOnly == true ? 0 : mappedIntensity,
      rightMotorSpeed: leftOnly == false ? 0 : mappedIntensity,
    );
    if (duration != null) {
      await Future.delayed(duration.seconds, () {
        if (vibrationId != id) {
          return;
        }
        _setVibrationZero();
      });
    }
  }

  //custom hold ticks for primary and secondary clicks
  void beginHoldCall(
    bool isPrimary,
  ) {
    if (isPrimaryTimerActive != null) {
      return;
    }
    isPrimaryTimerActive ??= isPrimary;

    Future.delayed(.5.seconds).then((value) {
      if (isPrimaryTimerActive == null) {
        return;
      }
      holdCallTimer = ac.Timer.periodic(incrementDuration, (timer) {
        if (isPrimaryTimerActive == null) {
          stopHoldCall(null);
          return;
        }

        if (isPrimaryTimerActive!) {
          customInputWatcherManager.onPrimaryHold();
        } else {
          customInputWatcherManager.onSecondaryHold();
        }
      });
    });
  }

  void buildGamepadCursor(GamepadEvent event) {
    final buttonToWatch = _systemDataReference.flipJoystickControl
        ? GamepadButtons.leftJoy
        : GamepadButtons.rightJoy;
    if (event.button != buttonToWatch) {
      return;
    }
    final gameRouterSizeOffset = _gameRouterReference.size.toOffset();
    _gamepadCursorPosition ??= gameRouterSizeOffset / 2;

    _gamepadCursorPosition =
        _gamepadCursorPosition! + (event.xyValue * gamepadCursorSpeed);
    _gamepadCursorPosition = Offset(
      _gamepadCursorPosition!.dx.clamp(0, gameRouterSizeOffset.dx),
      _gamepadCursorPosition!.dy.clamp(0, gameRouterSizeOffset.dy),
    );

    pointerFunnel(_gamepadCursorPosition!, ExternalInputType.gamepad, -1);

    // customInputWatcherManager.onPointerMove();
  }

  void cancelVibration() {
    vibrationId = null;
    _setVibrationZero();
  }

  void clearGamepadCursorPosition() => _gamepadCursorPosition = null;

  set externalInputType(ExternalInputType value) {
    _externalInputType = value;
  }

  Offset? fetchJoyState(GamepadButtons joy) {
    return gamepadInputManager.fetchJoyState(joy);
  }

  bool keyboardEventHandler(KeyEvent keyEvent) {
    for (final element in _keyEventList) {
      element.call(keyEvent);
    }

    customInputWatcherManager.handleWidgetKeyboardInput(keyEvent);
    late final PressState pressState;
    switch (keyEvent.runtimeType) {
      case KeyDownEvent:
        pressState = PressState.pressed;
        break;
      case KeyUpEvent:
        pressState = PressState.released;

        break;
      case KeyRepeatEvent:
        pressState = PressState.held;

        break;
      default:
    }

    externalInputType = ExternalInputType.mouseKeyboard;
    final mappedActions = _systemDataReference.keyboardMappings.entries
        .where((element) => element.value.either(keyEvent.logicalKey));
    for (final element in mappedActions) {
      onGameActionCall((gameAction: element.key, pressState: pressState));
    }

    final permanentMappedActions = _systemDataReference
        .constantKeyboardMappings.entries
        .where((element) => element.value.contains(keyEvent.logicalKey));
    for (final element in permanentMappedActions) {
      onGameActionCall((gameAction: element.key, pressState: pressState));
    }

    return !(permanentMappedActions.isEmpty && mappedActions.isEmpty);
  }

  void onGameActionCall(GameActionEvent event) {
    buildTimer();
    if (event.pressState != PressState.released) {
      activeGameActions.add(event.gameAction);
    } else {
      activeGameActions.remove(event.gameAction);
    }
    for (final element in _onGameActionMap[event.gameAction] ?? {}) {
      element.call(event, activeGameActions);
    }
  }

  void onGamepadEvent(GamepadEvent event) {
    for (final element in _gamepadEventList) {
      element.call(event);
    }
    customInputWatcherManager.handleGamepadInput(event);
    buildGamepadCursor(event);
    externalInputType = ExternalInputType.gamepad;
    final mappedActions = _systemDataReference.gamePadMappings.entries
        .where((element) => element.value.either(event.button));
    for (final element in mappedActions) {
      onGameActionCall((gameAction: element.key, pressState: event.pressState));
    }

    final constantMappedActions = _systemDataReference
        .constantGamePadMappings.entries
        .where((element) => element.value == (event.button));
    for (final element in constantMappedActions) {
      onGameActionCall((gameAction: element.key, pressState: event.pressState));
    }
  }

  void onPointerCancel(PointerCancelEvent event) {
    activePointers.remove(event.pointer);

    if (secondaryPointerId == event.pointer) {
      onSecondaryCancelCall(event);
      secondaryPointerId = null;
    } else {
      onPrimaryCancelCall(event);
    }
  }

  void onPointerDown(PointerDownEvent event) {
    activePointers.add(event.pointer);
    for (final element in pointerDownList) {
      element.call(event);
    }
    if (event.kind == PointerDeviceKind.mouse) {
      if (event.buttons == 2) {
        onSecondaryDownCall(event);
        secondaryPointerId = event.pointer;
      } else {
        onPrimaryDownCall(event);
      }
    } else if (event.kind == PointerDeviceKind.touch) {
      externalInputType = ExternalInputType.touch;
    }
  }

  void onPointerHover(PointerHoverEvent event) {
    pointerFunnel(
      event.position,
      event.kind == PointerDeviceKind.mouse
          ? ExternalInputType.mouseKeyboard
          : ExternalInputType.touch,
      event.pointer,
    );
  }

  void onPointerMove(PointerMoveEvent event) {
    pointerFunnel(
      event.position,
      event.kind == PointerDeviceKind.mouse
          ? ExternalInputType.mouseKeyboard
          : ExternalInputType.touch,
      event.pointer,
    );
  }

  void onPointerPanZoomEnd(event) {}

  void onPointerPanZoomStart(event) {}

  void onPointerPanZoomUpdate(event) {}

  void onPointerSignal(event) {}

  void onPointerUp(PointerUpEvent event) {
    activePointers.remove(event.pointer);

    if (secondaryPointerId == event.pointer) {
      onSecondaryUpCall(event);
      secondaryPointerId = null;
    } else {
      onPrimaryUpCall(event);
    }
  }

  void onPrimaryCancelCall(PointerCancelEvent info) {
    stopHoldCall(true);
    final actions = _systemDataReference.mouseButtonMappings.entries
        .where((element) => element.value.either(1))
        .map((e) => e.key);

    for (final element in actions) {
      onGameActionCall(
        (gameAction: element, pressState: PressState.released),
      );
    }
    customInputWatcherManager.onPrimaryUp();
  }

  void onPrimaryDownCall(PointerDownEvent info) {
    final actions = _systemDataReference.mouseButtonMappings.entries
        .where((element) => element.value.either(1))
        .map((e) => e.key);

    for (final element in actions) {
      onGameActionCall(
        (gameAction: element, pressState: PressState.pressed),
      );
    }

    customInputWatcherManager.onPrimary();

    beginHoldCall(true);
  }

  void onPrimaryUpCall(PointerUpEvent info) {
    final actions = _systemDataReference.mouseButtonMappings.entries
        .where((element) => element.value.either(1))
        .map((e) => e.key);

    for (final element in actions) {
      onGameActionCall(
        (gameAction: element, pressState: PressState.released),
      );
    }

    stopHoldCall(true);
    customInputWatcherManager.onPrimaryUp();
  }

  void onSecondaryCancelCall(PointerCancelEvent info) {
    // for (var element in onSecondaryCancel) {
    //   element.call(info);
    final actions = _systemDataReference.mouseButtonMappings.entries
        .where((element) => element.value.either(2))
        .map((e) => e.key);

    for (final element in actions) {
      onGameActionCall(
        (gameAction: element, pressState: PressState.released),
      );
    }
    customInputWatcherManager.onSecondaryUp();

    stopHoldCall(false);
  }

  void onSecondaryDownCall(PointerDownEvent info) {
    final actions = _systemDataReference.mouseButtonMappings.entries
        .where((element) => element.value.either(2))
        .map((e) => e.key);

    for (final element in actions) {
      onGameActionCall(
        (gameAction: element, pressState: PressState.pressed),
      );
    }
    beginHoldCall(false);
    customInputWatcherManager.onSecondary();

    // }
  }

  void onSecondaryUpCall(PointerUpEvent info) {
    // for (var element in onSecondaryUp) {
    //   element.call(info);
    final actions = _systemDataReference.mouseButtonMappings.entries
        .where((element) => element.value.either(2))
        .map((e) => e.key);

    for (final element in actions) {
      onGameActionCall(
        (gameAction: element, pressState: PressState.released),
      );
    }
    customInputWatcherManager.onSecondaryUp();
    stopHoldCall(false);
    // }
  }

  void pointerFunnel(Offset position, ExternalInputType inputType, int id) {
    buildTimer();
    externalInputType = inputType;

    pointerLocalPositions[id] = position;
    latestPointerPosition = position;
    for (final element in onPointerMoveList) {
      element.call(inputType, position);
    }
    customInputWatcherManager.checkStatesHovered();
  }

  void removeGameActionListener(
    GameAction gameAction,
    GameActionCallback callback,
  ) {
    _onGameActionMap[gameAction]?.remove(callback);
  }

  void removeGamepadEventListener(
    Function(GamepadEvent event) listenerToRemove,
  ) {
    _gamepadEventList.remove(listenerToRemove);
  }

  void removeKeyListener(Function(KeyEvent event) listenerToRemove) {
    _keyEventList.remove(listenerToRemove);
  }

  void setInitReferences(GameRouter gameRouter) {
    _gameRouterReference = gameRouter;

    _systemDataReference = _gameRouterReference.systemDataComponent.dataObject;
    customInputWatcherManager =
        CustomInputWatcherManager(this, _systemDataReference);
    if (!kIsWeb && Platform.isWindows) {
      gamepadInputManager =
          GamepadInputManager(this, onGamepadEvent, gameRouter);
    }
  }

  void stopHoldCall(bool? isPrimary) {
    if (isPrimaryTimerActive != isPrimary && isPrimary != null) {
      return;
    }
    isPrimaryTimerActive = null;
    holdCallTimer?.cancel();
    holdCallTimer = null;
  }

  @override
  void onWindowEvent(String eventName) {
    for (final element in onWindowEventList) {
      element.call(eventName);
    }

    super.onWindowEvent(eventName);
  }
}

enum ExternalInputType { touch, mouseKeyboard, gamepad }
// enum  GamePadButtons{ touch, keyboard, gamepad }

enum GameAction {
  primary,
  secondary,
  jump,
  dash,
  reload,
  pause,
  moveUp,
  moveDown,
  moveLeft,
  moveRight,
  swapWeapon,
  interact,
  useExpendable,
}

class CustomInputWatcherManager {
  CustomInputWatcherManager(
    this.parentInputManager,
    this._systemDataReference,
  ) {
    parentInputManager.onWindowEventList
        .add((windowEvent) => updateCustomInputWatcherRectangles());
  }

  late final SystemData _systemDataReference;

  //to check if pointer is inside widgets, custom hover implementation
  final Map<State<CustomInputWatcher>, Rect> _customInputWatcherRectangles = {};

  //Grouping all the widgets by their group id, allows for sorting by axis
  final Map<int, Map<int, List<State<CustomInputWatcher>>>>
      _customInputWatcherRows = {};

  //If there are buttons in a scroll widget,
  //save the scrollcontroller to modify it when we scroll/use keyboard
  final Map<ScrollController, List<State<CustomInputWatcher>>>
      _customInputWatcherScrollControllers = {};

  //Currently active streams
  final Map<State<CustomInputWatcher>,
          StreamController<CustomInputWatcherEvents>>
      _customInputWatcherStreams = {};

  final InputManager parentInputManager;

  (
    StreamController<CustomInputWatcherEvents>,
    StreamController<(Offset, Widget)?>
  ) addHoverOverlay(State<GamepadCursorDisplay> hoverOverlayState) {
    final eventController = StreamController<CustomInputWatcherEvents>();
    final hoveredWidgetEventController = StreamController<(Offset, Widget)?>();
    hoverOverlayWidget =
        (hoverOverlayState, eventController, hoveredWidgetEventController);
    return (eventController, hoveredWidgetEventController);
  }

  //only one active widget at a time
  State<CustomInputWatcher>? currentlyHoveredWidget;

  (
    State<GamepadCursorDisplay>,
    StreamController<CustomInputWatcherEvents>,
    StreamController<(Offset, Widget)?>,
  )? hoverOverlayWidget;

  //add a new widget to the input manager
  StreamController<CustomInputWatcherEvents> addCustomInputWatcher(
    State<CustomInputWatcher> customInputWatcher,
  ) {
    final eventController = StreamController<CustomInputWatcherEvents>();
    _customInputWatcherStreams[customInputWatcher] = eventController;

    if (_customInputWatcherRows.isNotEmpty &&
        customInputWatcher.widget.zIndex >
            _customInputWatcherRows.keys.reduce(max)) {
      setHoveredState(customInputWatcher);
    }

    ((_customInputWatcherRows[customInputWatcher.widget.zIndex] ??=
            {})[customInputWatcher.widget.rowId] ??= [])
        .add(customInputWatcher);

    // sort all the group lists when a new one is added, inneffecient but not needed to
    //optimize so its just easy :)
    sortRowStates(_customInputWatcherRows[customInputWatcher.widget.zIndex]!);

    //scroll controller
    if (customInputWatcher.widget.scrollController != null) {
      registerScrollController(
        customInputWatcher,
        customInputWatcher.widget.scrollController!,
      );
    }

    return eventController;
  }

  //Function that both keyboard and gamepad will call to move the currently hovered widget
  void changeHoveredState(AxisDirection directionOfInput) {
    final highestZIndex = _customInputWatcherRows.keys.reduce(max);

    if (currentlyHoveredWidget == null) {
      final entries = _customInputWatcherRectangles.entries
          .where((element) => element.key.widget.zIndex == highestZIndex);
      double initValue;
      switch (directionOfInput) {
        case AxisDirection.up:
          initValue = 0;
          for (final element in entries) {
            if (element.value.bottom > initValue) {
              initValue = element.value.bottom;
              setHoveredState(element.key);
            }
          }

          break;
        case AxisDirection.right:
          initValue = double.infinity;
          for (final element in entries) {
            if (element.value.left < initValue) {
              initValue = element.value.left;
              setHoveredState(element.key);
            }
          }

          break;
        case AxisDirection.down:
          initValue = double.infinity;
          for (final element in entries) {
            if (element.value.top < initValue) {
              initValue = element.value.top;
              setHoveredState(element.key);
            }
          }

          break;
        case AxisDirection.left:
          initValue = 0;
          for (final element in entries) {
            if (element.value.right > initValue) {
              initValue = element.value.right;
              setHoveredState(element.key);
            }
          }
          break;
        default:
      }

      return;
    }
    final currentRowId = currentlyHoveredWidget!.widget.rowId;

    final isSwappingRows = directionOfInput == AxisDirection.up ||
        directionOfInput == AxisDirection.down;

    final isHoveringScrollWidget =
        currentlyHoveredWidget!.widget.scrollController != null;

    //If the direction of the axisinput (up down left right) is against the axis of the
    //currently hovered widget, then we are swapping groups
    if (isHoveringScrollWidget) {
      final axis =
          currentlyHoveredWidget!.widget.scrollController!.position.axis;
      final currentScrollController =
          currentlyHoveredWidget!.widget.scrollController;
      // if (axis == Axis.vertical && !isSwappingRows ||
      //     (axis == Axis.horizontal && !isSwappingRows)) {
      //   shiftPositionInRow(directionOfInput, currentRowId, highestZIndex);
      //   return;
      // } else if (axis == Axis.vertical && isSwappingRows) {
      //   swapRows(directionOfInput, currentRowId, highestZIndex);
      //   return;
      // } else if ((axis == Axis.horizontal && isSwappingRows) ||
      //     isSwappingRows) {
      //   swapRows(directionOfInput, currentRowId, highestZIndex);
      //   return;
      // }

      isSwappingRows
          ? swapRows(directionOfInput, currentRowId, highestZIndex)
          : shiftPositionInRow(directionOfInput, currentRowId, highestZIndex);

      //If the group we are moving in is inside a scroll widget
      //we need to take that into account
      final scrollControllerChildren =
          _customInputWatcherScrollControllers[currentScrollController];

      // if (
      //     // scrollControllerChildren != null &&
      //     //   scrollControllerChildren.isNotEmpty
      //     //  &&
      //     !isSwappingRows) {
      // final currentIndex =
      //     scrollControllerChildren.indexOf(currentlyHoveredWidget!);
      // final nextIndex = currentIndex +
      //     ((directionOfInput == AxisDirection.up ||
      //             directionOfInput == AxisDirection.left)
      //         ? -1
      //         : 1);

      // final isEndOfScrollController =
      //     nextIndex < 0 || nextIndex >= scrollControllerChildren.length;
      // if (isEndOfScrollController) {
      //   if (isSwappingRows) {
      //     swapRows(directionOfInput, currentRowId, highestZIndex);
      //     // setHoveredState(scrollControllerChildren[nextIndex]);
      //     return;
      //   } else {
      //     shiftPositionInRow(directionOfInput, currentRowId, highestZIndex);
      //     return;
      //   }
      // }
      // setHoveredState(scrollControllerChildren[nextIndex]);
      final currentHoveredRect =
          _customInputWatcherRectangles[currentlyHoveredWidget!]!;
      final scrollAxis =
          currentlyHoveredWidget!.widget.scrollController?.position.axis;
      if (scrollAxis == Axis.vertical && directionOfInput == AxisDirection.up ||
          directionOfInput == AxisDirection.down) {
        //screen height
        final height = WidgetsBinding
            .instance.platformDispatcher.views.first.physicalSize.height;

        currentScrollController is InfiniteScrollController
            ? currentScrollController.animateToItem(
                scrollControllerChildren?.indexWhere(
                      (element) => element == currentlyHoveredWidget,
                    ) ??
                    0,
              )
            : currentScrollController?.animateTo(
                currentScrollController.position.pixels +
                    currentHoveredRect.top -
                    (height * .2),
                duration: .25.seconds,
                curve: Curves.ease,
              );
      }
    } else if (isSwappingRows) {
      swapRows(directionOfInput, currentRowId, highestZIndex);
    } else {
      sortRowStates(_customInputWatcherRows[highestZIndex]!);
      shiftPositionInRow(directionOfInput, currentRowId, highestZIndex);
    }
  }

  void checkStatesHovered() {
    if (_customInputWatcherRows.isEmpty) {
      return;
    }
    final maxIndex = _customInputWatcherRows.keys.reduce(max);
    for (final element in _customInputWatcherStreams.entries
        .where((element) => element.key.widget.zIndex == maxIndex)) {
      if (_checkIfStateHovered(element.key)) {
        break;
      }
    }
  }

  void handleGamepadInput(GamepadEvent event) {
    if (_customInputWatcherStreams.isEmpty ||
        event.pressState == PressState.held) {
      return;
    }

    if ([
      GamepadButtons.buttonA,
    ].contains(event.button)) {
      var eventType = CustomInputWatcherEvents.onPrimary;
      switch (event.pressState) {
        case PressState.pressed:
          eventType = CustomInputWatcherEvents.onPrimary;
          break;
        case PressState.released:
          eventType = CustomInputWatcherEvents.onPrimaryUp;

          break;
        case PressState.held:
          eventType = CustomInputWatcherEvents.onPrimaryHold;

          break;
        default:
      }
      sendStreamEvent(currentlyHoveredWidget, eventType);
    } else if ([
      GamepadButtons.buttonX,
    ].contains(event.button)) {
      var eventType = CustomInputWatcherEvents.onSecondary;
      switch (event.pressState) {
        case PressState.pressed:
          eventType = CustomInputWatcherEvents.onSecondary;
          break;
        case PressState.released:
          eventType = CustomInputWatcherEvents.onSecondaryUp;

          break;
        case PressState.held:
          eventType = CustomInputWatcherEvents.onSecondaryHold;

          break;
        default:
      }
      sendStreamEvent(currentlyHoveredWidget, eventType);
    }

    if (event.pressState == PressState.released) {
      return;
    }

    if ([
      GamepadButtons.dpadUp,
    ].contains(event.button)) {
      changeHoveredState(
        AxisDirection.up,
      );
    } else if ([
      GamepadButtons.dpadDown,
    ].contains(event.button)) {
      changeHoveredState(AxisDirection.down);
    } else if ([
      GamepadButtons.dpadLeft,
    ].contains(event.button)) {
      changeHoveredState(AxisDirection.left);
    } else if ([
      GamepadButtons.dpadRight,
    ].contains(event.button)) {
      changeHoveredState(AxisDirection.right);
    }
  }

  void handleWidgetKeyboardInput(KeyEvent keyEvent) {
    if (_customInputWatcherStreams.isEmpty) {
      return;
    }
    if ([
      LogicalKeyboardKey.space,
      LogicalKeyboardKey.enter,
      LogicalKeyboardKey.equal,
      LogicalKeyboardKey.keyE,
    ].contains(keyEvent.logicalKey)) {
      var eventType = CustomInputWatcherEvents.onPrimary;
      switch (keyEvent.runtimeType) {
        case KeyDownEvent:
          eventType = CustomInputWatcherEvents.onPrimary;
          break;
        case KeyUpEvent:
          eventType = CustomInputWatcherEvents.onPrimaryUp;

          break;
        case KeyRepeatEvent:
          eventType = CustomInputWatcherEvents.onPrimaryHold;

          break;
        default:
      }
      sendStreamEvent(currentlyHoveredWidget, eventType);
    } else if ([
      LogicalKeyboardKey.backspace,
      LogicalKeyboardKey.minus,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyQ,
    ].contains(keyEvent.logicalKey)) {
      var eventType = CustomInputWatcherEvents.onSecondary;
      switch (keyEvent.runtimeType) {
        case KeyDownEvent:
          eventType = CustomInputWatcherEvents.onSecondary;
          break;
        case KeyUpEvent:
          eventType = CustomInputWatcherEvents.onSecondaryUp;

          break;
        case KeyRepeatEvent:
          eventType = CustomInputWatcherEvents.onSecondaryHold;

          break;
        default:
      }
      sendStreamEvent(currentlyHoveredWidget, eventType);
    }

    if (keyEvent is KeyUpEvent) {
      return;
    }

    if ([
      LogicalKeyboardKey.keyW,
      LogicalKeyboardKey.arrowUp,
    ].contains(keyEvent.logicalKey)) {
      changeHoveredState(AxisDirection.up);
    } else if ([
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.arrowDown,
    ].contains(keyEvent.logicalKey)) {
      changeHoveredState(AxisDirection.down);
    } else if ([
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.arrowLeft,
    ].contains(keyEvent.logicalKey)) {
      changeHoveredState(AxisDirection.left);
    } else if ([
      LogicalKeyboardKey.keyD,
      LogicalKeyboardKey.arrowRight,
    ].contains(keyEvent.logicalKey)) {
      changeHoveredState(AxisDirection.right);
    }
  }

  void onPrimary() {
    sendStreamEvent(currentlyHoveredWidget, CustomInputWatcherEvents.onPrimary);
  }

  void onPrimaryHold() {
    sendStreamEvent(
      currentlyHoveredWidget,
      CustomInputWatcherEvents.onPrimaryHold,
    );
  }

  void onPrimaryUp() {
    sendStreamEvent(
      currentlyHoveredWidget,
      CustomInputWatcherEvents.onPrimaryUp,
    );
  }

  void onSecondary() {
    sendStreamEvent(
      currentlyHoveredWidget,
      CustomInputWatcherEvents.onSecondary,
    );
  }

  void onSecondaryHold() {
    sendStreamEvent(
      currentlyHoveredWidget,
      CustomInputWatcherEvents.onSecondaryHold,
    );
  }

  void onSecondaryUp() {
    sendStreamEvent(
      currentlyHoveredWidget,
      CustomInputWatcherEvents.onSecondaryUp,
    );
  }

  void registerScrollController(
    State<CustomInputWatcher> customInputWatcher,
    ScrollController scrollController,
  ) {
    final addListener =
        _customInputWatcherScrollControllers[scrollController] == null;

    _customInputWatcherScrollControllers[scrollController] ??= [];
    _customInputWatcherScrollControllers[scrollController]
        ?.add(customInputWatcher);
    if (addListener) {
      scrollController.addListener(
        () => updateCustomInputWatcherRectanglesFromScrollController(
          scrollController,
        ),
      );
    }
  }

  void removeCustomInputWatcher(State<CustomInputWatcher> customInputWatcher) {
    _customInputWatcherStreams[customInputWatcher]?.close();
    _customInputWatcherStreams.remove(customInputWatcher);
    _customInputWatcherRectangles.remove(customInputWatcher);
    _customInputWatcherRows[customInputWatcher.widget.zIndex]
            ?[customInputWatcher.widget.rowId]
        ?.remove(customInputWatcher);

    if (_customInputWatcherRows[customInputWatcher.widget.zIndex]
                ?[customInputWatcher.widget.rowId]
            ?.isEmpty ??
        true) {
      _customInputWatcherRows[customInputWatcher.widget.zIndex]
          ?.remove(customInputWatcher.widget.rowId);
    }

    if (_customInputWatcherRows[customInputWatcher.widget.zIndex]?.isEmpty ??
        true) {
      _customInputWatcherRows.remove(customInputWatcher.widget.zIndex);
    }

    if (customInputWatcher.widget.scrollController != null) {
      removeScrollController(customInputWatcher);
    }

    if (customInputWatcher == currentlyHoveredWidget) {
      removeHoveredState();
    }
  }

  void removeHoverOverlay() {
    hoverOverlayWidget?.$2.close();
    hoverOverlayWidget?.$3.close();
    hoverOverlayWidget = null;
  }

  void removeHoveredState() {
    sendStreamEvent(currentlyHoveredWidget, CustomInputWatcherEvents.hoverOff);
    updateOverlayHoverWidget(null, Offset.zero);
    currentlyHoveredWidget = null;
  }

  void removeScrollController(State<CustomInputWatcher> customInputWatcher) {
    customInputWatcher.widget.scrollController?.removeListener(
      () => updateCustomInputWatcherRectanglesFromScrollController(
        customInputWatcher.widget.scrollController!,
      ),
    );

    _customInputWatcherScrollControllers[
            customInputWatcher.widget.scrollController]
        ?.remove(customInputWatcher);
    if (_customInputWatcherScrollControllers[
                customInputWatcher.widget.scrollController]
            ?.isEmpty ??
        true) {
      _customInputWatcherScrollControllers
          .remove(customInputWatcher.widget.scrollController);
    }
  }

  void sendStreamEvent(
    State<CustomInputWatcher>? customInputWatcher,
    CustomInputWatcherEvents event,
  ) {
    _customInputWatcherStreams[customInputWatcher]?.add(event);

    hoverOverlayWidget?.$2.add(event);
  }

  void setHoveredState(State<CustomInputWatcher> widget) {
    removeHoveredState();

    sendStreamEvent(widget, CustomInputWatcherEvents.hoverOn);

    if (widget.widget.hoverWidget != null) {
      updateOverlayHoverWidget(
        widget.widget.hoverWidget,
        _customInputWatcherRectangles[widget]?.center ?? Offset.zero,
      );
    }

    currentlyHoveredWidget = widget;
  }

  void shiftPositionInRow(
    AxisDirection directionOfInput,
    int currentRowId,
    int highestZIndex,
  ) {
    final listOfCurrentRowStates = _customInputWatcherRows[highestZIndex]![
            currentRowId]!
        //     .where((element) {
        //   return
        //       // element.widget.scrollController !=
        //       //         currentlyHoveredWidget!.widget.scrollController ||
        //       element.widget.scrollController == null;
        // })
        .toList();

    if (listOfCurrentRowStates.isEmpty) {
      swapRows(directionOfInput, currentRowId, highestZIndex);
      return;
    }

    final currentHoveredWidgetIndex =
        listOfCurrentRowStates.indexOf(currentlyHoveredWidget!);

    var nextHoveredWidgetIndex = directionOfInput == AxisDirection.up ||
            directionOfInput == AxisDirection.left
        ? currentHoveredWidgetIndex - 1
        : currentHoveredWidgetIndex + 1;
    nextHoveredWidgetIndex =
        nextHoveredWidgetIndex.clamp(0, listOfCurrentRowStates.length - 1);
    State<CustomInputWatcher> nextHoveredWidget;

    if (nextHoveredWidgetIndex != currentHoveredWidgetIndex) {
      nextHoveredWidget =
          listOfCurrentRowStates.elementAt(nextHoveredWidgetIndex);
    } else {
      swapRows(directionOfInput, currentRowId, highestZIndex);
      return;
    }
    setHoveredState(nextHoveredWidget);
  }

  void sortRowStates(Map<int, List<State<CustomInputWatcher>>> rowIdMap) {
    for (final element in rowIdMap.entries) {
      element.value.sort((a, b) {
        return (_customInputWatcherRectangles[a]?.center.dx ?? 0)
            .compareTo(_customInputWatcherRectangles[b]?.center.dx ?? 0);
      });
    }
  }

  void swapRows(AxisDirection direction, int currentRowId, int highestZIndex) {
    final listOfAllIds = _customInputWatcherRows[highestZIndex]!.keys.toList()
      ..sort();

    final indexOfCurrentGroupId = listOfAllIds.indexOf(currentRowId);
    var indexOfNextGroupId =
        direction == AxisDirection.up || direction == AxisDirection.left
            ? indexOfCurrentGroupId - 1
            : indexOfCurrentGroupId + 1;

    if (indexOfNextGroupId < 0) {
      indexOfNextGroupId = listOfAllIds.length - 1;
    } else if (indexOfNextGroupId >= listOfAllIds.length) {
      indexOfNextGroupId = 0;
    }

    final nextRowId = listOfAllIds[indexOfNextGroupId];
    if (nextRowId == currentRowId) {
      return;
    }
    var closestDistance = double.maxFinite;
    State<CustomInputWatcher>? closestWidget;
    final goalCenter = _customInputWatcherRectangles[currentlyHoveredWidget!]
            ?.center
            .toVector2() ??
        Vector2.zero();

    for (final element in _customInputWatcherRows[highestZIndex]![nextRowId]!) {
      final rect = _customInputWatcherRectangles[element];
      if (rect == null) {
        continue;
      }

      final distance = rect.center.toVector2().distanceTo(goalCenter);
      if (distance < closestDistance) {
        closestDistance = distance;
        closestWidget = element;
      }
    }

    if (closestWidget != null) {
      setHoveredState(closestWidget);
    } else {
      removeHoveredState();
    }
  }

  void updateCustomInputWatcher(State<CustomInputWatcher> customInputWatcher) {
    // if (!_customInputWatcherStreams.containsKey(customInputWatcher)) return;
    final box = customInputWatcher.context.findRenderObject() as RenderBox?;
    if (box == null) {
      return;
    }
    final position = box.localToGlobal(Offset.zero);
    final size = box.size;
    _customInputWatcherRectangles[customInputWatcher] =
        Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
  }

  void updateCustomInputWatcherRectangles() {
    for (final element in _customInputWatcherStreams.entries) {
      sendStreamEvent(
        element.key,
        CustomInputWatcherEvents.updateOnPostFrameCallback,
      );
    }
  }

  void updateCustomInputWatcherRectanglesFromScrollController(
    ScrollController scrollController,
  ) {
    for (final element
        in _customInputWatcherScrollControllers[scrollController] ?? []) {
      sendStreamEvent(
        element as State<CustomInputWatcher>,
        CustomInputWatcherEvents.updateOnPostFrameCallback,
      );
    }
  }

  void updateOverlayHoverWidget(Widget? widget, Offset? position) {
    if (widget == null || position == null) {
      hoverOverlayWidget?.$3.add(null);
    } else {
      hoverOverlayWidget?.$3.add((position, widget));
    }
  }

  bool _checkIfStateHovered(State<CustomInputWatcher> widget) {
    if (
        //there is a widget currently being hovered
        currentlyHoveredWidget != null &&
            //the widget being checked is not the currently hovered widget
            currentlyHoveredWidget != widget &&
            //the widget being checked is not in the same group as the currently hovered widget
            widget.widget.zHeight <= currentlyHoveredWidget!.widget.zHeight) {
      return false;
    }
    final rect = _customInputWatcherRectangles[widget];
    if (rect == null) {
      return false;
    }
    final mousePosition = parentInputManager.latestPointerPosition ??
        parentInputManager.pointerLocalPositions.values.firstOrNull ??
        Offset.zero;
    final contains = rect.contains(mousePosition);

    if (!contains && currentlyHoveredWidget == null) {
      return false;
    }
    if (contains && currentlyHoveredWidget == widget) {
      return false;
    }

    if (!contains && currentlyHoveredWidget != widget) {
      return false;
    }

    if (contains) {
      setHoveredState(widget);
    } else {
      removeHoveredState();
    }
    return contains;
  }
}

class CustomInputWatcher extends StatefulWidget {
  ///Add a globalkey to [hoverWidget] to enable the prevention of window clipping
  ///aka prevent the content from going outside the window
  const CustomInputWatcher({
    required this.child,
    this.onHover,
    this.onPrimary,
    this.onPrimaryHold,
    this.onPrimaryUp,
    this.scrollController,
    this.rowId = 0,
    this.hoverWidget,
    this.zHeight = 0,
    this.zIndex = 0,
    this.onSecondary,
    this.onSecondaryHold,
    this.onSecondaryUp,
    super.key,
  });

  final Function(bool isHover)? onHover;
  final Function()? onPrimary;
  final Function()? onPrimaryHold;
  final Function()? onPrimaryUp;
  final Function()? onSecondary;
  final Function()? onSecondaryHold;
  final Function()? onSecondaryUp;
  final Widget child;
  final Widget? hoverWidget;
  final int rowId;
  final ScrollController? scrollController;
  final int zHeight;
  final int zIndex;

  @override
  State<CustomInputWatcher> createState() => CustomInputWatcherState();
}

class CustomInputWatcherState<T extends CustomInputWatcher> extends State<T> {
  late final GameState gameState = GameState();
  late final InputManager inputManager;
  late final StreamSubscription<CustomInputWatcherEvents> streamSubscription;

  void handleStreamEvents(CustomInputWatcherEvents event) {
    switch (event) {
      case CustomInputWatcherEvents.hoverOff:
        widget.onHover?.call(false);
        break;
      case CustomInputWatcherEvents.hoverOn:
        widget.onHover?.call(true);
        break;
      case CustomInputWatcherEvents.onPrimary:
        widget.onPrimary?.call();

        break;
      case CustomInputWatcherEvents.onPrimaryHold:
        widget.onPrimaryHold?.call();
        break;
      case CustomInputWatcherEvents.onPrimaryUp:
        widget.onPrimaryUp?.call();
        break;
      case CustomInputWatcherEvents.onSecondary:
        widget.onSecondary?.call();
        break;
      case CustomInputWatcherEvents.onSecondaryHold:
        widget.onSecondaryHold?.call();
        break;
      case CustomInputWatcherEvents.onSecondaryUp:
        widget.onSecondaryUp?.call();
        break;
      case CustomInputWatcherEvents.updateOnPostFrameCallback:
        updateCustomInputWatcher();
        break;
    }
  }

  void updateCustomInputWatcher() {
    Future.delayed(Duration.zero, () {
      if (!mounted) {
        return;
      }
      inputManager.customInputWatcherManager.updateCustomInputWatcher(this);
    });
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    inputManager.customInputWatcherManager.removeCustomInputWatcher(this);

    super.dispose();
  }

  @override
  void initState() {
    inputManager = InputManager();
    streamSubscription = inputManager.customInputWatcherManager
        .addCustomInputWatcher(this)
        .stream
        .listen(handleStreamEvents);

    updateCustomInputWatcher();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    updateCustomInputWatcher();
    return widget.child;
  }
}
