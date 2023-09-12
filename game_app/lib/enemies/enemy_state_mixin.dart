import 'package:flame/components.dart';
import 'package:game_app/main.dart';

import '../resources/functions/functions.dart';
import 'enemy.dart';
import '../entities/entity_mixin.dart';

typedef TriggerFunction = bool Function();
typedef FutureFunction = Future Function();

class EnemyState {
  // Constructor
  EnemyState(
    this.stateManagedAI, {
    required this.priority,
    required this.randomFunctions,
    required this.stateDuration,
    required this.triggerFunctions,
    this.onStateStart,
    this.onStateEnd,
    this.preventDoubleRandomFunction = true,
    this.minimumTimePassedBeforeStateChange = 3,
    this.randomEventTimeFrame = (5, 8),
    this.finalState = false,
    this.isBaseState = false,
  });

  // Properties
  final int priority;
  final StateManagedAI stateManagedAI;
  final List<TriggerFunction> triggerFunctions;
  final List<FutureFunction> randomFunctions;
  final (double, double) randomEventTimeFrame;
  final (double, double) stateDuration;
  final bool preventDoubleRandomFunction;
  final double minimumTimePassedBeforeStateChange;
  final Function? onStateStart;
  final Function? onStateEnd;
  final bool finalState;
  final bool isBaseState;

  TimerComponent? stateEventTimer;
  late TimerComponent stateDurationTimer;
  bool randomFunctionRunning = false;
  FutureFunction? previousFunction;

  // Methods

  /// Check if the state can be started based on trigger functions and duration check.
  bool canStart() =>
      durationPassedCheck() &&
      triggerFunctions.fold<bool>(
          true, (previousValue, elementD) => previousValue && elementD.call());

  /// Initialize the event timer to call random functions periodically.
  void initEventTimer() {
    double duration = (rng.nextDouble() *
            (randomEventTimeFrame.$2 - randomEventTimeFrame.$1)) +
        randomEventTimeFrame.$1;
    stateEventTimer = TimerComponent(
      period: duration,
      onTick: () async {
        await callRandomFunction(preventDoubleRandomFunction);
        initEventTimer();
      },
      removeOnFinish: true,
    )..addToParent(stateManagedAI);
  }

  void initDurationTimer() {
    stateDurationTimer = TimerComponent(
      period: randomBetween(stateDuration),
      onTick: () {
        onStateEndCall();
      },
      removeOnFinish: true,
    )..addToParent(stateManagedAI);
  }

  /// Call the onStateStart function and start the event timer.
  Future<void> onStateStartCall() async {
    if (stateDuration.$2 != 0) {
      initDurationTimer();
      initEventTimer();
    }

    onStateStart?.call();

    if (stateDuration.$2 == 0 && !isBaseState) {
      await callRandomFunction(preventDoubleRandomFunction);
      onStateEndCall();
    }
  }

  /// Call the onStateEnd function and remove the event timer.
  void onStateEndCall() {
    stateEventTimer?.timer.stop();
    stateEventTimer?.removeFromParent();
    onStateEnd?.call();
  }

  /// Check if enough time has passed since the previous state change.
  bool durationPassedCheck() =>
      stateManagedAI.durationSincePreviousStateChange >=
      minimumTimePassedBeforeStateChange;

  /// Call a random function if it's not already running and prevent duplicates if specified.
  Future<void> callRandomFunction(bool preventDuplicate) async {
    if (randomFunctions.isEmpty || stateManagedAI.randomFunctionRunning) return;
    try {
      randomFunctionRunning = true;
      FutureFunction randomFunction;
      if (preventDuplicate) {
        final tempList =
            randomFunctions.where((element) => element != previousFunction);
        randomFunction = tempList.elementAt(rng.nextInt(tempList.length));
      } else {
        randomFunction = randomFunctions[rng.nextInt(randomFunctions.length)];
      }
      previousFunction = randomFunction;
      await randomFunction.call();
    } finally {
      randomFunctionRunning = false;
    }
  }
}

///The purpose of this is to allow enemies the ability to change throughout their lifecycle based on external events
///for example, a enemy may change its fight pattern when attacked with fire damage which will be detected
///through the [EnemyState.canStart] function, when true, a state change will occur
///which may involve changing the current weapon, adding a firetrail, etc.
///
///But can also be triggered randomly, allowing the change of a boss fight to be ranged instead of melee
///after X minutes fighting it and Y health taken away.
mixin StateManagedAI
    on
        Enemy,
        MovementFunctionality,
        AimFunctionality,
        HealthFunctionality,
        AttackFunctionality {
  abstract EnemyState baseState;

  bool get randomFunctionRunning =>
      baseState.randomFunctionRunning ||
      enemyStates.values.any((element) => element.randomFunctionRunning);

  abstract Map<int, EnemyState> enemyStates;
  int? currentState;
  double aliveDuration = 0;
  double durationSincePreviousStateChange = 0;
  final double period = .1;
  late TimerComponent stateCheckerTimer;
  final double minimumTimeBeforeStateChange = 3;
  bool firstStateChangeCompleted = false;

  ///Every [period] seconds, this function will be called. It will check if the state should be changed
  ///If the state should be changed, it will change the state
  void stateChecker() {
    final activeState = enemyStates[currentState ?? -1];
    if (durationSincePreviousStateChange < minimumTimeBeforeStateChange &&
            firstStateChangeCompleted ||
        (activeState?.finalState ?? false) ||
        (activeState?.stateDurationTimer.timer.isRunning() ?? false) ||
        isDead) return;

    var enemyStatesList = enemyStates.entries
        .where((element) => element.key != currentState)
        .map((e) => e.value)
        .toList();

    enemyStatesList.sort((b, a) => a.priority.compareTo(b.priority));

    //For the first state, it will always be the lowest priority, as higher priority states
    //will normally be final stages of boss fights (priority) is there to prevent
    //clashes with minor states when it should 100% be a giga fight state
    if (!firstStateChangeCompleted) {
      enemyStatesList = enemyStatesList.reversed.toList();
    }

    for (var element in enemyStatesList) {
      if ((element.canStart() || !firstStateChangeCompleted)) {
        enemyStates[currentState ?? -1]?.onStateEndCall();
        currentState =
            enemyStates.keys.firstWhere((key) => enemyStates[key] == element);
        element.onStateStartCall();
        durationSincePreviousStateChange = 0;
        firstStateChangeCompleted = true;
        break;
      }
    }
  }

  @override
  Future<void> onLoad() async {
    //Init base state

    await super.onLoad();

    baseState.onStateStartCall();
    onDeath.add(baseState.onStateEndCall);

    stateCheckerTimer = TimerComponent(
      period: period,
      repeat: true,
      onTick: () {
        stateChecker();
      },
    )..addToParent(this);
    stateChecker();
  }

  @override
  void update(double dt) {
    aliveDuration += dt;
    durationSincePreviousStateChange += dt;
    super.update(dt);
  }
}
