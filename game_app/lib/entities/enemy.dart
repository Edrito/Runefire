import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/entities/enemy_mixin.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/pages/weapon_menu.dart';
import 'package:game_app/resources/powerups.dart';

import '../functions/functions.dart';
import '../functions/vector_functions.dart';
import '../game/enviroment.dart';
import '../resources/physics_filter.dart';
import '../resources/enums.dart';
import '../resources/priorities.dart';

class DummyTwo extends Enemy
    with
        HealthFunctionality,
        MovementFunctionality,
        DropExperienceFunctionality,
        DumbFollowAI,
        TouchDamageFunctionality {
  DummyTwo({
    required super.initPosition,
    required super.gameEnv,
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

abstract class Enemy extends Entity with ContactCallbacks {
  Enemy({
    required super.initPosition,
    required super.gameEnv,
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
  EnemyManagement(this.gameEnv);
  GameEnviroment gameEnv;

  void generateEnemies() {
    var section = 5.0;
    for (var i = 1; i < 5; i++) {
      for (var j = 1; j < 10; j++) {
        section = section - ((rng.nextDouble() * section / 2) - section / 4);
        gameEnv.physicsComponent.add(DummyTwo(
            initPosition: Vector2(section * i, section * j) -
                gameEnv.gameCamera.viewport.size / 50,
            gameEnv: gameEnv));
      }
    }
  }

  @override
  FutureOr<void> onLoad() {
    priority = enemyPriority;

    // add(DummyTwo(
    //     initPosition: Vector2(0, 0) - mainGameRef.gameCamera.viewport.size / 15,
    //     ancestor: mainGameRef));
    // add(TimerComponent(
    //   period: 2,
    //   repeat: true,
    //   onTick: () => add(
    //     DummyTwo(
    //       ancestor: mainGameRef,
    //       initPosition: generateRandomGamePositionUsingViewport(
    //         false,
    //         mainGameRef,
    //       ),
    //     ),wd
    //   ),
    // ));

    // add(
    //   TimerComponent(
    //       period: 30,
    //       repeat: true,
    //       onTick: () {
    //         add(PowerupItem(Damage(),
    //             generateRandomGamePositionUsingViewport(true, mainGameRef)));
    //         add(PowerupItem(Agility(),
    //             generateRandomGamePositionUsingViewport(true, mainGameRef)));
    //       }),
    // );

    add(PowerupItem(PowerAttribute(level: 0, entity: gameEnv.player),
        generateRandomGamePositionUsingViewport(true, gameEnv)));

    return super.onLoad();
  }
}
