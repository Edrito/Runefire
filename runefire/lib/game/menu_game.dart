import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:runefire/events/event_management.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/game/hexed_forest_game.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/game/enviroment_mixin.dart';
import 'package:runefire/resources/visuals.dart';

class MenuGame extends Enviroment with PlayerFunctionality {
  bool initAddAttempt = false;
  // List<RectangleComponent> platforms = [];
  late CharacterType currentPlayer;
  late String weaponHash;

  String reduceWeapons() {
    return game.playerDataComponent.dataObject.selectedWeapons.entries.fold(
          '',
          (previousValue, element) => previousValue + element.value.name,
        ) +
        game.playerDataComponent.dataObject.selectedSecondaries.entries.fold(
          '',
          (previousValue, element) => previousValue + element.value.name,
        );
  }

  @override
  Future<void> onLoad() async {
    game.componentsNotifier<PlayerDataComponent>().addListener(reAddPlayer);
    currentPlayer = game.playerDataComponent.dataObject.selectedPlayer;
    weaponHash = reduceWeapons();
    menuGameEventManagement.addToParent(this);
    addPlayer(menuGameEventManagement);
    super.onLoad();
  }

  late final menuGameEventManagement = MenuGameEventManagement(this);

  @override
  void onRemove() {
    game.componentsNotifier<PlayerDataComponent>().removeListener(reAddPlayer);
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    player?.height.baseParameter = getHeightScaleStep(
      size.y < size.x ? size.y : size.x,
    );
    player?.applyHeightToSprite();
    super.onGameResize(size);
  }

  @override
  Future<void> addPlayer(EventManagement? eventManagement) async {
    if (!initAddAttempt) {
      initAddAttempt = true;
      return;
    }
    if (playerAdded) {
      return;
    }
    super.addPlayer(eventManagement);
    player?.isDisplay = true;
    // player?.height = 2;
    // gameCamera.viewfinder.zoom = 75;
    await player?.loaded;
    onGameResize(gameCamera.visibleWorldRect.toVector2() * zoom);

    // if (platforms.isNotEmpty) return;

    // initPlatforms();
  }

  Future<void> reAddPlayer() async {
    if (currentPlayer != game.playerDataComponent.dataObject.selectedPlayer) {
      currentPlayer = game.playerDataComponent.dataObject.selectedPlayer;
      removePlayer(false);
      addPlayer(menuGameEventManagement);
    }

    if (weaponHash != reduceWeapons()) {
      weaponHash = reduceWeapons();

      player?.initializeWeapons();
    }
  }

  void removePlayer([bool removePlatforms = true]) {
    if (playerAdded) {
      player?.removeFromParent();
      player = null;
      if (!removePlatforms) return;
      // for (var element in platforms) {
      //   element.removeFromParent();
      // }
      // platforms.clear();
    }
  }

  @override
  // TODO: implement level
  GameLevel get level => GameLevel.menu;
}
