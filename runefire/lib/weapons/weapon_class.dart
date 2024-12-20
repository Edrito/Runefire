import 'dart:async';
import 'dart:math';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/weapons/secondary_abilities.dart';
import 'package:runefire/weapons/weapon_mixin.dart';
import 'package:uuid/uuid.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/resources/functions/custom.dart';

import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/constants/priorities.dart';

class PlayerAttachmentJointComponent extends PositionComponent
    with HasAncestor<Entity> {
  PlayerAttachmentJointComponent(
    this.jointPosition, {
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
  });

  bool isFrontVisible = false;
  WeaponSpritePosition jointPosition;
  WeaponSpriteAnimation? weaponSpriteAnimation;

  Weapon? weapon;

  Future<void> addWeaponClass(Weapon newWeapon) async {
    removePreviousComponents();
    weapon = newWeapon;
    anchor = Anchor.center;
    // weaponBase = PositionComponent(
    //     anchor: Anchor.center,
    //     position: Vector2(0, newWeapon.distanceFromPlayer));

    if (newWeapon.spirteComponentPositions.contains(jointPosition)) {
      weaponSpriteAnimation =
          await newWeapon.buildJointSpriteAnimationComponent(this);
      add(weaponSpriteAnimation!);
      if (jointPosition == WeaponSpritePosition.hand) {
        weaponSpriteAnimation?.position.y += weapon!.distanceFromPlayer;
      }

      // weaponTip = PositionComponent(
      //     anchor: Anchor.center, position: weaponSpriteAnimation!.tipOffset);
      // weaponTipCenter = PositionComponent(
      //     anchor: Anchor.center,
      //     position: Vector2(0, weaponSpriteAnimation!.tipOffset.y));

      // weaponSpriteAnimation?.addToParent(weaponBase!);
      // weaponTipCenter?.addToParent(weaponBase!);
      // weaponTip?.addToParent(weaponBase!);
    }
    // if (weaponBase!.parent == null) {
    // add(weaponBase!);
    // }
    weapon!.weaponAttachmentPoints[jointPosition] = this;
  }

  void removePreviousComponents() {
    // weaponTip?.removeFromParent();
    weaponSpriteAnimation?.removeFromParent();
    // weaponBase?.removeFromParent();
    // weaponTipCenter?.removeFromParent();
    weapon = null;
    // weaponBase = null;
    // weaponTip = null;
    // weaponTipCenter = null;
    weaponSpriteAnimation = null;
  }
}

typedef AttackSplitFunction = List<double> Function(
  double angle,
  int attackCount,
);

abstract class Weapon extends Component with UpgradeFunctions {
  Weapon(int? newUpgradeLevel, this.entityAncestor) {
    assert(
      this is! ProjectileFunctionality ||
          (this as ProjectileFunctionality).projectileType != null,
      'Projectile weapon types need a projectile type',
    );

    maxLevel = weaponType.maxLevel;
    newUpgradeLevel ??= 0;
    changeLevel(newUpgradeLevel);
    weaponId = const Uuid().v4();
  }

  final DoubleParameterManager attackTickRate =
      DoubleParameterManager(baseParameter: 1, minParameter: 0.01);

  final DamageParameterManager baseDamage =
      DamageParameterManager(damageBase: {});

  final IntParameterManager chainingTargets =
      IntParameterManager(baseParameter: 0);

  final BoolParameterManager countIncreaseWithTime = BoolParameterManager(
    baseParameter: false,
    frequencyDeterminesTruth: false,
  );

  final DoubleParameterManager critChance = DoubleParameterManager(
    baseParameter: 0.05,
    maxParameter: 1,
  );

  final DoubleParameterManager critDamage =
      DoubleParameterManager(baseParameter: 1.4, minParameter: 1);

  final DoubleParameterManager knockBackAmount =
      DoubleParameterManager(baseParameter: defaultKnockbackAmount);

  final IntParameterManager pierce = IntParameterManager(baseParameter: 0);
  final BoolParameterManager reverseHoming = BoolParameterManager(
    baseParameter: false,
    frequencyDeterminesTruth: false,
  );

  final DoubleParameterManager weaponRandomnessPercent = DoubleParameterManager(
    baseParameter: 0,
    maxParameter: 1,
  );

  // final DoubleParameterManager spreadDegrees =
  //     DoubleParameterManager(baseParameter: 1, minParameter: 0.1);

  ///String is the ID, for easy removal and addition
  ///Weapon is the weapon itself, preferably the weapon should not have reloadfunctionality
  final Map<String, Weapon> additionalWeapons = {};

