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
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:gamepads/gamepads.dart';
// import 'package:gamepads/gamepads.dart';
import 'package:runefire/game/background.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:runefire/main.dart';
import 'package:runefire/menus/menus.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/constants/sprite_animations.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/resources/data_classes/system_data.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
// import 'package:win32_gamepad/win32_gamepad.dart';
import 'game/menu_game.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'menus/overlays.dart';
import 'resources/constants/routes.dart' as routes;
import '../menus/overlays.dart' as overlay;
import 'package:win32_gamepad/win32_gamepad.dart';

typedef GameActionEvent = ({
  GameAction gameAction,
  bool isDownEvent,
});

typedef GameActionCallback = Function(
    GameActionEvent gameAction, List<GameAction> activeGameActions);

enum MovementType { mouse, tap1, tap2 }

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

class InputManager with WindowListener {
  //Const duration for the primary and secondary hold tick rate
  static const Duration incrementDuration = Duration(milliseconds: 50);

  //singleton goodies
  factory InputManager() {
    return _instance;
  }

  InputManager._internal() {
    windowManager.addListener(this);
  }

  final gamepad = Gamepad(0); // primary controller

  late final CustomInputWatcherManager customInputWatcherManager;

  //Keyboard
  List<Function(KeyEvent event)> keyEventList = [];
  // Keyboard
  List<Function(GamepadState event)> gamepadEventList = [];
  Map<GamepadButtons, bool> eventsProcessed = {};

  bool checkSimpleButton(bool state, GamepadButtons buttonToCheck) {
    if (eventsProcessed[buttonToCheck] ?? false) return false;

    if (gamepadEvents.containsKey(buttonToCheck)) {
      if (!state) {
        gamepadEvents.remove(buttonToCheck);
        createEvent = true;
        isPressed = false;
        button = buttonToCheck;
        return true;
      }
    } else if (state) {
      createEvent = true;
      isPressed = true;
      button = buttonToCheck;
      return true;
    }
    return false;
  }

  bool checkAnalogStick(int x, int y, GamepadButtons stickToCheck) {
    if (eventsProcessed[stickToCheck] ?? false) return false;
    final capabilities = GamepadCapabilities(0);
    int deadzone;
    if (stickToCheck == GamepadButtons.leftJoy) {
      deadzone = capabilities.leftThumbDeadzone;
    } else {
      deadzone = capabilities.rightThumbDeadzone;
    }
    bool isInDeadZone = x.abs() < deadzone && y.abs() < deadzone;

    if (gamepadEvents.containsKey(stickToCheck) && isInDeadZone) {
      gamepadEvents.remove(stickToCheck);
      createEvent = true;
      xyValue.setZero();
      isPressed = false;
      button = stickToCheck;
      return true;
    } else if (!isInDeadZone) {
      final double xClamped = (x / 32777).clamp(-1, 1);
      final double yClamped = (y / 32777).clamp(-1, 1);
      createEvent = true;
      xyValue.setValues(xClamped, yClamped);
      isPressed = true;
      button = stickToCheck;
      return true;
    }
    return false;
  }

  bool checkTrigger(int value, GamepadButtons triggerToCheck) {
    if (eventsProcessed[triggerToCheck] ?? false) return false;
    final capabilities = GamepadCapabilities(0);

    bool isInDeadZone = value < capabilities.triggerThreshold;

    if (gamepadEvents.containsKey(triggerToCheck) && isInDeadZone) {
      gamepadEvents.remove(triggerToCheck);
      createEvent = true;
      singleValue = 0;
      isPressed = false;
      button = triggerToCheck;
      return true;
    } else if (!isInDeadZone) {
      final double valueClamped = (value / 255).clamp(0, 1);
      createEvent = true;
      singleValue = valueClamped;
      isPressed = true;
      button = triggerToCheck;
      return true;
    }
    return false;
  }

