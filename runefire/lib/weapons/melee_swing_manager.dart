// ignore_for_file: parameter_assignments, use_if_null_to_convert_nulls_to_bools

import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'
    hide RotateEffect, MoveEffect, ScaleEffect;
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/resources/constants/physics_filter.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';
import 'package:uuid/uuid.dart';

import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/enums.dart';

class MeleeAttackHitbox extends BodyComponent<GameRouter>
    with ContactCallbacks {
  MeleeAttackHitbox(this.size, this.meleeAttackAncestor);

  List<(Vector2, Vector2)> hitboxPoints = [];
  int hitEnemies = 0;
  List<String> hitEnemiesId = [];
  bool hitboxIsDead = false;
  bool _isEnabled = false;

  bool get isEnabled => _isEnabled;

  set isEnabled(bool value) {
    _isEnabled = value;
  }

  MeleeAttackHandler meleeAttackAncestor;
  late PolygonShape shape;
  late Fixture weaponHitboxFixture;

  (Vector2, Vector2)? lastBackPos;
  (Vector2, Vector2)? lastCenterPos;

  Future<void> applyHitSpriteEffects(DamageInstance damage) async {
    final SpriteAnimation animation;
    switch (meleeAttackAncestor.currentAttack.meleeAttackType) {
      case MeleeType.crush:
        animation = await spriteAnimations.crustEffect1;
        break;
      case MeleeType.slash:
        animation = await spriteAnimations.slashEffect1;
        break;
      case MeleeType.stab:
        animation = await spriteAnimations.stabEffect1;
        break;
    }
    damage.victim.entityVisualEffectsWrapper.applyHitAnimation(
      animation,
      center,
      damage.damageMap.keys.first.color,
    );
  }

  void bodyContact(HealthFunctionality other) {
    hitEnemiesId.add(other.entityId);
    final damageInstance = meleeAttackAncestor.weaponAncestor.calculateDamage(
      other,
      this,
      forceCrit: meleeAttackAncestor.forceCrit,
    );
    other.hitCheck(meleeAttackAncestor.meleeId, damageInstance);
    applyHitSpriteEffects(damageInstance);
    hitEnemies++;
    meleeAttackAncestor.chain(other);
  }

  // double testLengthOfHitboxLife = 1000;

  void enableHitbox({required bool enable}) {
    isEnabled = enable;
    body.setActive(isEnabled);
  }

  final (Vector2 Function(), (double, double)) size;

  double trailStepDuration = .2;
  double backTrailStepDurationProgress = 0;
  double centerTrailStepDurationProgress = 0;
  late MeleeAttackSprite latestSwingRef;
  late final Vector2 vectorSize = size.$1.call();

  Future<void> updatePosition(double dt) async {
    final ref = meleeAttackAncestor.activeSwings;
    if (ref.isEmpty) {
      return;
    }
    if (hitboxPoints.isEmpty) {
      latestSwingRef = ref.last;
    } else if (latestSwingRef != ref.last) {
      hitboxPoints.clear();
      latestSwingRef = ref.last;
    }
    final halfWidth = vectorSize.x / 2;

    final topCenter = newPositionRad(
      latestSwingRef.swingPosition,
      -latestSwingRef.swingAngle,
      vectorSize.y,
    );
    final top1 = newPositionRad(
      topCenter,
      -latestSwingRef.swingAngle - pi / 2,
      -halfWidth,
    );
    final top2 = newPositionRad(
      topCenter,
      -latestSwingRef.swingAngle - pi / 2,
      halfWidth,
    );
    final botCenter = newPositionRad(
      latestSwingRef.swingPosition,
      -latestSwingRef.swingAngle,
      0,
    );
    final bot1 = newPositionRad(
      botCenter,
      -latestSwingRef.swingAngle - pi / 2,
      -halfWidth,
    );

    final bot2 = newPositionRad(
      botCenter,
      -latestSwingRef.swingAngle - pi / 2,
      halfWidth,
    );

    (Vector2, Vector2) getBehindPoints() =>
        meleeAttackAncestor.currentAttack.meleeAttackType == MeleeType.stab
            ? (top1, top2)
            : (bot1, top1);

    (Vector2, Vector2) getInfrontPoints() =>
        meleeAttackAncestor.currentAttack.meleeAttackType == MeleeType.stab
            ? (bot1, bot2)
            : (bot2, top2);

    if (hitboxPoints.isEmpty) {
      hitboxPoints.add(
        getBehindPoints(),
      );
      hitboxPoints.add(
        (botCenter, topCenter),
      );
      hitboxPoints.add(
        getInfrontPoints(),
      );
    } else if (isEnabled) {
      hitboxPoints[0] = lastBackPos ?? (lastBackPos = getBehindPoints());
      hitboxPoints[1] =
          lastCenterPos ?? (lastCenterPos = (botCenter, topCenter));
      hitboxPoints[2] = getInfrontPoints();

      backTrailStepDurationProgress += dt;
      centerTrailStepDurationProgress += dt;
      if (trailStepDuration < backTrailStepDurationProgress) {
        backTrailStepDurationProgress = 0;
        lastBackPos = getBehindPoints();
      }

      if ((trailStepDuration / 1.75) < centerTrailStepDurationProgress) {
        centerTrailStepDurationProgress = 0;
        lastCenterPos = (botCenter, topCenter);
      }
    }
    final newPoints = hitboxPoints.fold(
      [],
      (previousValue, element) => [...previousValue, element.$1, element.$2],
    );

    modifyFixture(sortPointsInCircle(List<Vector2>.from(newPoints)));
  }

  @override
  void beginContact(Object other, Contact contact) {
    try {
      if (meleeAttackAncestor.isDead || hitboxIsDead) {
        return;
      }

      if (other is HealthFunctionality) {
        if (hitEnemiesId.contains(other.entityId) || other.isDead) {
          return;
        }
        if (hitEnemies > meleeAttackAncestor.weaponAncestor.pierceParameter) {
          // meleeAttackAncestor.kill();
          hitboxIsDead = true;
          return;
        }

        bodyContact(other);
      }
    } finally {
      super.beginContact(other, contact);
    }
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      type: BodyType.kinematic,
      bullet: true,
      allowSleep: false,
    );
    renderBody = false;
    final returnBody = world.createBody(bodyDef);
    return returnBody;
  }

  void modifyFixture(List<Vector2> verts) {
    if (verts.length < 3) {
      return;
    }
    if (body.fixtures.isEmpty) {
      shape = PolygonShape();
      shape.set(verts);

      final swordFilter = Filter();
      if (meleeAttackAncestor.weaponAncestor.entityAncestor is Enemy) {
        swordFilter.maskBits = playerCategory;
      } else {
        swordFilter.maskBits = enemyCategory;
      }
      swordFilter.categoryBits = swordCategory;

      final fixtureDef = FixtureDef(
        shape,
        userData: {'type': FixtureType.body, 'object': this},
        isSensor: true,
        filter: swordFilter,
      );

      weaponHitboxFixture = body.createFixture(fixtureDef);
    } else {
      (weaponHitboxFixture.shape as PolygonShape).set(
        verts,
      );
    }
  }

  @override
  void update(double dt) {
    updatePosition(dt);
    super.update(dt);
  }
}

