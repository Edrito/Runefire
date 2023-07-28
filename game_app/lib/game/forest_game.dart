import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_app/entities/player.dart';
import '../entities/enemy_management.dart';
import '../resources/enums.dart';
import '../resources/constants/priorities.dart';
import 'background.dart';
import 'enviroment.dart';

extension PositionProvider on Player {
  Vector2 get position => body.worldCenter;
}

class ForestGame extends GameEnviroment {
  late EventManagement enemyManagement;
  late BackgroundComponent forestBackground;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    forestBackground = level.buildBackground(this);
    enemyManagement = ForestEnemyManagement(this);
    add(enemyManagement);
    add(forestBackground);
  }

  @override
  GameLevel level = GameLevel.forest;
}

class ForestBackground extends BackgroundComponent {
  ForestBackground(super.gameRef);

  @override
  FutureOr<void> onLoad() async {
    final backgroundLayer = await game.loadParallaxLayer(
      ParallaxImageData('background/test_tile.png'),
      filterQuality: FilterQuality.none,
      fill: LayerFill.none,
      repeat: ImageRepeat.repeat,
    );

    parallax = Parallax(
      [
        backgroundLayer,
      ],
    );

    anchor = Anchor.center;
    priority = backgroundPriority;

    positionType = PositionType.viewport;

    size = size / 50;
    return super.onLoad();
  }

  @override
  GameLevel get gameLevel => GameLevel.forest;
}

class ForestEnemyManagement extends EventManagement {
  @override
  List<GameEvent> eventsToDo = [];

  ForestEnemyManagement(super.gameEnviroment) {
    eventsToDo.addAll([
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomBrawler, 3)],
        numberOfClusters: 2,
        maxEnemies: 40,
        eventTriggerInterval: (4, 7),
        eventBeginEnd: (1, 500),
        spawnLocation: SpawnLocation.outside,
      ),
      // EnemyEvent(
      //   gameEnviroment,
      //   this,
      //   isBigBoss: true,
      //   clusterSpread: 3,
      //   enemyClusters: [EnemyCluster(EnemyType.mushroomBoss, 4)],
      //   numberOfClusters: 5,
      //   maxEnemies: 5,
      //   eventTriggerInterval: (0, 0),
      //   eventBeginEnd: (5, null),
      //   spawnLocation: SpawnLocation.outside,
      // ),
      // EnemyEvent(
      //   gameEnviroment,
      //   this,
      //   isBigBoss: true,
      //   clusterSpread: 1,
      //   enemyClusters: [EnemyCluster(EnemyType.mushroomBoss, 1)],
      //   numberOfClusters: 1,
      //   maxEnemies: 1,
      //   spawnIntervalSeconds: 1,
      //   spawnInterval: (5, null),
      //   spawnLocation: SpawnLocation.inside,
      // ),
    ]);
  }
}
