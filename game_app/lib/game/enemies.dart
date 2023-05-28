import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/game/characters.dart';
import 'package:game_app/game/entity.dart';
import 'package:game_app/game/games.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/game/player.dart';

import '../functions/functions.dart';

class Enemy extends Entity with ContactCallbacks {
  Enemy(
    Vector2 initPosition,
    this.enemyType,
  ) : super(
          file: enemyType.getFilename(),
          entityType: EntityType.enemy,
          position: initPosition,
        ) {
    invincibiltyDuration = 0;
  }

  EnemyType enemyType;

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

  @override
  void update(double dt) {
    if (hittingPlayer) {
      gameRef.player.hit(hashCode, 3);
    }
    body.applyForce(
        (gameRef.player.center - body.position).normalized() * maxSpeed);
    super.update(dt);
  }

  @override
  Filter? filter = Filter()..categoryBits = enemyCategory;

  @override
  double height = 5;

  @override
  double invincibiltyDuration = 0;

  @override
  double maxHealth = 10;

  @override
  double maxSpeed = 150;
}

class EnemyManagement extends Component with HasGameRef<GameplayGame> {
  double lastEnemySpawn = 0;

  @override
  void update(double dt) {
    if (lastEnemySpawn > .05) {
      add(Enemy(
          generateRandomGamePositionUsingViewport(
            false,
            gameRef,
          ),
          EnemyType.flameHead));
      lastEnemySpawn = 0;
    }
    lastEnemySpawn += dt;
    super.update(dt);
  }
}