  //WEAPON ATTRIBUTES
  final IntParameterManager attackCountIncrease =
      IntParameterManager(baseParameter: 0);

  //META INFORMATION
  bool attackOnAnimationFinish = false;

  Set<AttackSplitFunction> attackSpreadPatterns = {
    (double angle, int attackCount) => [angle],
    regularAttackSpread,
  };

  Vector2 baseOffset = Vector2.zero();
  abstract double distanceFromPlayer;
  bool isAdditionalWeapon = false;
  bool isAttacking = false;
  bool isSecondaryWeapon = false;
  IntParameterManager maxHomingTargets = IntParameterManager(baseParameter: 0);

  Vector2 get pngSize => weaponType.getImageClass.size.asVector2;

  Set<WeaponSpritePosition> removeSpriteOnAttack = {};
  Random rng = Random();
  //VISUAL
  abstract List<WeaponSpritePosition> spirteComponentPositions;

  bool spritesHidden = false;
  Map<WeaponSpritePosition, PlayerAttachmentJointComponent>
      weaponAttachmentPoints = {};

  late String weaponId;
  late Color weaponPrimaryColor =
      primaryDamageType?.color ?? baseDamage.damageBase.entries.first.key.color;

  abstract DoubleParameterManager weaponScale;
  WeaponStatus weaponStatus = WeaponStatus.idle;
  abstract WeaponType weaponType;

  Vector2? customOffset;
  AimFunctionality? entityAncestor;
  Weapon? parentWeapon;
  DamageType? primaryDamageType;
  SourceAttackLocation? sourceAttackLocation;
  Completer<bool>? weaponPrimaryAttackingCompleter;
  Completer<bool>? weaponSecondaryAttackingCompleter;

  //Weapon state info
  double get attackRateSecondComparison => 1 / attackTickRate.parameter;

  bool get attacksAreActive => false;
  AttributeWeaponFunctionsFunctionality? get attributeFunctionsFunctionality =>
      this is AttributeWeaponFunctionsFunctionality
          ? this as AttributeWeaponFunctionsFunctionality
          : null;

  AttributeWeaponFunctionsFunctionality?
      get attributeWeaponFunctionsFunctionality =>
          this is AttributeWeaponFunctionsFunctionality
              ? this as AttributeWeaponFunctionsFunctionality
              : null;

  double get durationHeld;
  SecondaryWeaponAbility? get getSecondaryAbility {
    if (this is SecondaryFunctionality) {
      return (this as SecondaryFunctionality).secondaryWeaponAbility;
    }
    return null;
  }

  Weapon? get getSecondaryWeapon {
    if (this is SecondaryFunctionality) {
      return (this as SecondaryFunctionality).secondaryWeapon;
    }
    return null;
  }

  bool get hasAltAttack => this is SecondaryFunctionality;
  bool get isCurrentWeapon {
    if (entityAncestor is AttackFunctionality) {
      final att = entityAncestor! as AttackFunctionality;
      return att.currentWeapon == this;
    }
    return false;
  }

  bool get isReloading =>
      this is ReloadFunctionality &&
      (this as ReloadFunctionality).reloadTimer != null;

  int get pierceParameter {
    return max(
      chainingTargets.parameter + maxHomingTargets.parameter,
      pierce.parameter,
    );
  }

  Vector2 get tipOffset => Vector2(pngSize.x / 2, pngSize.y * .9)
    ..scaledToHeight(
      entityAncestor,
      weapon: this,
    );

  bool get weaponCanChain => chainingTargets.parameter > 0;
  bool get weaponCanHome => maxHomingTargets.parameter > 0;
  double get weaponLength {
    return entityAncestor == null
        ? 0
        : (pngSize.clone()..scaledToHeight(entityAncestor, weapon: this)).y;
  }

  Future<void> get weaponPrimaryAttackingFuture =>
      weaponPrimaryAttackingCompleter?.future ?? Future.value();

  void addAdditionalWeapon(Weapon newWeapon) {
    additionalWeapons[newWeapon.weaponId] = newWeapon;
    newWeapon.isAdditionalWeapon = true;
    newWeapon.addToParent(this);
    newWeapon.parentWeapon = this;
  }

  /// Returns true if an attack occured, otherwise false.
  Future<void> attackAttempt(AttackConfiguration attackConfiguration) async {
    if (entityAncestor?.isDead ?? false) {
      return;
    }
    standardAttack(attackConfiguration);
  }

