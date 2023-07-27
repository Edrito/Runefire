import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/entities/enemy_mixin.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/entities/entity_mixin.dart';

import '../resources/area_effects.dart';
import '../resources/functions/functions.dart';
import '../resources/constants/physics_filter.dart';
import '../resources/enums.dart';
import '../resources/constants/priorities.dart';
import '../attributes/attributes_mixin.dart';
import 'enemy_state_mixin.dart';

class BossOne extends Enemy
    with
        MovementFunctionality,
        DumbFollowRangeAI,
        AimFunctionality,
        AttackFunctionality,
        AimControlFunctionality,
        DumbShoot,
        StateManagedAI {
  BossOne({
    required super.initPosition,
    required super.gameEnviroment,
  }) {
    height.baseParameter = 3;
    invincibilityDuration.baseParameter = 0;
    maxHealth.baseParameter = 500;
    speed.baseParameter = .07;
    // touchDamage.damageBase[DamageType.physical] = (1, 3);
    initialWeapons = [WeaponType.laserRifle];
    baseState = EnemyState(this,
        priority: 0,
        preventDoubleRandomFunction: false,
        randomFunctions: [
          () async {
            await loaded;
            gameEnviroment.physicsComponent.add(AreaEffect(
              sourceEntity: this,
              position: center,
              radius: 5,
              isInstant: true,
              duration: 0,
              onTick: (entity, areaId) {
                if (entity is HealthFunctionality) {
                  entity.hitCheck(areaId, [
                    DamageInstance(
                        damageBase: 4,
                        damageType: DamageType.psychic,
                        source: this)
                  ]);
                }
              },
            ));
          }
        ],
        stateDuration: 0,
        triggerFunctions: [() => rng.nextBool()]);
    enemyStates = {
      0: EnemyState(this,
          priority: 0,
          randomEventTimeFrame: (1, 2),
          preventDoubleRandomFunction: false,
          randomFunctions: [
            () async {
              gameEnviroment.physicsComponent.add(AreaEffect(
                sourceEntity: this,
                position: center,
                radius: 1,
                isInstant: true,
                duration: 0,
                onTick: (entity, areaId) {
                  if (entity is HealthFunctionality) {
                    entity.hitCheck(areaId, [
                      DamageInstance(
                          damageBase: 4,
                          damageType: DamageType.fire,
                          source: this)
                    ]);
                  }
                },
              ));
            }
          ],
          stateDuration: 0,
          triggerFunctions: [() => rng.nextBool()]),
      1: EnemyState(this,
          priority: 0,
          randomEventTimeFrame: (1, 2),
          preventDoubleRandomFunction: false,
          randomFunctions: [
            () async {
              gameEnviroment.physicsComponent.add(AreaEffect(
                sourceEntity: this,
                position: center,
                radius: 5,
                isInstant: true,
                duration: 0,
                onTick: (entity, areaId) {
                  if (entity is HealthFunctionality) {
                    entity.hitCheck(areaId, [
                      DamageInstance(
                          damageBase: 4,
                          damageType: DamageType.fire,
                          source: this)
                    ]);
                  }
                },
              ));
            }
          ],
          stateDuration: 0,
          triggerFunctions: [() => true])
    };
  }

  @override
  void update(double dt) {
    moveCharacter();
    super.update(dt);
  }

  @override
  (double, double) xpRate = (0.001, 0.01);

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
  EnemyType enemyType = EnemyType.mushroomBrawler;

  @override
  AimPattern aimPattern = AimPattern.player;

  @override
  late EnemyState baseState;

  @override
  late Map<int, EnemyState> enemyStates;
}

class DummyTwo extends Enemy
    with MovementFunctionality, DumbFollowAI, TouchDamageFunctionality {
  DummyTwo({
    required super.initPosition,
    required super.gameEnviroment,
  }) {
    height.baseParameter = 1.5;
    invincibilityDuration.baseParameter = 0;
    maxHealth.baseParameter = 100;
    speed.baseParameter = .05;
    touchDamage.damageBase[DamageType.physical] = (1, 3);
  }

  @override
  void update(double dt) {
    moveCharacter();
    super.update(dt);
  }

  @override
  (double, double) xpRate = (0.001, 0.01);

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
  EnemyType enemyType = EnemyType.mushroomBrawler;
}

abstract class Enemy extends Entity
    with
        ContactCallbacks,
        AttributeFunctionality,
        AttributeFunctionsFunctionality,
        HealthFunctionality,
        DropExperienceFunctionality {
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

  abstract EnemyType enemyType;

  @override
  int get priority => enemyPriority;

  @override
  Filter? filter = Filter()
    ..categoryBits = enemyCategory
    ..maskBits = attackCategory +
        playerCategory +
        enemyCategory +
        sensorCategory +
        swordCategory;

  TimerComponent? shooter;
  double shotFreq = 1;

  @override
  EntityType entityType = EntityType.enemy;
}

class MeleeTest extends Enemy
    with
        HealthFunctionality,
        // MovementFunctionality,
        DropExperienceFunctionality,
        // DumbFollowAI,
        TouchDamageFunctionality {
  MeleeTest({
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
  EnemyType enemyType = EnemyType.mushroomBrawler;
}
