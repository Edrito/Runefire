import 'dart:async';

import 'package:flame/components.dart';
import 'package:runefire/events/event_class.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:uuid/uuid.dart';

import 'package:runefire/game/enviroment_mixin.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/enemies/enemy.dart';

typedef AiTimerClass = ({Function() function, String id, double time});

abstract class EventManagement extends Component {
  EventManagement(this.enviroment);

  final Map<String, TimerComponent> _activeEventConfigTimers = {};
  final List<GameEvent> _eventsCurrentlyActive = [];
  final List<GameEvent> _eventsFinished = [];

  ///Current function index
  final Map<double, int> _activeAiFunctionIndex = {};

  ///Active timers
  final Map<double, TimerComponent> _activeAiTimers = {};

  List<AiTimerClass> currentTimers = [];

  void pauseOnBigBoss() {
    _eventTimer?.timer.pause();
    gameEnviroment.pauseGameTimer();

    for (final element in _activeEventConfigTimers.entries) {
      element.value.timer.pause();
    }
  }

  void resumeOnBigBoss() {
    _eventTimer?.timer.resume();
    for (final element in _activeEventConfigTimers.entries) {
      element.value.timer.resume();
    }
    gameEnviroment.customFollow.enable();
    gameEnviroment.unPauseGameTimer();
    gameEnviroment.removeBossBounds();
  }

  List<double> _spawnTimes = [];

  TimerComponent? _eventTimer;

  ///Total functions to call
  // final Map<double, Set<Function()>> _activeAiFunctions = {};

  ///Copied functions to call
  final Map<double, List<Function>> _tempAiFunctionsToCall = {};

  Enviroment enviroment;
  abstract List<GameEvent> eventsToDo;

  GameEnviroment get gameEnviroment => enviroment as GameEnviroment;

  void addAiTimer(AiTimerClass config) {
    currentTimers.add(config);
    _activeAiFunctionIndex[config.time] ??= 0;

    _recalculateAiTimer(config.time);
  }

  void _buildOngoingEventTimer(GameEvent event) {
    _activeEventConfigTimers[event.eventId] ??= TimerComponent(
      period: getRandomValue(event.eventTriggerInterval),
      repeat: true,
      onTick: () async {
        await event.onGoingEvent();
        _activeEventConfigTimers[event.eventId]?.timer.limit =
            getRandomValue(event.eventTriggerInterval);
      },
    )..addToParent(this);
  }

  //Check if any events should be started
  void _checkToDoEvents(double currentTime) {
    final eventsToParse = [
      ...eventsToDo.where((element) => element.eventBeginEnd.$1 <= currentTime),
    ];
    final listOfIds = eventsToParse.map((e) => e.eventId);
    eventsToDo.removeWhere((element) => listOfIds.contains(element.eventId));

    for (final element in eventsToParse) {
      if (element.eventBeginEnd.$2 != null) {
        _buildOngoingEventTimer(element);
      }
      element.startEvent();
    }

    _eventsCurrentlyActive.addAll(eventsToParse);
  }

  void _conductEvents() {
    final currentTime = gameEnviroment.timePassed;
    _checkToDoEvents(currentTime);
    _endActiveEvents(currentTime);
  }

  ///Check if any events should be ended
  void _endActiveEvents(double currentTime) {
    final eventsToParse = [
      ..._eventsCurrentlyActive.where((element) {
        final endInterval = element.eventBeginEnd.$2;
        if (endInterval == null) {
          return true;
        }
        if (endInterval <= currentTime) {
          return true;
        }
        return false;
      }),
    ];

    final listOfIds = eventsToParse.map((e) => e.eventId);
    final activeTimers = _activeEventConfigTimers.entries
        .where((element) => listOfIds.contains(element.key))
        .map((e) => e.value);
    for (final element in activeTimers) {
      element.removeFromParent();
    }
    _activeEventConfigTimers
        .removeWhere((key, value) => listOfIds.contains(key));
    _eventsCurrentlyActive.removeWhere(eventsToParse.contains);
    for (final element in eventsToParse) {
      element.hasCompleted = true;
    }
    _eventsFinished.addAll(eventsToParse);
  }

