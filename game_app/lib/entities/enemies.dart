import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/entities/player.dart';
import 'package:game_app/game/powerups.dart';
import 'package:game_app/weapons/weapons.dart';

import '../functions/functions.dart';
import '../functions/vector_functions.dart';
import '../resources/classes.dart';
import '../resources/enums.dart';

class Dummy extends Enemy with ContactCallbacks {
  Dummy({
    required super.initPosition,
    required super.ancestor,
  });

  @override
  double dashCooldown = 5;

  @override
  (double, double, double) xpRate = (0.001, 0.01, 0.989);

  EnemyType enemyType = EnemyType.flameHead;

  @override
  double height = 10;

  @override
  double invincibiltyDuration = 0;

  @override
  double maxHealth = 100;

  @override
  double maxSpeed = 20;

  @override
  double touchDamage = 4;

  @override
  Future<void> loadAnimationSprites() async {
    idleAnimation =
        await buildSpriteSheet(10, 'enemy_sprites/idle.png', .1, true);
    deathAnimation =
        await buildSpriteSheet(10, 'enemy_sprites/death.png', .1, false);
    runAnimation = await buildSpriteSheet(8, 'enemy_sprites/run.png', .1, true);
  }

  @override
  Future<void> onLoad() async {
    initialWeapons.addAll([Portal.create]);

    await loadAnimationSprites();
    await super.onLoad();
    startAttacking();
  }

  @override
  SpriteAnimation? damageAnimation;

  @override
  SpriteAnimation? dashAnimation;

  @override
  SpriteAnimation? deathAnimation;

  @override
  late SpriteAnimation idleAnimation;

  @override
  SpriteAnimation? jumpAnimation;

  @override
  SpriteAnimation? runAnimation;

  @override
  SpriteAnimation? spawnAnimation;

  @override
  SpriteAnimation? walkAnimation;
}

abstract class Enemy extends Entity with ContactCallbacks {
  Enemy({
    required super.initPosition,
    required super.ancestor,
  });

  abstract (double, double, double) xpRate;

  @override
  Filter? filter = Filter()
    ..categoryBits = enemyCategory
    ..maskBits =
        bulletCategory + playerCategory + sensorCategory + swordCategory;

  TimerComponent? shooter;
  bool hittingPlayer = false;
  double shotFreq = 1;

  abstract double touchDamage;

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

  void moveEnemy() {
    moveVelocities[InputType.ai] =
        (ancestor.player.center - body.position).normalized();
  }

  @override
  void update(double dt) {
    if (hittingPlayer) {
      ancestor.player.takeDamage(hashCode.toString(), touchDamage);
    }

    moveEnemy();

    super.update(dt);
  }

  @override
  EntityType entityType = EntityType.enemy;
}

class EnemyManagement extends Component {
  int enemiesSpawned = 0;
  EnemyManagement(this.mainGameRef);
  GameEnviroment mainGameRef;

  @override
  FutureOr<void> onLoad() {
    add(TimerComponent(
      period: 1,
      repeat: true,
      onTick: () => add(
        Dummy(
          ancestor: mainGameRef,
          initPosition: generateRandomGamePositionUsingViewport(
            false,
            mainGameRef,
          ),
        ),
      ),
    ));
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
