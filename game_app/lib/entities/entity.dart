import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/main.dart';
import 'package:uuid/uuid.dart';

import '../resources/enums.dart';
// ignore: unused_import
import '../resources/constants/priorities.dart';
import '../attributes/attributes_mixin.dart';
import 'entity_mixin.dart';

abstract class Entity extends BodyComponent<GameRouter> with BaseAttributes {
  Entity({required this.initPosition, required this.gameEnviroment}) {
    entityId = const Uuid().v4();
  }

  AttributeFunctionsFunctionality? get attributeFunctionsFunctionality =>
      this is AttributeFunctionsFunctionality
          ? this as AttributeFunctionsFunctionality
          : null;

  late String entityId;

  abstract EntityType entityType;
  dynamic gameEnviroment;

  bool get isPlayer => EntityType.player == entityType;

  void permanentlyDisableEntity() {}

  double get entityStatusHeight =>
      (height.parameter / 2) + (height.parameter / 4);

  late EntityStatusEffectsWrapper entityStatusWrapper;

  //STATUS
  Vector2 initPosition;

  EntityStatus? statusQueue;
  EntityStatus? previousStatus;
  EntityStatus entityStatus = EntityStatus.spawn;

  //ANIMATION
  abstract SpriteAnimation idleAnimation;
  abstract SpriteAnimation? walkAnimation;
  abstract SpriteAnimation? runAnimation;
  abstract SpriteAnimation? spawnAnimation;

  SpriteAnimation? animationQueue;
  SpriteAnimation? previousAnimation;

  bool tempAnimationPlaying = false;

  late SpriteAnimationComponent spriteAnimationComponent;
  late PositionComponent spriteWrapper;
  // late Shadow3DDecorator shadow3DDecorator;

  bool flipped = false;

  //POSITIONING

  late PlayerAttachmentJointComponent backJoint;
  abstract Filter? filter;

  Future<void> loadAnimationSprites();

  void tickerComplete() {
    tempAnimationPlaying = false;
    entityStatus = statusQueue ?? previousStatus ?? entityStatus;
    spriteAnimationComponent.animation = animationQueue ??
        previousAnimation ??
        spriteAnimationComponent.animation;
    previousAnimation = null;
    previousStatus = null;
  }

  void spawnStatus() {
    applyTempAnimation(spawnAnimation);
  }

  void attackStatus(SpriteAnimation? attackAnimation) {
    applyTempAnimation(attackAnimation);
  }

  void applyTempAnimation(SpriteAnimation? tempAnimation) {
    if (tempAnimation == null) return;
    previousAnimation = spriteAnimationComponent.animation;
    previousStatus = entityStatus;
    assert(!tempAnimation.loop, "Temp animations must not loop");
    tempAnimationPlaying = true;
    spriteAnimationComponent.animation = tempAnimation.clone();
    spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;
  }

  void jumpStatus() {}
  void dashStatus() {}
  void deadStatus() {}
  void damageStatus() {}
  void dodgeStatus() {}

  Future<void> setEntityStatus(EntityStatus newEntityStatus,
      [SpriteAnimation? attackAnimation]) async {
    if (entityStatus == EntityStatus.dead) return;

    SpriteAnimation? animation;
    if (newEntityStatus == EntityStatus.spawn) {
      animation = spawnAnimation ?? idleAnimation;
      spriteAnimationComponent = SpriteAnimationComponent(
        animation: animation,
        size: animation.frames.first.sprite.srcSize
            .scaled(height.parameter / animation.frames.first.sprite.srcSize.y),
      );
      entityStatus = newEntityStatus;
      return;
    }

    if (newEntityStatus == entityStatus &&
        [EntityStatus.run, EntityStatus.walk, EntityStatus.idle]
            .contains(newEntityStatus)) return;

    switch (newEntityStatus) {
      case EntityStatus.spawn:
        spawnStatus();
        break;
      case EntityStatus.attack:
        attackStatus(attackAnimation);

        break;

      case EntityStatus.jump:
        jumpStatus();
        break;
      case EntityStatus.dash:
        dashStatus();
        break;

      case EntityStatus.dead:
        deadStatus();
        break;
      case EntityStatus.damage:
        damageStatus();

        break;
      case EntityStatus.dodge:
        dodgeStatus();
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

    if (tempAnimationPlaying) {
      statusQueue = newEntityStatus;
      animationQueue = animation;
    } else {
      entityStatus = newEntityStatus;
      spriteAnimationComponent.animation = animation;
    }

    spriteAnimationComponent.animation ??= animationQueue ?? idleAnimation;

    if (!(spriteAnimationComponent.animation?.loop ?? false)) {
      await spriteAnimationComponent.animationTicker?.completed;
    }
  }

  @override
  void onRemove() {
    if (!game.router.currentRoute.maintainState) {
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

    // shadow3DDecorator = Shadow3DDecorator(
    //     base: spriteAnimationComponent.size,
    //     angle: 1.4,
    //     xShift: 250,
    //     yScale: 2,
    //     opacity: 1,
    //     blur: .2)
    //   ..base.y += -.8
    //   ..base.x -= 1;

    // spriteAnimationComponent.decorator = shadow3DDecorator;
    spriteWrapper = PositionComponent(
        size: spriteAnimationComponent.size, anchor: Anchor.center);
    spriteWrapper.flipHorizontallyAroundCenter();
    // if (isPlayer) {
    add(spriteWrapper..add(spriteAnimationComponent));
    // } else {
    //   add(spriteWrapper
    //     ..add(CircleComponent(
    //       radius: height / 2,
    //       paint: BasicPalette.blue.paint(),
    //     )));
    // }
    entityStatusWrapper = EntityStatusEffectsWrapper(
        position: Vector2(0, -entityStatusHeight),
        size: Vector2(spriteAnimationComponent.width * 1.5, 0))
      ..addToParent(this);

    add(backJoint);

    return super.onLoad();
  }

  void spriteFlipCheck() {
    final movement = body.linearVelocity.x;
    if ((movement > 0 && !flipped) || (movement <= 0 && flipped)) {
      flipSprite();
    }
  }

  void flipSprite() {
    // shadow3DDecorator.xShift = 250 * (flipped ? 1 : -1);
    backJoint.flipHorizontallyAroundCenter();
    spriteWrapper.flipHorizontallyAroundCenter();

    flipped = !flipped;
  }
}