  ///Get a random value between [(double,double)]
  double getRandomValue((double, double) values) {
    final returnVal = values.$1 + rng.nextDouble() * (values.$2 - values.$1);
    return returnVal;
  }

  ///Grab each interval the enemy management should create/remove timers
  void _initEventTimes() {
    _spawnTimes = [
      ...eventsToDo.fold<List<double>>(
        [],
        (previousValue, element) => [
          ...previousValue,
          ...[
            element.eventBeginEnd.$1,
            if (element.eventBeginEnd.$2 != null) element.eventBeginEnd.$2!,
          ],
        ],
      ),
    ];
    _spawnTimes.sort();
  }

  void _initTimer() {
    // try {
    final times =
        _spawnTimes.where((element) => element > gameEnviroment.timePassed);
    if (times.isEmpty) {
      return;
    }
    final period = times.first - gameEnviroment.timePassed;
    _eventTimer?.timer.limit = period;

    _eventTimer ??= TimerComponent(
      period: period,
      onTick: () {
        _initTimer();
        _conductEvents();
      },
      repeat: true,
    )..addToParent(this);
    // } catch (_) {}
  }

  List<Function> _getFunctionsFromTimekey(double timeKey) {
    final currentTimersFromTimeKey =
        currentTimers.where((element) => element.time == timeKey);

    if (currentTimersFromTimeKey.isEmpty) {
      return [];
    } else {
      return currentTimersFromTimeKey.map((e) => e.function).toList();
    }
  }

  void _recalculateAiTimer(double timeKey) {
    final functionsAmount = _getFunctionsFromTimekey(timeKey).length;
    if (functionsAmount == 0) {
      _activeAiTimers[timeKey]?.removeFromParent();
      return;
    }

    final stepTime = timeKey / functionsAmount;
    _activeAiTimers[timeKey]?.timer.limit = stepTime;
    _activeAiTimers[timeKey] ??= TimerComponent(
      period: stepTime,
      repeat: true,
      onTick: () {
        //Create timer that calls function over the difference between ticks
        // so there are no lag spikes...
        if ((_activeAiFunctionIndex[timeKey] ?? double.infinity) >=
            (_tempAiFunctionsToCall[timeKey]?.length ?? 0)) {
          _activeAiFunctionIndex[timeKey] = 0;
          _tempAiFunctionsToCall[timeKey] = [
            ..._getFunctionsFromTimekey(timeKey),
          ];
        }
        if (_tempAiFunctionsToCall[timeKey] == null) {
          return;
        }
        if (_tempAiFunctionsToCall[timeKey]!.isEmpty) {
          _tempAiFunctionsToCall.remove(timeKey);
          _recalculateAiTimer(timeKey);
          return;
        }
        _tempAiFunctionsToCall[timeKey]?[_activeAiFunctionIndex[timeKey]!]
            .call();
        _activeAiFunctionIndex[timeKey] = _activeAiFunctionIndex[timeKey]! + 1;
      },
    )..addToParent(this);
  }

  Future<void> removeAiTimer({AiTimerClass? config, String? id}) async {
    late final AiTimerClass currentConfig;
    if (id != null) {
      currentConfig = currentTimers.firstWhere((element) => element.id == id);
    } else if (config != null) {
      currentConfig = currentTimers.firstWhere((element) => element == config);
    } else {
      return;
    }

    final removedTimer = currentTimers.removeAt(
      currentTimers.indexWhere((element) => element == currentConfig),
    );
    if (!currentTimers.any((element) => removedTimer.time == element.time)) {
      _activeAiTimers[removedTimer.time]?.removeFromParent();
      _activeAiTimers.remove(removedTimer.time);
    }

    _recalculateAiTimer(removedTimer.time);
  }

  @override
  FutureOr<void> onLoad() {
    priority = enemyPriority;
    if (eventsToDo.isNotEmpty) {
      _initEventTimes();
      _conductEvents();
      _initTimer();
    }

    return super.onLoad();
  }
}
