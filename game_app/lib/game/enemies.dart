import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/game/characters.dart';
import 'package:game_app/game/entity.dart';
import 'package:game_app/game/main_game.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/game/player.dart';
import 'package:game_app/game/powerups.dart';
import 'package:game_app/game/weapons/weapons.dart';

import '../functions/vector_functions.dart';

class Enemy extends Entity with ContactCallbacks, CollisionCallbacks {
  Enemy(
      {required super.initPosition,
      required super.ancestor,
      required super.id,
      super.file = ""}) {
    super.file = enemyType.getFilename();
  }

  EnemyType enemyType = EnemyType.flameHead;
  @override
  double dashCooldown = 5;

  @override
  Filter? filter = Filter()
    ..categoryBits = enemyCategory
    ..maskBits =
        bulletCategory + playerCategory + sensorCategory + swordCategory;

  @override
  double height = 10;

  @override
  double invincibiltyDuration = 0;

  @override
  double maxHealth = 100;

  @override
  double maxSpeed = 20;

  @override
  EntityType entityType = EntityType.enemy;
  TimerComponent? shooter;
  bool hittingPlayer = false;
  double shotFreq = 1;

  @override
  Future<void> onLoad() async {
    initialWeapons.addAll([Portal.create]);
    await super.onLoad();
    startAttacking();
  }

  @override
  Future<void> onDeath() async {
    endAttacking();
    spriteAnimationComponent.add(OpacityEffect.fadeOut(
      EffectController(
        duration: .5,
      ),
      onComplete: () {
        removeFromParent();
      },
    ));
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Player) {
      hittingPlayer = true;
    }

    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is Player) {
      hittingPlayer = false;
    }
    super.endContact(other, contact);
  }

  @override
  void update(double dt) {
    if (hittingPlayer) {
      ancestor.player.takeDamage(id, 3);
    }

    moveVelocities[InputType.ai] =
        (ancestor.player.center - body.position).normalized();

    super.update(dt);
  }
}

class EnemyManagement extends Component {
  int enemiesSpawned = 0;
  EnemyManagement(this.mainGameRef);
  MainGame mainGameRef;

  @override
  FutureOr<void> onLoad() {
    const enemyType = EnemyType.flameHead;

    // add(TimerComponent(
    //   period: 1,
    //   repeat: true,
    //   onTick: () => add(Enemy(
    //       ancestor: mainGameRef,
    //       initPosition: generateRandomGamePositionUsingViewport(
    //         false,
    //         mainGameRef,
    //       ),
    //       id: (enemiesSpawned++).toString() + enemyType.name)),
    // ));
    add(
      TimerComponent(
          period: 20,
          repeat: true,
          onTick: () {
            add(PowerupItem(Damage(),
                generateRandomGamePositionUsingViewport(true, mainGameRef)));
            add(PowerupItem(Agility(),
                generateRandomGamePositionUsingViewport(true, mainGameRef)));
          }),
    );

    add(PowerupItem(
        Damage(), generateRandomGamePositionUsingViewport(true, mainGameRef)));
    return super.onLoad();
  }
}
