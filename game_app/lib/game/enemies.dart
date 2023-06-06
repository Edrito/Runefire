import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/game/characters.dart';
import 'package:game_app/game/entity.dart';
import 'package:game_app/game/main_game.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/game/player.dart';
import 'package:game_app/game/powerups.dart';
import 'package:game_app/weapons/weapons.dart';

import '../functions/vector_functions.dart';
import '../resources/classes.dart';

class Enemy extends Entity with ContactCallbacks {
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
    initialWeapons.addAll([Sword.create]);
    final idleSprite = (await Sprite.load('enemy_sprites/idle.png'));
    idleAnimation = SpriteSheet(
            image: idleSprite.image,
            srcSize: Vector2(idleSprite.srcSize.x / 10, idleSprite.srcSize.y))
        .createAnimation(row: 0, stepTime: .2);
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

class EnemyManagement extends Component {
  int enemiesSpawned = 0;
  EnemyManagement(this.mainGameRef);
  GameEnviroment mainGameRef;

  @override
  FutureOr<void> onLoad() {
    const enemyType = EnemyType.flameHead;

    add(TimerComponent(
      period: 1,
      repeat: true,
      onTick: () => add(Enemy(
          ancestor: mainGameRef,
          initPosition: generateRandomGamePositionUsingViewport(
            false,
            mainGameRef,
          ),
          id: (enemiesSpawned++).toString() + enemyType.name)),
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
