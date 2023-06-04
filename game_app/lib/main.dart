import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:game_app/game/main_game.dart';
import 'package:game_app/pages/main_menu.dart';
import 'resources/routes.dart' as routes;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();
  GameRouter gameRouter = GameRouter();
  runApp(
    GameWidget(
      game: gameRouter,
      overlayBuilderMap: {
        'PauseMenu': (context, _) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    child: const Text("Resume"),
                    onPressed: () {
                      gameRouter.overlays.remove('PauseMenu');
                      gameRouter.resumeEngine();
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    child: const Text("Main Menu"),
                    onPressed: () {
                      gameRouter.router.pushReplacementNamed(routes.mainMenu);
                      gameRouter.overlays.remove('PauseMenu');
                      gameRouter.resumeEngine();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      },
    ),
  );
  // );
}

class GameRouter extends Forge2DGame
    with HasKeyboardHandlerComponents, MouseMovementDetector {
  late final RouterComponent router;

  GameRouter() : super(gravity: Vector2.zero(), zoom: 1);

  Function? mouseCallback;

  @override
  void onLoad() {
    add(
      router = RouterComponent(
        routes: {
          routes.mainMenu: Route(MainMenu.new),
          routes.transition: Route(MainMenu.new),
          routes.gameplay: Route(MainGame.new, maintainState: false),
        },
        initialRoute: routes.gameplay,
      ),
    );
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    if (mouseCallback != null) {
      mouseCallback!(info);
    }
    super.onMouseMove(info);
  }
}
