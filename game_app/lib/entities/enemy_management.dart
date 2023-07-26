import 'dart:async';

import 'package:flame/components.dart';
import 'package:uuid/uuid.dart';

import '../game/enviroment_mixin.dart';
import '../resources/enums.dart';
import '../resources/functions/vector_functions.dart';
import '../game/enviroment.dart';
import '../main.dart';
import '../resources/constants/priorities.dart';
import 'enemy.dart';

enum SpawnLocation {
  inside,
  outside,
  both,
  onPlayer,
}

extension SpawnLocationExtension on SpawnLocation {
  Vector2 grabNewPosition(GameEnviroment gameEnviroment) {
    Vector2 position;
    switch (this) {
      case SpawnLocation.both:
        position = generateRandomGamePositionInViewport(
            rng.nextBool(), gameEnviroment);
        break;
      case SpawnLocation.inside:
        position = generateRandomGamePositionInViewport(true, gameEnviroment);

        break;
      case SpawnLocation.onPlayer:
        position = gameEnviroment.player?.center ?? Vector2.zero();
        break;
      case SpawnLocation.outside:
        position = generateRandomGamePositionInViewport(false, gameEnviroment);

        break;
      default:
        position = Vector2.zero();
    }
    return position;
  }
}

enum OnSpawnEnd {
  instantKill,
  periodicallyKill,
  noKill,
}

class EnemyConfig {
  EnemyConfig({
    required this.spawnInterval,
    required this.spawnIntervalSeconds,
    required this.maxEnemies,
    required this.enemyClusters,
    required this.clusterSpread,
    required this.numberOfClusters,
    required this.spawnLocation,
    required this.onWaveComplete,
    required this.isBigBoss,
  }) {
    configId = const Uuid().v4();
  }
  late final String configId;
  final (double, double?) spawnInterval;
  final double spawnIntervalSeconds;
  final int maxEnemies;
  double clusterSpread;
  final int numberOfClusters;
  final SpawnLocation spawnLocation;
  final Function onWaveComplete;
  final bool isBigBoss;
  final List<EnemyCluster> enemyClusters;
  bool hasCompleted = false;
}

class EnemyCluster {
  EnemyCluster(this.enemyType, this.clusterSize);
  final EnemyType enemyType;
  final int clusterSize;
}

abstract class EnemyManagement extends Component {
  EnemyManagement(this.gameEnviroment);
  abstract List<EnemyConfig> enemyEventsToDo;
  List<double> spawnTimes = [];

  GameTimerFunctionality gameEnviroment;

  TimerComponent? eventTimer;

  List<EnemyConfig> enemyEventsCurrentlyActive = [];
  List<EnemyConfig> enemyEventsFinished = [];
  Map<String, TimerComponent> activeEnemyConfigTimers = {};

  int enemiesSpawned = 0;

  ///Grab each interval the enemy management should create/remove timers
  void initEventTimes() {
    spawnTimes = [
      ...enemyEventsToDo.fold<List<double>>(
          [],
          (previousValue, element) => [
                ...previousValue,
                ...[
                  element.spawnInterval.$1,
                  if (element.spawnInterval.$2 != null)
                    element.spawnInterval.$2!
                ]
              ])
    ];
    spawnTimes.sort();
  }

  //Check if any events should be started
  void checkToDoEvents(double currentTime) {
    final eventsToParse = [
      ...enemyEventsToDo
          .where((element) => element.spawnInterval.$1 <= currentTime)
    ];
    final listOfIds = eventsToParse.map((e) => e.configId);
    enemyEventsToDo
        .removeWhere((element) => listOfIds.contains(element.configId));

    for (var element in eventsToParse) {
      if (element.spawnInterval.$2 != null) {
        activeEnemyConfigTimers[element.configId] = (TimerComponent(
            period: element.spawnIntervalSeconds,
            repeat: true,
            onTick: () => preformEnemyEvent(element),
            removeOnFinish: true))
          ..addToParent(this);
      }
    }

    enemyEventsCurrentlyActive.addAll(eventsToParse);

    final boss = eventsToParse.where((element) => element.isBigBoss);
    if (boss.isNotEmpty) {
      onBoss(false);
      preformEnemyEvent(boss.first);
    }
  }

