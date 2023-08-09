import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../player/player.dart';
import '../game/enviroment.dart';
import '../game/enviroment_mixin.dart';
import '../game/menu_game.dart';
import '../main.dart';
import '../menus/menus.dart';
import 'data_classes/player_data.dart';
import 'data_classes/system_data.dart';
import 'enums.dart';
import 'constants/routes.dart' as routes;
import '../menus/overlays.dart' as overlays;

class GameState {
  GameState(this.gameRouter, this.playerData, this.systemData,
      {required this.currentMenuPage});
  late GameStateComponent parentComponent;
  final SystemData systemData;
  final PlayerData playerData;
  final GameRouter gameRouter;

  late GlobalKey centerBackgroundKey;

  MenuPageType currentMenuPage;
  String? currentOverlay;
  late String currentRoute;
  bool transitionOccuring = false;

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
        volume = volume =
            gameRouter.systemDataComponent.dataObject.musicVolume / 100;
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
}

class GameStateComponent extends Component with Notifier {
  GameStateComponent(this._gameStateObject) {
    _gameStateObject.parentComponent = this;
  }
  final GameState _gameStateObject;

  GameState get gameState => _gameStateObject;
}

extension GameStateGetters on GameState {
  Color get basePortalColor => const Color.fromARGB(255, 62, 184, 255);
  Color portalColor([bool returnBlueIfNotLevelMenu = false]) {
    if (returnBlueIfNotLevelMenu && !menuPageIsLevel) return basePortalColor;
    if (playerData.selectedDifficulty != GameDifficulty.regular) {
      return playerData.selectedDifficulty.color;
    }
    return playerData.selectedLevel.levelColor;
  }

  bool get menuPageIsLevel => currentMenuPage == MenuPageType.levelMenu;

  bool get gameIsPaused => gameRouter.paused;

  Enviroment? get currentEnviroment {
    var result =
        gameRouter.router.currentRoute.children.whereType<Enviroment>();

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
}

extension GameStateFunctions on GameState {
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

  void handlePlayerPreview(MenuPageType page) {
    MenuGame? menuGame;
    if (currentEnviroment is MenuGame) {
      menuGame = currentEnviroment as MenuGame;
    }

    if (page == MenuPageType.weaponMenu) {
      menuGame?.addPlayer();
    } else {
      menuGame?.removePlayer();
    }
  }

  void changeMainMenuPage(MenuPageType page, [bool setState = true]) {
    // toggleGameStart(null);
    handlePlayerPreview(page);

    currentMenuPage = page;

    ///This function rebuilds the overlay "MainMenu"
    parentComponent.notifyListeners();
  }

  ///null route = go to main menu
  ///string route = leave main menu to route
  void toggleGameStart(String? route) {
    gameRouter.router.pushReplacementNamed(routes.blank);
    resumeGame();
    if (route != null) {
      Future.delayed(const Duration(milliseconds: 50)).then((_) {
        gameRouter.router.pushReplacementNamed(route!);
        parentComponent.notifyListeners();
      });
    } else {
      route = routes.blank;
      Future.delayed(const Duration(milliseconds: 50)).then((_) {
        gameRouter.overlays.add(overlays.caveFront.key);
        gameRouter.overlays.add(overlays.mainMenu.key);
        parentComponent.notifyListeners();
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
      changeMainMenuPage(MenuPageType.startMenuPage, false);
    } else {
      toggleGameStart(routes.gameplay);
    }
    resumeGame();
  }

  void killPlayer(bool showDeathScreen, Player player) {
    player.setEntityStatus(EntityStatus.dead);
    transitionOccuring = true;
    Future.delayed(2.seconds).then(
      (value) {
        transitionOccuring = false;
        if (showDeathScreen) {
          pauseGame(overlays.deathScreen.key, wipeMovement: true);
        } else {
          endGame(false);
        }
      },
    );
  }
}
