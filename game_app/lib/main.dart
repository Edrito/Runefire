import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:game_app/game/home_room.dart';
import 'package:game_app/game/forest_game.dart';
import 'package:game_app/pages/main_menu.dart';
import 'package:game_app/resources/classes.dart';
import 'resources/routes.dart' as routes;
import 'resources/overlays.dart' as overlays;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();
  GameRouter gameRouter = GameRouter();
  runApp(
    GameWidget(
        game: gameRouter,
        overlayBuilderMap:
            Map<String, Widget Function(BuildContext, GameRouter)>.fromEntries([
          overlays.pauseMenu,
          overlays.weaponModifyMenu,
        ])),
  );
  // );
}

class GameRouter extends Forge2DGame
    with HasKeyboardHandlerComponents, ScrollDetector, MouseMovementDetector
// TapDetector,
// TertiaryTapDetector,
// SecondaryTapDetector
{
  late final RouterComponent router;

  GameRouter() : super(gravity: Vector2.zero(), zoom: 1);

  Function? mouseCallback;

  @override
  void onLoad() {
    add(
      router = RouterComponent(
        routes: {
          routes.mainMenu: Route(MainMenu.new),
          routes.transition: Route(HomeRoom.new, maintainState: false),
          routes.homeroom: Route(HomeRoom.new, maintainState: false),
          routes.gameplay: Route(ForestGame.new, maintainState: false),
        },
        initialRoute: routes.gameplay,
      ),
    );
  }

  //TODO: SIMILAR TO MOUSE CALLBACK, MULTI CLICK FUNCTIONS HERE

  // @override
  // void onSecondaryTapDown(TapDownInfo info) {
  //   //

  //   super.onSecondaryTapDown(info);
  // }

  // @override
  // void onTapDown(TapDownInfo info) {
  //   //
  //   super.onTapDown(info);
  // }

  // @override
  // void onTertiaryTapDown(TapDownInfo info) {
  //   if (isLoaded) {

  //   }
  //   super.onTertiaryTapDown(info);
  // }

  @override
  void onMouseMove(PointerHoverInfo info) {
    if (mouseCallback != null) {
      mouseCallback!(info);
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
}
