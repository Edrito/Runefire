import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/parallax.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/cupertino.dart';
import 'package:runefire/enviroment_interactables/areas.dart';
import 'package:runefire/enviroment_interactables/runes.dart';
import 'package:runefire/events/event_class.dart';
import 'package:runefire/events/event_types.dart';
import 'package:runefire/game/enviroment_mixin.dart';
import 'package:runefire/main.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/custom_test.dart';
import 'package:runefire/events/event_management.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/game/background.dart';
import 'package:runefire/game/enviroment.dart';

extension PositionProvider on Entity {
  Vector2 get position => body.worldCenter;
}

class ForestGame extends GameEnviroment {
  late SpriteComponent forestBackground;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    setEventManagement = ForestEnemyManagement(this);

    await Flame.images.loadAll([
      ...ImagesAssetsMushroomBoomer.allFilesFlame,
      ...ImagesAssetsMushroomBurrower.allFilesFlame,
      ...ImagesAssetsMushroomRunner.allFilesFlame,
      ...ImagesAssetsMushroomSpinner.allFilesFlame,
      ...ImagesAssetsMushroomHopper.allFilesFlame,
    ]);

    final srcSprite = await Sprite.load('background/mushroom_garden.png');

    forestBackground = SpriteComponent(
      sprite: srcSprite,
      priority: backgroundPriority,
      size: srcSprite.srcSize..scaledToHeight(null, env: this, amount: 3),
      anchor: Anchor.center,
    );

    add(forestBackground);
    conductTests(this);
    for (var i = 0; i < rng.nextInt(5) + 2; i++) {
      final location = SpawnLocation.entireMap.grabNewPosition(gameEnviroment);
      addPhysicsComponent([
        VineTrap(
          upgradeLevel: 0,
          position: location,
          gameEnviroment: gameEnviroment,
        ),
      ]);
    }
    for (var i = 0; i < rng.nextInt(5) + 2; i++) {
      final location = SpawnLocation.entireMap.grabNewPosition(gameEnviroment);
      addPhysicsComponent([
        HealingFont(
          upgradeLevel: 0,
          position: location,
          gameEnviroment: gameEnviroment,
        ),
      ]);
    }
    for (var i = 0; i < rng.nextInt(15) + 5; i++) {
      final location = SpawnLocation.entireMap.grabNewPosition(gameEnviroment);
      addPhysicsComponent([
        MushroomSpores(
          upgradeLevel: rng.nextInt(2),
          position: location,
          gameEnviroment: gameEnviroment,
        ),
      ]);
    }
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
      repeat: ImageRepeat.repeat,
    );

    parallax = Parallax(
      [
        backgroundLayer,
      ],
      size: Vector2.all(50),
    );

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

  ///game length = five minutes

  ForestEnemyManagement(super.gameEnviroment) {
    eventsToDo.addAll([
      //Mushroom Boomers
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomBoomer, 1)],
        numberOfClusters: 3,
        maxEnemies: 3,
        eventTriggerInterval: (1, 10),
        levels: (0, 0),
        eventBeginEnd: (30, 150),
        spawnLocation: SpawnLocation.outside,
      ),
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomBoomer, 1)],
        numberOfClusters: 3,
        maxEnemies: 3,
        eventTriggerInterval: (1, 10),
        levels: (0, 1),
        eventBeginEnd: (150, 280),
        spawnLocation: SpawnLocation.outside,
      ),
//Mushroom Runners

      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomRunner, 3)],
        numberOfClusters: 1,
        maxEnemies: 12,
        eventTriggerInterval: (1, 3),
        levels: (0, 0),
        eventBeginEnd: (1, 30),
        spawnLocation: SpawnLocation.outside,
      ),
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomRunner, 2)],
        numberOfClusters: 1,
        maxEnemies: 4,
        eventTriggerInterval: (1, 2),
        levels: (0, 0),
        eventBeginEnd: (30, 120),
        spawnLocation: SpawnLocation.outside,
      ),
      // EnemyEvent(
      //   gameEnviroment,
      //   this,
      //   isBigBoss: false,
      //   clusterSpread: 4,
      //   enemyClusters: [EnemyCluster(EnemyType.mushroomRunner, 4)],
      //   numberOfClusters: 1,
      //   maxEnemies: 8,
      //   eventTriggerInterval: (1, 3),
      //   levels: (1, 1),
      //   eventBeginEnd: (120, 280),
      //   spawnLocation: SpawnLocation.outside,
      // ),

//Scared
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomRunnerScared, 15)],
        numberOfClusters: 1,
        maxEnemies: 15,
        eventTriggerInterval: (20, 20),
        levels: (0, 0),
        eventBeginEnd: (60, 120),
        spawnLocation: SpawnLocation.outside,
      ),
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomRunnerScared, 4)],
        numberOfClusters: 1,
        maxEnemies: 10,
        eventTriggerInterval: (1, 3),
        levels: (0, 1),
        eventBeginEnd: (120, 160),
        spawnLocation: SpawnLocation.outside,
      ),

//Spinner
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomSpinner, 1)],
        numberOfClusters: 1,
        maxEnemies: 3,
        eventTriggerInterval: (1, 3),
        levels: (0, 0),
        eventBeginEnd: (120, 160),
        spawnLocation: SpawnLocation.outside,
      ),

      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomSpinner, 2)],
        numberOfClusters: 1,
        maxEnemies: 5,
        eventTriggerInterval: (1, 3),
        levels: (0, 1),
        eventBeginEnd: (160, 1000),
        spawnLocation: SpawnLocation.outside,
      ),
//shooter
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomShooter, 2)],
        numberOfClusters: 2,
        maxEnemies: 4,
        eventTriggerInterval: (1, 3),
        levels: (0, 1),
        eventBeginEnd: (30, 180),
        spawnLocation: SpawnLocation.outside,
      ),

//burrower
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomBurrower, 2)],
        numberOfClusters: 2,
        maxEnemies: 5,
        eventTriggerInterval: (5, 10),
        levels: (0, 0),
        eventBeginEnd: (140, 1000),
        spawnLocation: SpawnLocation.outside,
      ),
      KillEnemiesGameEvent(
        gameEnviroment,
        this,
        eventBeginEnd: (234, null),
        eventTriggerInterval: (1, 1),
        enemyFilter: (p0) => true,
      ),
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: true,
        clusterSpread: 4,
        enemyClusters: [EnemyCluster(EnemyType.mushroomBoss, 1)],
        numberOfClusters: 1,
        maxEnemies: 1,
        eventTriggerInterval: (1, 1),
        levels: (0, 0),
        eventBeginEnd: (235, null),
        spawnLocation: SpawnLocation.inside,
      ),

      DeathHandEvent(
        gameEnviroment,
        this,
        eventBeginEnd: (240, double.infinity),
        eventTriggerInterval: (1, 5),
      ),
      DeathHandEvent(
        gameEnviroment,
        this,
        fast: true,
        spawnLocation: SpawnLocation.infrontOfPlayer,
        eventBeginEnd: (400, double.infinity),
        eventTriggerInterval: (1, 4),
      ),
      EndGameEvent(
        gameEnviroment,
        this,
        eventBeginEnd: (240, null),
        eventTriggerInterval: (0, 0),
      ),
    ]);
  }
}
