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
  mouse,
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

  late final String eventId;
  final EventManagement eventManagement;
  final GameTimerFunctionality gameEnviroment;

  bool hasCompleted = false;

  void endEvent();

  final (double, double?) eventBeginEnd;

  final (double, double) eventTriggerInterval;

  Future<void> onGoingEvent();

  void startEvent();
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
      gameEnviroment.unPauseGameTimer();
      for (var element in eventManagement.activeEventConfigTimers.entries) {
        element.value.timer.resume();
      }
      if (gameEnviroment is BoundsFunctionality) {
        (gameEnviroment as BoundsFunctionality).removeBossBounds();
      }
    } else {
      spawnEnemies();
      eventManagement.eventTimer?.timer.pause();
      gameEnviroment.pauseGameTimer();

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

  void spawnEnemies() {
    for (var _ = 0; _ < numberOfClusters; _++) {
      final position =
          spawnLocation?.grabNewPosition(gameEnviroment as GameEnviroment) ??
              spawnPosition;
      for (var cluster in enemyClusters) {
        List<Enemy> enemyCluster = [];
        for (var i = 0; i < cluster.clusterSize; i++) {
          if (enemyLimitReached) {
            break;
          }

          final spreadPos = (position ?? Vector2.zero()) +
              (Vector2.random() * clusterSpread) -
              Vector2.all(clusterSpread / 2);

          final enemy = cluster.enemyType.build(spreadPos,
              gameEnviroment as GameEnviroment, randomLevel, eventManagement);
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

abstract class EventManagement extends Component {
  EventManagement(this.env);

  Map<double, int> activeAiFunctionIndex = {};
  Map<double, List<Function>> activeAiFunctions = {};
  List<Function> activeAiFunctionsToCall = [];
  Map<double, List<String>> activeAiIds = {};
  Map<double, TimerComponent> activeAiTimers = {};
  Map<String, TimerComponent> activeEventConfigTimers = {};
  List<GameEvent> eventsCurrentlyActive = [];
  List<GameEvent> eventsFinished = [];
  abstract List<GameEvent> eventsToDo;
  Enviroment env;
  GameTimerFunctionality get gameEnviroment => env as GameTimerFunctionality;
  List<double> spawnTimes = [];

  TimerComponent? eventTimer;

  void addAiTimer(Function function, String id, double time) {
    activeAiIds[time] ??= [];
    activeAiFunctions[time] ??= [];
    activeAiFunctionIndex[time] ??= 0;
    activeAiIds[time]?.add(id);
    activeAiFunctions[time]?.add(function);
    recalculateAiTimer(time);
  }

  void buildOngoingEventTimer(GameEvent event) {
    activeEventConfigTimers[event.eventId] ??= TimerComponent(
        period: getRandomValue(event.eventTriggerInterval),
        repeat: true,
        onTick: () async {
          await event.onGoingEvent();
          activeEventConfigTimers[event.eventId]?.timer.limit =
              getRandomValue(event.eventTriggerInterval);
        })
      ..addToParent(this);
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

  void conductEvents() {
    final currentTime = gameEnviroment.timePassed;
    checkToDoEvents(currentTime);
    endActiveEvents(currentTime);
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

  ///Get a random value between [(double,double)]
  double getRandomValue((double, double) values) {
    final returnVal = values.$1 + rng.nextDouble() * (values.$2 - values.$1);
    return returnVal;
  }

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

  void initTimer() {
    // try {
    final time =
        spawnTimes.firstWhere((element) => element > gameEnviroment.timePassed);
    final period = time - gameEnviroment.timePassed;
    eventTimer?.timer.limit = period;

    eventTimer ??= TimerComponent(
        period: period,
        onTick: () {
          initTimer();
          conductEvents();
        },
        repeat: true,
        removeOnFinish: false)
      ..addToParent(this);
    // } catch (_) {}
  }

  void recalculateAiTimer(double time) {
    final functionsAmount = (activeAiFunctions[time]?.length ?? 0);
    if (functionsAmount == 0) {
      activeAiTimers[time]?.removeFromParent();
    }

    final stepTime = time / functionsAmount;
    activeAiTimers[time]?.timer.limit = stepTime;
    activeAiTimers[time] ??= TimerComponent(
      period: stepTime,
      repeat: true,
      onTick: () {
        //Create timer that calls function over the difference between ticks
        // so there are no lag spikes...
        if (activeAiFunctionIndex[time]! >= activeAiFunctionsToCall.length) {
          activeAiFunctionIndex[time] = 0;
          activeAiFunctionsToCall = [...activeAiFunctions[time]!];
        }
        if (activeAiFunctionsToCall.isEmpty) return;
        activeAiFunctionsToCall[activeAiFunctionIndex[time]!].call();
        activeAiFunctionIndex[time] = activeAiFunctionIndex[time]! + 1;
      },
    )..addToParent(this);
  }

  void removeAiTimer(Function function, String id, double time) async {
    activeAiIds[time]?.remove(id);
    activeAiFunctions[time]?.remove(function);

    if (activeAiIds[time]?.isEmpty ?? false) {
      activeAiTimers[time]?.removeFromParent();
      activeAiTimers.remove(time);
      activeAiFunctions[time]?.clear();
    }

    recalculateAiTimer(time);
  }

  @override
  FutureOr<void> onLoad() {
    priority = enemyPriority;
    if (eventsToDo.isNotEmpty) {
      initEventTimes();
      conductEvents();
      initTimer();
    }

    return super.onLoad();
  }
}
