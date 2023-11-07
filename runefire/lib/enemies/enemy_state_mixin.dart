import 'package:flame/components.dart';
import 'package:runefire/main.dart';
import 'package:uuid/uuid.dart';

import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/entity_mixin.dart';

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
    this.isFinalState = false,
    this.isBaseState = false,
  });

  late final stateId = const Uuid().v4();

  // Properties
  final int priority;
  final StateManagedAI stateManagedAI;
  final List<TriggerFunction> triggerFunctions;
  final List<FutureFunction> randomFunctions;
  final (double, double) randomEventTimeFrame;
  final (double, double) stateDuration;
  final bool preventDoubleRandomFunction;
  final double minimumTimePassedBeforeStateChange;
  final Function(double duration)? onStateStart;
  final Function()? onStateEnd;
  final bool isFinalState;
  final bool isBaseState;

  TimerComponent? stateDurationTimer;
  bool randomFunctionRunning = false;
  FutureFunction? previousFunction;

  late final double eventPeriodDuration =
      randomBetween(randomEventTimeFrame).roundToDouble();

  // Methods

  /// Check if the state can be started based on trigger functions and duration check.
  bool canStart() =>
      durationPassedCheck() &&
      triggerFunctions.fold<bool>(
        true,
        (previousValue, elementD) => previousValue && elementD.call(),
      );

  /// Initialize the event timer to call random functions periodically.
  void initEventTimer() {
    stateManagedAI.eventManagement
        .addAiTimer(callRandomFunction, stateId, eventPeriodDuration);
  }

  double initDurationTimer() {
    final timerLimit = randomBetween(stateDuration);
    stateDurationTimer = TimerComponent(
      period: timerLimit,
      onTick: onStateEndCall,
    )..addToParent(stateManagedAI);
    return timerLimit;
  }

  /// Call the onStateStart function and start the event timer.
  Future<void> onStateStartCall() async {
    var durationOfState = 0.0;
    if (stateDuration.$2 != 0) {
      durationOfState = initDurationTimer();
      initEventTimer();
    }

    onStateStart?.call(durationOfState);

    if (stateDuration.$2 == 0 && !isBaseState) {
      await callRandomFunction();
      onStateEndCall();
    }
  }

  /// Call the onStateEnd function and remove the event timer.
  void onStateEndCall() {
    stateManagedAI.eventManagement
        .removeAiTimer(callRandomFunction, stateId, eventPeriodDuration);
    onStateEnd?.call();
  }

  /// Check if enough time has passed since the previous state change.
  bool durationPassedCheck() =>
      stateManagedAI.durationSincePreviousStateChange >=
      minimumTimePassedBeforeStateChange;

  /// Call a random function if it's not already running and prevent duplicates if specified.
  Future<void> callRandomFunction() async {
    //update duration timer using the period of the random event timer

    //wont be accurate but will be close enough
    stateDurationTimer?.update(eventPeriodDuration);

    if (randomFunctions.isEmpty || stateManagedAI.randomFunctionRunning) return;
    try {
      randomFunctionRunning = true;
      FutureFunction randomFunction;
      if (preventDoubleRandomFunction) {
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
  final double minimumTimeBeforeStateChange = 3;
  bool firstStateChangeCompleted = false;

  ///Every [period] seconds, this function will be called. It will check if the state should be changed
  ///If the state should be changed, it will change the state
  void stateChecker() {
    final activeState = enemyStates[currentState ?? -1];

    //only changes after X seconds
    //     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀⢸⡄⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⣤⣤⡤⣤⣀⣻⣷⣶⣾⣿⣦⡀⢠⠇⢀⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢤⣤⣼⣿⣇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⢴⣞⣳⢦⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⢾⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣄⠀⣯⡜⣷⢳⡀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡙⠃⠀⠀⣲⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣾⡿⣿⣿⣿⣷⡌⢷⠺⣧⣵⡀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣼⣿⣿⣿⣿⣿⡑⠀⠀⠀⠈⢲⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣿⣟⢿⣷⣺⣿⣿⣿⡗⠌⠳⣿⣿⠇⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠋⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠣⠀⠀⠰⠲⣩⠃⠀⠀⠀⠀⠀⠀⠀⢀⣴⣾⣿⣿⠻⣿⡆⢹⣷⣝⣿⣿⣷⣧⠶⠊⠁⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⢰⢿⣿⣿⣿⣿⣿⣿⡟⠛⠛⠛⣿⢏⣽⣿⣿⡿⣿⣿⣿⡏⠀⠀⣀⡠⣤⣀⡔⡹⣀⠩⠶⣄⣠⣾⣿⡿⣿⡌⢻⣧⣈⣿⣿⣿⣿⣿⣟⣛⣢⣄⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣧⠀⠀⠀⠀⠀⠀⠀⠀⠸⣻⣿⢻⣿⣹⠛⠃⠀⠀⡾⠁⢸⠏⣹⣏⣱⡎⣼⣷⣅⣴⣿⢟⣷⢋⠜⣰⢃⣿⣱⣾⣿⣿⣟⢿⣷⡘⣿⣦⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣹⢿⡸⣖⠿⡿⠿⣶⣏⠁⠶⣿⠿⠿⢋⡽⣧⣻⣿⣷⡽⠛⠝⢁⡌⠰⠃⠺⣿⣿⠿⣧⡘⣿⣤⣻⣿⣾⣿⡿⢋⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣾⣿⣿⣷⣧⠈⠁⠒⠈⠋⠁⣀⠀⠈⠉⠉⠁⣼⣽⠟⠛⢫⠀⠸⡔⢎⠘⢦⡀⠐⠹⢿⣦⡸⣷⣾⣿⣿⠟⢋⢛⡑⠛⢯⣿⣟⡿⢿⣿⣿⣿⣿⣿⣿⡽⣯⠧⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣤⣤⣶⣿⣿⣿⣿⣿⣿⣿⣦⣤⡀⠀⠀⠀⣿⠀⠀⠀⠀⢀⣿⣿⡀⠀⠺⣦⡀⠙⢦⡛⠄⡹⠦⣤⡜⢻⣿⣿⠿⢋⠀⡀⠂⣴⢎⠰⣀⠍⠿⢿⣿⣿⣿⣿⣿⣿⣿⣷⣻⣧⢣⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⢾⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⡇⠀⠶⠾⠶⠶⠶⠄⢀⣾⣿⣿⣿⡖⣤⡬⢿⣶⣄⣈⣻⣿⣐⡜⠛⣿⠛⡥⢋⢄⡈⢐⣰⠯⣤⣃⢄⠫⣹⢚⣜⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⡇
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡌⣹⣷⣄⠀⠉⠀⣀⣴⣿⢸⣿⣯⣿⣧⣼⡷⠀⢻⣿⣿⣿⣶⡶⠟⣍⢣⠙⠂⠃⠀⢀⣉⠛⠓⠲⠬⢄⢣⢎⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢷⠇
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⢟⣿⣿⣿⣿⣿⣿⣿⣿⣟⣿⣿⣿⣿⡃⣿⣿⣛⣶⠤⠴⣿⣿⣿⡸⣿⣿⣿⣿⣿⠇⢴⣈⣿⠛⣛⠻⡇⠴⠉⠊⡀⠔⠂⣠⣾⣿⣤⣀⠀⠀⣈⣞⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢋⠎⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡿⢿⣿⣿⣿⣿⣿⢿⣿⠋⠉⠛⠸⣿⣿⣿⣿⡧⢠⠟⠙⣺⠏⣹⠟⠉⢐⠹⣿⣿⣿⣻⣦⣀⣙⠉⠈⠀⠄⠩⠄⠀⣀⣠⣴⣾⣽⣿⣿⣬⣟⠛⣟⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢏⣵⡏⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣷⣬⡲⣄⠀⠀⣿⣿⣿⣿⡇⠐⢾⡶⡯⠛⠁⣠⣶⣿⣷⡙⣿⣿⣿⢯⣿⣿⣿⣿⡲⣤⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣍⣛⠻⢿⢿⣿⣿⣿⣿⣿⠿⣋⣴⣿⡿⠃⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⡿⢿⣟⣿⣿⣿⣿⣮⣧⠀⣿⣿⣿⣿⡇⢀⠤⠊⢀⣴⣾⣿⣿⣿⣿⣿⣾⣟⣛⣿⣿⢻⣿⡿⠇⢻⣷⣾⣿⣿⣿⡿⠿⠟⠛⠛⠿⠿⢿⡿⣿⣿⣿⣾⣿⣿⣯⣷⣾⡿⠟⠋⠁⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢘⣿⣿⠿⢿⣿⣿⣿⡎⢿⣸⣿⣿⣿⣿⠟⢑⣾⣿⣿⡾⠘⠁⣠⣶⠟⠋⠀⢀⣡⠟⣥⣾⣿⣿⠀⣿⣷⠀⣿⣇⢰⡌⢿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⣠⢶⠶⣿⣿⣿⠰⣮⣿⣿⣿⣿⣄⠁⣿⣿⣿⣎⡀⠛⢻⠸⠋⣀⣤⡾⠟⠁⠀⢀⡴⢋⠬⡹⣴⣿⣿⡿⢠⣿⣯⠀⢺⣿⡘⣷⡍⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⢐⣷⡘⢿⣷⣾⣤⣄⡉⣙⣿⣿⣿⣿⣧⣹⣿⣿⢿⣿⡴⠊⣀⣴⡿⢋⠄⠀⡠⢾⡻⢄⣵⡾⣵⣿⣿⣿⡷⢸⣿⣷⠀⠘⣿⣿⣿⣿⣽⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⢀⣴⣿⠟⣃⣤⣾⣿⣿⣿⣿⣿⣻⡿⠛⠉⠀⢀⠈⡹⠒⠋⣀⣾⠟⠁⠐⣁⠔⠁⢸⣼⡀⣿⣵⣿⣿⣿⣿⣿⡷⢸⣿⣿⢸⣇⣿⣿⣿⣽⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⣿⣿⣿⣿⢿⣿⣿⣿⣿⡿⠿⠛⠁⠀⠀⠀⢦⣿⢸⣅⣴⡾⠋⠁⢀⣠⣾⣿⡄⠀⢨⢹⣶⣿⣿⣿⣿⣿⣿⣿⡧⢸⣿⣿⢸⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⢸⣿⡿⢋⣶⣿⣿⣿⣿⠏⠀⠀⠀⠤⣄⠀⠀⠀⢿⡈⢿⣿⣂⣠⣴⣿⣿⣿⣯⣴⣴⣿⢿⠟⢯⣿⣿⣿⣿⣿⣿⣷⣾⣿⣷⢨⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⣿⠟⣵⣿⣿⣿⣿⣿⠸⡆⠀⠀⣄⡀⠙⢷⣄⠀⠈⢷⣌⡻⣯⣽⣿⣿⣿⣿⣿⣿⡿⣛⢸⣾⣿⣿⣿⣿⣿⣿⣿⣟⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⡝⣼⣿⣿⣿⣿⣿⣿⣧⣿⣖⠠⣌⡛⢦⣀⠹⣦⠀⢀⠍⠉⢰⣿⣿⣿⣿⣿⣿⣿⣿⣽⣾⣿⣿⣿⣿⣿⣿⣿⣿⢁⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⢰⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣭⣝⣻⢯⣗⡾⣿⣿⣾⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⣼⣿⣿⣿⣿⣿⣿⡧⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠈⢾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⣿⣿⣿⣿⣿⣿⣿⣏⣼⣿⣿⣿⣿⣿⣿⣿⣷⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠑⠈⠙⢾⣋⣿⣿⣿⣿⣿⣿⣿⠟⢩⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣼⣿⣿⣿⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⠀⠀⢠⣼⣿⣿⣿⣿⣿⠟⠁⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⠟⠉⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⡿⠉⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⠀⢀⣴⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⣼⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣏⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⠀⠀⣠⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    // ⢀⣴⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⢠⣿⣿⢿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    final enoughTimeHasPassed =
        durationSincePreviousStateChange > minimumTimeBeforeStateChange;

    if ((!enoughTimeHasPassed && firstStateChangeCompleted) ||
        //if final state, dont change
        (activeState?.isFinalState ?? false) ||
        (activeState?.stateDurationTimer?.timer.isRunning() ?? false) ||
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

    for (final element in enemyStatesList) {
      if (element.canStart() || !firstStateChangeCompleted) {
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
    onDeath.add((_) {
      baseState.onStateEndCall();
    });

    eventManagement.addAiTimer(stateChecker, entityId, period);

    stateChecker();
  }

  @override
  void onRemove() {
    eventManagement.removeAiTimer(stateChecker, entityId, period);
    super.onRemove();
  }

  @override
  void update(double dt) {
    aliveDuration += dt;
    durationSincePreviousStateChange += dt;
    super.update(dt);
  }
}