  FutureOr<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  );

  DamageInstance calculateDamage(
    HealthFunctionality victim,
    dynamic sourceAttack, {
    bool forceCrit = false,
  }) =>
      damageCalculations(
        entityAncestor!,
        victim,
        baseDamage.parameter,
        sourceWeapon: this,
        sourceAttack: sourceAttack,
        damageSource: baseDamage,
        forceCrit: forceCrit,
      );

  void completeAttackCompleter({bool isAltAttack = false}) {
    if (isAltAttack) {
      if (weaponSecondaryAttackingCompleter?.isCompleted != true) {
        weaponSecondaryAttackingCompleter?.complete(true);
      }
    } else {
      if (weaponPrimaryAttackingCompleter?.isCompleted != true) {
        weaponPrimaryAttackingCompleter?.complete(true);
      }
    }
  }

  void endAltAttacking() {
    completeAttackCompleter(isAltAttack: true);
  }

  void endAttacking() {
    spriteVisibilityCheck();
    isAttacking = false;

    if (this is AttributeWeaponFunctionsFunctionality) {
      final att = this as AttributeWeaponFunctionsFunctionality;
      for (final element in att.onAttackingFinish) {
        element.call(this);
      }
    }
    completeAttackCompleter();
  }

  Vector2 generateGlobalPosition(
    SourceAttackLocation attackLocation, {
    Vector2? delta,
    bool melee = false,
    double? tipPercent,
  }) {
    if (parentWeapon != null) {
      return parentWeapon!.generateGlobalPosition(
        attackLocation,
        delta: delta,
        melee: melee,
        tipPercent: tipPercent,
      );
    }
    var center = Vector2.zero();

    switch (attackLocation) {
      case SourceAttackLocation.mouse:
        center += entityAncestor!.mouseJoint?.position ?? Vector2.zero();
        break;
      case SourceAttackLocation.weaponTip:
        center = weaponTipPosition(tipPercent ?? 1);
        break;
      case SourceAttackLocation.weaponMid:
        center = weaponTipPosition(0.5);

      case SourceAttackLocation.distanceFromPlayer:
        center = weaponTipPosition(0, distanceFromPlayer: true);
        break;
      case SourceAttackLocation.customOffset:
        if (melee) {
          center = weaponTipPosition(0);
        }

        center += customOffset ?? Vector2.zero();
        break;
      default:
    }

    return center += entityAncestor!.center;
  }

  int getAttackCount(double chargeDuration) {
    var additional = 0;
    if (this is SemiAutomatic) {
      final semi = this as SemiAutomatic;
      if (semi.increaseAttackCountWhenCharged) {
        additional =
            (semi.increaseWhenFullyCharged.parameter * chargeDuration).round();
      }
    }
    final additionalDurationCountIncrease = countIncreaseWithTime.parameter
        ? (durationHeld * 2).round().clamp(0, 3)
        : 0;
    return attackCountIncrease.parameter +
        additionalDurationCountIncrease +
        additional;
  }

  void muzzleFlash() {
    for (final element in weaponAttachmentPoints.entries) {
      if (element.value.weaponSpriteAnimation == null) {
        continue;
      }

      element.value.weaponSpriteAnimation!.addMuzzleFlash();
    }
  }

  void removeAdditionalWeapon(String id) {
    final weapon = additionalWeapons.remove(id);
    weapon?.removeFromParent();
  }

  ///Sets the current status of the weapon, i.e. idle, shooting, reloading
  Future<void> setWeaponStatus(WeaponStatus weaponStatus) async {
    this.weaponStatus = weaponStatus;
    final futures = <Future>[];
    for (final element in weaponAttachmentPoints.entries) {
      if (element.value.weaponSpriteAnimation == null) {
        continue;
      }

      futures.add(
        element.value.weaponSpriteAnimation!.setWeaponStatus(this.weaponStatus),
      );
    }

    await Future.wait(futures);
  }

  void spriteVisibilityCheck() {
    if (removeSpriteOnAttack.isEmpty || isAdditionalWeapon) {
      return;
    }
    if (attacksAreActive && !spritesHidden) {
      for (final element in removeSpriteOnAttack) {
        weaponAttachmentPoints[element]?.weaponSpriteAnimation?.opacity = 0;
      }

      spritesHidden = true;
    } else if (!attacksAreActive && spritesHidden) {
      for (final element in removeSpriteOnAttack) {
        weaponAttachmentPoints[element]?.weaponSpriteAnimation?.opacity = 1;
      }

      spritesHidden = false;
    }
  }

  @mustCallSuper
  void standardAttack(AttackConfiguration attackConfiguration) {
    muzzleFlash();
    for (final element in additionalWeapons.entries) {
      element.value.attackAttempt(attackConfiguration);
    }
    if (attackConfiguration.callFunctions &&
        entityAncestor is AttributeCallbackFunctionality) {
      for (final element
          in (entityAncestor! as AttributeCallbackFunctionality).onAttack) {
        element.call(this);
      }
    }
  }

  void startAltAttacking() {
    completeAttackCompleter(isAltAttack: true);
    weaponSecondaryAttackingCompleter = Completer<bool>();
  }

  void startAttacking() {
    completeAttackCompleter();
    isAttacking = true;
    weaponPrimaryAttackingCompleter = Completer<bool>();
  }

  void weaponSwappedFrom() {}

  void weaponSwappedTo() {
    setWeaponStatus(WeaponStatus.spawn);
  }

  Vector2 weaponTipPosition(double percent, {bool distanceFromPlayer = false}) {
    return newPositionRad(
      entityAncestor!.handJoint.absolutePosition,
      -entityAncestor!.handJoint.angle,
      distanceFromPlayer
          ? this.distanceFromPlayer
          : (tipOffset.y * percent) + this.distanceFromPlayer,
    );
  }

  @override
  FutureOr<void> onLoad() async {
    while (chainingTargets.parameter > pierce.parameter) {
      pierce.baseParameter++;
    }
    await super.onLoad();
    setWeaponStatus(weaponStatus);
  }
}

