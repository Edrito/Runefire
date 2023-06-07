import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

Future<SpriteAnimation> buildSpriteSheet(
    int width, String source, double stepTime, bool loop) async {
  final sprite = (await Sprite.load(source));
  return SpriteSheet(
          image: sprite.image,
          srcSize: Vector2(sprite.srcSize.x / width, sprite.srcSize.y))
      .createAnimation(
          row: 0, stepTime: stepTime, loop: loop, to: loop ? null : width);
}
