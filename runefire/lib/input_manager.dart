import 'dart:async';
import 'dart:async' as ac;
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart' hide World;
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
// import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:gamepads/gamepads.dart';
import 'package:runefire/game/background.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:runefire/main.dart';
import 'package:runefire/menus/menus.dart';
import 'package:runefire/resources/assets/assets.dart';
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
  onSecondary,
  onSecondaryHold,
  onSecondaryUp,
}

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

  //Keyboard
  List<Function(KeyEvent)> keyEventList = [];

  // Callbacks for pointer moving
  List<Function(MovementType type, PointerMoveEvent event)> onPointerMoveList =
      [];

  //Currently active game actions, passed into game callbacks
  List<GameAction> activeGameActions = [];
  //for secondary pointer if using mobile
  Set<int> activePointers = {};
  //for icons
  ExternalInputType externalInputType = ExternalInputType.touch;
  //easy access to pointer locations
  Map<int, Offset> pointerLocalPositions = {};

  //only one active widget at a time
  State<CustomInputWatcher>? currentlyHoveredWidget;
  //tick rate faker for primary and secondary mouse/pointer holding
  ac.Timer? holdCallTimer;
  //if true then the holdcalltimer is for primary click, if false then for secondary
  //if null then not active
  bool? isPrimaryTimerActive;
  //You can only determine if a input click is a secondary click on the pointer down event
  //so we use this to determine what pointer is the secondary when the various "pointer down" etc functions are called
  int? secondaryPointerId;

  //singleton
  static final InputManager _instance = InputManager._internal();

  //Grouping all the widgets by their group id, allows for sorting by axis
  final Map<int, List<State<CustomInputWatcher>>> _customInputWatcherGroups =
      {};

  //If there are buttons in a scroll widget,
  //save the scrollcontroller to modify it when we scroll/use keyboard
  final Map<ScrollController, List<State<CustomInputWatcher>>>
      _customInputWatcherScrollControllers = {};

  late final GameRouter _gameRouterReference;
  //callbacks
  final Map<GameAction, List<GameActionCallback>> _onGameActionMap = {};
  late final SystemData _systemDataReference;

  //to check if pointer is inside widgets, custom hover implementation
  final Map<State<CustomInputWatcher>, Rect> _customInputWatcherRectangles = {};

  //Currently active streams
  final Map<State<CustomInputWatcher>,
          StreamController<CustomInputWatcherEvents>>
      _customInputWatcherStreams = {};

  //Window events (windows only I think)
  List<Function(String windowEvent)> onWindowEventList = [
    (_) => _instance.updateCustomInputWatcherRectangles()
  ];

  //add a new widget to the input manager
  StreamController<CustomInputWatcherEvents> addCustomInputWatcher(
      State<CustomInputWatcher> customInputWatcher) {
    final eventController = StreamController<CustomInputWatcherEvents>();
    _customInputWatcherStreams[customInputWatcher] = eventController;
    _customInputWatcherGroups[customInputWatcher.widget.groupId] ??= [];
    _customInputWatcherGroups[customInputWatcher.widget.groupId]
        ?.add(customInputWatcher);
    final newOrientation = customInputWatcher.widget.groupOrientation;

    //make sure groups are all the same orientation
    assert(_customInputWatcherGroups[customInputWatcher.widget.groupId]!.fold(
        true,
        (previousValue, element) =>
            previousValue &&
            element.widget.groupOrientation == newOrientation));

    // sort all the group lists when a new one is added, inneffecient but not needed to
    //optimize so its just easy :)
    sortGroupStates();

    //scroll controller
    if (customInputWatcher.widget.scrollController != null) {
      registerScrollController(
          customInputWatcher, customInputWatcher.widget.scrollController!);
    }

    return eventController;
  }

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
          _customInputWatcherStreams[currentlyHoveredWidget]
              ?.add(CustomInputWatcherEvents.onPrimaryHold);
        } else {
          _customInputWatcherStreams[currentlyHoveredWidget]
              ?.add(CustomInputWatcherEvents.onSecondaryHold);
        }
      });
    });
  }

  //Function that both keyboard and gamepad will call to move the currently hovered widget
  void changeHoveredState(AxisDirection directionOfInput) {
    if (currentlyHoveredWidget == null) {
      double initValue;
      switch (directionOfInput) {
        case AxisDirection.up:
          initValue = 0;
          for (var element in _customInputWatcherRectangles.entries) {
            if (element.value.bottom > initValue) {
              initValue = element.value.bottom;
              setHoveredState(element.key);
            }
          }

          break;
        case AxisDirection.right:
          initValue = double.infinity;
          for (var element in _customInputWatcherRectangles.entries) {
            if (element.value.left < initValue) {
              initValue = element.value.left;
              setHoveredState(element.key);
            }
          }

          break;
        case AxisDirection.down:
          initValue = double.infinity;
          for (var element in _customInputWatcherRectangles.entries) {
            if (element.value.top < initValue) {
              initValue = element.value.top;
              setHoveredState(element.key);
            }
          }

          break;
        case AxisDirection.left:
          initValue = 0;
          for (var element in _customInputWatcherRectangles.entries) {
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

    final axis = currentlyHoveredWidget!.widget.groupOrientation;
    final currentGroupId = currentlyHoveredWidget!.widget.groupId;

    bool isSwappingGroups = (axis == Axis.horizontal &&
            (directionOfInput == AxisDirection.up ||
                directionOfInput == AxisDirection.down)) ||
        (axis == Axis.vertical &&
            (directionOfInput == AxisDirection.left ||
                directionOfInput == AxisDirection.right));

    //If the direction of the axisinput (up down left right) is against the axis of the
    //currently hovered widget, then we are swapping groups
    if (isSwappingGroups) {
      final listOfAllIds = _customInputWatcherGroups.keys.toList()..sort();

      final indexOfCurrentGroupId = listOfAllIds.indexOf(currentGroupId);
      int indexOfNextGroupId = directionOfInput == AxisDirection.up ||
              directionOfInput == AxisDirection.left
          ? indexOfCurrentGroupId - 1
          : indexOfCurrentGroupId + 1;

      if (indexOfNextGroupId < 0) {
        indexOfNextGroupId = listOfAllIds.length - 1;
      } else if (indexOfNextGroupId >= listOfAllIds.length) {
        indexOfNextGroupId = 0;
      }

      final nextGroupId = listOfAllIds[indexOfNextGroupId];
      if (nextGroupId == currentGroupId) return;
      removeHoveredState();
      setHoveredState(_customInputWatcherGroups[nextGroupId]?.first ??
          currentlyHoveredWidget!);

      return;
    }

    final listOfCurrentGroupStates = _customInputWatcherGroups[currentGroupId]!;

    final currentHoveredWidgetIndex =
        listOfCurrentGroupStates.indexOf(currentlyHoveredWidget!);

    int nextHoveredWidgetIndex = directionOfInput == AxisDirection.up ||
            directionOfInput == AxisDirection.left
        ? currentHoveredWidgetIndex - 1
        : currentHoveredWidgetIndex + 1;
    nextHoveredWidgetIndex =
        nextHoveredWidgetIndex.clamp(0, listOfCurrentGroupStates.length - 1);
    final nextHoveredWidget =
        listOfCurrentGroupStates.elementAt(nextHoveredWidgetIndex);

    //If the group we are moving in is inside a scroll widget
    //we need to take that into account
    final scrollControllerChildren = _customInputWatcherScrollControllers[
        nextHoveredWidget.widget.scrollController];
    if (scrollControllerChildren != null &&
        scrollControllerChildren.isNotEmpty) {
      final currentIndex =
          scrollControllerChildren.indexOf(currentlyHoveredWidget!);

      final heightOfItem = (nextHoveredWidget
                  .widget.scrollController?.position.maxScrollExtent ??
              0) /
          scrollControllerChildren.length;

      bool isNextIndexAfterCurrentIndex =
          nextHoveredWidgetIndex >= currentIndex;
      print(heightOfItem);

      nextHoveredWidget.widget.scrollController?.animateTo(
          heightOfItem * 2 * nextHoveredWidgetIndex,
          duration: .5.seconds,
          curve: Curves.ease);
    }

    setHoveredState(nextHoveredWidget);
  }

  bool checkMouseHoverStates(State<CustomInputWatcher> widget) {
    if (
        //there is a widget currently being hovered
        currentlyHoveredWidget != null &&
            //the widget being checked is not the currently hovered widget
            currentlyHoveredWidget != widget &&
            //the widget being checked is not in the
            // same height as the currently hovered widget
            widget.widget.zIndex <= currentlyHoveredWidget!.widget.zIndex) {
      return false;
    }
    final Rect rect = _customInputWatcherRectangles[widget]!;
    final Offset mousePosition = pointerLocalPositions[0] ?? Offset.zero;
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
      _customInputWatcherStreams[currentlyHoveredWidget]?.add(eventType);
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
      _customInputWatcherStreams[currentlyHoveredWidget]?.add(eventType);
    }

    if (keyEvent is KeyUpEvent) return;

    if ([
          PhysicalKeyboardKey.keyW,
          PhysicalKeyboardKey.arrowUp,
        ].contains(keyEvent.physicalKey) ||
        _systemDataReference.keyboardMappings[keyEvent.physicalKey] ==
            GameAction.moveUp) {
      changeHoveredState(AxisDirection.up);
    } else if ([
          PhysicalKeyboardKey.keyS,
          PhysicalKeyboardKey.arrowDown,
        ].contains(keyEvent.physicalKey) ||
        _systemDataReference.keyboardMappings[keyEvent.physicalKey] ==
            GameAction.moveDown) {
      changeHoveredState(AxisDirection.down);
    } else if ([
          PhysicalKeyboardKey.keyA,
          PhysicalKeyboardKey.arrowLeft,
        ].contains(keyEvent.physicalKey) ||
        _systemDataReference.keyboardMappings[keyEvent.physicalKey] ==
            GameAction.moveLeft) {
      changeHoveredState(AxisDirection.left);
    } else if ([
          PhysicalKeyboardKey.keyD,
          PhysicalKeyboardKey.arrowRight,
        ].contains(keyEvent.physicalKey) ||
        _systemDataReference.keyboardMappings[keyEvent.physicalKey] ==
            GameAction.moveRight) {
      changeHoveredState(AxisDirection.right);
    }
  }

  bool keyboardEventHandler(KeyEvent keyEvent) {
    for (var element in keyEventList) {
      element.call(keyEvent);
    }
    if (_customInputWatcherStreams.isNotEmpty) {
      handleWidgetKeyboardInput(keyEvent);
    }
    if (keyEvent is KeyRepeatEvent) return false;

    externalInputType = ExternalInputType.keyboard;
    GameAction? mappedAction =
        _systemDataReference.keyboardMappings[keyEvent.physicalKey];
    if (mappedAction == null) return false;
    onGameActionCall(
        (gameAction: mappedAction, isDownEvent: keyEvent is KeyDownEvent));

    return true;
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

    for (var element in _customInputWatcherStreams.entries) {
      if (checkMouseHoverStates(element.key)) break;
    }
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
    _customInputWatcherStreams[currentlyHoveredWidget]
        ?.add(CustomInputWatcherEvents.onPrimaryUp);
  }

  void onPrimaryDownCall(PointerDownEvent info) {
    onGameActionCall((gameAction: GameAction.primary, isDownEvent: true));
    _customInputWatcherStreams[currentlyHoveredWidget]
        ?.add(CustomInputWatcherEvents.onPrimary);
    beginHoldCall(true);
  }

  void onPrimaryUpCall(PointerUpEvent info) {
    onGameActionCall((gameAction: GameAction.primary, isDownEvent: false));
    stopHoldCall(true);
    _customInputWatcherStreams[currentlyHoveredWidget]
        ?.add(CustomInputWatcherEvents.onPrimaryUp);
  }

  void onSecondaryCancelCall(PointerCancelEvent info) {
    // for (var element in onSecondaryCancel) {
    //   element.call(info);
    onGameActionCall((gameAction: GameAction.secondary, isDownEvent: false));
    _customInputWatcherStreams[currentlyHoveredWidget]
        ?.add(CustomInputWatcherEvents.onSecondaryUp); // }
    stopHoldCall(false);
  }

  void onSecondaryDownCall(PointerDownEvent info) {
    // for (var element in onSecondaryDown) {
    onGameActionCall((gameAction: GameAction.secondary, isDownEvent: true));
    //   element.call(info);
    beginHoldCall(false);
    _customInputWatcherStreams[currentlyHoveredWidget]
        ?.add(CustomInputWatcherEvents.onSecondary);
    // }
  }

  void onSecondaryUpCall(PointerUpEvent info) {
    // for (var element in onSecondaryUp) {
    //   element.call(info);
    onGameActionCall((gameAction: GameAction.secondary, isDownEvent: false));
    _customInputWatcherStreams[currentlyHoveredWidget]
        ?.add(CustomInputWatcherEvents.onSecondaryUp);
    stopHoldCall(false);
    // }
  }

  void registerScrollController(State<CustomInputWatcher> customInputWatcher,
      ScrollController scrollController) {
    _customInputWatcherScrollControllers[scrollController] ??= [];
    _customInputWatcherScrollControllers[scrollController]
        ?.add(customInputWatcher);
    scrollController
        .addListener(() => updateCustomInputWatcher(customInputWatcher));
  }

  void removeCustomInputWatcher(State<CustomInputWatcher> customInputWatcher) {
    _customInputWatcherStreams[customInputWatcher]?.close();
    _customInputWatcherStreams.remove(customInputWatcher);
    _customInputWatcherRectangles.remove(customInputWatcher);
    _customInputWatcherGroups[customInputWatcher.widget.groupId]
        ?.remove(customInputWatcher);

    if (_customInputWatcherGroups[customInputWatcher.widget.groupId]?.isEmpty ??
        true) {
      _customInputWatcherGroups.remove(customInputWatcher.widget.groupId);
    }
    if (customInputWatcher.widget.scrollController != null) {
      removeScrollController(customInputWatcher);
    }

    if (customInputWatcher == currentlyHoveredWidget) removeHoveredState();
  }

  void removeGameActionListener(
      GameAction gameAction, GameActionCallback callback) {
    _onGameActionMap[gameAction]?.remove(callback);
  }

  void removeHoveredState() {
    _customInputWatcherStreams[currentlyHoveredWidget]
        ?.add(CustomInputWatcherEvents.hoverOff);

    currentlyHoveredWidget = null;
  }

  void removeScrollController(State<CustomInputWatcher> customInputWatcher) {
    customInputWatcher.widget.scrollController
        ?.removeListener(() => updateCustomInputWatcher(customInputWatcher));

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

  void setGameRouter(GameRouter gameRouter) {
    _gameRouterReference = gameRouter;
    _systemDataReference = _gameRouterReference.systemDataComponent.dataObject;
  }

  void setHoveredState(State<CustomInputWatcher> widget) {
    removeHoveredState();

    _customInputWatcherStreams[widget]?.add(CustomInputWatcherEvents.hoverOn);

    currentlyHoveredWidget = widget;
  }

  void sortGroupStates() {
    for (var element in _customInputWatcherGroups.entries) {
      element.value.sort((a, b) {
        if (a.widget.groupOrientation == Axis.horizontal) {
          return (_customInputWatcherRectangles[a]?.right ?? 0)
              .compareTo((_customInputWatcherRectangles[b]?.right ?? 0));
        } else {
          return (_customInputWatcherRectangles[a]?.bottom ?? 0)
              .compareTo((_customInputWatcherRectangles[b]?.bottom ?? 0));
        }
      });
    }
  }

  void stopHoldCall(bool? isPrimary) {
    if (isPrimaryTimerActive != isPrimary && isPrimary != null) return;
    isPrimaryTimerActive = null;
    holdCallTimer?.cancel();
    holdCallTimer = null;
  }

  void updateCustomInputWatcher(State<CustomInputWatcher> customInputWatcher) {
    if (!_customInputWatcherStreams.containsKey(customInputWatcher)) return;
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
      updateCustomInputWatcher(element.key);
    }
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

enum GameAction {
  primary,
  secondary,
  jump,
  dash,
  reload,
  pause,
  moveLeft,
  moveRight,
  moveUp,
  moveDown,
  interact,
  useExpendable,
  swapWeapon
}

class CustomInputWatcher extends StatefulWidget {
  const CustomInputWatcher(
      {this.onHover,
      required this.child,
      this.onPrimary,
      this.onPrimaryHold,
      this.onPrimaryUp,
      this.scrollController,
      this.groupId = 0,
      this.zIndex = 0,
      this.groupOrientation = Axis.horizontal,
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
  final int groupId;
  final Axis groupOrientation;
  final ScrollController? scrollController;
  final int zIndex;

  @override
  State<CustomInputWatcher> createState() => CustomInputWatcherState();
}

class CustomInputWatcherState<T extends CustomInputWatcher> extends State<T> {
  late final GameState gameState = GameState();
  late final InputManager inputManager;

  late final StreamSubscription<CustomInputWatcherEvents> _streamSubscription;

  void handleStreamEvents(CustomInputWatcherEvents event) {
    // print(event);
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
    }
  }

  void updateCustomInputWatcher() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      inputManager.updateCustomInputWatcher(this);
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    inputManager.removeCustomInputWatcher(this);

    super.dispose();
  }

  @override
  void initState() {
    inputManager = InputManager();
    _streamSubscription = inputManager
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
