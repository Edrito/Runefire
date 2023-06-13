import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/entities/player.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/main.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

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

class Agility extends Powerup {
  @override
  double duration = 10;

  @override
  String spriteString = "powerups/start.png";

  @override
  int uniqueId = 1;

  double speedIncrease = .5;

  Effect? colorEffect;

  @override
  void applyToEntityPowerup(Entity entity) {
    if (entity is MovementFunctionality) {
      entity.speedIncreasePercent += speedIncrease;
    }

    colorEffect = ColorEffect(
        Colors.yellow,
        const Offset(0, .5),
        InfiniteEffectController(
            EffectController(duration: .2, reverseDuration: .2)));
    entity.spriteAnimationComponent.add(colorEffect!);
  }

  Map<Weapon, double> previousReloadTime = {};

  @override
  void applyToWeaponPowerup(Weapon weapon) {
    weapon.fireRateIncrease += speedIncrease;
    if (weapon is ReloadFunctionality) {
      previousReloadTime[weapon] = weapon.reloadTime;
      weapon.reloadTime = 0;
    }
    if (weapon.attackTimer != null) {
      weapon.attackTimer!.timer.limit = weapon.fireRate;
    }
  }

  @override
  void removeEntityPowerup(Entity entity) {
    if (entity is MovementFunctionality) {
      entity.speedIncreasePercent -= speedIncrease;
    }
    colorEffect?.controller.setToStart();
    colorEffect?.removeFromParent();
  }

  @override
  void removeWeaponPowerup(Weapon weapon) {
    weapon.fireRateIncrease -= speedIncrease;
    if (weapon is ReloadFunctionality) {
      weapon.reloadTime = previousReloadTime[weapon]!;
      weapon.spentAttacks = 0;
    }
    if (weapon.attackTimer != null) {
      weapon.attackTimer!.timer.limit = weapon.fireRate;
    }
  }
}

class Damage extends Powerup {
  @override
  double duration = 10;

  @override
  String spriteString = "powerups/power.png";

  @override
  int uniqueId = 0;

  double healthIncrease = 20;
  double damageIncrease = .5;

  Effect? colorEffect;

  @override
  void applyToEntityPowerup(Entity entity) {
    if (entity is! HealthFunctionality) return;
    entity.healthFlatIncrease += healthIncrease;

    colorEffect = ColorEffect(
        Colors.red,
        const Offset(0, .5),
        InfiniteEffectController(
            EffectController(duration: .2, reverseDuration: .2)));
    entity.spriteAnimationComponent.add(colorEffect!);
  }

  @override
  void applyToWeaponPowerup(Weapon weapon) {
    weapon.damageIncrease += damageIncrease;
  }

  @override
  void removeEntityPowerup(Entity entity) {
    if (entity is! HealthFunctionality) return;
    entity.healthFlatIncrease -= healthIncrease;
    entity.damageTaken =
        (entity.damageTaken - healthIncrease).clamp(0, entity.getMaxHealth - 5);
    colorEffect?.controller.setToStart();
    colorEffect?.removeFromParent();
  }

  @override
  void removeWeaponPowerup(Weapon weapon) {
    weapon.damageIncrease -= damageIncrease;
  }
}

abstract class Powerup {
  void assignPowerup(Entity entity) {
    if (entity.currentPowerups.containsKey(uniqueId)) {
      entity.currentPowerups[uniqueId]!.currentTimer!.timer.limit =
          entity.currentPowerups[uniqueId]!.currentTimer!.timer.current +
              duration;
    } else {
      entity.currentPowerups[uniqueId] = this;
      if (entity is AttackFunctionality) {
        entity.carriedWeapons
            .forEach((key, value) => applyToWeaponPowerup(value));
      }
      applyToEntityPowerup(entity);
      currentTimer = TimerComponent(
        period: duration,
        removeOnFinish: true,
        onTick: () {
          removePowerup(entity);
          currentTimer = null;
        },
      );
      entity.gameRef.add(currentTimer!);
    }
  }

  void removePowerup(Entity entity) {
    if (entity is AttackFunctionality) {
      entity.carriedWeapons.forEach((key, value) => removeWeaponPowerup(value));
    }
    removeEntityPowerup(entity);
    entity.currentPowerups.removeWhere((key, value) => key == uniqueId);
  }

  void applyToWeaponPowerup(Weapon weapon);
  void applyToEntityPowerup(Entity entity);
  void removeWeaponPowerup(Weapon weapon);
  void removeEntityPowerup(Entity entity);
  abstract double duration;
  TimerComponent? currentTimer;
  abstract String spriteString;
  abstract int uniqueId;
}

class PowerupItem extends BodyComponent<GameRouter> with ContactCallbacks {
  PowerupItem(this.powerup, this.originPosition);

  Powerup powerup;
  late SpriteComponent spriteComponent;
  double size = 8;
  Vector2 originPosition;

  @override
  Future<void> onLoad() async {
    spriteComponent = SpriteComponent(
        sprite: await Sprite.load(powerup.spriteString),
        size: Vector2.all(size),
        anchor: Anchor.center);
    spriteComponent.add(MoveEffect.by(
        Vector2(0, 1.2),
        InfiniteEffectController(
            EffectController(duration: .5, reverseDuration: .5))));
    add(spriteComponent);
    return super.onLoad();
  }

  late PolygonShape shape;

  @override
  void render(Canvas canvas) {}

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! Player) return;
    powerup.assignPowerup(other);
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
        userData: this,
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
