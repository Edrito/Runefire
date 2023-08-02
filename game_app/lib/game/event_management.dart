import 'dart:async';

import 'package:flame/components.dart';
import 'package:uuid/uuid.dart';

import 'enviroment_mixin.dart';
import '../resources/enums.dart';
import '../resources/functions/vector_functions.dart';
import 'enviroment.dart';
import '../main.dart';
import '../resources/constants/priorities.dart';
import '../enemies/enemy.dart';

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
    required this.eventBeginEnd,
    required this.eventTriggerInterval,
  }) {
    eventId = const Uuid().v4();
  }
  bool hasCompleted = false;
  final GameTimerFunctionality gameEnviroment;
  final EventManagement eventManagement;
  late final String eventId;
  final (double, double?) eventBeginEnd;
  final (double, double) eventTriggerInterval;
  void startEvent();
  Future<void> onGoingEvent();
  void endEvent();
}

abstract class PositionEvent extends GameEvent {
  PositionEvent(
    super.gameEnviroment,
    super.eventManagement, {
    required super.eventBeginEnd,
    this.spawnLocation,
    this.spawnPosition,
    required super.eventTriggerInterval,
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
    required this.levels,
    required this.clusterSpread,
    required this.numberOfClusters,
    required this.isBigBoss,
    this.boundsScope = BossBoundsScope.viewportSize,
    this.bossBoundsIsCircular = false,
    this.bossBoundsSize,
    super.spawnLocation,
    super.spawnPosition,
    required super.eventBeginEnd,
    required super.eventTriggerInterval,
  }) {
    bossBoundsSize ??= Vector2.all(6);
  }
  bool bossBoundsIsCircular;
  BossBoundsScope boundsScope;
  Vector2? bossBoundsSize;
  final int maxEnemies;
  double clusterSpread;
  final int numberOfClusters;
  final bool isBigBoss;
  final List<EnemyCluster> enemyClusters;
  final (int, int) levels;

  ///Getter that gets a random value between level tuple
  int get randomLevel => rng.nextInt((levels.$2 - levels.$1) + 1) + levels.$1;

  bool enemyLimitReached() {
    return enemyCount >= maxEnemies;
  }

  int get enemyCount => enemies.length;
  List<Enemy> enemies = [];

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

          final enemy = cluster.enemyType
              .build(spreadPos, gameEnviroment as GameEnviroment, randomLevel);
          enemy.onDeath.add(() {
            incrementEnemyCount([enemy], true);
          });
          incrementEnemyCount([enemy], false);

          gameEnviroment.physicsComponent.add(enemy);
        }
      }
    }
  }

  void incrementEnemyCount(List<Enemy> amount, bool remove) {
    if (remove) {
      for (var element in amount) {
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
      (gameEnviroment as GameEnviroment).customFollow.enable();
      gameEnviroment.unPauseGame();
      for (var element in eventManagement.activeEventConfigTimers.entries) {
        element.value.timer.resume();
      }
      if (gameEnviroment is BoundsFunctionality) {
        (gameEnviroment as BoundsFunctionality).removeBossBounds();
      }
    } else {
      spawnEnemies();
      eventManagement.eventTimer?.timer.pause();
      gameEnviroment.pauseGame();

      if (boundsScope == BossBoundsScope.viewportSize) {
        (gameEnviroment as GameEnviroment).customFollow.disable();
      }

      for (var element in eventManagement.activeEventConfigTimers.entries) {
        element.value.timer.pause();
      }
      if (gameEnviroment is BoundsFunctionality) {
        (gameEnviroment as BoundsFunctionality)
            .createBossBounds(bossBoundsIsCircular, this);
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
                  element.eventBeginEnd.$1,
                  if (element.eventBeginEnd.$2 != null)
                    element.eventBeginEnd.$2!
                ]
              ])
    ];
    spawnTimes.sort();
  }

  ///Get a random value between [(double,double)]
  double getRandomValue((double, double) values) {
    return values.$1 + rng.nextDouble() * (values.$2 - values.$1);
  }

  //Check if any events should be started
  void checkToDoEvents(double currentTime) {
    final eventsToParse = [
      ...eventsToDo.where((element) => element.eventBeginEnd.$1 <= currentTime)
    ];
    final listOfIds = eventsToParse.map((e) => e.eventId);
    eventsToDo.removeWhere((element) => listOfIds.contains(element.eventId));

    for (var element in eventsToParse) {
      if (element.eventBeginEnd.$2 != null) {
        buildOngoingEventTimer(element);
      }
      element.startEvent();
    }

    eventsCurrentlyActive.addAll(eventsToParse);
  }

  void buildOngoingEventTimer(GameEvent event) {
    activeEventConfigTimers[event.eventId] = (TimerComponent(
        period: getRandomValue(event.eventTriggerInterval),
        repeat: true,
        onTick: () async {
          await event.onGoingEvent();
          activeEventConfigTimers[event.eventId]?.timer.limit =
              getRandomValue(event.eventTriggerInterval);
        }))
      ..addToParent(this);
  }

  ///Check if any events should be ended
  void endActiveEvents(double currentTime) {
    final eventsToParse = [
      ...eventsCurrentlyActive.where((element) {
        final endInterval = element.eventBeginEnd.$2;
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
