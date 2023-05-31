import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/game/characters.dart';
import 'package:game_app/game/entity.dart';
import 'package:game_app/game/games.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/game/player.dart';
import 'package:game_app/game/weapons.dart';
import 'package:game_app/game/weapon_class.dart';

import '../functions/vector_functions.dart';

class Enemy extends Entity with ContactCallbacks {
  Enemy({required Vector2 initPosition, required this.id})
      : super(
          file: EnemyType.flameHead.getFilename(),
          position: initPosition,
        ) {
    invincibiltyDuration = .0;
  }

  EnemyType enemyType = EnemyType.flameHead;

  String id;

  Weapon? _projectileWeapon;
  TimerComponent? shooter;
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    shooter = TimerComponent(
      period: shotFreq,
      repeat: true,
      onTick: () {
        _projectileWeapon?.shoot();
      },
    );
    add(shooter!);
    _projectileWeapon = Pistol();
    aimingAnglePosition.add(_projectileWeapon!);
  }

  @override
  Future<void> onDeath() async {
    spriteAnimationComponent.add(OpacityEffect.fadeOut(
      EffectController(
        duration: .5,
      ),
      onComplete: () {
        removeFromParent();
      },
    ));
  }

  bool hittingPlayer = false;

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

  double shotFreq = 1;

  @override
  void update(double dt) {
    if (hittingPlayer) {
      gameRef.player.takeDamage(id, 3);
    }
    moveCharacter();
    super.update(dt);
  }

  @override
  void moveCharacter({Vector2? delta}) {
    super.moveCharacter(
        delta: (gameRef.player.center - body.position).normalized());
  }

  @override
  Filter? filter = Filter()..categoryBits = enemyCategory;

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
}

class EnemyManagement extends Component with HasGameRef<GameplayGame> {
  int enemiesSpawned = 0;
  @override
  FutureOr<void> onLoad() {
    const enemyType = EnemyType.flameHead;

    add(TimerComponent(
      period: 1,
      repeat: true,
      onTick: () => add(Enemy(
          initPosition: generateRandomGamePositionUsingViewport(
            false,
            gameRef,
          ),
          id: (enemiesSpawned++).toString() + enemyType.name)),
    ));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // if (lastEnemySpawn > .5) {
    // const enemyType = EnemyType.flameHead;
    // add(Enemy(
    //     initPosition: generateRandomGamePositionUsingViewport(
    //       false,
    //       gameRef,
    //     ),
    //     id: (enemiesSpawned++).toString() + enemyType.name));
    // lastEnemySpawn = 0;
    // }
    super.update(dt);
  }
}
