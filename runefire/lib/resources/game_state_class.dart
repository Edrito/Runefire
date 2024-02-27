import 'dart:async';
import 'dart:ffi';

import 'package:flame/components.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/achievements/achievements.dart';
import 'package:runefire/entities/input_priorities.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/menus/overlays.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/entities/entity_class.dart';

import 'package:runefire/player/player.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/game/enviroment_mixin.dart';
import 'package:runefire/game/menu_game.dart';
import 'package:runefire/main.dart';
import 'package:runefire/menus/menus.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/resources/data_classes/system_data.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/constants/routes.dart' as routes;
import 'package:runefire/menus/overlays.dart' as overlays;

class OverlayMessage {
  OverlayMessage({
    required this.title,
    this.description = '',
    this.duration = 5,
    this.isImportant = false,
    this.showBackground = true,
    this.image,
  });
  final String title;
  final String description;
  final double duration;
  final bool isImportant;
  final bool showBackground;
  final String? image;
}

class GameState {
  factory GameState() {
    return _instance;
  }
  GameState._internal();

  static final GameState _instance = GameState._internal();

  void initParameters({
    required GameRouter gameRouter,
    required PlayerData playerData,
    required SystemData systemData,
    required MenuPageType currentMenuPage,
  }) {
    this.gameRouter = gameRouter;
    this.playerData = playerData;
    this.systemData = systemData;
    this.currentMenuPage = currentMenuPage;
  }

  late GameStateComponent parentComponent;
  late final SystemData systemData;
  late final PlayerData playerData;
  late final GameRouter gameRouter;
  late MenuPageType currentMenuPage;

  late GlobalKey centerBackgroundKey;

  late final StreamController<OverlayMessage> textOverlayController =
      StreamController<OverlayMessage>();

  String? currentOverlay;
  late String currentRoute;
  bool transitionOccuring = false;

  void displayOverlayMessage(OverlayMessage message) {
    textOverlayController.add(message);
  }

  void obtainAchievement(Achievements achievement) {
    if (playerData.unlockedAchievements.contains(achievement)) {
      return;
    }
    playerData.addAchievement(achievement);
    displayOverlayMessage(
      OverlayMessage(
        title: achievement.getInformation[0],
        description: achievement.getInformation[1],
        duration: 2,
        image: achievement.getImage,
      ),
    );
  }

  //Key and audiopool
  //Key format is {audioScope}_{audioLocation}
  Map<(AudioScope, String), AudioPool> audioPools = {};

  void removeAudioPools(AudioScope audioScope, [String? audioLocation]) {
    List<MapEntry<(AudioScope, String), AudioPool>> listToRemove;
    if (audioLocation != null) {
      listToRemove = audioPools.entries
          .where(
            (element) =>
                element.key.$1 == audioScope && element.key.$2 == audioLocation,
          )
          .toList();
      return;
    } else {
      listToRemove = audioPools.entries
          .where((element) => element.key.$1 == audioScope)
          .toList();
    }

    for (final element in listToRemove) {
      element.value.audioCache.clear(element.key.$2);
      audioPools.remove(element.key);
    }
  }

  Future<void> playAudio(
    String audioLocation, {
    AudioType audioType = AudioType.sfx,
    AudioDurationType audioScopeType = AudioDurationType.short,
    AudioScope audioScope = AudioScope.game,
    bool useAudioPool = false,
    int maxPlayers = 3,
    bool isLooping = false,
  }) async {
    // return;

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
    volume = volume.clamp(0, 1);

    if (useAudioPool) {
      final key = (audioScope, audioLocation);
      audioPools[key] ??= await FlameAudio.createPool(
        audioLocation,
        maxPlayers: maxPlayers,
      );
      audioPools[key]?.start(volume: volume);
      return;
    }

    switch (audioScopeType) {
      case AudioDurationType.bgm:
        FlameAudio.bgm.play(audioLocation, volume: volume);
        break;
      case AudioDurationType.short:
        if (isLooping) {
          FlameAudio.loop(audioLocation, volume: volume);
        } else {
          FlameAudio.play(audioLocation, volume: volume);
        }
        break;

      case AudioDurationType.long:
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
  bool get gameIsPlaying =>
      gameRouter.router.currentRoute.name == routes.gameplay &&
      !gameRouter.paused;

  Color get basePortalColor => ApolloColorPalette.lightCyan.color;
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
    final result =
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
  void pauseGame(
    String overlay, {
    bool pauseGame = true,
    bool wipeMovement = false,
  }) {
    final game = currentEnviroment;
    if (currentOverlay != null ||
        transitionOccuring ||
        game is! GameEnviroment) {
      return;
    }
    gameRouter.overlays.add(overlay);
    currentOverlay = overlay;
    if (wipeMovement) {
      game.player?.removeMoveVelocity(userInputPriority);
      InputManager().activeGameActions.clear();
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
      menuGame = currentEnviroment! as MenuGame;
    }

    if (page == MenuPageType.weaponMenu) {
      menuGame?.addPlayer(null);
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
  void toggleGameStart(String? newRoute) {
    resumeGame();
    InputManager().buildTimer();
    var tempRoute = newRoute;
    if (tempRoute != null) {
      Future.delayed(Duration.zero).then((_) {
        gameRouter.router.pushReplacementNamed(tempRoute!);
        parentComponent.notifyListeners();
      });
    } else {
      gameRouter.router.pushReplacementNamed(routes.blank);
      tempRoute = routes.blank;
      Future.delayed(Duration.zero).then((_) {
        gameRouter.overlays.add(overlays.caveFront.key);
        gameRouter.overlays.add(overlays.mainMenu.key);
        parentComponent.notifyListeners();
      });
    }
    currentRoute = tempRoute;
  }

  void endGame(
    EndGameState endGameState, [
    bool restart = false,
    MenuPageType? customMenuPage,
  ]) {
    final player = currentPlayer;
    if (player != null && player.enviroment is GameEnviroment) {
      gameRouter.playerDataComponent.dataObject
          .modifyGameVariables(endGameState, player.gameEnviroment);
      gameRouter.playerDataComponent.dataObject.updateInformation(player);
    }

    if (!restart) {
      toggleGameStart(null);
      changeMainMenuPage(
        customMenuPage ??
            (endGameState == EndGameState.win && false
                ? MenuPageType.weaponMenu
                : MenuPageType.startMenuPage),
        false,
      );
    } else {
      toggleGameStart(routes.gameplay);
    }
    resumeGame();
  }

  void killPlayer(
    EndGameState gameEndState,
    Player player,
    DamageInstance instance,
  ) {
    if (transitionOccuring) {
      return;
    }

    transitionOccuring = true;
    player.game.gameAwait(2).then(
      (value) {
        transitionOccuring = false;
        if (gameEndState == EndGameState.playerDeath) {
          pauseGame(overlays.deathScreen.key, wipeMovement: true);
        } else {
          endGame(gameEndState);
        }
      },
    );
  }
}
