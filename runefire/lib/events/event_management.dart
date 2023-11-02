import 'dart:async';

import 'package:flame/components.dart';
import 'package:runefire/events/event_class.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:uuid/uuid.dart';

import '../game/enviroment_mixin.dart';
import '../resources/enums.dart';
import '../resources/functions/vector_functions.dart';
import '../game/enviroment.dart';
import '../main.dart';
import '../resources/constants/priorities.dart';
import '../enemies/enemy.dart';

abstract class EventManagement extends Component {
  EventManagement(this.enviroment);

  Map<double, int> activeAiFunctionIndex = {};
  Map<double, List<Function>> activeAiFunctions = {};
  List<Function> activeAiFunctionsToCall = [];
  Map<double, List<String>> activeAiIds = {};
  Map<double, TimerComponent> activeAiTimers = {};
  Map<String, TimerComponent> activeEventConfigTimers = {};
  List<GameEvent> eventsCurrentlyActive = [];
  List<GameEvent> eventsFinished = [];
  abstract List<GameEvent> eventsToDo;
  Enviroment enviroment;
  GameEnviroment get gameEnviroment => enviroment as GameEnviroment;
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
    final times =
        spawnTimes.where((element) => element > gameEnviroment.timePassed);
    if (times.isEmpty) return;
    final period = times.first - gameEnviroment.timePassed;
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