class MeleeAttackSprite extends PositionComponent {
  MeleeAttackSprite(
    WeaponSpriteAnimation? swingAnimation,
    this.initPosition,
    this.target,
    this.handler,
  ) {
    if (target != null) {
      initTargetPosition = target!.center.clone();
    }
    position.setFrom(initPosition);

    weaponTrailConfig =
        handler.currentAttack.weaponTrailConfig ?? WeaponTrailConfig();
    if (handler.isCharging) {
      disableTrail = true;
    } else {
      disableTrail = weaponTrailConfig.disableTrail;
    }
    weaponSpriteAnimation = swingAnimation;
  }

  late final double bottomStartFromTipPercent;
  late final Color color;
  late final Curve curve;
  late final bool disableTrail;
  late final Paint drawPaint;
  late final int swingCutOff;
  late final double topStartFromTipPercent;
  late final WeaponTrailConfig weaponTrailConfig;

  MeleeAttackHandler handler;
  Vector2 initPosition;
  late Vector2 initTargetPosition;
  List<Offset> points = [];
  bool renderTrail = false;
  bool triggerRemove = false;
  late double widthOfTrail;

  TimerComponent? swingTimer;
  Entity? target;
  WeaponSpriteAnimation? weaponSpriteAnimation;

  double get swingAngle => weaponSpriteAnimation!.angle;
  Vector2 get swingPosition => weaponSpriteAnimation!.position + position;

