import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/entities/player.dart';
import 'package:game_app/game/enviroment.dart';
import 'package:game_app/resources/enums.dart';

class CustomFollowBehavior extends Component {
  CustomFollowBehavior(this.player, this.camera, this.gameEnviroment) {
    priority = 2000;
  }
  double timerDuration = 2;
  TimerComponent? disableTimer;
  TimerComponent? enableTimer;
  GameEnviroment gameEnviroment;

  void disable() {
    isDisabled = true;
    disableTimer = TimerComponent(
      period: timerDuration,
      removeOnFinish: true,
    )..addToParent(this);
  }

  void enable() {
    isDisabled = false;
    disableTimer = null;
    enableTimer = TimerComponent(
      period: timerDuration,
      removeOnFinish: true,
      onTick: () {
        enableTimer = null;
      },
    )..addToParent(this);
  }

  Vector2 shiftCameraPositionBecauseOfMouse() {
    final position = player.inputAimPositions[InputType.mouseMove];
    final distance = position?.distanceTo(Vector2.zero()) ?? 0;
    var amount = (distance - 4) / 25;
    amount = amount.clamp(0, 1);
    amount = pow(amount, 2).toDouble();
    amount = amount.clamp(0, 1);
    if (position != null) {
      return (position * amount);
    }
    return Vector2.zero();
  }

  double getPercentTimerComplete(TimerComponent timer) {
    return timer.timer.current / timerDuration;
  }

  bool isDisabled = false;
  Player player;
  CameraComponent camera;
  void followTarget() {
    Vector2 playerTarget = player.center.clone();
    playerTarget += shiftCameraPositionBecauseOfMouse();

    var interpolationAmount = 1.0;
    if (disableTimer != null) {
      interpolationAmount = 1 - getPercentTimerComplete(disableTimer!);
    } else if (enableTimer != null) {
      interpolationAmount = getPercentTimerComplete(enableTimer!);
    }

    String formattedNumber = interpolationAmount.toStringAsFixed(2);
    interpolationAmount = double.parse(formattedNumber);
    if (interpolationAmount == 0) return;
    final newPos = (camera.viewfinder.position +
        ((playerTarget - camera.viewfinder.position) * interpolationAmount));
    newPos.clamp(-Vector2(maxX, maxY), Vector2(maxX, maxY));

    camera.viewfinder.position = newPos;
  }

  double get maxY =>
      gameEnviroment.boundsDistanceFromCenter -
      ((camera.viewport.size.y / 2) / camera.viewfinder.zoom);
  double get maxX =>
      gameEnviroment.boundsDistanceFromCenter -
      ((camera.viewport.size.x / 2) / camera.viewfinder.zoom);

  @override
  void update(double dt) {
    if (player.isMounted) {
      followTarget();
    }
    super.update(dt);
  }
}

extension CameraFollow on CameraComponent {
  void followCustom(
    Body target, {
    double maxSpeed = double.infinity,
    bool horizontalOnly = false,
    bool verticalOnly = false,
    bool snap = false,
  }) {
    stop();
    viewfinder.add(
      RemadeFollowBehavior(
        target: target,
        owner: viewfinder,
        maxSpeed: maxSpeed,
        horizontalOnly: horizontalOnly,
        verticalOnly: verticalOnly,
      ),
    );
    if (snap) {
      viewfinder.position = target.position;
    }
  }
}

class RemadeFollowBehavior extends Component {
  RemadeFollowBehavior({
    required Body target,
    PositionProvider? owner,
    double maxSpeed = double.infinity,
    this.horizontalOnly = false,
    this.verticalOnly = false,
    super.priority,
  })  : _target = target,
        _owner = owner,
        _speed = maxSpeed,
        assert(maxSpeed > 0, 'maxSpeed must be positive: $maxSpeed'),
        assert(
          !(horizontalOnly && verticalOnly),
          'The behavior cannot be both horizontalOnly and verticalOnly',
        );

  final Body _target;

  PositionProvider get owner => _owner!;
  PositionProvider? _owner;

  double get maxSpeed => _speed;
  final double _speed;

  final bool horizontalOnly;
  final bool verticalOnly;

  @override
  void onMount() {
    if (_owner == null) {
      assert(
        parent is PositionProvider,
        'Can only apply this behavior to a PositionProvider',
      );
      _owner = parent! as PositionProvider;
    }
  }

  @override
  void update(double dt) async {
    final delta = _target.worldCenter - owner.position;
    if (horizontalOnly) {
      delta.y = 0;
    }
    if (verticalOnly) {
      delta.x = 0;
    }
    final distance = delta.length;
    if (distance > _speed * dt) {
      delta.scale(_speed * dt / distance);
    }
    owner.position = delta..add(owner.position);
  }
}
