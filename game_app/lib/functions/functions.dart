import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

Future<SpriteAnimation> buildSpriteSheet(
  int numberOfSprites,
  String source,
  double stepTime,
  bool loop,
) async {
  final sprite = (await Sprite.load(source));
  final newScale =
      Vector2(sprite.srcSize.x / numberOfSprites, sprite.srcSize.y);

  return SpriteSheet(image: sprite.image, srcSize: newScale).createAnimation(
      row: 0,
      stepTime: stepTime,
      loop: loop,
      to: loop ? null : numberOfSprites);
}

bool boolAbilityDecipher(bool base, List<bool> boolIncrease) =>
    [base, ...boolIncrease].fold<int>(
        0, (previousValue, element) => previousValue + (element ? 1 : -1)) >
    0;
