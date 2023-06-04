import 'package:flame/src/camera/viewfinder.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:game_app/game/entity.dart';

class CustomFollowBehavior extends Component {
  CustomFollowBehavior(
    this.target,
    this.owner,
  );

  Entity target;
  Viewfinder owner;

  @override
  void update(double dt) {
    final delta = target.body.position - owner.position;

    // final distance = delta.length;
    // if (distance > _speed * dt) {
    //   delta.scale(_speed * dt / distance);
    // }
    owner.position = delta..add(owner.position);
  }
}
