import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:game_app/resources/enums.dart';

import '../../entities/entity.dart';
import '../../main.dart';
import '../../weapons/weapon_class.dart';

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

bool boolAbilityDecipher(bool base, List<bool> boolIncrease) {
  if (boolIncrease.isEmpty) {
    return base;
  }
  return [base, ...boolIncrease].fold<int>(
          0,
          (previousValue, element) =>
              previousValue + ((element) ? 0 : (element ? 1 : -1))) >=
      0;
}

List<DamageInstance> damageCalculations(
    Map<DamageType, (double, double)> base,
    Map<DamageType, (double, double)> increase,
    double? duration,
    Entity source,
    Weapon? sourceWeapon) {
  List<DamageInstance> returnList = [];

  for (var element in base.entries) {
    var min = element.value.$1;
    var max = element.value.$2;
    if (increase.containsKey(element.key)) {
      min += increase[element.key]?.$1 ?? 0;
      max += increase[element.key]?.$2 ?? 0;
    }

    returnList.add(DamageInstance(
        source: source,
        damageBase: ((rng.nextDouble() * max - min) + min),
        damageType: element.key,
        duration: duration ?? 1,
        sourceWeapon: sourceWeapon));
  }

  return returnList;
}
