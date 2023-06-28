import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/rendering.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/entities/player.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/main.dart';
import 'package:uuid/uuid.dart';

import '../game/enviroment.dart';
import '../resources/enums.dart';
// ignore: unused_import
import '../resources/priorities.dart';
import 'entity_mixin.dart';

abstract class Entity extends BodyComponent<GameRouter> with BaseAttributes {
  Entity({required this.initPosition, required this.ancestor}) {
    entityId = const Uuid().v4();
  }

  late String entityId;
  Random rng = Random();

  abstract EntityType entityType;
  GameEnviroment ancestor;

  bool get isPlayer => this is Player;

  //STATUS
  Vector2 initPosition;

  EntityStatus? statusQueue;
  EntityStatus entityStatus = EntityStatus.spawn;
  abstract double height;

  //ANIMATION
  abstract SpriteAnimation idleAnimation;
  abstract SpriteAnimation? walkAnimation;
  abstract SpriteAnimation? runAnimation;
  abstract SpriteAnimation? spawnAnimation;

  SpriteAnimation? animationQueue;

  bool tempAnimationPlaying = false;

  late SpriteAnimationComponent spriteAnimationComponent;
  late PositionComponent spriteWrapper;
  late Shadow3DDecorator shadow3DDecorator;

  bool flipped = false;

  //POSITIONING

  late PlayerAttachmentJointComponent backJoint;
  abstract Filter? filter;

  Future<void> loadAnimationSprites();

  void tickerComplete() {
    tempAnimationPlaying = false;
    entityStatus = statusQueue ?? entityStatus;
    spriteAnimationComponent.animation = animationQueue;
  }

  void setEntityStatus(EntityStatus newEntityStatus,
      [SpriteAnimation? attackAnimation]) {
    SpriteAnimation? animation;
    if (newEntityStatus == EntityStatus.spawn) {
      animation = spawnAnimation ?? idleAnimation;
      spriteAnimationComponent = SpriteAnimationComponent(
        animation: animation,
        size: animation.frames.first.sprite.srcSize
            .scaled(height / animation.frames.first.sprite.srcSize.y),
      );
      entityStatus = newEntityStatus;
      return;
    }

    if (newEntityStatus == entityStatus &&
        [EntityStatus.run, EntityStatus.walk, EntityStatus.idle]
            .contains(newEntityStatus)) return;

    switch (newEntityStatus) {
      case EntityStatus.spawn:
        if (spawnAnimation == null) break;
        assert(!spawnAnimation!.loop, "Temp animations must not loop");
        tempAnimationPlaying = true;
        spriteAnimationComponent.animation = spawnAnimation?.clone();
        spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;

        break;
      case EntityStatus.attack:
        if (attackAnimation == null) break;
        assert(!attackAnimation.loop, "Temp animations must not loop");
        tempAnimationPlaying = true;
        spriteAnimationComponent.animation = attackAnimation.clone();
        spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;

        break;

      case EntityStatus.jump:
        if (this is! JumpFunctionality) return;
        var jump = this as JumpFunctionality;
        if (!jump.jump() || jump.jumpAnimation == null) break;
        assert(!jump.jumpAnimation!.loop, "Temp animations must not loop");
        tempAnimationPlaying = true;
        spriteAnimationComponent.animation = jump.jumpAnimation?.clone();

        spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;

        break;
      case EntityStatus.dash:
        if (this is! DashFunctionality) return;
        var dash = this as DashFunctionality;
        if (!dash.dash() || dash.dashAnimation == null) break;
        assert(!dash.dashAnimation!.loop, "Temp animations must not loop");
        tempAnimationPlaying = true;
        spriteAnimationComponent.animation = dash.dashAnimation?.clone();
        spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;

        break;
      case EntityStatus.dead:
        if (this is! HealthFunctionality) return;
        var health = this as HealthFunctionality;
        if (this is AttackFunctionality) {
          var attack = (this as AttackFunctionality);
          attack.endAttacking();
        }
        disableMovement = true;
        if (health.deathAnimation == null) {
          spriteAnimationComponent.add(OpacityEffect.fadeOut(
            EffectController(
              duration: 1.5,
            ),
            onComplete: () {
              removeFromParent();
            },
          ));
          break;
        }
        tempAnimationPlaying = true;
        assert(!health.deathAnimation!.loop, "Temp animations must not loop");
        spriteAnimationComponent.animation = health.deathAnimation?.clone();
        spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;
        spriteAnimationComponent.add(OpacityEffect.fadeOut(
          EffectController(
            duration: spriteAnimationComponent.animationTicker?.totalDuration(),
          ),
          onComplete: () {
            removeFromParent();
          },
        ));

        break;
      case EntityStatus.damage:
        if (this is! HealthFunctionality) return;
        var health = this as HealthFunctionality;
        if (health.damageAnimation == null) break;
        assert(!health.damageAnimation!.loop, "Temp animations must not loop");
        tempAnimationPlaying = true;
        spriteAnimationComponent.animation = health.damageAnimation?.clone();
        spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;

        break;
      case EntityStatus.dodge:
        if (this is! DodgeFunctionality) return;
        var dodge = this as DodgeFunctionality;
        if (dodge.dodgeAnimation == null) break;
        assert(!dodge.dodgeAnimation!.loop, "Temp animations must not loop");
        tempAnimationPlaying = true;
        spriteAnimationComponent.animation = dodge.dodgeAnimation?.clone();
        spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;

        break;
      case EntityStatus.idle:
        animation = idleAnimation;

        break;
      case EntityStatus.run:
        animation = runAnimation;

        break;
      case EntityStatus.walk:
        animation = walkAnimation;

        break;
      default:
        animation = idleAnimation;
    }
    animation ??= idleAnimation;

    if (tempAnimationPlaying) {
      statusQueue = newEntityStatus;
      animationQueue = animation;
    } else {
      entityStatus = newEntityStatus;
      spriteAnimationComponent.animation = animation;
    }
  }

