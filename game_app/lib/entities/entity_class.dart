import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/attributes/attributes_status_effect.dart';
import 'package:game_app/enemies/enemy.dart';
import 'package:game_app/entities/child_entities.dart';
import 'package:game_app/game/enviroment.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/main.dart';
import 'package:uuid/uuid.dart';

import '../game/enviroment_mixin.dart';
import '../resources/enums.dart';
// ignore: unused_import
import '../resources/constants/priorities.dart';
import '../attributes/attributes_mixin.dart';
import 'entity_mixin.dart';

abstract class Entity extends BodyComponent<GameRouter> with BaseAttributes {
  Entity({required this.initialPosition, required this.enviroment}) {
    initializeParameterManagers();
    entityId = const Uuid().v4();
  }

  AttributeFunctionsFunctionality? get attributeFunctionsFunctionality {
    bool thisIsAttr = this is AttributeFunctionsFunctionality;

    if (thisIsAttr) {
      return this as AttributeFunctionsFunctionality;
    }
    bool thisIsChildEntity = this is ChildEntity;

    if (thisIsChildEntity) {
      return (this as ChildEntity).parentEntity.attributeFunctionsFunctionality;
    }
    return null;
  }

  Set<StatusEffects> get statusEffects {
    if (isChildEntity) {
      return (this as ChildEntity).parentEntity.statusEffects;
    }

    bool thisIsAttr = this is AttributeFunctionality;
    if (thisIsAttr) {
      return (this as AttributeFunctionality)
          .currentAttributes
          .values
          .whereType<StatusEffectAttribute>()
          .map((e) => e.statusEffect)
          .toSet();
    }

    return {};
  }

  Map<dynamic, ChildEntity> childrenEntities = {};

  late String entityId;

  Iterable<Weapon> getAllWeaponItems(
      bool includeSecondaries, bool includeAdditionalPrimaries) {
    Iterable<Weapon> returnList = [];
    // await loaded;
    if (this is! AttackFunctionality) return returnList;

    final attackFunctionality = this as AttackFunctionality;
    for (var element in attackFunctionality.carriedWeapons.values) {
      returnList = [...returnList, element];
      if (includeSecondaries) {
        final secondary = element.getSecondaryWeapon;
        if (secondary != null) {
          returnList = [...returnList, secondary];
        }
      }
      if (includeAdditionalPrimaries) {
        for (var element in element.additionalWeapons.entries) {
          returnList = [...returnList, element.value];
        }
      }
    }
    return returnList;
  }

  Future<void> applyGroundAnimation(
      SpriteAnimation animation, bool followEntity, double yOffset) async {
    final size = animation.frames.first.sprite.srcSize;
    size.scaleTo(height.parameter * 1.35);
    final sprite = SpriteAnimationComponent(
        anchor: Anchor.center, size: size, animation: animation);
    if (!isFlipped) {
      sprite.flipHorizontallyAroundCenter();
    }
    if (followEntity) {
      sprite.position = Vector2(0, yOffset);
    } else {
      enviroment.add(sprite);

      sprite.position = Vector2(center.x, center.y + yOffset);
    }
    sprite.animationTicker?.completed
        .then((value) => sprite.removeFromParent());
  }

  Future<void> applyHitAnimation(
      SpriteAnimation animation, Vector2 sourcePosition, double size) async {
    if (animation.loop) return;
    final spriteSize = animation.frames.first.sprite.srcSize;
    spriteSize.scaleTo(size);
    final thisHeight = height.parameter;
    final sprite = SpriteAnimationComponent(
        anchor: Anchor.center, size: spriteSize, animation: animation);
    sprite.position = Vector2(
        (rng.nextDouble() * thisHeight / 3) - thisHeight / 6,
        (sourcePosition - center).y);

    add(sprite);
    sprite.animationTicker?.completed
        .then((value) => sprite.removeFromParent());
  }

  abstract EntityType entityType;
  Enviroment enviroment;
  GameEnviroment get gameEnviroment => enviroment as GameEnviroment;
  PlayerFunctionality get playerFunctionality =>
      enviroment as PlayerFunctionality;

  bool get isPlayer =>
      EntityType.player == entityType ||
      (isChildEntity && (this as ChildEntity).parentEntity.isPlayer);

  void permanentlyDisableEntity() {}

  double get entityStatusHeight =>
      (height.parameter / 2) + (height.parameter / 4);

  late EntityStatusEffectsWrapper entityStatusWrapper;

  //STATUS
  Vector2 initialPosition;

  dynamic statusQueue;
  dynamic statusPrevious;
  dynamic entityStatus = EntityStatus.spawn;

  Map<dynamic, SpriteAnimation> entityAnimations = {};

  bool temporaryAnimationPlaying = false;

  late SpriteAnimationGroupComponent spriteAnimationGroupComponent;
  // late PositionComponent spriteWrapper;
  // late Shadow3DDecorator shadow3DDecorator;

  bool isFlipped = false;