  Future<void> fadeOut() async {
    if (weaponSpriteAnimation?.animations?.containsKey(WeaponStatus.dead) ??
        false) {
      await weaponSpriteAnimation?.setWeaponStatus(WeaponStatus.dead);
      removeSwing();
    } else {
      const fadeOutDuration = .3;
      final controller = EffectController(
        duration: fadeOutDuration,
        curve: Curves.easeIn,
        onMax: removeSwing,
      );
      weaponSpriteAnimation?.add(OpacityEffect.fadeOut(controller));
    }
  }

  void generateSwingTrail() {
    final timer = swingTimer?.timer;
    if (triggerRemove && points.length < 3 ||
        (timer != null && timer.current > timer.limit * .6)) {
      points.clear();
      return;
    }

    final tipPos = newPositionRad(
      weaponSpriteAnimation!.position,
      // Vector2.zero(),
      -swingAngle,
      handler.weaponAncestor.tipOffset.y * topStartFromTipPercent,
    ).toOffset();
    final midPos = newPositionRad(
      weaponSpriteAnimation!.position,
      -swingAngle,
      handler.weaponAncestor.tipOffset.y * bottomStartFromTipPercent,
    ).toOffset();

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

  void initSwingTrail() {
    if (disableTrail) {
      return;
    }
    swingCutOff = weaponTrailConfig.swingCutOff;
    curve = weaponTrailConfig.curve;
    renderTrail = true;
    color = weaponTrailConfig.color ??
        handler.weaponAncestor.baseDamage.damageBase.keys
            .toList()
            .random()
            .color;
    topStartFromTipPercent = weaponTrailConfig.topStartFromTipPercent;
    bottomStartFromTipPercent = weaponTrailConfig.bottomStartFromTipPercent;

    widthOfTrail = (handler.weaponAncestor.tipOffset.y) *
        (topStartFromTipPercent - bottomStartFromTipPercent);
    drawPaint = Paint()..color = color.withOpacity(1);
    final centerPoint =
        handler.weaponAncestor.entityAncestor!.center - position;
    drawPaint.shader = ui.Gradient.radial(
      centerPoint.toOffset(),
      3,
      [color.darken(.25), color],
      [.7, .7],
    );
  }

  void removeSwing() {
    handler.removeSwing(this);
  }

  @override
  FutureOr<void> onLoad() {
    if (!handler.isCharging) {
      swingTimer = TimerComponent(
        period: handler.duration,
        onTick: fadeOut,
      );
      add(swingTimer!);
    }
    if (handler.isCharging) {
      weaponSpriteAnimation?.weaponCharging();
    }
    add(weaponSpriteAnimation!);

    initSwingTrail();
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    if (!disableTrail) {
      generateSwingTrail();
      canvas.drawVertices(
        Vertices(VertexMode.triangleStrip, points),
        BlendMode.plus,
        drawPaint,
      );
    }

    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (target != null) {
      position.setFrom(initPosition + (target!.center - initTargetPosition));
    }
    super.update(dt);
  }
}

class MeleeAttackHandler extends Component {
  MeleeAttackHandler({
    required this.currentAttack,
    required this.initPosition,
    required this.initAngle,
    required this.weaponAncestor,
    this.forceCrit = false,
    this.isCharging = false,
    this.attachmentPoint,
  }) {
    double? tempStepDuration;
    int? tempAttackPatternLength;

    if (isCharging && weaponAncestor is SemiAutomatic) {
      tempStepDuration = (weaponAncestor as SemiAutomatic).customChargeDuration;
      tempAttackPatternLength = currentAttack.chargePattern.length;
    }
    final l = tempAttackPatternLength ?? currentAttack.attackPattern.length;

    attackStepDuration =
            ((tempStepDuration ?? weaponAncestor.attackTickRate.parameter) /
                    (l - 1))
                .clamp(0, double.infinity)
        //  *2
        ;
    duration = tempStepDuration ?? weaponAncestor.attackTickRate.parameter;
    meleeId = const Uuid().v4();
    if (!currentAttack.customStartAngle) {
      initAngle = 0;
    }
    hitboxBeginEnd = (
      currentAttack.attackHitboxSizeBuild.$2.$1 * duration,
      currentAttack.attackHitboxSizeBuild.$2.$2 * duration
    );
  }
  bool forceCrit;
  List<MeleeAttackSprite> activeSwings = [];
  late double attackStepDuration;
  Map<MeleeAttackSprite, double> attackStepTimer = {};
  MeleeAttack currentAttack;
  bool disableChaining = false;

