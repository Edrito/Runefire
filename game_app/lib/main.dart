import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/game/background.dart';
import 'package:game_app/game/enviroment_mixin.dart';
import 'package:game_app/game/forest_game.dart';
import 'package:game_app/overlays/menus.dart';
import 'package:game_app/resources/data_classes/player_data.dart';
import 'package:game_app/resources/data_classes/system_data.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/visuals.dart';
import 'entities/player.dart';
import 'game/enviroment.dart';
import 'game/menu_game.dart';
import 'resources/constants/routes.dart' as routes;
import 'overlays/overlays.dart' as overlays;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';

final rng = Random();
late GameRouter gameRouter;
late MenuPages menuPage;
String? currentOverlay;
bool get gameIsPaused => gameRouter.paused;
bool startInGame = false;
late String currentRoute;

void playAudio(String audioLocation,
    {AudioType audioType = AudioType.sfx,
    AudioScopeType audioScopeType = AudioScopeType.short,
    bool isLooping = false}) {
  return;

  double volume;

  switch (audioType) {
    case AudioType.sfx:
      volume =
          volume = gameRouter.systemDataComponent.dataObject.sfxVolume / 100;
      break;
    case AudioType.music:
      volume =
          volume = gameRouter.systemDataComponent.dataObject.musicVolume / 100;
      break;
    default:
      volume =
          volume = gameRouter.systemDataComponent.dataObject.sfxVolume / 100;
  }

  switch (audioScopeType) {
    case AudioScopeType.bgm:
      FlameAudio.bgm.play(audioLocation, volume: volume);
      break;
    case AudioScopeType.short:
      if (isLooping) {
        FlameAudio.loop(audioLocation, volume: volume);
      } else {
        FlameAudio.play(audioLocation, volume: volume);
      }
      break;

    case AudioScopeType.long:
      if (isLooping) {
        FlameAudio.loopLongAudio(audioLocation, volume: volume);
      } else {
        FlameAudio.playLongAudio(audioLocation, volume: volume);
      }
  }
}

Enviroment? get currentEnviroment {
  var result = gameRouter.router.currentRoute.children.whereType<Enviroment>();

  if (result.isNotEmpty) {
    return result.first;
  } else {
    return null;
  }
}

Enviroment? getEnviromentFromRouter(GameRouter router) {
  var result = router.router.currentRoute.children.whereType<Enviroment>();

  if (result.isNotEmpty) {
    return result.first;
  } else {
    return null;
  }
}

Player? get currentPlayer {
  Player? player;
  final currentEnviromentTemp = currentEnviroment;
  if (currentEnviromentTemp is PlayerFunctionality) {
    player = currentEnviromentTemp.player;
  }
  return player;
}

bool transitionOccuring = false;

void pauseGame(String overlay,
    {bool pauseGame = true, bool wipeMovement = false}) {
  if (currentOverlay != null || transitionOccuring) return;
  gameRouter.overlays.add(overlay);
  currentOverlay = overlay;
  if (wipeMovement) {
    final game = currentEnviroment;
    if (game != null && game is PlayerFunctionality) {
      game.player?.physicalKeysPressed.clear();
      game.player?.parseKeys(null);
    }
  }

  if (pauseGame) gameRouter.pauseEngine();
}

void resumeGame() {
  gameRouter.overlays.clear();
  currentOverlay = null;
  gameRouter.resumeEngine();
}

void handlePlayerPreview(MenuPages page) {
  MenuGame? menuGame;
  if (currentEnviroment is MenuGame) {
    menuGame = currentEnviroment as MenuGame;
  }

  if (page == MenuPages.weaponMenu) {
    menuGame?.addPlayer();
  } else {
    menuGame?.removePlayer();
  }
}

void changeMainMenuPage(MenuPages page, [bool setState = true]) {
  // toggleGameStart(null);
  handlePlayerPreview(page);

  menuPage = page;
  if (setState) {
    setStateMainMenu(() {});
  }
}

///null route = go to main menu
///string route = leave main menu to route
void toggleGameStart(String? route) {
  gameRouter.router.pushReplacementNamed(routes.blank);
  resumeGame();
  if (route != null) {
    Future.delayed(const Duration(milliseconds: 50)).then((_) {
      gameRouter.router.pushReplacementNamed(route!);
    });
  } else {
    gameRouter.overlays.add(overlays.caveFront.key);
    route = routes.blank;
    Future.delayed(const Duration(milliseconds: 50)).then((_) {
      gameRouter.overlays.add(overlays.mainMenu.key);
    });
  }
  currentRoute = route;
}