  ///
  Map<GamepadButtons, GamepadEvent> gamepadEvents = {};
  Vector2 xyValue = Vector2.zero();
  double singleValue = 0;
  bool shouldWaitForNextEvent = false;
  bool createEvent = false;
  late GamepadButtons button;
  late bool isPressed;
  void parseGameState() {
    GamepadState event = gamepad.state;
    createEvent = false;
    xyValue.setZero();
    singleValue = 0;

    try {
      if (checkSimpleButton(event.dpadUp, GamepadButtons.dpadUp) ||
          checkSimpleButton(event.dpadDown, GamepadButtons.dpadDown) ||
          checkSimpleButton(event.dpadLeft, GamepadButtons.dpadLeft) ||
          checkSimpleButton(event.dpadRight, GamepadButtons.dpadRight) ||
          checkSimpleButton(event.buttonA, GamepadButtons.buttonA) ||
          checkSimpleButton(event.buttonB, GamepadButtons.buttonB) ||
          checkSimpleButton(event.buttonX, GamepadButtons.buttonX) ||
          checkSimpleButton(event.buttonY, GamepadButtons.buttonY) ||
          checkSimpleButton(event.leftShoulder, GamepadButtons.leftShoulder) ||
          checkSimpleButton(
              event.rightShoulder, GamepadButtons.rightShoulder) ||
          checkSimpleButton(event.leftThumb, GamepadButtons.leftThumb) ||
          checkSimpleButton(event.rightThumb, GamepadButtons.rightThumb) ||
          checkSimpleButton(event.buttonStart, GamepadButtons.buttonStart) ||
          checkSimpleButton(event.buttonBack, GamepadButtons.buttonBack) ||
          checkAnalogStick(event.leftThumbstickX, event.leftThumbstickY,
              GamepadButtons.leftJoy) ||
          checkAnalogStick(event.rightThumbstickX, event.rightThumbstickY,
              GamepadButtons.rightJoy) ||
          checkTrigger(event.leftTrigger, GamepadButtons.leftTrigger) ||
          checkTrigger(event.rightTrigger, GamepadButtons.rightTrigger)) {
        return;
      }

// checkSimpleButton(event.leftTrigger, GamepadButtons.leftTrigger);
// checkSimpleButton(event.rightTrigger, GamepadButtons.rightTrigger );
    } finally {
      if (createEvent) {
        final GamepadEvent gamepadEvent =
            GamepadEvent(button, xyValue, singleValue, isPressed);
        if (gamepadEvent.isPressed) {
          gamepadEvents[button] = gamepadEvent;
        }
        eventsProcessed[button] = true;
        onGamepadEvent(gamepadEvent);
        parseGameState();
      }
    }
  }

  void onGamepadEvent(GamepadEvent event) {
    print(event);
    // for (var element in gamepadEventList) {
    //   element.call(event);
    // }

    // bool isDownEvent = event.type == KeyType.button
    //     ? event.value == 1.0
    //     : (event.value / 32777).clamp(0, 1.0) > .75;

    // externalInputType = ExternalInputType.gamepad;
    // final mappedActions = _systemDataReference.gamePadMappings.entries
    //     .where((element) => element.value.any(event.key));
    // for (var element in mappedActions) {
    //   onGameActionCall((gameAction: element.key, isDownEvent: isDownEvent));
    // }

    // final constantMappedActions = _systemDataReference
    //     .constantGamePadMappings.entries
    //     .where((element) => element.value == (event.key));
    // for (var element in constantMappedActions) {
    //   onGameActionCall((gameAction: element.key, isDownEvent: isDownEvent));
    // }
  }

  List<Function(PointerDownEvent event)> pointerDownList = [];

  // Callbacks for pointer moving
  List<Function(MovementType type, PointerMoveEvent event)> onPointerMoveList =
      [];

  //Window events (windows only I think)
  List<Function(String windowEvent)> onWindowEventList = [];

  //Currently active game actions, passed into game callbacks
  List<GameAction> activeGameActions = [];

  //for secondary pointer if using mobile
  Set<int> activePointers = {};

