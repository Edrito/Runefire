import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/parallax.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/cupertino.dart';
import 'package:runefire/events/event_class.dart';
import 'package:runefire/events/event_types.dart';
import 'package:runefire/main.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/resources/visuals.dart';
import '../test.dart';
import '../events/event_management.dart';
import '../entities/entity_class.dart';
import '../resources/enums.dart';
import '../resources/constants/priorities.dart';
import 'background.dart';
import 'enviroment.dart';

extension PositionProvider on Entity {
  Vector2 get position => body.worldCenter;
}

class ForestGame extends GameEnviroment {
  // late BackgroundComponent forestBackground;
  late SpriteComponent forestBackground;
  late final Component entityShadow;
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    setEventManagement = ForestEnemyManagement(this);
    add(eventManagement);
    await Flame.images.loadAll([
      ...ImagesAssetsMushroomBoomer.allFilesFlame,
      ...ImagesAssetsMushroomBurrower.allFilesFlame,
      ...ImagesAssetsMushroomRunner.allFilesFlame,
      ...ImagesAssetsMushroomSpinner.allFilesFlame,
      ...ImagesAssetsMushroomHopper.allFilesFlame,
    ]);
    // forestBackground = level.buildBackground(this);
    final srcSprite = await Sprite.load('background/mushroom_garden.png');
    forestBackground = SpriteComponent(
        sprite: srcSprite,
        priority: backgroundPriority,
        size: srcSprite.srcSize..scaledToHeight(null, env: this, amount: 3),
        anchor: Anchor.center);

    entityShadow = SpriteShadows(this);
    add(entityShadow);
    add(forestBackground);
    conductTests(this);
  }

  @override
  GameLevel level = GameLevel.hexedForest;
}

class HexedForestBackground extends BackgroundComponent {
  HexedForestBackground(super.gameRef);

  @override
  FutureOr<void> onLoad() async {
    final backgroundLayer = await game.loadParallaxLayer(
      ParallaxImageData('background/mushroom_garden.png'),
      filterQuality: FilterQuality.none,
      alignment: Alignment.center,
      fill: LayerFill.height,
      repeat: ImageRepeat.repeat,
    );

    parallax = Parallax([
      backgroundLayer,
    ], size: Vector2.all(50));

    anchor = Anchor.center;
    priority = backgroundPriority;
    scale = Vector2.all(.02);
    size = Vector2.all(50);
    return super.onLoad();
  }
}

class MenuGameEventManagement extends EventManagement {
  @override
  List<GameEvent> eventsToDo = [];

  MenuGameEventManagement(super.gameEnviroment);
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
        enemyClusters: [EnemyCluster(EnemyType.mushroomRunner, 1)],
        numberOfClusters: 3,
        maxEnemies: 10,
        eventTriggerInterval: (1, 5),
        levels: (0, 1),
        eventBeginEnd: (2, 30),
        spawnLocation: SpawnLocation.outside,
      ),
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomRunner, 1)],
        numberOfClusters: 2,
        maxEnemies: 15,
        eventTriggerInterval: (1, 5),
        levels: (0, 1),
        eventBeginEnd: (30, 120),
        spawnLocation: SpawnLocation.outside,
      ),
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomBoomer, 1)],
        numberOfClusters: 1,
        maxEnemies: 8,
        eventTriggerInterval: (2, 10),
        levels: (0, 1),
        eventBeginEnd: (60, 600),
        spawnLocation: SpawnLocation.outside,
      ),
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomRunner, 1)],
        numberOfClusters: 3,
        maxEnemies: 20,
        eventTriggerInterval: (1, 5),
        levels: (0, 1),
        eventBeginEnd: (75, 240),
        spawnLocation: SpawnLocation.outside,
      ),
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomBurrower, 1)],
        numberOfClusters: 1,
        maxEnemies: 2,
        eventTriggerInterval: (1, 1),
        levels: (0, 1),
        eventBeginEnd: (1, 500),
        spawnLocation: SpawnLocation.outside,
      ),
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomBoomer, 1)],
        numberOfClusters: 1,
        maxEnemies: 2,
        eventTriggerInterval: (1, 1),
        levels: (0, 1),
        eventBeginEnd: (1, 500),
        spawnLocation: SpawnLocation.outside,
      ),
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 10,
        enemyClusters: [EnemyCluster(EnemyType.mushroomShooter, 2)],
        numberOfClusters: 2,
        maxEnemies: 10,
        eventTriggerInterval: (1, 1),
        levels: (0, 1),
        eventBeginEnd: (1, 30),
        spawnLocation: SpawnLocation.outside,
      ),
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 2,
        enemyClusters: [EnemyCluster(EnemyType.mushroomSpinner, 1)],
        numberOfClusters: 3,
        maxEnemies: 2,
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
      DeathHandEvent(
        gameEnviroment,
        this,
        fast: true,
        eventBeginEnd: (90, 900),
        eventTriggerInterval: (1, 5),
      ),

      EndGameEvent(gameEnviroment, this,
          eventBeginEnd: (2, 2), eventTriggerInterval: (0, 0))
    ]);
  }
}