  late double duration;

  double durationTimer = 0;
  double initAngle;
  Vector2 initPosition;
  bool isCharging;
  bool isDead = false;
  late String meleeId;
  Map<MeleeAttackSprite, Queue<Function>> meleeSteps = {};
  MeleeFunctionality weaponAncestor;

  Entity? attachmentPoint;
  MeleeAttackHitbox? hitbox;

  MeleeAttackSprite get currentSwing => activeSwings.last;
  bool get isFlipped => weaponAncestor.entityAncestor?.isFlipped ?? false;

  void addStepToSwing(
    int previousIndex,
    double currentAngle,
    MeleeAttackSprite swing,
  ) {
    (Vector2, double, double) previousPattern;
    (Vector2, double, double) newPattern;
    if (isCharging) {
      previousPattern = currentAttack.chargePattern[previousIndex];
      previousIndex++;
      if (previousIndex == currentAttack.chargePattern.length) {
        return;
      }
      newPattern = currentAttack.chargePattern[previousIndex];
    } else {
      previousPattern = currentAttack.attackPattern[previousIndex];
      previousIndex++;
      if (previousIndex == currentAttack.attackPattern.length) {
        return;
      }
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
    // final rotatedEndPosition = rotateVector2(newPattern.$1, currentAngle);

    final totalAngle = newPattern.$2 - previousPattern.$2;
    final effectController = EffectController(
      duration: attackStepDuration * 2,
      curve: Curves.easeInOutCubicEmphasized,
    );
    final rotateEffect = RotateEffect.by(
      radians(totalAngle),
      effectController,
    );

    final scaleEffect = SizeEffect.to(
      swing.weaponSpriteAnimation!.size * newPattern.$3,
      effectController,
    );
    final moveEffect = MoveEffect.by(
      rotatedEndPosition,
      effectController,
    );

    meleeSteps[swing] ??= Queue();
    attackStepTimer[swing] ??= attackStepDuration;

    meleeSteps[swing]?.add(() {
      swing.weaponSpriteAnimation
          ?.addAll([rotateEffect, moveEffect, scaleEffect]);
    });

    addStepToSwing(previousIndex, currentAngle += totalAngle, swing);
  }

  void chain(HealthFunctionality other) {
    if (weaponAncestor.weaponCanChain &&
        hitbox!.hitEnemies < weaponAncestor.chainingTargets.parameter &&
        !isDead) {
      final bodies = <Body>[
        ...weaponAncestor.entityAncestor?.world.physicsWorld.bodies
                .where((element) {
              if (weaponAncestor.entityAncestor is Player) {
                return element.userData is Enemy &&
                    element.userData != other &&
                    !hitbox!.hitEnemiesId
                        .contains((element.userData! as Entity).entityId);
              } else {
                return element.userData is Player &&
                    element.userData != other &&
                    !hitbox!.hitEnemiesId.contains(other.entityId);
              }
            }) ??
            [],
      ];
      if (bodies.isEmpty) {
        return;
      }
      bodies.sort(
        (a, b) => (a.position - other.center)
            .length2
            .compareTo((b.position - other.center).length2),
      );

      final delta = other.center - bodies.first.position;

      final otherAngle = -radiansBetweenPoints(
        Vector2(0, -1),
        delta,
      );
      attachmentPoint = other;

      initSwing(otherAngle, other.center);
    }
  }

  late final (double, double) hitboxBeginEnd;

  Future<void> initSwing(double swingAngle, Vector2 swingPosition) async {
    const animationStepIndex = 0;

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
    if (isFlipped) {
      weaponSpriteAnimation?.flipHorizontallyAroundCenter();
    }
    if (currentAttack.flippedDuringAttack) {
      weaponSpriteAnimation?.flipHorizontallyAroundCenter();
    }

    final newSwing = MeleeAttackSprite(
      weaponSpriteAnimation,
      swingPosition + rotatedStartPosition,
      attachmentPoint,
      this,
    );

    final startAngle = radians(startPattern.$2) + swingAngle;
    newSwing.weaponSpriteAnimation?.angle = startAngle;

    addStepToSwing(animationStepIndex, swingAngle, newSwing);

    activeSwings.add(newSwing);
    newSwing.addToParent(this);
  }

  void kill() {
    activeSwings.forEach((element) {
      element.removeFromParent();
    });
    activeSwings.clear();
    removeSwing();
    isDead = true;
  }

  void removeSwing([MeleeAttackSprite? attack]) {
    activeSwings.remove(attack);
    currentAttack.latestAttackSpriteAnimation
        .remove(attack?.weaponSpriteAnimation);
    if (activeSwings.isEmpty) {
      weaponAncestor.activeSwings.remove(this);
      weaponAncestor.spriteVisibilityCheck();
      hitbox?.removeFromParent();
      removeFromParent();
    }
  }

  @override
  Future<void> onLoad() async {
    weaponAncestor.activeSwings.add(this);
    weaponAncestor.spriteVisibilityCheck();
    final hitboxSize = currentAttack.attackHitboxSizeBuild;

    await initSwing(initAngle, initPosition);

    if (!isCharging) {
      if (currentAttack.entitySpriteAnimation != null) {
        weaponAncestor.entityAncestor?.entityAnimationsGroup
                .animations?['swordAttack'] ??=
            await currentAttack.entitySpriteAnimation!;
        weaponAncestor.entityAncestor?.setEntityAnimation(
          EntityStatus.dash,
        );
      }

      hitbox = MeleeAttackHitbox(hitboxSize, this);
      weaponAncestor.entityAncestor?.enviroment.addPhysicsComponent([hitbox!]);
    }
    return super.onLoad();
  }

  @override
  void onRemove() {
    kill();
    super.onRemove();
  }

  @override
  void update(double dt) {
    attackStepTimer.forEach((key, value) {
      attackStepTimer[key] = attackStepTimer[key]! + dt;
      if (attackStepTimer[key]! >= attackStepDuration) {
        attackStepTimer[key] = 0;
        if (meleeSteps.isNotEmpty) {
          if (meleeSteps[key]?.isEmpty ?? false) {
            meleeSteps.remove(key);
            return;
          }
          meleeSteps[key]?.removeFirst().call();
        } else {}
      }
    });
    durationTimer += dt;

    if (durationTimer > hitboxBeginEnd.$1 &&
        durationTimer < hitboxBeginEnd.$2 &&
        hitbox?.isEnabled == false) {
      hitbox?.enableHitbox(enable: true);
    } else if (durationTimer >= hitboxBeginEnd.$2 &&
        hitbox?.isEnabled == true) {
      hitbox?.enableHitbox(enable: false);
    }

    super.update(dt);
  }
}

class WeaponTrailConfig {
  WeaponTrailConfig({
    this.bottomStartFromTipPercent = .5,
    this.topStartFromTipPercent = 1,
    this.color,
    this.curve = Curves.easeIn,
    this.disableTrail = false,
    this.swingCutOff = 26,
  });

  final double bottomStartFromTipPercent;
  final Curve curve;
  final int swingCutOff;
  final double topStartFromTipPercent;

  bool disableTrail;

  Color? color;
}
