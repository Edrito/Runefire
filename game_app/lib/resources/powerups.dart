import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/resources/attributes.dart';
import 'package:game_app/resources/attributes_enum.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/physics_filter.dart';
import 'package:game_app/entities/player.dart';

// class WeaponUtility extends Powerup {
//   @override
//   double duration = 10;

//   @override
//   String spriteString = "powerups/energy.png";

//   @override
//   int uniqueId = 1;

//   bool previousHoming = false;
//   int  previousCount = 0;

//   Effect? colorEffect;

//   @override
//   void applyToEntityPowerup(Entity entity) {
//     entity.maxSpeed *= speedIncrease;

//     colorEffect = ColorEffect(
//         Colors.yellow,
//         const Offset(0, .5),
//         InfiniteEffectController(
//             EffectController(duration: .2, reverseDuration: .2)));
//     entity.spriteAnimationComponent.add(colorEffect!);
//   }

//   int? previousMaxAmmo;
//   @override
//   void applyToWeaponPowerup(Weapon weapon) {
//     weapon.fireRate /= speedIncrease;
//     previousMaxAmmo = weapon.maxAmmo;
//     weapon.maxAmmo = null;
//     if (weapon.shootingTimer != null) {
//       weapon.shootingTimer!.timer.limit = weapon.fireRate;
//     }
//   }

//   @override
//   void removeEntityPowerup(Entity entity) {
//     entity.maxSpeed /= speedIncrease;

//     colorEffect?.removeFromParent();
//   }

//   @override
//   void removeWeaponPowerup(Weapon weapon) {
//     weapon.fireRate *= speedIncrease;
//     weapon.maxAmmo = previousMaxAmmo;
//     if (weapon.shootingTimer != null) {
//       weapon.shootingTimer!.timer.limit = weapon.fireRate;
//     }
//   }
// }

// class Agility extends TemporaryAttribute {
//   @override
//   double duration = 10;

//   @override
//   String spriteString = "powerups/start.png";

//   @override
//   int uniqueId = 1;

//   double speedIncrease = .5;

//   Effect? colorEffect;

//   @override
//   String icon = "powerups/start.png";

//   @override
//   String title = "Speed and Attack Rate";

//   Agility({required super.level, required super.entity});

//   @override
//   // TODO: implement attributeEnum
//   AttributeEnum get attributeEnum => throw UnimplementedError();

//   @override
//   // TODO: implement attributeType
//   AttributeCategory get attributeType => throw UnimplementedError();

//   @override
//   String description() {
//     // TODO: implement description
//     throw UnimplementedError();
//   }

//   @override
//   void mapAttribute() {
//     // TODO: implement mapAttribute
//   }

//   @override
//   void unmapAttribute() {
//     // TODO: implement unmapAttribute
//   }
// }

class PowerAttribute extends TemporaryAttribute {
  @override
  double duration = 1;

  @override
  int uniqueId = 0;

  double healthIncrease = 20;
  double damageIncrease = .5;

  Effect? colorEffect;

  @override
  String title = "Strength and POWER";

  PowerAttribute({required super.level, required super.entity});

  @override
  // TODO: implement attributeEnum
  AttributeEnum get attributeEnum => AttributeEnum.power;

  @override
  String description() {
    // TODO: implement description
    return "aaa";
  }

  @override
  void mapAttribute() {
    // TODO: implement mapAttribute
  }

  @override
  void unmapAttribute() {
    // TODO: implement unmapAttribute
  }

  @override
  String icon = "powerups/power.png";
}

class PowerupItem extends BodyComponent with ContactCallbacks {
  PowerupItem(this.powerup, this.originPosition);

  TemporaryAttribute powerup;
  late SpriteComponent spriteComponent;
  double size = 1;
  Vector2 originPosition;

  @override
  Future<void> onLoad() async {
    spriteComponent = SpriteComponent(
        sprite: await Sprite.load(powerup.icon),
        size: Vector2.all(size),
        anchor: Anchor.center);
    spriteComponent.add(MoveEffect.by(
        Vector2(0, .25),
        InfiniteEffectController(EffectController(
          duration: .5,
          reverseDuration: .5,
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOut,
        ))));
    add(spriteComponent);
    return super.onLoad();
  }

  late PolygonShape shape;

  @override
  void render(Canvas canvas) {}

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! Player) return;
    other.addAttribute(powerup);
    removeFromParent();
    super.beginContact(other, contact);
  }

  @override
  Body createBody() {
    shape = PolygonShape();
    shape.set([
      Vector2(-spriteComponent.size.x / 2, -spriteComponent.size.y / 2),
      Vector2(spriteComponent.size.x / 2, -spriteComponent.size.y / 2),
      Vector2(spriteComponent.size.x / 2, spriteComponent.size.y / 2),
      Vector2(-spriteComponent.size.x / 2, spriteComponent.size.y / 2),
    ]);

    final powerupFilter = Filter()
      ..maskBits = playerCategory
      ..categoryBits = powerupCategory;

    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        restitution: 0,
        friction: 0,
        density: 0,
        isSensor: true,
        filter: powerupFilter);

    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      type: BodyType.static,
      bullet: false,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
