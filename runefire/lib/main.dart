import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';

import 'package:flame/cache.dart';
import 'package:flame/components.dart' hide World;
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
// import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:gamepads/gamepads.dart';
// import 'package:gamepads/gamepads.dart';
import 'package:runefire/game/background.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/menus/menus.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/sprite_animations.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/resources/data_classes/system_data.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
// import 'package:win32_gamepad/win32_gamepad.dart';
import 'package:runefire/game/menu_game.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:runefire/menus/overlays.dart';
import 'package:runefire/resources/constants/routes.dart' as routes;
import 'package:runefire/menus/overlays.dart' as overlay;

final rng = Random();

bool _startInGame = false;

final ApolloColorPalette colorPalette = ApolloColorPalette();
final SpriteAnimations spriteAnimations = SpriteAnimations();

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && Platform.isWindows) {
    await windowManager.ensureInitialized();
  }
  await Future.wait([
    Flame.device.setLandscape(),
    Hive.initFlutter(),
  ]);

  //load goodies from HIVE

  Hive.registerAdapter(SystemDataAdapter());

  final playerData = PlayerData();
  late final SystemData systemData;
  final box = await Hive.openBox<SystemData>('systemData');
  if (!box.containsKey(0)) {
    systemData = SystemData();
    box.put(0, systemData);
  } else {
    systemData = box.get(0)!;
  }

  final toLoad = <String>[
    ...ImagesAssetsUi.allFiles,
    ...ImagesAssetsBackground.allFiles,
    ...ImagesAssetsRunes.allFiles,
    ...ImagesAssetsAttributeSprites.allFiles,
    ...ImagesAssetsRunes.allFiles,
  ];

  Images().loadAllImages();
  binding.addPostFrameCallback((_) async {
    final context = binding.rootElement!;
    final futures = <Future>[];
    for (final asset in toLoad) {
      futures.add(precacheImage(AssetImage(asset), context));
    }
    await Future.wait(futures);
  });

  final gameRouter = GameRouter(systemData, playerData);

  gameRouter.gameStateComponent = GameStateComponent(GameState());

  // final gamepad = Gamepad(0);
  // gamepad.vibrate(
  //   leftMotorSpeed: 25000,
  // );

  GameState().currentRoute = _startInGame ? routes.gameplay : routes.blank;

  GameState().initParameters(
    currentMenuPage: MenuPageType.startMenuPage,
    gameRouter: gameRouter,
    playerData: playerData,
    systemData: systemData,
  );

  final inputManagerState = InputManager();
  inputManagerState.setInitReferences(gameRouter);

  ServicesBinding.instance.keyboard
      .addHandler(inputManagerState.keyboardEventHandler);

  runApp(
    MouseRegion(
      cursor: SystemMouseCursors.none,
      child: Material(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Listener(
            onPointerHover: inputManagerState.onPointerHover,
            onPointerDown: inputManagerState.onPointerDown,
            onPointerMove: inputManagerState.onPointerMove,
            onPointerUp: inputManagerState.onPointerUp,
            onPointerSignal: inputManagerState.onPointerSignal,
            onPointerCancel: inputManagerState.onPointerCancel,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GameWidget(
                    backgroundBuilder: (context) {
                      if (GameState().currentRoute == routes.gameplay) {
                        return const SizedBox();
                      }
                      return CaveBackground(
                        gameRef: gameRouter,
                      );
                    },
                    loadingBuilder: (p0) {
                      return Padding(
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          'LOADING',
                          style: defaultStyle,
                        ).animate().fadeIn(),
                      );
                    },
                    game: gameRouter,
                    initialActiveOverlays: [
                      if (!_startInGame) ...[caveFront.key, mainMenu.key],
                    ],
                    overlayBuilderMap: Map<String,
                        Widget Function(BuildContext, GameRouter)>.fromEntries([
                      overlay.pauseMenu,
                      overlay.mainMenu,
                      overlay.caveFront,
                      overlay.gameWinDisplay,
                      overlay.deathScreen,
                      overlay.attributeSelection,
                    ]),
                  ),
                ),
                GamepadCursorDisplay(gameRouter),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class GameRouter extends Forge2DGame {
  late final RouterComponent router;

  GameRouter(SystemData systemData, PlayerData playerData)
      : super(gravity: Vector2.zero(), zoom: 1) {
    playerDataComponent = PlayerDataComponent(playerData);
    systemDataComponent = SystemDataComponent(systemData);
  }

  late PlayerDataComponent playerDataComponent;
  late SystemDataComponent systemDataComponent;
  late GameStateComponent gameStateComponent;
  late ComponentsNotifier systemDataNotifier =
      componentsNotifier<SystemDataComponent>();

  List<Function(SystemData data)> onSystemDataChange = [];
  void callOnSystemDataChange(SystemData data) {
    for (final function in onSystemDataChange) {
      function(data);
    }
  }

  @override
  void onRemove() {
    systemDataNotifier.removeListener(() {
      callOnSystemDataChange(systemDataComponent.dataObject);
    });
    super.onRemove();
  }

  @override
  Future<void> onLoad() async {
    // debugMode = true;
    router = RouterComponent(
      routes: {
        routes.blank: Route(MenuGame.new, maintainState: false),
        routes.transition: Route(Component.new, maintainState: false),
        routes.gameplay: Route(
          playerDataComponent.dataObject.selectedLevel.buildEnvrioment,
          maintainState: false,
        ),
      },
      initialRoute: gameStateComponent.gameState.currentRoute,
    );
    add(systemDataComponent);
    add(playerDataComponent);
    add(gameStateComponent);
    add(router);

    systemDataNotifier.addListener(() {
      callOnSystemDataChange(systemDataComponent.dataObject);
    });

    await super.onLoad();
  }

  late final GamepadInputManager gamepadInputManager =
      InputManager().gamepadInputManager;
  @override
  void update(double dt) {
    if (!kIsWeb && Platform.isWindows) {
      gamepadInputManager.gamepad.updateState();
      gamepadInputManager.parseGameState();
    }
    super.update(dt);
  }

  @override
  bool containsLocalPoint(Vector2 p) {
    return true;
  }
}
