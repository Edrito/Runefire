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

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _projectileWeapon = Bow();
    aimingAnglePosition.add(_projectileWeapon!);
  }

  @override
  Future<void> onDeath() async {
    spriteComponent.add(OpacityEffect.fadeOut(
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

  double lastShot = 0;
  double shotFreq = .5;

  @override
  void update(double dt) {
    if (hittingPlayer) {
      gameRef.player.takeDamage(id, 3);
    }
    if (lastShot > shotFreq) {
      _projectileWeapon?.shoot();
      lastShot = 0;
    } else {
      lastShot += dt;
    }
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
  double height = 5;

  @override
  double invincibiltyDuration = 0;

  @override
  double maxHealth = 100;

  @override
  double maxSpeed = 150;

  @override
  EntityType entityType = EntityType.enemy;
}

class EnemyManagement extends Component with HasGameRef<GameplayGame> {
  double lastEnemySpawn = 0;
  int enemiesSpawned = 0;
  @override
  FutureOr<void> onLoad() {
    const enemyType = EnemyType.flameHead;
    add(Enemy(
        initPosition: generateRandomGamePositionUsingViewport(
          false,
          gameRef,
        ),
        id: (enemiesSpawned++).toString() + enemyType.name));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (lastEnemySpawn > .5) {
      const enemyType = EnemyType.flameHead;
      add(Enemy(
          initPosition: generateRandomGamePositionUsingViewport(
            false,
            gameRef,
          ),
          id: (enemiesSpawned++).toString() + enemyType.name));
      lastEnemySpawn = 0;
    }
    lastEnemySpawn += dt;
    super.update(dt);
  }
}
