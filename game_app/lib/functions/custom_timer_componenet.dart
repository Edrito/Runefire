import 'dart:ui';

import 'package:flame/components.dart';

import 'custom_timer.dart';

/// A component that uses a [Timer] instance which you can react to when it has
/// finished.
class CustomTimerComponent extends Component {
  late final CustomTimer timer;
  final bool removeOnFinish;
  final VoidCallback? _onTick;

  /// Creates a [CustomTimerComponent]
  ///
  /// [period] The period of time in seconds that the tick will be called
  /// [repeat] When true, this will continue running after [period] is reached
  /// [autoStart] When true, will start upon instantiation (default is true)
  /// [onTick] When provided, will be called every time [period] is reached.
  /// This overrides the [onTick] method
  CustomTimerComponent({
    required double period,
    bool repeat = false,
    bool autoStart = true,
    this.removeOnFinish = false,
    VoidCallback? onTick,
  }) : _onTick = onTick {
    timer = CustomTimer(
      period,
      repeat: repeat,
      onTick: this.onTick,
      autoStart: autoStart,
    );
  }

  /// Called every time the [timer] reached a tick.
  /// The default implementation calls the closure received on the
  /// constructor and can be overridden to add custom logic.
  void onTick() {
    _onTick?.call();
  }

  @override
  void update(double dt) {
    timer.update(dt);

    if (removeOnFinish && timer.finished) {
      removeFromParent();
    }
  }
}
