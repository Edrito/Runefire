import 'package:flame/components.dart';
import 'package:flame/src/camera/viewfinder.dart';
import 'package:game_app/entities/player.dart';

class CustomFollowBehavior extends Component {
  CustomFollowBehavior(
    this.target,
    this.owner,
  );

  Player target;
  Viewfinder owner;
  double aimingInterpolationAmount = .75;
  Vector2 playerTarget = Vector2.zero();
  void followTarget() {
    owner.position +=
        (playerTarget - owner.position) * aimingInterpolationAmount;
  }

  @override
  void update(double dt) {
    // final distance = delta.length;
    // if (distance > _speed * dt) {
    //   delta.scale(_speed * dt / distance);
    // }
    playerTarget = target.body.worldCenter.clone();
    followTarget();
  }
}