abstract class PlayerWeapon extends Weapon
    with AttributeWeaponFunctionsFunctionality, SecondaryFunctionality {
  PlayerWeapon(super.newUpgradeLevel, super.entityAncestor);

  @override
  void standardAttack(AttackConfiguration attackConfiguration) {
    InputManager().applyVibration(.1, .25);

    super.standardAttack(attackConfiguration);
  }
}

abstract class EnemyWeapon extends Weapon
    with AttributeWeaponFunctionsFunctionality {
  EnemyWeapon(super.newUpgradeLevel, super.entityAncestor);

  @override
  late int? maxLevel;
}

///Custom SpriteAnimation that attaches to each joint on an entity that is defined
///within the current weapon parameters
///
///Based on the current action of the weapon, this will display different kinds
///of animations.
class WeaponSpriteAnimation extends SpriteAnimationGroupComponent {
  WeaponSpriteAnimation(
    this.spriteOffset, {
    required this.weaponAnimations,
    required this.weapon,
    required this.parentJoint,
    this.flashSize = 1,
    super.angle,
    this.idleOnly = false,
  }) {
    animations = weaponAnimations;
    applyKey(WeaponStatus.idle);
    anchor = Anchor.topCenter;

    priority = attackPriority;
    position = spriteOffset;
    setWeaponStatus(WeaponStatus.spawn);
  }

  WeaponStatus currentStatus = WeaponStatus.spawn;
  double flashSize;
  bool idleOnly;
  Vector2 spriteOffset;
  bool tempAnimationPlaying = false;
  late Vector2 tipOffset = weapon.tipOffset;
  Weapon weapon;
  Map<dynamic, SpriteAnimation> weaponAnimations;

  SpriteAnimationComponent? muzzleFlashComponent;
  PlayerAttachmentJointComponent? parentJoint;
  WeaponStatus? statusQueue;

  // @override
  // void update(double dt) {
  //   if (!isAnimationPlaying) {
  //     setWeaponStatus(WeaponStatus.idle);
  //   }
  //   super.update(dt);
  // }

  bool get isAnimationPlaying => !(animationTicker?.done() ?? true);

  void addMuzzleFlash() {
    if (!weaponAnimations.containsKey('muzzle_flash')) {
      return;
    }
    final muzzleFlash = weaponAnimations['muzzle_flash']!;
    muzzleFlashComponent = SpriteAnimationComponent(
      animation: muzzleFlash,
      position: weapon.tipOffset,
      size: (muzzleFlash.frames.first.sprite.srcSize
            ..scaledToHeight(
              weapon.entityAncestor,
              weapon: weapon,
            )) *
          flashSize,
      anchor: Anchor.topCenter,
      // angle: weapon.entityAncestor!.handJoint.angle,
      priority: attackPriority,
    );

    addAll([muzzleFlashComponent!]);

    final previousComponent = muzzleFlashComponent;

    previousComponent?.animationTicker?.onComplete =
        previousComponent.removeFromParent;
  }

  void applyAnimation(dynamic key) {
    applyKey(key);
    initTicker();
  }

  void applyKey(dynamic key) {
    if (animations?.containsKey(key) != true) {
      return;
    }
    current = key;
    resize();
  }

  void initTicker() {
    tempAnimationPlaying = true;
    animationTicker?.onComplete = tickerComplete;
  }

