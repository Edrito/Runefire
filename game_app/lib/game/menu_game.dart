import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:game_app/game/enviroment.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/enums.dart';
import '../resources/data_classes/player_data.dart';
import 'enviroment_mixin.dart';
import '../resources/visuals.dart';

class MenuGame extends Enviroment with PlayerFunctionality {
  bool initAddAttempt = false;
  List<RectangleComponent> platforms = [];
  late CharacterType currentPlayer;
  late String weaponHash;

  String reduceWeapons() {
    return game.playerDataComponent.dataObject.selectedWeapons.entries.fold("",
            (previousValue, element) => previousValue + element.value.name) +
        game.playerDataComponent.dataObject.selectedSecondaries.entries.fold(
            "", (previousValue, element) => previousValue + element.value.name);
  }

  @override
  void onLoad() async {
    game.componentsNotifier<PlayerDataComponent>().addListener(reAddPlayer);
    currentPlayer = game.playerDataComponent.dataObject.selectedPlayer;
    weaponHash = reduceWeapons();
    super.onLoad();
  }

  @override
  void onRemove() {
    game.componentsNotifier<PlayerDataComponent>().removeListener(reAddPlayer);
    super.onRemove();
  }

  void initPlatforms() async {
    const platformsLength = 5;
    for (var i = 0; i < platformsLength; i++) {
      if (player == null) return;
      final rectSize = Vector2(1.4 - (1.4 * i / platformsLength), .15);
      final rectPos =
          Vector2(0, ((player!.height.parameter / 2) - .25) - (i * -.2));
      final rect = RectangleComponent(
        anchor: Anchor.topCenter,
        size: rectSize,
        priority: -1,
        position: Vector2(0, 10),
        paint: ApolloColorPalette.lightBlue
            .withAlpha((255 * (1 - (1 * i / platformsLength))).round())
            .paint(),
      );
      platforms.add(rect);
      if (i != 0) {
        final infEffect = InfiniteEffectController(EffectController(
          duration: 1,
          curve: Curves.easeInOut,
          reverseDuration: 1,
          reverseCurve: Curves.easeInOut,
        ));
        rect.add(MoveEffect.by(
            Vector2((.012 * rng.nextDouble()) - .006, -.03), infEffect));
      }

      final effect =
          EffectController(duration: 1, curve: Curves.fastEaseInToSlowEaseOut);

      rect.add(MoveEffect.to(rectPos, effect));

      await Future.delayed(const Duration(milliseconds: 200));

      player?.add(rect);
    }
  }

  @override
  void addPlayer() async {
    if (!initAddAttempt) {
      initAddAttempt = true;
      return;
    }
    if (playerAdded) return;
    super.addPlayer();
    player?.isDisplay = true;
    // player?.height = 2;
    gameCamera.viewfinder.zoom = 75;

    if (platforms.isNotEmpty) return;

    initPlatforms();
  }

  void reAddPlayer() async {
    if (currentPlayer != game.playerDataComponent.dataObject.selectedPlayer) {
      currentPlayer = game.playerDataComponent.dataObject.selectedPlayer;
      removePlayer(false);
      addPlayer();
    }

    if (weaponHash != reduceWeapons()) {
      weaponHash = reduceWeapons();

      player?.initializeWeapons();

      final weapon = player?.currentWeapon;
      if (weapon != null) {
        await player?.setWeapon(weapon);
      }
    }
  }

  void removePlayer([bool removePlatforms = true]) {
    if (playerAdded) {
      player?.removeFromParent();
      player = null;
      if (!removePlatforms) return;
      for (var element in platforms) {
        element.removeFromParent();
      }
      platforms.clear();
    }
  }

  @override
  // TODO: implement level
  GameLevel get level => GameLevel.menu;
}
