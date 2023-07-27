import 'dart:async';

import 'package:flame/components.dart';
import 'package:uuid/uuid.dart';

import '../game/enviroment_mixin.dart';
import '../resources/enums.dart';
import '../resources/functions/vector_functions.dart';
import '../game/enviroment.dart';
import '../main.dart';
import '../resources/constants/priorities.dart';

enum SpawnLocation {
  inside,
  outside,
  both,
  entireMap,
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
      case SpawnLocation.entireMap:
        position =
            (Vector2.random() * gameEnviroment.boundsDistanceFromCenter * 2) -
                Vector2.all(gameEnviroment.boundsDistanceFromCenter);

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

abstract class GameEvent {
  GameEvent(
    this.gameEnviroment,
    this.eventManagement, {
    required this.spawnInterval,
    required this.spawnIntervalSeconds,
  }) {
    eventId = const Uuid().v4();
  }
  bool hasCompleted = false;
  final GameTimerFunctionality gameEnviroment;
  final EventManagement eventManagement;
  late final String eventId;
  final (double, double?) spawnInterval;
  final double spawnIntervalSeconds;
  void startEvent();
  void onGoingEvent();
  void endEvent();
}

abstract class PositionEvent extends GameEvent {
  PositionEvent(
    super.gameEnviroment,
    super.eventManagement, {
    required super.spawnInterval,
    this.spawnLocation,
    this.spawnPosition,
    required super.spawnIntervalSeconds,
  });

  final SpawnLocation? spawnLocation;
  final Vector2? spawnPosition;
}

class EnemyEvent extends PositionEvent {
  EnemyEvent(
    super.gameEnviroment,
    super.eventManagement, {
    required this.maxEnemies,
    required this.enemyClusters,
    required this.clusterSpread,
    required this.numberOfClusters,
    required this.isBigBoss,
    super.spawnLocation,
    super.spawnPosition,
    required super.spawnInterval,
    required super.spawnIntervalSeconds,
  });

  final int maxEnemies;
  double clusterSpread;
  final int numberOfClusters;
  final bool isBigBoss;
  final List<EnemyCluster> enemyClusters;

  bool enemyLimitReached() {
    return enemyCount >= maxEnemies;
  }

  int enemyCount = 0;

  void spawnEnemies() {
    final position =
        spawnLocation?.grabNewPosition(gameEnviroment as GameEnviroment) ??
            spawnPosition;

    for (var _ = 0; _ < numberOfClusters; _++) {
      for (var cluster in enemyClusters) {
        for (var i = 0; i < cluster.clusterSize; i++) {
          if (enemyLimitReached()) {
            return;
          }

          final spreadPos = (position ?? Vector2.zero()) +
              (Vector2.random() * clusterSpread) -
              Vector2.all(clusterSpread / 2);

          final enemy = cluster.enemyType.build(spreadPos, gameEnviroment);
          enemy.onDeath.add(() {
            incrementEnemyCount(-1);
          });
          incrementEnemyCount(1);

          gameEnviroment.physicsComponent.add(enemy);
        }
      }
    }
  }

  void incrementEnemyCount(int amount) {
    enemyCount += amount;
    if (enemyCount == 0 && hasCompleted) {
      endEvent();
    }
  }

  void onBigBoss(bool isDead) {
    if (isDead) {
      eventManagement.eventTimer?.timer.resume();
      (gameEnviroment as GameEnviroment).customFollow.enable();
      gameEnviroment.unPauseGame();
      for (var element in eventManagement.activeEventConfigTimers.entries) {
        element.value.timer.resume();
      }
      if (gameEnviroment is BoundsFunctionality) {
        (gameEnviroment as BoundsFunctionality).removeBossBounds();
      }
    } else {
      eventManagement.eventTimer?.timer.pause();
      gameEnviroment.pauseGame();
      (gameEnviroment as GameEnviroment).customFollow.disable();
      for (var element in eventManagement.activeEventConfigTimers.entries) {
        element.value.timer.pause();
      }
      spawnEnemies();
      if (gameEnviroment is BoundsFunctionality) {
        (gameEnviroment as BoundsFunctionality).createBossBounds();
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
  void onGoingEvent() {
    if (!isBigBoss) {
      spawnEnemies();
    }
  }

  @override
  void startEvent() {
    if (isBigBoss) {
      onBigBoss(false);
    }
  }
}

class EnemyCluster {
  EnemyCluster(this.enemyType, this.clusterSize);
  final EnemyType enemyType;
  final int clusterSize;
}

abstract class EventManagement extends Component {
  EventManagement(this.gameEnviroment);
  GameTimerFunctionality gameEnviroment;

  List<double> spawnTimes = [];
  abstract List<GameEvent> eventsToDo;
  List<GameEvent> eventsCurrentlyActive = [];
  List<GameEvent> eventsFinished = [];

  Map<String, TimerComponent> activeEventConfigTimers = {};

  TimerComponent? eventTimer;

  ///Grab each interval the enemy management should create/remove timers
  void initEventTimes() {
    spawnTimes = [
      ...eventsToDo.fold<List<double>>(
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
      ...eventsToDo.where((element) => element.spawnInterval.$1 <= currentTime)
    ];
    final listOfIds = eventsToParse.map((e) => e.eventId);
    eventsToDo.removeWhere((element) => listOfIds.contains(element.eventId));

    for (var element in eventsToParse) {
      if (element.spawnInterval.$2 != null) {
        activeEventConfigTimers[element.eventId] = (TimerComponent(
            period: element.spawnIntervalSeconds,
            repeat: true,
            onTick: () => element.onGoingEvent(),
            removeOnFinish: true))
          ..addToParent(this);
      }
      element.startEvent();
    }

    eventsCurrentlyActive.addAll(eventsToParse);
  }

  ///Check if any events should be ended
  void endActiveEvents(double currentTime) {
    final eventsToParse = [
      ...eventsCurrentlyActive.where((element) {
        final endInterval = element.spawnInterval.$2;
        if (endInterval == null) return true;
        if (endInterval <= currentTime) {
          return true;
        }
        return false;
      })
    ];

    final listOfIds = eventsToParse.map((e) => e.eventId);
    final activeTimers = activeEventConfigTimers.entries
        .where((element) => listOfIds.contains(element.key))
        .map((e) => e.value);
    for (var element in activeTimers) {
      element.removeFromParent();
    }
    activeEventConfigTimers
        .removeWhere((key, value) => listOfIds.contains(key));
    eventsCurrentlyActive
        .removeWhere((element) => eventsToParse.contains(element));
    for (var element in eventsToParse) {
      element.hasCompleted = true;
    }
    eventsFinished.addAll(eventsToParse);
  }

  void conductEvents() {
    final currentTime = gameEnviroment.timePassed;
    checkToDoEvents(currentTime);
    endActiveEvents(currentTime);
  }

  @override
  FutureOr<void> onLoad() {
    priority = enemyPriority;
    initEventTimes();
    conductEvents();
    initTimer();
    return super.onLoad();
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
