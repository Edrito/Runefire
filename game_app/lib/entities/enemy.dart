import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/entities/enemy_mixin.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/game/powerups.dart';

import '../functions/functions.dart';
import '../functions/vector_functions.dart';
import '../game/enviroment.dart';
import '../resources/physics_filter.dart';
import '../resources/enums.dart';
import '../resources/priorities.dart';

class Dummy extends Enemy with HealthFunctionality {
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
        HealthFunctionality,
        DodgeFunctionality,
        MovementFunctionality,
        DropExperienceFunctionality,
        TouchDamageFunctionality,
        DumbFollowScaredAI {
  DummyTwo({
    required super.initPosition,
    required super.ancestor,
  });

  EnemyType enemyType = EnemyType.flameHead;
  @override
  double baseDodgeChance = .1;

  @override
  (double, double) xpRate = (0.001, 0.01);

  @override
  double height = 4;

  @override
  double baseInvincibilityDuration = 0.0;

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

  @override
  SpriteAnimation? dodgeAnimation;

  @override
  Map<DamageType, (double, double)> touchDamageLevels = {
    DamageType.energy: (1, 4)
  };
}

abstract class Enemy extends Entity with ContactCallbacks {
  Enemy({
    required super.initPosition,
    required super.ancestor,
  });

  @override
  // TODO: implement priority
  int get priority => enemyPriority;

  @override
  Filter? filter = Filter()
    ..categoryBits = enemyCategory
    ..maskBits = bulletCategory +
        playerCategory +
        enemyCategory +
        sensorCategory +
        swordCategory;
  // ..maskBits = 0xFFFF;

  TimerComponent? shooter;
  double shotFreq = 1;

  abstract double touchDamage;

  @override
  EntityType entityType = EntityType.enemy;
}

class EnemyManagement extends Component {
  int enemiesSpawned = 0;
  EnemyManagement(this.mainGameRef);
  GameEnviroment mainGameRef;

  @override
  FutureOr<void> onLoad() {
    var section = 10.0;
    for (var i = 1; i < 10; i++) {
      for (var j = 1; j < 10; j++) {
        section = section - ((Random().nextDouble() * 5) - 2.5);
        add(DummyTwo(
            initPosition: Vector2(section * i, section * j) -
                mainGameRef.gameCamera.viewport.size / 15,
            ancestor: mainGameRef));
      }
    }
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

    add(PowerupItem(
        Damage(), generateRandomGamePositionUsingViewport(true, mainGameRef)));
    return super.onLoad();
  }
}