  void resize([Vector2? sourceSize]) {
    final tempSize =
        sourceSize ?? animation?.frames.first.sprite.srcSize ?? weapon.pngSize;
    tempSize.scaledToHeight(weapon.entityAncestor, weapon: weapon);
    size.setFrom(tempSize);
  }

  Future<void> setWeaponStatus(
    WeaponStatus newWeaponStatus, [
    dynamic key,
  ]) async {
    final newAnimation =
        weaponAnimations[key] ?? weaponAnimations[newWeaponStatus];
    if (newWeaponStatus == currentStatus &&
        [WeaponStatus.idle].contains(newWeaponStatus)) {
      return;
    }

    if (tempAnimationPlaying) {
      statusQueue = newWeaponStatus;
      // animationQueue = newAnimation ?? weaponAnimations[WeaponStatus.idle];
    } else {
      // animationQueue = null;
      currentStatus = newWeaponStatus;
    }

    if (newAnimation != null) {
      switch (newWeaponStatus) {
        case WeaponStatus.spawn:
          assert(!newAnimation.loop, 'Temp animations must not loop');
          break;
        case WeaponStatus.dead:
          assert(!newAnimation.loop, 'Temp animations must not loop');
          break;
        case WeaponStatus.attack:
          assert(!newAnimation.loop, 'Temp animations must not loop');
          weaponAnimations[WeaponStatus.attack]?.stepTime =
              weapon.attackTickRate.parameter / newAnimation.frames.length;
          break;
        case WeaponStatus.reload:
          if (weapon is! ReloadFunctionality) {
            break;
          }
          assert(!newAnimation.loop, 'Temp animations must not loop');
          weaponAnimations[WeaponStatus.reload]?.stepTime =
              (weapon as ReloadFunctionality).reloadTime.parameter /
                  newAnimation.frames.length;
          break;

        case WeaponStatus.charge:
          await weaponCharging();
          break;
        default:
      }
      applyAnimation(newWeaponStatus);
    } else {
      if (newWeaponStatus == WeaponStatus.dead) {
        final duration = weapon.attackTickRate.baseParameter / 3;
        add(
          OpacityEffect.fadeOut(
            EffectController(
              duration: duration,
              curve: Curves.easeOut,
            ),
          ),
        );
        await weapon.entityAncestor?.game.gameAwait(duration);
      }
    }

    if (!(animation?.loop ?? false)) {
      await animationTicker?.completed;
    }
  }

  void tickerComplete() {
    tempAnimationPlaying = false;
    currentStatus = statusQueue ?? WeaponStatus.idle;
    animationTicker?.reset();
    applyKey(currentStatus);
    statusQueue = null;
    // current = animationQueue ?? weaponAnimations[WeaponStatus.idle];
  }

  Future<void> weaponCharging() async {
    if (animations?.containsKey(WeaponStatus.charge) != true) {
      return;
    }
    final chargeDuration = weapon.attackTickRate.parameter;
    final length = weaponAnimations[WeaponStatus.charge]!.frames.length;

    weaponAnimations[WeaponStatus.charge]?.stepTime = chargeDuration / length;

    applyAnimation(WeaponStatus.charge);

    statusQueue = WeaponStatus.chargeIdle;
  }
}

@immutable
class AttackConfiguration {
  const AttackConfiguration({
    this.holdDurationPercent = 1,
    this.callFunctions = true,
    this.customAttackSpreadPattern,
    this.customAttackLocation,
    this.customAttackPosition,
    this.useAmmo = true,
    this.isAltAttack = false,
  });

  final Set<List<double> Function(double, int)>? customAttackSpreadPattern;

  final bool callFunctions;
  final SourceAttackLocation? customAttackLocation;
  final double holdDurationPercent;
  final bool useAmmo;
  final bool isAltAttack;
  final Vector2? customAttackPosition;

  AttackConfiguration copyWith({
    bool? callFunctions,
    double? holdDurationPercent,
    Vector2? customAttackPosition,
    bool? isAltAttack,
    Set<List<double> Function(double, int)>? customAttackSpreadPattern,
    SourceAttackLocation? customAttackLocation,
  }) {
    return AttackConfiguration(
      callFunctions: callFunctions ?? this.callFunctions,
      holdDurationPercent: holdDurationPercent ?? this.holdDurationPercent,
      isAltAttack: isAltAttack ?? this.isAltAttack,
      customAttackPosition: customAttackPosition ?? this.customAttackPosition,
      customAttackSpreadPattern:
          customAttackSpreadPattern ?? customAttackSpreadPattern,
      customAttackLocation: customAttackLocation ?? customAttackLocation,
    );
  }
}
