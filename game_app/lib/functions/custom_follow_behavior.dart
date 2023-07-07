import 'package:flame/src/camera/viewfinder.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:game_app/entities/player.dart';

class CustomFollowBehavior extends Component {
  CustomFollowBehavior(
    this.target,
    this.owner,
  );

  Player target;
  Viewfinder owner;

  @override
  void update(double dt) {
    // final distance = delta.length;
    // if (distance > _speed * dt) {
    //   delta.scale(_speed * dt / distance);
    // }
    owner.position = target.body.worldCenter;
  }
}
