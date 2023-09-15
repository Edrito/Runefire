import 'dart:async';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'
    hide RotateEffect, MoveEffect;
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/resources/constants/physics_filter.dart';
import 'package:game_app/resources/functions/custom.dart';
import 'package:game_app/resources/functions/functions.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';
import 'package:uuid/uuid.dart';

import '../entities/entity_class.dart';
import '../player/player.dart';
import '../resources/functions/vector_functions.dart';
import '../enemies/enemy.dart';
import '../main.dart';
import '../resources/enums.dart';

class MeleeAttackHitbox extends BodyComponent<GameRouter>
    with ContactCallbacks {
  MeleeAttackHitbox(this.size, this.meleeAttackAncestor, this.onHit);
  MeleeAttackHandler meleeAttackAncestor;
  Function(DamageInstance damage) onHit;
  List<String> hitEnemiesId = [];
  final Vector2 size;
  late PolygonShape shape;
  int hitEnemies = 0;

  bool hitboxIsDead = false;

  @override
  void preSolve(Object other, Contact contact, Manifold oldManifold) async {
    if (other is HealthFunctionality) {
      other.applyHitAnimation(
          await loadSpriteAnimation(
              4, 'weapons/melee/small_slash_effect.png', .05, false),
          oldManifold.localNormal,
          2);
    }
    super.preSolve(other, contact, oldManifold);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (meleeAttackAncestor.isDead || hitboxIsDead) {
      return;
    }

    if (other is HealthFunctionality) {
      if (hitEnemiesId.contains(other.entityId) || other.isDead) {
        return;
      }
      if (hitEnemies > meleeAttackAncestor.weaponAncestor.pierce.parameter) {
        // meleeAttackAncestor.kill();
        hitboxIsDead = true;
        return;
      }

      bodyContact(other);
    }

    super.beginContact(other, contact);
  }

  void bodyContact(HealthFunctionality other) {
    hitEnemiesId.add(other.entityId);
    final damageInstance =
        meleeAttackAncestor.weaponAncestor.calculateDamage(other, this);
    onHitFunctions(damageInstance);
    other.hitCheck(meleeAttackAncestor.meleeId, damageInstance);
    applyHitSpriteEffects(other);
    hitEnemies++;
  }

  void applyHitSpriteEffects(HealthFunctionality other) async {
    switch (meleeAttackAncestor.weaponAncestor.meleeType) {
      case MeleeType.crush:
        // other.applyHitAnimation(
        //     await buildSpriteSheet(
        //         4, 'weapons/melee/small_crush_effect.png', .1, false),
        //     center,
        //     1);
        break;
      case MeleeType.slash:
        break;
      case MeleeType.stab:
        break;
    }
    other.applyHitAnimation(
        await loadSpriteAnimation(
            4, 'weapons/melee/small_slash_effect.png', .05, false),
        center,
        1);
  }

  void onHitFunctions(DamageInstance instance) {
    if (meleeAttackAncestor.weaponAncestor
        is AttributeWeaponFunctionsFunctionality) {
      final weapon = meleeAttackAncestor.weaponAncestor
          as AttributeWeaponFunctionsFunctionality;
      for (var element in weapon.onHitMelee) {
        element(instance);
      }
    }

    meleeAttackAncestor
        .weaponAncestor.entityAncestor?.attributeFunctionsFunctionality
        ?.onHitFunctions(instance);

    onHit(instance);
  }

  @override
  Body createBody() {
    shape = PolygonShape();

    final verts = [
      Vector2(-size.x / 2, 0),
      Vector2(size.x / 2, 0),
      Vector2(size.x / 2, size.y),
      Vector2(-size.x / 2, size.y),
    ];

    shape.set(verts);

    // add(PolygonComponent(verts,
    //     anchor: Anchor.center,
    //     paint: Paint()..color = Colors.red.withOpacity(.2)));

    final swordFilter = Filter();
    if (meleeAttackAncestor.weaponAncestor.entityAncestor is Enemy) {
      swordFilter.maskBits = playerCategory;
    } else {
      swordFilter.maskBits = enemyCategory;
    }
    swordFilter.categoryBits = swordCategory;

    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        restitution: 0,
        friction: 0,
        density: 0,
        isSensor: true,
        filter: swordFilter);

    final bodyDef = BodyDef(
      userData: this,
      allowSleep: false,
      position: meleeAttackAncestor.activeSwings.last.swingPosition,
      angle: meleeAttackAncestor.activeSwings.last.swingAngle,
      type: BodyType.kinematic,
    );
    renderBody = false;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class MeleeAttackSprite extends PositionComponent {
  MeleeAttackSprite(WeaponSpriteAnimation? swingAnimation, this.initPosition,
      this.target, this.handler) {
    if (target != null) {
      initTargetPosition = target!.center.clone();
    }
    position.setFrom(initPosition);

    weaponTrailConfig = handler.currentAttack.weaponTrailConfig;
    if (handler.isCharging) {
      disableTrail = true;
    } else {
      disableTrail = weaponTrailConfig?.disableTrail ?? false;
    }
    animationComponent = swingAnimation;
  }
  void removeSwing() {
    handler.removeSwing(this);
  }

  late final WeaponTrailConfig? weaponTrailConfig;
  late final bool disableTrail;
  WeaponSpriteAnimation? animationComponent;

  Entity? target;
  late Vector2 initTargetPosition;
  Vector2 initPosition;

  void fadeOut() async {
    if (animationComponent?.animations?.containsKey(WeaponStatus.dead) ==
        true) {
      await animationComponent?.setWeaponStatus(WeaponStatus.dead);
      removeSwing();
    } else {
      const fadeOutDuration = .3;
      final controller = EffectController(
        duration: fadeOutDuration,
        curve: Curves.easeIn,
        onMax: () {
          removeSwing();
        },
      );
      animationComponent?.add(OpacityEffect.fadeOut(controller));
    }
  }

  Vector2 get swingPosition => animationComponent!.position + position;
  double get swingAngle => animationComponent!.angle;

  @override
  void update(double dt) {
    if (target != null) {
      position.setFrom(initPosition + (target!.center - initTargetPosition));
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (!disableTrail) {
      generateSwingTrail();
      canvas.drawVertices(Vertices(VertexMode.triangleStrip, points),
          BlendMode.plus, drawPaint);
    }

    super.render(canvas);
  }

  MeleeAttackHandler handler;
  TimerComponent? swingTimer;

  @override
  FutureOr<void> onLoad() {
    if (!handler.isCharging) {
      swingTimer = TimerComponent(
        period: handler.duration,
        onTick: () {
          fadeOut();
        },
      );
      add(swingTimer!);
    }
    if (handler.isCharging) {
      animationComponent?.weaponCharging();
    }
    add(animationComponent!);
    initSwingTrail();
    return super.onLoad();
  }

  bool renderTrail = false;
  bool triggerRemove = false;

  List<Offset> points = [];
  late final Paint drawPaint;
  late double widthOfTrail;
  late final double topStartFromTipPercent;
  late final double bottomStartFromTipPercent;
  late final int swingCutOff;
  late final Color color;
  late final Curve curve;

  void initSwingTrail() {
    if (disableTrail) return;
    swingCutOff = weaponTrailConfig?.swingCutOff ?? 14;
    curve = weaponTrailConfig?.curve ?? Curves.easeIn;
    renderTrail = true;
    color = weaponTrailConfig?.color ??
        (handler.weaponAncestor.baseDamage.damageBase.keys
                .toList()
                .getRandomElement() as DamageType)
            .color;
    topStartFromTipPercent = weaponTrailConfig?.topStartFromTipPercent ?? .95;
    bottomStartFromTipPercent =
        weaponTrailConfig?.bottomStartFromTipPercent ?? .3;

    widthOfTrail = handler.weaponAncestor.tipOffset.y *
        (topStartFromTipPercent - bottomStartFromTipPercent);
    drawPaint = Paint()..color = color.withOpacity(1);
    final centerPoint =
        handler.weaponAncestor.entityAncestor!.center - position;
    drawPaint.shader = ui.Gradient.radial(centerPoint.toOffset(), 3,
        [color.darken(.25), color], [.7, .7], TileMode.clamp, null, null, 0);
  }

  void generateSwingTrail() {
    final timer = swingTimer?.timer;
    if (triggerRemove && points.length < 3 ||
        (timer != null && timer.current > timer.limit * .6)) {
      points.clear();
      return;
    }

    final tipPos = newPosition(
            animationComponent!.position,
            // Vector2.zero(),
            degrees(-swingAngle),
            handler.weaponAncestor.tipOffset.y * topStartFromTipPercent)
        .toOffset();
    final midPos = newPosition(
            animationComponent!.position,
            // swing.swingPosition,
            degrees(-swingAngle),
            handler.weaponAncestor.tipOffset.y * bottomStartFromTipPercent)
        .toOffset();

    points.addAll([tipPos, midPos]);
    // }

    if (triggerRemove || points.length > swingCutOff) {
      points.removeRange(0, 2);
      triggerRemove = true;
    }
    // bool toggle = false;
    for (var i = 0; i < points.length; i += 2) {
      final closeToEnd = curve.transform(1.0 - (i / points.length).clamp(0, 1));
      final element = points[i];
      final nextElement = points[i + 1];
      final diff = nextElement - element;
      points[i] = element + (diff * 0);
      points[i + 1] = nextElement - (diff * (.8 * closeToEnd));
    }
  }
}

class MeleeAttackHandler extends Component {
  MeleeAttackHandler(
      {
      // required this.chargeAmount,
      required this.currentAttack,
      this.isCharging = false,
      required this.initPosition,
      required this.initAngle,
      this.attachmentPoint,
      required this.weaponAncestor}) {
    attackStepDuration = weaponAncestor.attackTickRate.parameter /
            (currentAttack.attackPattern.length - 1).clamp(1, double.infinity)
        //  *2
        ;
    duration = weaponAncestor.attackTickRate.parameter;
    meleeId = const Uuid().v4();

    if (!currentAttack.customStartAngle) initAngle = 0;
  }

  bool isCharging;

  Vector2 initPosition;
  double initAngle;

  bool isDead = false;

  bool disableChaining = false;
  MeleeAttack currentAttack;

  List<MeleeAttackSprite> activeSwings = [];
  Entity? attachmentPoint;
  // double chargeAmount;

  late double duration;
  late double attackStepDuration;
  late String meleeId;

  MeleeFunctionality weaponAncestor;
  MeleeAttackHitbox? hitbox;

  bool get isFlipped => weaponAncestor.entityAncestor?.isFlipped ?? false;

  void onHitFunction(DamageInstance damage) {
    chain(damage.victim);
  }

  void chain(HealthFunctionality other) {
    if (!disableChaining &&
        weaponAncestor.weaponCanChain &&
        hitbox!.hitEnemies < weaponAncestor.maxChainingTargets.parameter &&
        !isDead) {
      List<Body> bodies = [
        ...weaponAncestor.entityAncestor?.gameRef.world.bodies.where((element) {
              if (weaponAncestor.entityAncestor is Player) {
                return element.userData is Enemy &&
                    element.userData != other &&
                    !hitbox!.hitEnemiesId
                        .contains((element.userData as Entity).entityId);
              } else {
                return element.userData is Player &&
                    element.userData != other &&
                    !hitbox!.hitEnemiesId.contains(other.entityId);
              }
            }) ??
            []
      ];
      if (bodies.isEmpty) {
        return;
      }
      bodies.sort((a, b) => (a.position - other.center)
          .length2
          .compareTo((b.position - other.center).length2));

      final delta = (other.center - bodies.first.position);

      final otherAngle = -radiansBetweenPoints(
        Vector2(0, -1),
        delta,
      );
      attachmentPoint = other;

      initSwing(otherAngle, other.center);
    }
  }

  void addStepToSwing(int previousIndex, double currentAngle,
      MeleeAttackSprite swing, Future? previousFuture) {
    (Vector2, double, double) previousPattern;
    (Vector2, double, double) newPattern;
    if (isCharging) {
      previousPattern = currentAttack.chargePattern[previousIndex];
      previousIndex++;
      if (previousIndex == currentAttack.chargePattern.length) return;
      newPattern = currentAttack.chargePattern[previousIndex];
    } else {
      previousPattern = currentAttack.attackPattern[previousIndex];
      previousIndex++;
      if (previousIndex == currentAttack.attackPattern.length) return;
      newPattern = currentAttack.attackPattern[previousIndex];
    }

    if (isFlipped) {
      previousPattern = (
        Vector2(-previousPattern.$1.x, previousPattern.$1.y),
        -previousPattern.$2,
        previousPattern.$3
      );
      newPattern = (
        Vector2(-newPattern.$1.x, newPattern.$1.y),
        -newPattern.$2,
        newPattern.$3
      );
    }

    final rotatedEndPosition = rotateVector2(newPattern.$1, currentAngle);

    final totalAngle = newPattern.$2 - previousPattern.$2;
    final effectController = EffectController(
      duration: attackStepDuration * 2,
      curve: Curves.easeInOutCubicEmphasized,
    );
    final rotateEffect = RotateEffect.by(
      radians(totalAngle),
      effectController,
    );

    final moveEffect = MoveEffect.to(
      rotatedEndPosition,
      effectController,
    );
    if (previousFuture == null) {
      swing.animationComponent?.addAll([rotateEffect, moveEffect]);
    } else {
      previousFuture.then((value) =>
          swing.animationComponent?.addAll([rotateEffect, moveEffect]));
    }

    final newFuture = (previousFuture
            ?.then((value) => Future.delayed(attackStepDuration.seconds))) ??
        Future.delayed(attackStepDuration.seconds);
    addStepToSwing(previousIndex, currentAngle += totalAngle, swing, newFuture);
  }

  Future<void> initSwing(double swingAngle, Vector2 swingPosition) async {
    int animationStepIndex = 0;

    (Vector2, double, double) startPattern;
    if (isCharging) {
      startPattern = currentAttack.chargePattern[animationStepIndex];
    } else {
      startPattern = currentAttack.attackPattern[animationStepIndex];
    }

    if (isFlipped) {
      startPattern = (
        Vector2(-startPattern.$1.x, startPattern.$1.y),
        -startPattern.$2,
        startPattern.$3
      );
    }

    final rotatedStartPosition = rotateVector2(startPattern.$1, swingAngle);
    final weaponSpriteAnimation =
        await currentAttack.buildWeaponSpriteAnimation();
    weaponSpriteAnimation?.setWeaponStatus(WeaponStatus.attack);
    // if(!(weaponSpriteAnimation!.animation?.loop??true))
    // {
    //   weaponSpriteAnimation.animation.
    // }
    if (isFlipped) {
      weaponSpriteAnimation?.flipHorizontallyAroundCenter();
    }
    if (currentAttack.flippedDuringAttack) {
      weaponSpriteAnimation?.flipHorizontallyAroundCenter();
    }

    final newSwing = MeleeAttackSprite(weaponSpriteAnimation,
        swingPosition + rotatedStartPosition, attachmentPoint, this);

    final startAngle = radians(startPattern.$2) + swingAngle;
    newSwing.animationComponent?.angle = startAngle;
    addStepToSwing(animationStepIndex, swingAngle, newSwing, null);
    activeSwings.add(newSwing);
    newSwing.addToParent(this);
  }

  @override
  Future<void> onLoad() async {
    weaponAncestor.activeSwings.add(this);
    weaponAncestor.spriteVisibilityCheck();
    final hitboxSize = currentAttack.attackHitboxSize;

    await initSwing(initAngle, initPosition);
    if (!isCharging) {
      hitbox = MeleeAttackHitbox(hitboxSize, this, onHitFunction);
      weaponAncestor.entityAncestor?.enviroment.physicsComponent.add(hitbox!);
    }
    return super.onLoad();
  }

  void kill() {
    // for (var element in activeSwings) {
    //   // if (isCharging) {
    //   // element.removeFromParent();
    //   // } else {
    //   element.fadeOut();
    //   // }
    // }
    activeSwings.clear();
    removeSwing();
    isDead = true;
  }

  void removeSwing([MeleeAttackSprite? attack]) {
    activeSwings.remove(attack);
    currentAttack.latestAttackSpriteAnimation
        .remove(attack?.animationComponent);
    if (activeSwings.isEmpty) {
      weaponAncestor.activeSwings.remove(this);
      weaponAncestor.spriteVisibilityCheck();
      hitbox?.removeFromParent();
      removeFromParent();
    }
  }

  MeleeAttackSprite get currentSwing => activeSwings.last;

  void updatePosition() {
    if (activeSwings.isEmpty) return;
    hitbox?.body.setTransform(
        activeSwings.last.swingPosition, activeSwings.last.swingAngle);
  }

  @override
  void update(double dt) {
    if (hitbox?.isLoaded ?? false) {
      updatePosition();
    }

    super.update(dt);
  }
}

class WeaponTrailConfig {
  final double bottomStartFromTipPercent;
  final double topStartFromTipPercent;
  Color? color;
  bool disableTrail;
  final int swingCutOff;
  final Curve curve;

  WeaponTrailConfig(
      {this.bottomStartFromTipPercent = .5,
      this.topStartFromTipPercent = 1,
      this.color,
      this.curve = Curves.easeIn,
      this.disableTrail = false,
      this.swingCutOff = 26});
}
