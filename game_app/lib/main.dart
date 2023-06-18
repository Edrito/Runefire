import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:game_app/game/forest_game.dart';
import 'package:game_app/pages/main_menu.dart';
import 'package:game_app/resources/data_classes/player_data.dart';
import 'package:game_app/resources/data_classes/system_data.dart';
import 'game/enviroment.dart';
import 'resources/routes.dart' as routes;
import 'resources/overlays.dart' as overlays;
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();
  await Hive.initFlutter();

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

  GameRouter gameRouter = GameRouter(systemData, playerData);

  runApp(
    DefaultTextStyle(
      style: const TextStyle(fontFamily: "HeroSpeak"),
      child: GameWidget(
          backgroundBuilder: (context) {
            return Container(
              color: const Color.fromARGB(255, 37, 112, 108),
            );
          },
          game: gameRouter,
          overlayBuilderMap: Map<String,
              Widget Function(BuildContext, GameRouter)>.fromEntries([
            overlays.pauseMenu,
            overlays.weaponModifyMenu,
          ])),
    ),
  );
  // );
}

class GameRouter extends Forge2DGame
    with
        HasKeyboardHandlerComponents,
        ScrollDetector,
        MouseMovementDetector,
        TapDetector,
        SecondaryTapDetector {
  late final RouterComponent router;

  GameRouter(this.systemData, this.playerData)
      : super(gravity: Vector2.zero(), zoom: 1);

  final PlayerData playerData;
  final SystemData systemData;
  late PlayerDataComponent playerDataComponent;
  late SystemDataComponent systemDataComponent;

  List<MouseCallbackWrapper> mouseCallback = [];

  @override
  void onLoad() {
    playerDataComponent = PlayerDataComponent(playerData);
    systemDataComponent = SystemDataComponent(systemData);

    router = RouterComponent(
      routes: {
        routes.mainMenu: Route(MainMenu.new),
        routes.transition: Route(ForestGame.new, maintainState: false),
        // routes.homeroom: Route(HomeRoom.new, maintainState: false),
        routes.gameplay: Route(ForestGame.new, maintainState: false),
      },
      initialRoute: routes.mainMenu,
    );

    add(systemDataComponent);
    systemDataComponent.add(playerDataComponent);
    playerDataComponent.add(router);
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
    super.onMouseMove(info);
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
    // TODO: implement containsLocalPoint
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
