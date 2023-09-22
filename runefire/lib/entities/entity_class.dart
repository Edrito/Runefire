import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:runefire/attributes/attributes_status_effect.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/child_entities.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/main.dart';
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

  List<Function(bool isFlipped)> onBodyFlip = [];

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

  int currentHitAnimations = 0;
  Future<void> applyHitAnimation(
      SpriteAnimation animation, Vector2 sourcePosition, double size,
      [Color? color]) async {
    if (animation.loop || currentHitAnimations > hitAnimationLimit) return;
    currentHitAnimations++;
    final spriteSize = animation.frames.first.sprite.srcSize;
    spriteSize.scaleTo(size);
    final thisHeight = height.parameter;
    final sprite = SpriteAnimationComponent(
        anchor: Anchor.center, size: spriteSize, animation: animation);
    if (color != null) {
      sprite.paint = colorPalette.buildProjectile(
          color: color,
          projectileType: ProjectileType.paintBullet,
          lighten: false);
    }
    sprite.position = Vector2(
        (rng.nextDouble() * thisHeight / 3) - thisHeight / 6,
        ((sourcePosition - center).y).clamp(thisHeight / -2, thisHeight / 2));

    add(sprite);
    sprite.animationTicker?.completed.then((value) {
      sprite.removeFromParent();

      currentHitAnimations--;
    });
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

  late SpriteAnimationGroupComponent entityAnimationsGroup;
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
    entityAnimationsGroup.current = entityStatus;

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
        entityAnimationsGroup.current == newEntityStatus &&
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

      if (entityAnimationsGroup.animations!.containsKey(entityStatus)) {
        entityAnimationsGroup.current = entityStatus;
      } else {
        tickerComplete();
      }

      entityAnimationsGroup.animationTicker?.reset();

      if (!(entityAnimationsGroup.animation?.loop ?? true) &&
          newEntityStatus != EntityStatus.dead) {
        temporaryAnimationPlaying = true;

        entityAnimationsGroup.animationTicker?.onComplete = () {
          entityAnimationsGroup.animationTicker?.reset();
          tickerComplete();
        };
      }
    }

    if (temporaryAnimationPlaying) {
      await entityAnimationsGroup.animationTicker?.completed;
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
    shape.radius = entityAnimationsGroup.size.x / 3;
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
    entityAnimationsGroup.size = Vector2.all(height.parameter);
  }

  @override
  Future<void> onLoad() async {
    entityAnimationsGroup = SpriteAnimationGroupComponent(
        anchor: Anchor.center, animations: entityAnimations);

    setEntityStatus(EntityStatus.spawn);
    applyHeightToSprite();
    backJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.back,
        anchor: Anchor.center,
        size: Vector2.zero(),
        priority: playerBackPriority);

    // spriteWrapper = PositionComponent(
    //     size: spriteAnimationComponent.size, anchor: Anchor.center);
    entityAnimationsGroup.flipHorizontallyAroundCenter();
    add(entityAnimationsGroup);
    entityStatusWrapper = EntityStatusEffectsWrapper(
        position: Vector2(0, -entityStatusHeight),
        size: Vector2(entityAnimationsGroup.width * 1.5, 0),
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
    entityAnimationsGroup.flipHorizontallyAroundCenter();

    isFlipped = !isFlipped;
    for (var element in onBodyFlip) {
      element.call(isFlipped);
    }
  }
}