void endGame([bool restart = false]) {
  final player = currentPlayer;
  if (player != null) {
    gameRouter.playerDataComponent.dataObject.updateInformation(player);
  }

  if (!restart) {
    toggleGameStart(null);
    changeMainMenuPage(MenuPages.startMenuPage, false);
  } else {
    toggleGameStart(routes.gameplay);
  }
  resumeGame();
}

late Function setStateMainMenu;

Map<int, bool> isSecondaryPointer = {};
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
  }
  await Future.wait([
    Flame.device.setLandscape(),
    Hive.initFlutter(),
  ]);

  //load goodies from HIVE
  Hive.registerAdapter(SystemDataAdapter());

  final PlayerData playerData = PlayerData();
  late final SystemData systemData;
  var box = await Hive.openBox<SystemData>('systemData');
  if (!box.containsKey(0)) {
    systemData = SystemData();
    box.put(0, systemData);
  } else {
    systemData = box.get(0)!;
  }
  FocusNode node = FocusNode();
  node.requestFocus();

  gameRouter = GameRouter(systemData, playerData);
  menuPage = MenuPages.startMenuPage;

  currentRoute = startInGame ? routes.gameplay : routes.blank;

  runApp(
    Material(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Listener(
          onPointerHover: (event) {
            gameRouter.onMouseMove(event);
          },
          onPointerMove: (event) {
            if (event.kind == PointerDeviceKind.mouse) {
              if (event.buttons == 2) {
                gameRouter.onSecondaryMove(event);
              } else {
                gameRouter.onTapMove(event);
              }
            }

            gameRouter.onMouseMove(PointerHoverEvent(
                buttons: event.buttons,
                delta: event.delta,
                pointer: event.pointer,
                position: event.position,
                timeStamp: event.timeStamp,
                kind: event.kind,
                obscured: event.obscured,
                embedderId: event.embedderId,
                device: event.device));
          },
          onPointerDown: (event) {
            if (gameRouter.paused) return;
            if (event.kind == PointerDeviceKind.mouse) {
              if (event.buttons == 2) {
                isSecondaryPointer[event.pointer] = true;
                gameRouter.onSecondaryTapDown(event);
              } else {
                isSecondaryPointer[event.pointer] = false;

                gameRouter.onTapDown(event);
              }
            }
          },
          onPointerUp: (event) {
            if (event.kind == PointerDeviceKind.mouse) {
              if (isSecondaryPointer[event.pointer] == true) {
                gameRouter.onSecondaryTapUp(event);
              } else {
                gameRouter.onTapUp(event);
              }
            }
            isSecondaryPointer.remove(event.pointer);
          },
          onPointerCancel: (event) {
            if (event.kind == PointerDeviceKind.mouse) {
              if (isSecondaryPointer[event.pointer] == true) {
                gameRouter.onSecondaryTapCancel();
              } else {
                gameRouter.onTapCancel();
              }
            }
            isSecondaryPointer.remove(event.pointer);
          },
          child: RawKeyboardListener(
            focusNode: node,
            onKey: gameRouter.onKeyEvent,
            child: GameWidget(
                backgroundBuilder: (context) {
                  if (currentRoute == routes.gameplay) {
                    print('here');
                    return const SizedBox();
                  }
                  return const CaveBackground();
                },
                loadingBuilder: (p0) {
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      "LOADING",
                      style: defaultStyle,
                    ).animate().fadeIn(),
                  );
                },
                game: gameRouter,
                overlayBuilderMap: Map<String,
                    Widget Function(BuildContext, GameRouter)>.fromEntries([
                  overlays.pauseMenu,
                  overlays.mainMenu,
                  overlays.caveFront,
                  overlays.deathScreen,
                  overlays.attributeSelection,
                ])),
          ),
        ),
      ),
    ),
  );
}

class GameRouter extends Forge2DGame with ScrollDetector, WindowListener {
  late final RouterComponent router;

  GameRouter(this._systemData, this._playerData)
      : super(gravity: Vector2.zero(), zoom: 1) {
    playerDataComponent = PlayerDataComponent(_playerData);
    systemDataComponent = SystemDataComponent(_systemData);
  }

  final PlayerData _playerData;
  final SystemData _systemData;
  late PlayerDataComponent playerDataComponent;
  late SystemDataComponent systemDataComponent;

