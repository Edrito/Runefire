import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/rendering.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/main.dart';

import '../resources/classes.dart';
import '../resources/enums.dart';
// ignore: unused_import
import 'enemy.dart';
import 'entity_mixin.dart';

abstract class Entity extends BodyComponent<GameRouter> with BaseAttributes {
  Entity({required this.initPosition, required this.ancestor});

  abstract EntityType entityType;
  GameEnviroment ancestor;

  //STATUS
  Vector2 initPosition;

  EntityStatus? statusQueue;
  EntityStatus entityStatus = EntityStatus.spawn;
  abstract double height;

  //META

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
  late PlayerAttachmentJointComponent mouseJoint;
  late PlayerAttachmentJointComponent handJoint;
  late PlayerAttachmentJointComponent backJoint;
  Vector2 lastAimingPosition = Vector2.zero();
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
        priority: 0,
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
              duration: .5,
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
    if (this is AttackFunctionality) {
      (this as AttackFunctionality)
          .carriedWeapons
          .forEach((key, value) => value.removeFromParent());
    }
    if (!gameRef.router.currentRoute.maintainState) {
      super.onRemove();
    }
  }

  @override
  Body createBody() {
    late CircleShape shape;
    shape = CircleShape();
    shape.radius = spriteAnimationComponent.size.x / 2;
    renderBody = false;
    final fixtureDef = FixtureDef(shape,
        restitution: 0, friction: 0, density: 0.001, filter: filter);
    final bodyDef = BodyDef(
      userData: this,
      position: initPosition,
      type: BodyType.dynamic,
      linearDamping: 12,
      fixedRotation: true,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  Future<void> onLoad() async {
    setEntityStatus(EntityStatus.spawn);
    handJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.hand,
        anchor: Anchor.center, size: Vector2.zero());
    backJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.back,
        anchor: Anchor.center, size: Vector2.zero(), priority: -1);
    mouseJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.mouse,
        anchor: Anchor.center, size: Vector2.zero(), priority: 0);
    priority = 0;
    shadow3DDecorator = Shadow3DDecorator(
        base: spriteAnimationComponent.size,
        angle: 1.4,
        xShift: 250,
        yScale: 1.5,
        opacity: .5,
        blur: .5)
      ..base.y += -3
      ..base.x -= 1;

    spriteAnimationComponent.decorator = shadow3DDecorator;
    spriteWrapper = PositionComponent(
        priority: 0,
        size: spriteAnimationComponent.size,
        anchor: Anchor.center);
    spriteWrapper.flipHorizontallyAroundCenter();
    add(spriteWrapper..add(spriteAnimationComponent));
    add(backJoint);
    add(handJoint);
    add(mouseJoint);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    flipSpriteCheck();

    super.update(dt);
  }

  void flipSpriteCheck() {
    final degree = -degrees(handJoint.angle);
    if ((degree < 180 && !flipped) || (degree >= 180 && flipped)) {
      // if (!(handJoint.weaponClass?.attackTypes.contains(AttackType.melee) ??
      //     true)) {
      // }
      shadow3DDecorator.xShift = 250 * (flipped ? 1 : -1);
      handJoint.flipHorizontallyAroundCenter();

      spriteWrapper.flipHorizontallyAroundCenter();
      flipped = !flipped;
    }
  }
}