  //POSITIONING

  late PlayerAttachmentJointComponent backJoint;
  abstract Filter? filter;

  Future<void> loadAnimationSprites();

  void tickerComplete() {
    temporaryAnimationPlaying = false;
    entityStatus = statusQueue ?? statusPrevious ?? EntityStatus.idle;
    spriteAnimationGroupComponent.current = entityStatus;

    statusPrevious = null;
    statusQueue = null;
  }

  void spawnStatus() {
    // applyTempAnimation(entityAnimations[EntityStatus.spawn]);
    statusQueue = EntityStatus.idle;
  }

  void attackStatus() {
    // applyTempAnimation();
  }

  void customStatus() {
    // applyTempAnimation(customAnimation);
  }

  bool jumpStatus() {
    return true;
  }

  bool dashStatus() {
    return true;
  }

  bool deadStatus() {
    return true;
  }

  bool damageStatus() {
    return true;
  }

  bool dodgeStatus() {
    return true;
  }

  Future<void> setEntityStatus(EntityStatus newEntityStatus,
      {dynamic customAnimationKey, bool playAnimation = true}) async {
    if (entityStatus == EntityStatus.dead) return;

    if (newEntityStatus == entityStatus &&
        spriteAnimationGroupComponent.current == newEntityStatus &&
        [EntityStatus.run, EntityStatus.walk, EntityStatus.idle]
            .contains(newEntityStatus)) return;

    bool statusResult = true;
    switch (newEntityStatus) {
      case EntityStatus.spawn:
        spawnStatus();
        break;
      case EntityStatus.attack:
        attackStatus();

        break;

      case EntityStatus.jump:
        statusResult = jumpStatus();
        break;
      case EntityStatus.dash:
        statusResult = dashStatus();
        break;

      case EntityStatus.dead:
        statusResult = deadStatus();
        break;
      case EntityStatus.custom:
        customStatus();
        break;
      case EntityStatus.damage:
        statusResult = damageStatus();

        break;
      case EntityStatus.dodge:
        statusResult = dodgeStatus();
        break;

      default:
    }

    if (!statusResult) return;

    ///If a temporary animation is playing, queue the animation
    if (temporaryAnimationPlaying && newEntityStatus != EntityStatus.dead) {
      statusQueue = customAnimationKey ?? newEntityStatus;
    } else {
      entityStatus = customAnimationKey ?? newEntityStatus;

      if (spriteAnimationGroupComponent.animations!.containsKey(entityStatus)) {
        spriteAnimationGroupComponent.current = entityStatus;
      } else {
        tickerComplete();
      }

      spriteAnimationGroupComponent.animationTicker?.reset();

      if (!(spriteAnimationGroupComponent.animation?.loop ?? true) &&
          newEntityStatus != EntityStatus.dead) {
        temporaryAnimationPlaying = true;

        spriteAnimationGroupComponent.animationTicker?.onComplete = () {
          spriteAnimationGroupComponent.animationTicker?.reset();
          tickerComplete();
        };
      }
    }

    if (temporaryAnimationPlaying) {
      await spriteAnimationGroupComponent.animationTicker?.completed;
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
    shape.radius = spriteAnimationGroupComponent.size.x / 3;
    renderBody = false;
    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        restitution: 0,
        friction: 0,
        density: 0.001,
        filter: filter);
    final bodyDef = BodyDef(
      position: initialPosition,
      userData: this,
      type: BodyType.dynamic,
      linearDamping: 12,
      fixedRotation: true,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  void applyHeightToSprite() {
    spriteAnimationGroupComponent.size = Vector2.all(height.parameter);
  }

  @override
  Future<void> onLoad() async {
    spriteAnimationGroupComponent = SpriteAnimationGroupComponent(
        anchor: Anchor.center, animations: entityAnimations);

    setEntityStatus(EntityStatus.spawn);
    applyHeightToSprite();
    backJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.back,
        anchor: Anchor.center,
        size: Vector2.zero(),
        priority: playerBackPriority);

    // spriteWrapper = PositionComponent(
    //     size: spriteAnimationComponent.size, anchor: Anchor.center);
    spriteAnimationGroupComponent.flipHorizontallyAroundCenter();
    add(spriteAnimationGroupComponent);
    entityStatusWrapper = EntityStatusEffectsWrapper(
        position: Vector2(0, -entityStatusHeight),
        size: Vector2(spriteAnimationGroupComponent.width * 1.5, 0),
        entity: this)
      ..addToParent(this);

    add(backJoint);

    return super.onLoad();
  }

  void spriteFlipCheck() {
    final movement = body.linearVelocity.x;
    if ((movement > 0 && !isFlipped) || (movement <= 0 && isFlipped)) {
      flipSprite();
    }
  }

  void flipSprite() {
    backJoint.flipHorizontallyAroundCenter();
    spriteAnimationGroupComponent.flipHorizontallyAroundCenter();

    isFlipped = !isFlipped;
  }
}
