import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/cupertino.dart';
import '../test.dart';
import 'event_management.dart';
import '../entities/entity_class.dart';
import '../resources/enums.dart';
import '../resources/constants/priorities.dart';
import 'background.dart';
import 'enviroment.dart';

extension PositionProvider on Entity {
  Vector2 get position => body.worldCenter;
}

class ForestGame extends GameEnviroment {
  late EventManagement enemyManagement;
  late BackgroundComponent forestBackground;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // forestBackground = level.buildBackground(this);
    enemyManagement = ForestEnemyManagement(this);
    add(enemyManagement);
    // add(forestBackground);
    conductTests(this);
  }

  @override
  GameLevel level = GameLevel.mushroomForest;
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
}

class ForestEnemyManagement extends EventManagement {
  @override
  List<GameEvent> eventsToDo = [];

  ForestEnemyManagement(super.gameEnviroment) {
    eventsToDo.addAll([
      // EnemyEvent(
      //   gameEnviroment,
      //   this,
      //   isBigBoss: false,
      //   clusterSpread: 4,
      //   enemyClusters: [EnemyCluster(EnemyType.mushroomHopper, 1)],
      //   numberOfClusters: 1,
      //   maxEnemies: 2,
      //   eventTriggerInterval: (1, 1),
      //   levels: (0, 1),
      //   eventBeginEnd: (1, 500),
      //   spawnLocation: SpawnLocation.outside,
      // ),
      // EnemyEvent(
      //   gameEnviroment,
      //   this,
      //   isBigBoss: false,
      //   clusterSpread: 4,
      //   enemyClusters: [EnemyCluster(EnemyType.mushroomBurrower, 1)],
      //   numberOfClusters: 1,
      //   maxEnemies: 2,
      //   eventTriggerInterval: (1, 1),
      //   levels: (0, 1),
      //   eventBeginEnd: (1, 500),
      //   spawnLocation: SpawnLocation.outside,
      // ),
      // EnemyEvent(
      //   gameEnviroment,
      //   this,
      //   isBigBoss: false,
      //   clusterSpread: 4,
      //   enemyClusters: [EnemyCluster(EnemyType.mushroomBoomer, 1)],
      //   numberOfClusters: 1,
      //   maxEnemies: 2,
      //   eventTriggerInterval: (1, 1),
      //   levels: (0, 1),
      //   eventBeginEnd: (1, 500),
      //   spawnLocation: SpawnLocation.outside,
      // ),
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 5,
        enemyClusters: [EnemyCluster(EnemyType.mushroomRunner, 2)],
        numberOfClusters: 1,
        maxEnemies: 10,
        eventTriggerInterval: (1, 1),
        levels: (0, 1),
        eventBeginEnd: (1, 500),
        spawnLocation: SpawnLocation.outside,
      ),
      // EnemyEvent(
      //   gameEnviroment,
      //   this,
      //   isBigBoss: false,
      //   clusterSpread: 1,
      //   enemyClusters: [EnemyCluster(EnemyType.mushroomDummy, 1)],
      //   numberOfClusters: 20,
      //   maxEnemies: 20,
      //   eventTriggerInterval: (0, 0),
      //   levels: (0, 1),
      //   eventBeginEnd: (1, null),
      //   spawnLocation: SpawnLocation.inside,
      // ),
    ]);
  }
}