  @override
  onRemove() {
    windowManager.removeListener(this);
  }

  List<MouseKeyboardCallbackWrapper> mouseCallback = [];

  @override
  void onLoad() async {
    windowManager.addListener(this);
    router = RouterComponent(
      routes: {
        routes.blank: Route(MenuGame.new, maintainState: false),
        routes.transition: Route(ForestGame.new, maintainState: false),
        routes.gameplay: Route(ForestGame.new, maintainState: false),
      },
      initialRoute: currentRoute,
    );
    add(systemDataComponent);
    add(playerDataComponent);
    add(router);
  }

  @override
  void onMount() {
    super.onMount();
    if (!startInGame) {
      gameRouter.overlays.add(overlays.caveFront.key);
      gameRouter.overlays.add(overlays.mainMenu.key);
    }
  }

  void onSecondaryTapDown(PointerDownEvent info) {
    for (var element
        in mouseCallback.where((element) => element.onSecondaryDown != null)) {
      element.onSecondaryDown!(info);
    }
  }

  void onTapDown(PointerDownEvent info) {
    for (var element
        in mouseCallback.where((element) => element.onPrimaryDown != null)) {
      element.onPrimaryDown!(info);
    }
  }

  void onSecondaryTapUp(PointerUpEvent info) {
    for (var element
        in mouseCallback.where((element) => element.onSecondaryUp != null)) {
      element.onSecondaryUp!(info);
    }
  }

  void onSecondaryTapCancel() {
    for (var element in mouseCallback
        .where((element) => element.onSecondaryCancel != null)) {
      element.onSecondaryCancel!();
    }
  }

  void onTapCancel() {
    for (var element
        in mouseCallback.where((element) => element.onPrimaryCancel != null)) {
      element.onPrimaryCancel!();
    }
  }

  void onTapUp(PointerUpEvent info) {
    for (var element
        in mouseCallback.where((element) => element.onPrimaryUp != null)) {
      element.onPrimaryUp!(info);
    }
  }

  void onTapMove(PointerMoveEvent info) {
    for (var element
        in mouseCallback.where((element) => element.onPrimaryMove != null)) {
      element.onPrimaryMove!(info);
    }
  }

  void onSecondaryMove(PointerMoveEvent info) {
    for (var element
        in mouseCallback.where((element) => element.onSecondaryMove != null)) {
      element.onSecondaryMove!(info);
    }
  }

  void onMouseMove(PointerHoverEvent info) {
    for (var element
        in mouseCallback.where((element) => element.onMouseMove != null)) {
      element.onMouseMove!(info);
    }
  }

  @override
  void onWindowEvent(String eventName) {
    for (var element
        in mouseCallback.where((element) => element.onWindowEvent != null)) {
      element.onWindowEvent!(eventName);
    }

    super.onWindowEvent(eventName);
  }

  void onKeyEvent(RawKeyEvent event) {
    if (mouseCallback.isNotEmpty) {
      for (var element in mouseCallback) {
        if (element.keyEvent != null) {
          element.keyEvent!(event);
        }
      }
    }
  }

  @override
  void onScroll(PointerScrollInfo info) {
    // if (router.currentRoute.children.first is Enviroment) {
    //   final test = (router.currentRoute.children.first as Enviroment);

    //   var currentZoom = test.gameCamera.viewfinder.zoom;

    //   currentZoom += info.scrollDelta.game.normalized().y * -1;

    //   currentZoom = currentZoom.clamp(3, 100);
    //   test.gameCamera.viewfinder.zoom = currentZoom;
    // }

    super.onScroll(info);
  }

  @override
  bool containsLocalPoint(Vector2 p) {
    return true;
  }
}

class MouseKeyboardCallbackWrapper {
  //LCLICK
  Function(PointerUpEvent)? onPrimaryUp;
  Function()? onPrimaryCancel;
  Function(PointerDownEvent)? onPrimaryDown;
  Function(PointerMoveEvent)? onPrimaryMove;

  //RCLICK
  Function(PointerUpEvent)? onSecondaryUp;
  Function()? onSecondaryCancel;
  Function(PointerDownEvent)? onSecondaryDown;
  Function(RawKeyEvent)? keyEvent;
  Function(PointerMoveEvent)? onSecondaryMove;

  //Move
  Function(PointerHoverEvent)? onMouseMove;

  //Window
  Function(String windowEvent)? onWindowEvent;
}
