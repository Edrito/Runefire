import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/entities/enemy_mixin.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/entities/entity_mixin.dart';

import '../resources/functions/functions.dart';
import '../resources/functions/vector_functions.dart';
import '../game/enviroment.dart';
import '../main.dart';
import '../resources/constants/physics_filter.dart';
import '../resources/enums.dart';
import '../resources/constants/priorities.dart';
import '../attributes/attributes_mixin.dart';

class DummyTwo extends Enemy
    with
        HealthFunctionality,
        // MovementFunctionality,
        DropExperienceFunctionality
// DumbFollowAI,
// TouchDamageFunctionality
{
  DummyTwo({
    required super.initPosition,
    required super.gameEnviroment,
  });

  @override
  void update(double dt) {
    // moveCharacter();
    super.update(dt);
  }

  @override
  (double, double) xpRate = (0.001, 0.01);

  @override
  double height = 1;

  @override
  double baseInvincibilityDuration = 0.0;

  @override
  double baseHealth = 50000000;

  @override
  double baseSpeed = .0175;

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
    await loadAnimationSprites();
    await super.onLoad();
    // startAttacking();
  }

  @override
  SpriteAnimation? damageAnimation;

  @override
  SpriteAnimation? deathAnimation;

  @override
  late SpriteAnimation idleAnimation;

  @override
  SpriteAnimation? runAnimation;

  @override
  SpriteAnimation? spawnAnimation;

  @override
  SpriteAnimation? walkAnimation;

  @override
  Map<DamageType, (double, double)> baseTouchDamage = {
    DamageType.energy: (2, 10)
  };
}

abstract class Enemy extends Entity
    with
        ContactCallbacks,
        AttributeFunctionality,
        AttributeFunctionsFunctionality {
  Enemy({
    required super.initPosition,
    required super.gameEnviroment,
  }) {
    priority = enemyPriority;
  }

  bool collisionOnDeath = false;

  @override
  void preSolve(Object other, Contact contact, Manifold oldManifold) {
    if (isDead) {
      contact.setEnabled(collisionOnDeath);
    }
    super.preSolve(other, contact, oldManifold);
  }

  @override
  // TODO: implement priority
  int get priority => enemyPriority;

  @override
  Filter? filter = Filter()
    ..categoryBits = enemyCategory
    ..maskBits = attackCategory +
        playerCategory +
        enemyCategory +
        sensorCategory +
        swordCategory;
  // ..maskBits = 0x0000;

  TimerComponent? shooter;
  double shotFreq = 1;

  abstract double touchDamage;

  @override
  EntityType entityType = EntityType.enemy;
}

class EnemyManagement extends Component {
  int enemiesSpawned = 0;
  EnemyManagement(this.gameEnviroment);
  GameEnviroment gameEnviroment;

  void generateEnemies() {
    for (var i = 1; i < rng.nextInt(4) + 1; i++) {
      for (var j = 1; j < rng.nextInt(4) + 1; j++) {
        gameEnviroment.physicsComponent.add(DummyTwo(
            initPosition:
                generateRandomGamePositionInViewport(false, gameEnviroment),
            gameEnviroment: gameEnviroment));
      }
    }
  }

  @override
  FutureOr<void> onLoad() {
    priority = enemyPriority;

    // add(TimerComponent(
    //   period: 2,
    //   repeat: true,
    //   onTick: () {
    //     generateEnemies();

    //   },
    // )..onTick());

    gameEnviroment.physicsComponent.add(
        DummyTwo(initPosition: Vector2.zero(), gameEnviroment: gameEnviroment));
    return super.onLoad();
  }
}

class MeleeTest extends Enemy
    with
        HealthFunctionality,
        MovementFunctionality,
        DropExperienceFunctionality,
        DumbFollowAI,
        TouchDamageFunctionality {
  MeleeTest({
    required super.initPosition,
    required super.gameEnviroment,
  });

  @override
  void update(double dt) {
    moveCharacter();
    super.update(dt);
  }

  @override
  (double, double) xpRate = (0.001, 0.01);

  @override
  double height = 1;

  @override
  double baseInvincibilityDuration = 0.0;

  @override
  double baseHealth = 5;

  @override
  double baseSpeed = .02;

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
    await loadAnimationSprites();
    await super.onLoad();
    // startAttacking();
  }

  @override
  SpriteAnimation? damageAnimation;

  @override
  SpriteAnimation? deathAnimation;

  @override
  late SpriteAnimation idleAnimation;

  @override
  SpriteAnimation? runAnimation;

  @override
  SpriteAnimation? spawnAnimation;

  @override
  SpriteAnimation? walkAnimation;

  @override
  Map<DamageType, (double, double)> baseTouchDamage = {
    DamageType.energy: (1, 4)
  };
}