  @override
  void onRemove() {
    if (!gameRef.router.currentRoute.maintainState) {
      super.onRemove();
    }
  }

  @override
  Body createBody() {
    late CircleShape shape;
    shape = CircleShape();
    shape.radius = spriteAnimationComponent.size.x / 3;
    renderBody = false;
    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        restitution: 0,
        friction: 0,
        density: 0.001,
        filter: filter);
    final bodyDef = BodyDef(
      position: initPosition,
      userData: this,
      type: BodyType.dynamic,
      linearDamping: 12,
      fixedRotation: true,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  Future<void> onLoad() async {
    setEntityStatus(EntityStatus.spawn);

    backJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.back,
        anchor: Anchor.center,
        size: Vector2.zero(),
        priority: playerBackPriority);

    shadow3DDecorator = Shadow3DDecorator(
        base: spriteAnimationComponent.size,
        angle: 1.4,
        xShift: 250,
        yScale: 2,
        opacity: 1,
        blur: .2)
      ..base.y += -.8
      ..base.x -= 1;

    spriteAnimationComponent.decorator = shadow3DDecorator;
    spriteWrapper = PositionComponent(
        size: spriteAnimationComponent.size, anchor: Anchor.center);
    spriteWrapper.flipHorizontallyAroundCenter();
    add(spriteWrapper..add(spriteAnimationComponent));
    add(backJoint);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    flipSpriteCheck();
    super.update(dt);
  }

  void flipSpriteCheck() {
    final movement = body.linearVelocity.x;
    if ((movement > 0 && !flipped) || (movement <= 0 && flipped)) {
      flipSprite();
    }
  }

  void flipSprite() {
    shadow3DDecorator.xShift = 250 * (flipped ? 1 : -1);
    backJoint.flipHorizontallyAroundCenter();
    spriteWrapper.flipHorizontallyAroundCenter();
    flipped = !flipped;
  }
}
