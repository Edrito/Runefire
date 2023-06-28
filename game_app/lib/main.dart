import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/services.dart';
import 'package:game_app/game/forest_game.dart';
import 'package:game_app/pages/menu.dart';
import 'package:game_app/resources/data_classes/player_data.dart';
import 'package:game_app/resources/data_classes/system_data.dart';
import 'package:game_app/resources/visuals.dart';
import 'game/enviroment.dart';
import 'resources/routes.dart' as routes;
import 'resources/overlays.dart' as overlays;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';

late GameRouter gameRouter;
late MenuPages menuPage;

void changeMainMenuPage(MenuPages page) {
  setStateMainMenu(() {
    toggleGameStart(null);
    menuPage = page;
  });
}

bool startInGame = true;

///null route = go to main menu
///string route = leave main menu to route
void toggleGameStart(String? route) {
  if (route != null) {
    gameRouter.overlays.remove(overlays.mainMenu.key);
    gameRouter.router.pushReplacementNamed(route);
  } else {
    gameRouter.overlays.add(overlays.mainMenu.key);
    gameRouter.router.pushReplacementNamed(routes.blank);
  }
}

late Function setStateMainMenu;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
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
          child: GameWidget(
              backgroundBuilder: (context) {
                return Container(
                  color: backgroundColor,
                );
              },
              loadingBuilder: (p0) {
                return Container(
                    color: const Color.fromARGB(255, 72, 37, 112),
                    child: const CircularProgressIndicator());
              },
              game: gameRouter,
              overlayBuilderMap: Map<String,
                  Widget Function(BuildContext, GameRouter)>.fromEntries([
                overlays.pauseMenu,
                overlays.weaponModifyMenu,
                overlays.mainMenu,
              ])),
        ),
      ),
    ),
  );
  if (!startInGame) {
    gameRouter.overlays.add(overlays.mainMenu.key);
  }
}

class GameRouter extends Forge2DGame
    with
        HasKeyboardHandlerComponents,
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

  List<MouseCallbackWrapper> mouseCallback = [];

  @override
  void onLoad() async {
    router = RouterComponent(
      routes: {
        routes.blank: Route(Component.new),
        routes.transition: Route(ForestGame.new, maintainState: false),
        // routes.homeroom: Route(HomeRoom.new, maintainState: false),
        routes.gameplay: Route(ForestGame.new, maintainState: false),
      },
      initialRoute: startInGame ? routes.gameplay : routes.blank,
    );

    add(systemDataComponent);
    add(playerDataComponent);
    add(router);
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

  @override
  void onScroll(PointerScrollInfo info) {
    if (router.currentRoute.children.first is GameEnviroment) {
      final test = (router.currentRoute.children.first as GameEnviroment);

      var currentZoom = test.gameCamera.viewfinder.zoom;

      currentZoom += info.scrollDelta.game.normalized().y * -1;

      currentZoom = currentZoom.clamp(3, 20);
      test.gameCamera.viewfinder.zoom = currentZoom;
    }

    super.onScroll(info);
  }

  @override
  bool containsLocalPoint(Vector2 p) {
    return true;
  }
}

class MouseCallbackWrapper {
  //LCLICK
  Function(TapUpInfo)? onPrimaryUp;
  Function()? onPrimaryCancel;
  Function(TapDownInfo)? onPrimaryDown;

  //RCLICK
  Function(TapUpInfo)? onSecondaryUp;
  Function()? onSecondaryCancel;
  Function(TapDownInfo)? onSecondaryDown;

  //Move
  Function(PointerHoverInfo)? onMouseMove;
}