  //for icons
  ExternalInputType externalInputType = ExternalInputType.touch;

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

  //singleton
  static final InputManager _instance = InputManager._internal();

  late final GameRouter _gameRouterReference;
  late final SystemData _systemDataReference;

  //callbacks
  final Map<GameAction, List<GameActionCallback>> _onGameActionMap = {};

  //Game components use this to add new callbacks
  void addGameActionListener(
      GameAction gameAction, GameActionCallback callback) {
    _onGameActionMap[gameAction] ??= [];
    _onGameActionMap[gameAction]!.add(callback);
  }

  //custom hold ticks for primary and secondary clicks
  void beginHoldCall(
    bool isPrimary,
  ) {
    if (isPrimaryTimerActive != null) return;
    isPrimaryTimerActive ??= isPrimary;

    Future.delayed(.5.seconds).then((value) {
      if (isPrimaryTimerActive == null) return;
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

  bool keyboardEventHandler(KeyEvent keyEvent) {
    for (var element in keyEventList) {
      element.call(keyEvent);
    }

    customInputWatcherManager.handleWidgetKeyboardInput(keyEvent);

    if (keyEvent is KeyRepeatEvent) return false;

    externalInputType = ExternalInputType.keyboard;
    final mappedActions = _systemDataReference.keyboardMappings.entries
        .where((element) => element.value.any(keyEvent.physicalKey));
    for (var element in mappedActions) {
      onGameActionCall(
          (gameAction: element.key, isDownEvent: keyEvent is KeyDownEvent));
    }

    final permanentMappedActions = _systemDataReference
        .constantKeyboardMappings.entries
        .where((element) => element.value.contains(keyEvent.physicalKey));
    for (var element in permanentMappedActions) {
      onGameActionCall(
          (gameAction: element.key, isDownEvent: keyEvent is KeyDownEvent));
    }

    return !(permanentMappedActions.isEmpty && mappedActions.isEmpty);
  }

  void onGameActionCall(GameActionEvent event) {
    if (_gameRouterReference.paused) return;
    if (event.isDownEvent) {
      activeGameActions.add(event.gameAction);
    } else {
      activeGameActions.remove(event.gameAction);
    }
    for (GameActionCallback element
        in _onGameActionMap[event.gameAction] ?? []) {
      element.call(event, activeGameActions);
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
    for (var element in pointerDownList) {
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
    onPointerMove(PointerMoveEvent(
      buttons: event.buttons,
      delta: event.delta,
      device: event.device,
      kind: event.kind,
      position: event.position,
    ));
  }

  void onPointerMove(PointerMoveEvent info) {
    bool isMouse = info.kind == PointerDeviceKind.mouse;
    bool isSecondary = activePointers.isNotEmpty;
    MovementType type = isMouse
        ? MovementType.mouse
        : isSecondary
            ? MovementType.tap2
            : MovementType.tap1;

    pointerLocalPositions[info.pointer] = info.localPosition;
    for (var element in onPointerMoveList) {
      element.call(type, info);
    }
    customInputWatcherManager.onPointerMove();
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
    onGameActionCall((gameAction: GameAction.primary, isDownEvent: false));

    customInputWatcherManager.onPrimaryUp();
  }

  void onPrimaryDownCall(PointerDownEvent info) {
    onGameActionCall((gameAction: GameAction.primary, isDownEvent: true));
    customInputWatcherManager.onPrimary();

    beginHoldCall(true);
  }

  void onPrimaryUpCall(PointerUpEvent info) {
    onGameActionCall((gameAction: GameAction.primary, isDownEvent: false));
    stopHoldCall(true);
    customInputWatcherManager.onPrimaryUp();
  }

  void onSecondaryCancelCall(PointerCancelEvent info) {
    // for (var element in onSecondaryCancel) {
    //   element.call(info);
    onGameActionCall((gameAction: GameAction.secondary, isDownEvent: false));
    customInputWatcherManager.onSecondaryUp();

    stopHoldCall(false);
  }

  void onSecondaryDownCall(PointerDownEvent info) {
    // for (var element in onSecondaryDown) {
    onGameActionCall((gameAction: GameAction.secondary, isDownEvent: true));
    //   element.call(info);
    beginHoldCall(false);
    customInputWatcherManager.onSecondary();

    // }
  }

  void onSecondaryUpCall(PointerUpEvent info) {
    // for (var element in onSecondaryUp) {
    //   element.call(info);
    onGameActionCall((gameAction: GameAction.secondary, isDownEvent: false));
    customInputWatcherManager.onSecondaryUp();
    stopHoldCall(false);
    // }
  }

  void removeGameActionListener(
      GameAction gameAction, GameActionCallback callback) {
    _onGameActionMap[gameAction]?.remove(callback);
  }

  void setInitReferences(GameRouter gameRouter) {
    _gameRouterReference = gameRouter;

    _systemDataReference = _gameRouterReference.systemDataComponent.dataObject;
    customInputWatcherManager =
        CustomInputWatcherManager(this, _systemDataReference);
  }

  void stopHoldCall(bool? isPrimary) {
    if (isPrimaryTimerActive != isPrimary && isPrimary != null) return;
    isPrimaryTimerActive = null;
    holdCallTimer?.cancel();
    holdCallTimer = null;
  }

  @override
  void onWindowEvent(String eventName) {
    for (var element in onWindowEventList) {
      element.call(eventName);
    }

    super.onWindowEvent(eventName);
  }
}

enum ExternalInputType { touch, keyboard, gamepad }
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
      this.parentInputManager, this._systemDataReference) {
    parentInputManager.onWindowEventList
        .add((windowEvent) => updateCustomInputWatcherRectangles());
  }

  final InputManager parentInputManager;

  //only one active widget at a time
  State<CustomInputWatcher>? currentlyHoveredWidget;

  late final SystemData _systemDataReference;

  //Grouping all the widgets by their group id, allows for sorting by axis
  final Map<int, Map<int, List<State<CustomInputWatcher>>>>
      _customInputWatcherRows = {};

  //to check if pointer is inside widgets, custom hover implementation
  final Map<State<CustomInputWatcher>, Rect> _customInputWatcherRectangles = {};

  //If there are buttons in a scroll widget,
  //save the scrollcontroller to modify it when we scroll/use keyboard
  final Map<ScrollController, List<State<CustomInputWatcher>>>
      _customInputWatcherScrollControllers = {};

  //Currently active streams
  final Map<State<CustomInputWatcher>,
          StreamController<CustomInputWatcherEvents>>
      _customInputWatcherStreams = {};

  //add a new widget to the input manager
  StreamController<CustomInputWatcherEvents> addCustomInputWatcher(
      State<CustomInputWatcher> customInputWatcher) {
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
          customInputWatcher, customInputWatcher.widget.scrollController!);
    }

    return eventController;
  }

  void swapRows(AxisDirection direction, int currentRowId, int highestZIndex) {
    final listOfAllIds = _customInputWatcherRows[highestZIndex]!.keys.toList()
      ..sort();

    final indexOfCurrentGroupId = listOfAllIds.indexOf(currentRowId);
    int indexOfNextGroupId =
        direction == AxisDirection.up || direction == AxisDirection.left
            ? indexOfCurrentGroupId - 1
            : indexOfCurrentGroupId + 1;

    if (indexOfNextGroupId < 0) {
      indexOfNextGroupId = listOfAllIds.length - 1;
    } else if (indexOfNextGroupId >= listOfAllIds.length) {
      indexOfNextGroupId = 0;
    }

    final nextRowId = listOfAllIds[indexOfNextGroupId];
    if (nextRowId == currentRowId) return;
    double closestDistance = (double.maxFinite);
    State<CustomInputWatcher>? closestWidget;
    Vector2 goalCenter = _customInputWatcherRectangles[currentlyHoveredWidget!]
            ?.center
            .toVector2() ??
        Vector2.zero();

    for (var element in _customInputWatcherRows[highestZIndex]![nextRowId]!) {
      final rect = _customInputWatcherRectangles[element];
      if (rect == null) continue;

      final double distance = rect.center.toVector2().distanceTo(goalCenter);
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

  void shiftPositionInRow(
      AxisDirection directionOfInput, int currentRowId, int highestZIndex) {
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

    int nextHoveredWidgetIndex = directionOfInput == AxisDirection.up ||
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

  //Function that both keyboard and gamepad will call to move the currently hovered widget
  void changeHoveredState(AxisDirection directionOfInput) {
    final int highestZIndex = _customInputWatcherRows.keys.reduce(max);

    if (currentlyHoveredWidget == null) {
      final entries = _customInputWatcherRectangles.entries
          .where((element) => element.key.widget.zIndex == highestZIndex);
      double initValue;
      switch (directionOfInput) {
        case AxisDirection.up:
          initValue = 0;
          for (var element in entries) {
            if (element.value.bottom > initValue) {
              initValue = element.value.bottom;
              setHoveredState(element.key);
            }
          }

          break;
        case AxisDirection.right:
          initValue = double.infinity;
          for (var element in entries) {
            if (element.value.left < initValue) {
              initValue = element.value.left;
              setHoveredState(element.key);
            }
          }

          break;
        case AxisDirection.down:
          initValue = double.infinity;
          for (var element in entries) {
            if (element.value.top < initValue) {
              initValue = element.value.top;
              setHoveredState(element.key);
            }
          }

          break;
        case AxisDirection.left:
          initValue = 0;
          for (var element in entries) {
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

    bool isSwappingRows = (directionOfInput == AxisDirection.up ||
        directionOfInput == AxisDirection.down);

    bool isHoveringScrollWidget =
        currentlyHoveredWidget!.widget.scrollController != null;

    //If the direction of the axisinput (up down left right) is against the axis of the
    //currently hovered widget, then we are swapping groups
    if (isSwappingRows && !isHoveringScrollWidget) {
      swapRows(directionOfInput, currentRowId, highestZIndex);
      return;
    } else if (isHoveringScrollWidget) {
      Axis axis =
          currentlyHoveredWidget!.widget.scrollController!.position.axis;

      if (axis == Axis.vertical && !isSwappingRows) {
        shiftPositionInRow(directionOfInput, currentRowId, highestZIndex);
        return;
      } else if (axis == Axis.horizontal && isSwappingRows) {
        swapRows(directionOfInput, currentRowId, highestZIndex);
        return;
      }

      //If the group we are moving in is inside a scroll widget
      //we need to take that into account
      final scrollControllerChildren = _customInputWatcherScrollControllers[
          currentlyHoveredWidget!.widget.scrollController];

      if (scrollControllerChildren != null &&
          scrollControllerChildren.isNotEmpty) {
        int currentIndex =
            scrollControllerChildren.indexOf(currentlyHoveredWidget!);
        int nextIndex = currentIndex +
            ((directionOfInput == AxisDirection.up ||
                    directionOfInput == AxisDirection.left)
                ? -1
                : 1);

        bool isEndOfScrollController =
            nextIndex < 0 || nextIndex >= scrollControllerChildren.length;
        if (isEndOfScrollController) {
          if (isSwappingRows) {
            swapRows(directionOfInput, currentRowId, highestZIndex);
            // setHoveredState(scrollControllerChildren[nextIndex]);
            return;
          } else {
            shiftPositionInRow(directionOfInput, currentRowId, highestZIndex);
            return;
          }
        }
        setHoveredState(scrollControllerChildren[nextIndex]);

        // Axis  scrollAxis = currentlyHoveredWidget!.widget.scrollController!
        //     .position.axis;

        // if(scrollAxis == Axis.vertical &&
        // directionOfInput == AxisDirection.up || directionOfInput == AxisDirection.down){
        //   final nextHoveredWidget =
        //   shiftPositionInRow(directionOfInput, currentRowId, highestZIndex);

        // }
        // final heightOfItem = (nextHoveredWidget
        //             .widget.scrollController?.position.maxScrollExtent ??
        //         0) /
        //     scrollControllerChildren.length;

        // bool isNextIndexAfterCurrentIndex =
        //     nextHoveredWidgetIndex >= currentIndex;

        // nextHoveredWidget.widget.scrollController?.animateTo(
        //     heightOfItem * nextHoveredWidgetIndex * 1.5,
        //     duration: .5.seconds,
        //     curve: Curves.ease);
      }
    } else {
      sortRowStates(_customInputWatcherRows[highestZIndex]!);

      shiftPositionInRow(directionOfInput, currentRowId, highestZIndex);
    }
  }

  bool checkMouseHoverStates(State<CustomInputWatcher> widget) {
    if (
        //there is a widget currently being hovered
        currentlyHoveredWidget != null &&
            //the widget being checked is not the currently hovered widget
            currentlyHoveredWidget != widget &&
            //the widget being checked is not in the same group as the currently hovered widget
            widget.widget.zHeight <= currentlyHoveredWidget!.widget.zHeight) {
      return false;
    }
    final Rect? rect = _customInputWatcherRectangles[widget];
    if (rect == null) return false;
    final Offset mousePosition =
        parentInputManager.pointerLocalPositions[0] ?? Offset.zero;
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

  void handleWidgetKeyboardInput(KeyEvent keyEvent) {
    if (_customInputWatcherStreams.isEmpty) return;
    if ([
      PhysicalKeyboardKey.space,
      PhysicalKeyboardKey.enter,
      PhysicalKeyboardKey.equal,
      PhysicalKeyboardKey.keyE,
    ].contains(keyEvent.physicalKey)) {
      CustomInputWatcherEvents eventType = CustomInputWatcherEvents.onPrimary;
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
      PhysicalKeyboardKey.backspace,
      PhysicalKeyboardKey.minus,
      PhysicalKeyboardKey.controlLeft,
      PhysicalKeyboardKey.keyQ,
    ].contains(keyEvent.physicalKey)) {
      CustomInputWatcherEvents eventType = CustomInputWatcherEvents.onSecondary;
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

    if (keyEvent is KeyUpEvent) return;

    if ([
      PhysicalKeyboardKey.keyW,
      PhysicalKeyboardKey.arrowUp,
    ].contains(keyEvent.physicalKey)) {
      changeHoveredState(AxisDirection.up);
    } else if ([
      PhysicalKeyboardKey.keyS,
      PhysicalKeyboardKey.arrowDown,
    ].contains(keyEvent.physicalKey)) {
      changeHoveredState(AxisDirection.down);
    } else if ([
      PhysicalKeyboardKey.keyA,
      PhysicalKeyboardKey.arrowLeft,
    ].contains(keyEvent.physicalKey)) {
      changeHoveredState(AxisDirection.left);
    } else if ([
      PhysicalKeyboardKey.keyD,
      PhysicalKeyboardKey.arrowRight,
    ].contains(keyEvent.physicalKey)) {
      changeHoveredState(AxisDirection.right);
    }
  }

  void onPointerMove() {
    for (var element in _customInputWatcherStreams.entries.where((element) =>
        element.key.widget.zIndex ==
        _customInputWatcherRows.keys.reduce(max))) {
      if (checkMouseHoverStates(element.key)) break;
    }
  }

  void onPrimary() {
    sendStreamEvent(currentlyHoveredWidget, CustomInputWatcherEvents.onPrimary);
  }

  void onPrimaryHold() {
    sendStreamEvent(
        currentlyHoveredWidget, CustomInputWatcherEvents.onPrimaryHold);
  }

  void onPrimaryUp() {
    sendStreamEvent(
        currentlyHoveredWidget, CustomInputWatcherEvents.onPrimaryUp);
  }

  void onSecondary() {
    sendStreamEvent(
        currentlyHoveredWidget, CustomInputWatcherEvents.onSecondary);
  }

  void onSecondaryHold() {
    sendStreamEvent(
        currentlyHoveredWidget, CustomInputWatcherEvents.onSecondaryHold);
  }

  void onSecondaryUp() {
    sendStreamEvent(
        currentlyHoveredWidget, CustomInputWatcherEvents.onSecondaryUp);
  }

  void registerScrollController(State<CustomInputWatcher> customInputWatcher,
      ScrollController scrollController) {
    bool addListener =
        _customInputWatcherScrollControllers[scrollController] == null;

    _customInputWatcherScrollControllers[scrollController] ??= [];
    _customInputWatcherScrollControllers[scrollController]
        ?.add(customInputWatcher);
    if (addListener) {
      scrollController.addListener(() =>
          updateCustomInputWatcherRectanglesFromScrollController(
              scrollController));
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

    if (customInputWatcher == currentlyHoveredWidget) removeHoveredState();
  }

  void removeHoveredState() {
    sendStreamEvent(currentlyHoveredWidget, CustomInputWatcherEvents.hoverOff);

    currentlyHoveredWidget = null;
  }

  void removeScrollController(State<CustomInputWatcher> customInputWatcher) {
    customInputWatcher.widget.scrollController?.removeListener(() =>
        updateCustomInputWatcherRectanglesFromScrollController(
            customInputWatcher.widget.scrollController!));

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

  void sendStreamEvent(State<CustomInputWatcher>? customInputWatcher,
      CustomInputWatcherEvents event) {
    _customInputWatcherStreams[customInputWatcher]?.add(event);
  }

  void setHoveredState(State<CustomInputWatcher> widget) {
    removeHoveredState();

    sendStreamEvent(widget, CustomInputWatcherEvents.hoverOn);

    currentlyHoveredWidget = widget;
  }

  void sortRowStates(Map<int, List<State<CustomInputWatcher>>> rowIdMap) {
    for (var element in rowIdMap.entries) {
      element.value.sort((a, b) {
        return (_customInputWatcherRectangles[a]?.center.dx ?? 0)
            .compareTo((_customInputWatcherRectangles[b]?.center.dx ?? 0));
      });
    }
  }

  void updateCustomInputWatcher(State<CustomInputWatcher> customInputWatcher) {
    // if (!_customInputWatcherStreams.containsKey(customInputWatcher)) return;
    RenderBox? box =
        customInputWatcher.context.findRenderObject() as RenderBox?;
    if (box == null) return;
    Offset position = box.localToGlobal(Offset.zero);
    Size size = box.size;
    _customInputWatcherRectangles[customInputWatcher] =
        Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
  }

  void updateCustomInputWatcherRectangles() {
    for (var element in _customInputWatcherStreams.entries) {
      sendStreamEvent(
          element.key, CustomInputWatcherEvents.updateOnPostFrameCallback);
    }
  }

  void updateCustomInputWatcherRectanglesFromScrollController(
      ScrollController scrollController) {
    for (State<CustomInputWatcher> element
        in _customInputWatcherScrollControllers[scrollController] ?? []) {
      sendStreamEvent(
          element, CustomInputWatcherEvents.updateOnPostFrameCallback);
    }
  }
}

class CustomInputWatcher extends StatefulWidget {
  const CustomInputWatcher(
      {this.onHover,
      required this.child,
      this.onPrimary,
      this.onPrimaryHold,
      this.onPrimaryUp,
      this.scrollController,
      this.rowId = 0,
      this.zHeight = 0,
      this.zIndex = 0,
      this.onSecondary,
      this.onSecondaryHold,
      this.onSecondaryUp,
      super.key});

  final Function(bool isHover)? onHover;
  final Function()? onPrimary;
  final Function()? onPrimaryHold;
  final Function()? onPrimaryUp;
  final Function()? onSecondary;
  final Function()? onSecondaryHold;
  final Function()? onSecondaryUp;
  final Widget child;
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
      if (!mounted) return;
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