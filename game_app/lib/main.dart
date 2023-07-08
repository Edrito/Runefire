import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/game/enviroment_mixin.dart';
import 'package:game_app/game/forest_game.dart';
import 'package:game_app/overlays/menus.dart';
import 'package:game_app/resources/data_classes/player_data.dart';
import 'package:game_app/resources/data_classes/system_data.dart';
import 'package:game_app/resources/visuals.dart';
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

Enviroment? get currentEnviroment {
  var result = gameRouter.router.currentRoute.children.whereType<Enviroment>();

  if (result.isNotEmpty) {
    return result.first;
  } else {
    return null;
  }
}

bool get gameIsPaused => gameRouter.paused;

void pauseGame(String overlay,
    {bool pauseGame = true, bool wipeMovement = false}) {
  if (currentOverlay != null) return;
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

void changeMainMenuPage(MenuPages page, [bool setState = true]) {
  toggleGameStart(null);
  MenuGame? menuGame;
  if (currentEnviroment is MenuGame) {
    menuGame = currentEnviroment as MenuGame;
  }

  if (page == MenuPages.weaponMenu) {
    menuGame?.addPlayer();
  } else {
    menuGame?.removePlayer();
  }
  menuPage = page;
  if (setState) {
    setStateMainMenu(() {});
  }
}

bool startInGame = true;

///null route = go to main menu
///string route = leave main menu to route
void toggleGameStart(String? route) {
  gameRouter.router.pushReplacementNamed(routes.blank);

  resumeGame();
  if (route != null) {
    Future.delayed(const Duration(milliseconds: 50)).then((_) {
      gameRouter.router.pushReplacementNamed(route);
    });
  } else {
    Future.delayed(const Duration(milliseconds: 50)).then((_) {
      gameRouter.overlays.add(overlays.mainMenu.key);
    });
  }
}

late Function setStateMainMenu;

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

  runApp(
    Material(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Listener(
          onPointerMove: (event) {
            if (event.buttons == 2 && event.kind == PointerDeviceKind.mouse) {
              gameRouter.onMouseMove(PointerHoverInfo.fromDetails(
                  gameRouter, PointerHoverEvent(position: event.position)));
            }
          },
          child: RawKeyboardListener(
            focusNode: node,
            onKey: gameRouter.onKeyEvent,
            child: GameWidget(
                backgroundBuilder: (context) {
                  return const BackgroundWidget();
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
                  overlays.deathScreen,
                  overlays.attributeSelection,
                ])),
          ),
        ),
      ),
    ),
  );
}

class GameRouter extends Forge2DGame
    with
        ScrollDetector,
        SecondaryTapDetector,
        MouseMovementDetector,
        TapDetector {
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

  List<MouseKeyboardCallbackWrapper> mouseCallback = [];

  @override
  void onLoad() async {
    router = RouterComponent(
      routes: {
        routes.blank: Route(MenuGame.new, maintainState: false),
        routes.transition: Route(ForestGame.new, maintainState: false),
        routes.gameplay: Route(ForestGame.new, maintainState: false),
      },
      initialRoute: startInGame ? routes.gameplay : routes.blank,
    );
    add(systemDataComponent);
    add(playerDataComponent);
    add(router);
  }

  @override
  void onMount() {
    super.onMount();
    if (!startInGame) {
      gameRouter.overlays.add(overlays.mainMenu.key);
    }
  }

  @override
  void onSecondaryTapDown(TapDownInfo info) {
    if (mouseCallback.isNotEmpty && info.raw.kind == PointerDeviceKind.mouse) {
      for (var element in mouseCallback) {
        if (element.onSecondaryDown != null) {
          element.onSecondaryDown!(info);
        }
      }
    }
    super.onSecondaryTapDown(info);
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (mouseCallback.isNotEmpty && info.raw.kind == PointerDeviceKind.mouse) {
      for (var element in mouseCallback) {
        if (element.onPrimaryDown != null) {
          element.onPrimaryDown!(info);
        }
      }
    }
    super.onTapDown(info);
  }

  @override
  void onSecondaryTapUp(TapUpInfo info) {
    if (mouseCallback.isNotEmpty && info.raw.kind == PointerDeviceKind.mouse) {
      for (var element in mouseCallback) {
        if (element.onSecondaryUp != null) {
          element.onSecondaryUp!(info);
        }
      }
    }
    super.onSecondaryTapUp(info);
  }

  @override
  void onSecondaryTapCancel() {
    if (mouseCallback.isNotEmpty) {
      for (var element in mouseCallback) {
        if (element.onSecondaryCancel != null) {
          element.onSecondaryCancel!();
        }
      }
    }
    super.onSecondaryTapCancel();
  }

  @override
  void onTapCancel() {
    if (mouseCallback.isNotEmpty) {
      for (var element in mouseCallback) {
        if (element.onPrimaryCancel != null) {
          element.onPrimaryCancel!();
        }
      }
    }
    super.onTapCancel();
  }

  @override
  void onTapUp(TapUpInfo info) {
    if (mouseCallback.isNotEmpty && info.raw.kind == PointerDeviceKind.mouse) {
      for (var element in mouseCallback) {
        if (element.onPrimaryUp != null) {
          element.onPrimaryUp!(info);
        }
      }
    }
    super.onTapUp(info);
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    if (mouseCallback.isNotEmpty) {
      for (var element in mouseCallback) {
        if (element.onMouseMove != null) {
          element.onMouseMove!(info);
        }
      }
    }
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
    if (router.currentRoute.children.first is Enviroment) {
      final test = (router.currentRoute.children.first as Enviroment);

      var currentZoom = test.gameCamera.viewfinder.zoom;

      currentZoom += info.scrollDelta.game.normalized().y * -1;

      currentZoom = currentZoom.clamp(3, 50);
      test.gameCamera.viewfinder.zoom = currentZoom;
    }

    super.onScroll(info);
  }

  @override
  bool containsLocalPoint(Vector2 p) {
    return true;
  }
}

class MouseKeyboardCallbackWrapper {
  //LCLICK
  Function(TapUpInfo)? onPrimaryUp;
  Function()? onPrimaryCancel;
  Function(TapDownInfo)? onPrimaryDown;

  //RCLICK
  Function(TapUpInfo)? onSecondaryUp;
  Function()? onSecondaryCancel;
  Function(TapDownInfo)? onSecondaryDown;
  Function(RawKeyEvent)? keyEvent;

  //Move
  Function(PointerHoverInfo)? onMouseMove;
}
