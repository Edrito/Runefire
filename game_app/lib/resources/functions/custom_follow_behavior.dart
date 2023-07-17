import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/src/camera/viewfinder.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/entities/player.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/enums.dart';

class CustomFollowBehavior extends Component {
  CustomFollowBehavior(
    this.player,
    this.owner,
  ) {
    priority = 2000;
  }

  Player player;
  Viewfinder owner;
  double aimingInterpolationAmount = .8;
  Vector2 playerTarget = Vector2.zero();
  void followTarget() {
    final position = player.inputAimPositions[InputType.mouseMove];

    final distance = position?.distanceTo(Vector2.zero()) ?? 0;
    var amount = (distance - 4) / 25;
    amount = amount.clamp(0, 1);
    amount = pow(amount, 2).toDouble();
    amount = amount.clamp(0, 1);
    if (position != null) {
      playerTarget += (position * amount);
    }
    // print(amount);
    owner.position = owner.position +
        ((playerTarget - owner.position) * aimingInterpolationAmount);
  }

  @override
  void update(double dt) {
    // playerTarget = player.body.worldCenter.clone();
    if (player.isMounted) {
      owner.position = (player.body.worldCenter);
    }
    // followTarget();
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
