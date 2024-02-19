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

  ForestEnemyManagement(super.gameEnviroment) {
    eventsToDo.addAll([
      EnemyEvent(
        gameEnviroment,
        this,
        isBigBoss: false,
        clusterSpread: 25,
        enemyClusters: [EnemyCluster(EnemyType.mushroomDummy, 20)],
        numberOfClusters: 1,
        maxEnemies: 20,
        eventTriggerInterval: (1, 1),
        levels: (0, 1),
        eventBeginEnd: (2, 30),
        spawnLocation: SpawnLocation.inside,
      ),
      // EnemyEvent(
      //   gameEnviroment,
      //   this,
      //   isBigBoss: false,
      //   clusterSpread: 4,
      //   enemyClusters: [EnemyCluster(EnemyType.mushroomRunner, 1)],
      //   numberOfClusters: 2,
      //   maxEnemies: 15,
      //   eventTriggerInterval: (1, 5),
      //   levels: (0, 1),
      //   eventBeginEnd: (30, 120),
      //   spawnLocation: SpawnLocation.outside,
      // ),
      // EnemyEvent(
      //   gameEnviroment,
      //   this,
      //   isBigBoss: false,
      //   clusterSpread: 4,
      //   enemyClusters: [EnemyCluster(EnemyType.mushroomBoomer, 1)],
      //   numberOfClusters: 1,
      //   maxEnemies: 8,
      //   eventTriggerInterval: (2, 10),
      //   levels: (0, 1),
      //   eventBeginEnd: (60, 600),
      //   spawnLocation: SpawnLocation.outside,
      // ),
      // EnemyEvent(
      //   gameEnviroment,
      //   this,
      //   isBigBoss: false,
      //   clusterSpread: 4,
      //   enemyClusters: [EnemyCluster(EnemyType.mushroomRunner, 1)],
      //   numberOfClusters: 3,
      //   maxEnemies: 20,
      //   eventTriggerInterval: (1, 5),
      //   levels: (0, 1),
      //   eventBeginEnd: (2, 240),
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

      // EnemyEvent(
      //   gameEnviroment,
      //   this,
      //   isBigBoss: false,
      //   clusterSpread: 5,
      //   enemyClusters: [EnemyCluster(EnemyType.mushroomSpinner, 5)],
      //   numberOfClusters: 3,
      //   maxEnemies: 10,
      //   eventTriggerInterval: (1, 2),
      //   levels: (0, 1),
      //   eventBeginEnd: (4, 500),
      //   spawnLocation: SpawnLocation.outside,
      // ),
      // DeathHandEvent(
      //   gameEnviroment,
      //   this,
      //   fast: true,
      //   eventBeginEnd: (150, 400),
      //   eventTriggerInterval: (1, 5),
      // ),
      // DeathHandEvent(
      //   gameEnviroment,
      //   this,
      //   fast: true,
      //   spawnLocation: SpawnLocation.infrontOfPlayer,
      //   eventBeginEnd: (400, 1000),
      //   eventTriggerInterval: (1, 4),
      // ),
      // EndGameEvent(
      //   gameEnviroment,
      //   this,
      //   eventBeginEnd: (150, 120),
      //   eventTriggerInterval: (0, 0),
      // ),
    ]);
  }
}
