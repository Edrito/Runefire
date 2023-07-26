import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:game_app/resources/functions/vector_functions.dart';

Future<SpriteAnimation> buildSpriteSheet(
    int numberOfSprites, String source, double stepTime, bool loop,
    [double? scaledToDimension]) async {
  final sprite = (await Sprite.load(source));
  Vector2 newScale = sprite.srcSize;
  if (scaledToDimension != null) {
    newScale = newScale.scaledToDimension(false, scaledToDimension);
  }
  newScale = Vector2(newScale.x / numberOfSprites, newScale.y);
  return SpriteSheet(image: sprite.image, srcSize: newScale).createAnimation(
      row: 0,
      stepTime: stepTime,
      loop: loop,
      to: loop ? null : numberOfSprites);
}

String convertSecondsToMinutesSeconds(int seconds) {
  int minutes = seconds ~/ 60;
  int remainingSeconds = seconds % 60;
  String minutesString = minutes.toString().padLeft(2, '0');
  String secondsString = remainingSeconds.toString().padLeft(2, '0');
  return "$minutesString:$secondsString";
}
