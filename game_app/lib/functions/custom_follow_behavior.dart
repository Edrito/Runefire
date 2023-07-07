import 'package:flame/src/camera/viewfinder.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:game_app/entities/entity.dart';

class CustomFollowBehavior extends Component {
  CustomFollowBehavior(
    this.target,
    this.owner,
  );

  Entity target;
  Viewfinder owner;

  @override
  void update(double dt) {
    owner.position = target.body.position.clone();
  }
}
