import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart' hide World;
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/game/background.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:runefire/menus/menus.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/sprite_animations.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/resources/data_classes/system_data.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
import 'game/menu_game.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'menus/overlays.dart';
import 'resources/constants/routes.dart' as routes;
import '../menus/overlays.dart' as overlay;

final rng = Random();
late final GameState gameState;

bool startInGame = true;

Map<int, bool> isSecondaryPointer = {};

final ApolloColorPalette colorPalette = ApolloColorPalette();
final SpriteAnimations spriteAnimations = SpriteAnimations();

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
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

  final List<String> toLoad = [
    ...ImagesAssetsUi.allFiles,
    ...ImagesAssetsBackground.allFiles,
    ...ImagesAssetsRunes.allFiles,
    ...ImagesAssetsAttributeSprites.allFiles,
    ...ImagesAssetsRunes.allFiles
  ];

  Images().loadAllImages();
  binding.addPostFrameCallback((_) async {
    BuildContext context = binding.rootElement as BuildContext;
    List<Future> futures = [];
    for (var asset in toLoad) {
      futures.add(precacheImage(AssetImage(asset), context));
    }
    await Future.wait(futures);
  });

  final gameRouter = GameRouter(systemData, playerData);
  gameState = GameState(gameRouter, playerData, systemData,
      currentMenuPage: MenuPageType.startMenuPage);
  gameRouter.gameStateComponent = GameStateComponent(gameState);

  gameState.currentRoute = startInGame ? routes.gameplay : routes.blank;

  runApp(
    Material(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Listener(
          onPointerHover: (event) {
            gameRouter.onMouseMove(event);
          },
          onPointerMove: (event) {
            // if (event.kind == PointerDeviceKind.mouse) {
            if (event.kind == PointerDeviceKind.mouse && event.buttons == 2) {
              gameRouter.onSecondaryMove(event);
            } else {
              gameRouter.onTapMove(event);
            }
            // }

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
            // if (event.kind == PointerDeviceKind.mouse) {
            if (event.kind == PointerDeviceKind.mouse && event.buttons == 2) {
              isSecondaryPointer[event.pointer] = true;
              gameRouter.onSecondaryTapDown(event);
            } else {
              isSecondaryPointer[event.pointer] = false;

              gameRouter.onTapDown(event);
            }
            // }
          },
          onPointerUp: (event) {
            // if (event.kind == PointerDeviceKind.mouse) {
            if (event.kind == PointerDeviceKind.mouse &&
                isSecondaryPointer[event.pointer] == true) {
              gameRouter.onSecondaryTapUp(event);
            } else {
              gameRouter.onTapUp(event);
            }
            // }
            isSecondaryPointer.remove(event.pointer);
          },
          onPointerCancel: (event) {
            // if (event.kind == PointerDeviceKind.mouse) {
            if (event.kind == PointerDeviceKind.mouse &&
                isSecondaryPointer[event.pointer] == true) {
              gameRouter.onSecondaryTapCancel();
            } else {
              gameRouter.onTapCancel();
            }
            // }
            isSecondaryPointer.remove(event.pointer);
          },
          child: RawKeyboardListener(
            focusNode: node,
            onKey: gameRouter.onKeyEvent,
            child: GameWidget(
                backgroundBuilder: (context) {
                  if (gameState.currentRoute == routes.gameplay) {
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
                      "LOADING",
                      style: defaultStyle,
                    ).animate().fadeIn(),
                  );
                },
                game: gameRouter,
                overlayBuilderMap: Map<String,
                    Widget Function(BuildContext, GameRouter)>.fromEntries([
                  overlay.pauseMenu,
                  overlay.mainMenu,
                  overlay.caveFront,
                  overlay.deathScreen,
                  overlay.attributeSelection,
                ])),
          ),
        ),
      ),
    ),
  );
}

class GameRouter extends Forge2DGame with ScrollDetector, WindowListener {
  late final RouterComponent router;

  GameRouter(SystemData systemData, PlayerData playerData)
      : super(gravity: Vector2.zero(), zoom: 1) {
    playerDataComponent = PlayerDataComponent(playerData);
    systemDataComponent = SystemDataComponent(systemData);
  }

  late PlayerDataComponent playerDataComponent;
  late SystemDataComponent systemDataComponent;
  late GameStateComponent gameStateComponent;

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
        routes.transition: Route(Component.new, maintainState: false),
        routes.gameplay: Route(
            playerDataComponent.dataObject.selectedLevel.buildEnvrioment,
            maintainState: false),
      },
      initialRoute: gameStateComponent.gameState.currentRoute,
    );
    add(systemDataComponent);
    add(playerDataComponent);
    add(gameStateComponent);
    add(router);
    await super.onLoad();
  }

  @override
  void onMount() {
    super.onMount();
    if (!startInGame) {
      overlays.add(caveFront.key);
      overlays.add(mainMenu.key);
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
