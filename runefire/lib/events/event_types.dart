import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:runefire/enviroment_interactables/interactable.dart';
import 'package:runefire/events/event_class.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:uuid/uuid.dart';

import 'package:runefire/game/enviroment_mixin.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/resources/damage_type_enum.dart';

class DeathHandEvent extends PositionEvent {
  DeathHandEvent(
    super.gameEnviroment,
    super.eventManagement, {
    required super.eventBeginEnd,
    required super.eventTriggerInterval,
    super.spawnPosition,
    this.fast = false,
    super.spawnLocation = SpawnLocation.onPlayer,
  });
  bool fast;

  @override
  void endEvent() {}

  @override
  Future<void> onGoingEvent() async {
    final positionOfHand =
        spawnPosition ?? spawnLocation!.grabNewPosition(gameEnviroment, 1);
    final spriteAnimation = await spriteAnimations.ghostHandAttack1;

    final spriteTickSpeed = fast ? .06 : .1;
    spriteAnimation.stepTime = spriteTickSpeed;

    final areaEffect = AreaEffect(
      position: positionOfHand,
      overridePriority: 10,
      radius: 1.5 + (rng.nextDouble() * 1),
      sourceEntity: gameEnviroment.god!,
      collisionDelay: spriteTickSpeed * 13,
      animationRandomlyFlipped: true,
      onTick: (entity, areaId) async {
        entity.applyHitAnimation(
          await spriteAnimations.scratchEffect1,
          entity.center,
          DamageType.fire.color,
        );
      },
      animationComponent: SimpleStartPlayEndSpriteAnimationComponent(
        spawnAnimation: spriteAnimation,
        durationType: DurationType.instant,
      ),
      damage: {DamageType.fire: (double.infinity, double.infinity)},
    );

    gameEnviroment.addPhysicsComponent([areaEffect]);
  }

  @override
  Future<void> startEvent() async {}
}

class EnemyEvent extends PositionEvent {
  EnemyEvent(
    super.gameEnviroment,
    super.eventManagement, {
    required this.maxEnemies,
    required this.enemyClusters,
    required this.levels,
    required this.clusterSpread,
    required this.numberOfClusters,
    required this.isBigBoss,
    required super.eventBeginEnd,
    required super.eventTriggerInterval,
    this.boundsScope = BossBoundsScope.viewportSize,
    this.bossBoundsIsCircular = false,
    this.bossBoundsSize,
    super.spawnLocation,
    super.spawnPosition,
  }) {
    bossBoundsSize ??= Vector2.all(6);
  }

  final List<EnemyCluster> enemyClusters;
  final bool isBigBoss;
  final int maxEnemies;
  final int numberOfClusters;

  bool bossBoundsIsCircular;
  BossBoundsScope boundsScope;
  double clusterSpread;
  List<Enemy> enemies = [];

  Vector2? bossBoundsSize;

  int get enemyCount => enemies.length;

  ///Getter that gets a random value between level tuple
  int get randomLevel => rng.nextInt((levels.$2 - levels.$1) + 1) + levels.$1;

  bool get enemyLimitReached {
    return enemyCount >= maxEnemies;
  }

  final (int, int) levels;

  void incrementEnemyCount(List<Enemy> amount, bool remove) {
    if (remove) {
      for (final element in amount) {
        enemies.remove(element);
      }
    } else {
      enemies.addAll(amount);
    }

    if (enemyCount == 0 && hasCompleted) {
      endEvent();
    }
  }

  void onBigBoss(bool isDead) {
    if (isDead) {
      eventManagement.eventTimer?.timer.resume();
      gameEnviroment.customFollow.enable();
      gameEnviroment.unPauseGameTimer();
      for (final element in eventManagement.activeEventConfigTimers.entries) {
        element.value.timer.resume();
      }
      gameEnviroment.removeBossBounds();
    } else {
      spawnEnemies();
      eventManagement.eventTimer?.timer.pause();
      gameEnviroment.pauseGameTimer();

      if (boundsScope == BossBoundsScope.viewportSize) {
        gameEnviroment.customFollow.disable();
      }

      for (final element in eventManagement.activeEventConfigTimers.entries) {
        element.value.timer.pause();
      }
      gameEnviroment.createBossBounds(bossBoundsIsCircular, this);
    }
  }

  void spawnEnemies() {
    for (var _ = 0; _ < numberOfClusters; _++) {
      final position =
          spawnLocation?.grabNewPosition(gameEnviroment) ?? spawnPosition;
      for (final cluster in enemyClusters) {
        final enemyCluster = <Enemy>[];
        for (var i = 0; i < cluster.clusterSize; i++) {
          if (enemyLimitReached) {
            break;
          }

          final spreadPos = (position ?? Vector2.zero()) +
              (Vector2.random() * clusterSpread) -
              Vector2.all(clusterSpread / 2);

          final enemy = cluster.enemyType
              .build(spreadPos, gameEnviroment, randomLevel, eventManagement);
          enemy.onDeath.add((_) {
            incrementEnemyCount([enemy], true);
          });
          enemyCluster.add(enemy);
        }

        incrementEnemyCount(enemyCluster, false);

        gameEnviroment.addPhysicsComponent(enemyCluster, duration: .5);
      }
    }
  }

  @override
  void endEvent() {
    if (isBigBoss) {
      onBigBoss(true);
    }
  }

  @override
  Future<void> onGoingEvent() async {
    if (!isBigBoss) {
      spawnEnemies();
    }
  }

  @override
  void startEvent() {
    if (isBigBoss) {
      onBigBoss(false);
    } else {
      spawnEnemies();
    }
  }
}

class EnemyCluster {
  EnemyCluster(this.enemyType, this.clusterSize);

  final int clusterSize;
  final EnemyType enemyType;
}

class EndGameEvent extends GameEvent {
  EndGameEvent(
    super.gameEnviroment,
    super.eventManagement, {
    required super.eventBeginEnd,
    required super.eventTriggerInterval,
  });

  @override
  void endEvent() {}

  @override
  Future<void> onGoingEvent() async {}

  @override
  void startEvent() {
    gameEnviroment.gameHasEnded = true;
    GameState()
        .displayOverlayMessage(OverlayMessage(title: endGameMessages.random()));
    final exitVector =
        (Vector2.random() * gameEnviroment.boundsDistanceFromCenter * 2) -
            Vector2.all(gameEnviroment.boundsDistanceFromCenter);
    gameEnviroment.player?.add(ExitArrowPainter(gameEnviroment, exitVector));
    gameEnviroment.addPhysicsComponent([
      ExitPortal(
        initialPosition: exitVector,
        gameEnviroment: gameEnviroment,
        player: gameEnviroment.player!,
      ),
    ]);
  }
}
