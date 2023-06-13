import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/entities/enemy_mixin.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/entities/player.dart';
import 'package:game_app/game/powerups.dart';
import 'package:game_app/weapons/weapons.dart';

import '../functions/functions.dart';
import '../functions/vector_functions.dart';
import '../game/physics_filter.dart';
import '../resources/classes.dart';
import '../resources/enums.dart';

class Dummy extends Enemy
    with
        MovementFunctionality,
        AimFunctionality,
        AttackFunctionality,
        AimControlFunctionality,
        DumbFollowRangeAI,
        HealthFunctionality {
  Dummy({
    required super.initPosition,
    required super.ancestor,
  });

  EnemyType enemyType = EnemyType.flameHead;

  @override
  double height = 4;

  @override
  double baseInvincibilityDuration = 0.1;

  @override
  double baseHealth = 100;

  @override
  double baseSpeed = 2;

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
  AimPattern aimPattern = AimPattern.player;
}

class DummyTwo extends Enemy
    with
        // AttackFunctionality,
        MovementFunctionality,
        HealthFunctionality,
        DropExperienceFunctionality,
        DumbFollowScaredAI {
  DummyTwo({
    required super.initPosition,
    required super.ancestor,
  });

  EnemyType enemyType = EnemyType.flameHead;

  @override
  (double, double) xpRate = (0.001, 0.01);

  @override
  double height = 4;

  @override
  double baseInvincibilityDuration = 0.1;

  @override
  double baseHealth = 100;

  @override
  double baseSpeed = 2;

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
    // initialWeapons.addAll([Sword.create]);
//
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
}

abstract class Enemy extends Entity with ContactCallbacks {
  Enemy({
    required super.initPosition,
    required super.ancestor,
  });

  @override
  Filter? filter = Filter()
    ..categoryBits = enemyCategory
    ..maskBits =
        bulletCategory + playerCategory + sensorCategory + swordCategory;
  // ..maskBits = 0xFFFF;

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

  @override
  void update(double dt) {
    if (hittingPlayer) {
      ancestor.player.takeDamage(hashCode.toString(), touchDamage);
    }

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
    // add(
    //   Dummy(
    //     ancestor: mainGameRef,
    //     initPosition: generateRandomGamePositionUsingViewport(
    //       false,
    //       mainGameRef,
    //     ),
    //   ),
    // );
    // add(TimerComponent(
    //   period: 2,
    //   repeat: true,
    //   onTick: () => add(
    //     Dummy(
    //       ancestor: mainGameRef,
    //       initPosition: generateRandomGamePositionUsingViewport(
    //         false,
    //         mainGameRef,
    //       ),
    //     ),
    //   ),
    // ));
    add(TimerComponent(
      period: 2,
      repeat: true,
      onTick: () => add(
        DummyTwo(
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
          period: 30,
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
