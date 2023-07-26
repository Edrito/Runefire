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
  late EnemyManagement enemyManagement;
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

class ForestEnemyManagement extends EnemyManagement {
  @override
  List<EnemyConfig> enemyEventsToDo = [];

  ForestEnemyManagement(super.gameEnviroment) {
    enemyEventsToDo.addAll([
      EnemyConfig(
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomBrawler, 5)],
        numberOfClusters: 1,
        onWaveComplete: () {},
        maxEnemies: 100,
        spawnIntervalSeconds: 3,
        spawnInterval: (1, 120),
        spawnLocation: SpawnLocation.outside,
      ),
      EnemyConfig(
        isBigBoss: true,
        clusterSpread: 1,
        enemyClusters: [EnemyCluster(EnemyType.mushroomBrawler, 1)],
        numberOfClusters: 1,
        onWaveComplete: () {},
        maxEnemies: 1,
        spawnIntervalSeconds: 1,
        spawnInterval: (15, null),
        spawnLocation: SpawnLocation.outside,
      ),
      // (
      //   EnemyType.mushroomBrawler,
      //   EnemyConfig(
      //     clusterSize: 5,
      //     isBoss: false,
      //     numberOfClusters: 1,
      //     onWaveComplete: () {},
      //     maxEnemies: 5,
      //     spawnIntervalSeconds: 1,
      //     spawnInterval: (10, 15),
      //     spawnLocation: SpawnLocation.outside,
      //   )
      // )
    ]);
  }
}