  ///Check if any events should be ended
  void endActiveEvents(double currentTime) {
    final eventsToParse = [
      ...enemyEventsCurrentlyActive.where((element) {
        final endInterval = element.spawnInterval.$2;
        if (endInterval == null) return true;
        if (endInterval <= currentTime) {
          return true;
        }
        return false;
      })
    ];

    final listOfIds = eventsToParse.map((e) => e.configId);
    final activeTimers = activeEnemyConfigTimers.entries
        .where((element) => listOfIds.contains(element.key))
        .map((e) => e.value);
    for (var element in activeTimers) {
      element.removeFromParent();
    }
    activeEnemyConfigTimers
        .removeWhere((key, value) => listOfIds.contains(key));
    enemyEventsCurrentlyActive
        .removeWhere((element) => eventsToParse.contains(element));
    for (var element in eventsToParse) {
      element.hasCompleted = true;
    }
    enemyEventsFinished.addAll(eventsToParse);
  }

  void conductEvents() {
    final currentTime = gameEnviroment.timePassed;
    checkToDoEvents(currentTime);
    endActiveEvents(currentTime);
  }

  Map<String, int> enemyCount = {};

  void preformEnemyEvent(EnemyConfig enemyConfigObject) {
    spawnEnemy(enemyConfigObject);
  }

  bool enemyLimitReached(String configId, int maxEnemies) {
    enemyCount[configId] ??= 0;
    return enemyCount[configId]! >= maxEnemies;
  }

  void incrementEnemyCount(EnemyConfig enemyConfig, int amount) {
    enemyCount[enemyConfig.configId] =
        enemyCount[enemyConfig.configId]! + amount;
    final currentNumberEnemy = enemyCount[enemyConfig.configId]!;
    if (currentNumberEnemy == 0 && enemyConfig.hasCompleted) {
      enemyConfig.onWaveComplete();
    }
  }

  void spawnEnemy(EnemyConfig enemyConfig) {
    final position = enemyConfig.spawnLocation
        .grabNewPosition(gameEnviroment as GameEnviroment);

    for (var _ = 0; _ < enemyConfig.numberOfClusters; _++) {
      for (var cluster in enemyConfig.enemyClusters) {
        for (var i = 0; i < cluster.clusterSize; i++) {
          if (enemyLimitReached(enemyConfig.configId, enemyConfig.maxEnemies)) {
            return;
          }

          final spreadPos = position +
              (Vector2.random() * enemyConfig.clusterSpread) -
              Vector2.all(enemyConfig.clusterSpread / 2);

          final enemy =
              DummyTwo(initPosition: spreadPos, gameEnviroment: gameEnviroment);

          enemy.onDeath.add(() {
            if (enemyConfig.isBigBoss) {
              onBoss(true);
            }
            incrementEnemyCount(enemyConfig, -1);
          });
          incrementEnemyCount(enemyConfig, 1);

          gameEnviroment.physicsComponent.add(enemy);
        }
      }
    }
  }

  @override
  FutureOr<void> onLoad() {
    priority = enemyPriority;
    initEventTimes();
    conductEvents();
    initTimer();
    return super.onLoad();
  }

  void onBoss(bool isDead) {
    if (isDead) {
      eventTimer?.timer.resume();
      gameEnviroment.unPauseGame();
      for (var element in activeEnemyConfigTimers.entries) {
        element.value.timer.resume();
      }
    } else {
      eventTimer?.timer.pause();
      gameEnviroment.pauseGame();
      for (var element in activeEnemyConfigTimers.entries) {
        element.value.timer.pause();
      }
    }
  }

  void initTimer() {
    try {
      final time = spawnTimes
          .firstWhere((element) => element > gameEnviroment.timePassed);
      eventTimer = TimerComponent(
          period: time - gameEnviroment.timePassed,
          onTick: () {
            conductEvents();
            initTimer();
          },
          repeat: false,
          removeOnFinish: true)
        ..addToParent(this);
    } catch (_) {}
  }
}
