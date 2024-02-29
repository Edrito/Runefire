import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'dart:math';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/resources/enums.dart';

import 'package:runefire/resources/functions/custom.dart';
import 'package:uuid/uuid.dart';

abstract class SecondaryWeaponAbility extends Component with UpgradeFunctions {
  SecondaryWeaponAbility(this.weapon, this.cooldown, int? newUpgradeLevel) {
    entityStatusWrapper = weapon?.entityAncestor?.entityStatusWrapper;

    newUpgradeLevel ??= 0;
    maxLevel = secondaryType.maxLevel;
    changeLevel(newUpgradeLevel);
  }
  bool endAbilityOnSecondaryRelease = true;
  @override
  FutureOr<void> onLoad() {
    if (weapon is AttributeWeaponFunctionsFunctionality?) {
      final attributeWeapon = weapon as AttributeWeaponFunctionsFunctionality?;

      attributeWeapon?.onSwappedFrom.add(
        onSwappedFrom,
      );
      attributeWeapon?.onSwappedTo.add(
        onSwappedFrom,
      );
    }

    return super.onLoad();
  }

  @override
  void onRemove() {
    if (weapon is AttributeWeaponFunctionsFunctionality?) {
      final attributeWeapon = weapon as AttributeWeaponFunctionsFunctionality?;

      attributeWeapon?.onSwappedFrom.add(
        onSwappedFrom,
      );
      attributeWeapon?.onSwappedTo.add(
        onSwappedFrom,
      );
    }
    super.onRemove();
  }

  late final EntityStatusEffectsWrapper? entityStatusWrapper;
  Weapon? weapon;
  double cooldown;
  TimerComponent? cooldownTimer;
  bool get isCoolingDown => cooldownTimer?.timer.isRunning() ?? false;

  void onSwappedTo(Weapon weapon) {}
  void onSwappedFrom(Weapon weapon) {
    endAbility();
  }

  late final String id = const Uuid().v4();
  abstract SecondaryType secondaryType;
  @override
  late int? maxLevel;

  String get nextLevelStringDescription;
  String get abilityDescription;

  void startAbility();

  void startAbilityCheck() {
    if (isCoolingDown || weapon?.entityAncestor == null) {
      return;
    }
    cooldownTimer?.timer.start();
    cooldownTimer ??= TimerComponent(
      period: cooldown,
      removeOnFinish: true,
      onTick: () {
        entityStatusWrapper?.removeReloadAnimation(
          id,
          true,
        );
        cooldownTimer?.timer.stop();
      },
    )..addToParent(this);

    entityStatusWrapper?.addReloadAnimation(
      id,
      cooldown,
      cooldownTimer!,
      true,
    );

    startAbility();
  }

  void endAbility();
}

class EssentialFocusSecondary extends SecondaryWeaponAbility {
  EssentialFocusSecondary(super.weapon, super.cooldown, super.level);

  @override
  void onSwappedTo(Weapon weapon) {
    switch (weapon.weaponType.attackType) {
      case AttackType.guns:
        weapon.attackTickRate.setParameterPercentValue(id, -0.05);
        break;
      case AttackType.magic:
        if (weapon.entityAncestor is StaminaFunctionality?) {
          final staminaCost = weapon.entityAncestor as StaminaFunctionality?;
          staminaCost?.staminaRegen.setParameterPercentValue(id, 0.15);
        }

        break;
      case AttackType.melee:
        if (weapon.entityAncestor is MovementFunctionality?) {
          final move = weapon.entityAncestor as MovementFunctionality?;
          move?.speed.setParameterPercentValue(id, 0.1);
        }
        break;
      default:
    }
  }

  @override
  void onSwappedFrom(Weapon weapon) {
    switch (weapon.weaponType.attackType) {
      case AttackType.guns:
        weapon.attackTickRate.removeKey(id);
        break;
      case AttackType.magic:
        if (weapon.entityAncestor is StaminaFunctionality?) {
          final staminaCost = weapon.entityAncestor as StaminaFunctionality?;
          staminaCost?.staminaRegen.removeKey(id);
        }

        break;
      case AttackType.melee:
        if (weapon.entityAncestor is MovementFunctionality?) {
          final move = weapon.entityAncestor as MovementFunctionality?;
          move?.speed.removeKey(id);
        }
        break;
      default:
    }
  }

  @override
  SecondaryType secondaryType = SecondaryType.essentialFocus;

  @override
  String get nextLevelStringDescription => '';

  @override
  void endAbility() {}

  @override
  Future<void> startAbility() async {}

  @override
  String get abilityDescription => 'Increase attack speed if using a gun.\n'
      'Increase stamina regen if using magic.\n'
      'Increase movement speed if using melee.\n';
}

///Reloads the weapon and mag dumps at a firerate of approx 5x original
class RapidFire extends SecondaryWeaponAbility {
  RapidFire(
    super.weapon,
    super.cooldown,
    super.level, {
    this.baseAttackRateIncrease = 5,
  });
  TimerComponent? rapidFireTimer;
  bool get isCurrentlyRunning => rapidFireTimer != null;

  double get attackRateIncrease =>
      (baseAttackRateIncrease + attackRateIncreaseIncrease)
          .clamp(2, double.infinity);
  double baseAttackRateIncrease;
  double attackRateIncreaseIncrease = 0;

  int get baseLoops => upgradeLevel;
  int attacks = 0;

  @override
  void endAbility() {}

  void cancelFire() {
    rapidFireTimer?.timer.stop();
    rapidFireTimer?.removeFromParent();
    rapidFireTimer = null;
    completedLoops = 0;
  }

  void onTick() {
    final reload = weapon as ReloadFunctionality?;
    if ((reload?.entityAncestor as AttackFunctionality?)
            ?.currentWeapon
            ?.weaponId !=
        weapon?.weaponId) {
      cancelFire();
      return;
    }

    if (weapon is SemiAutomatic) {
      weapon?.attackAttempt(const AttackConfiguration(holdDurationPercent: .5));
      attacks++;
    } else {
      weapon?.attackAttempt(const AttackConfiguration());
    }
    if (reload?.remainingAttacks == 1 && completedLoops != baseLoops) {
      reload?.spentAttacks = 0;
      completedLoops++;
      return;
    }

    reload?.reloadCheck();
    if (reload?.isReloading ?? false) {
      rapidFireTimer?.timer.stop();
      rapidFireTimer?.removeFromParent();
      rapidFireTimer = null;
      completedLoops = 0;
    }
  }

  @override
  Future<void> startAbility() async {
    if (isCurrentlyRunning) {
      return;
    }

    if (weapon is! ReloadFunctionality) {
      return;
    }

    final weaponAttackRate = weapon?.attackTickRate.parameter ?? 0;
    final reload = weapon! as ReloadFunctionality;
    if (reload.isReloading) {
      reload.stopReloading();
    } else {
      reload.spentAttacks = 0;
    }
    rapidFireTimer = TimerComponent(
      repeat: true,
      period: weaponAttackRate / attackRateIncrease,
      onTick: onTick,
    );
    add(rapidFireTimer!);
  }

  int completedLoops = 0;

  @override
  SecondaryType secondaryType = SecondaryType.rapidFire;

  @override
  String get abilityDescription =>
      'Instantly reloads weapon and shoots at an increased attack-rate!';

  @override
  String get nextLevelStringDescription =>
      'Increases attack rate and total mags dumped';
}

///Reloads the weapon and mag dumps at a firerate of approx 5x original
class ExplodeProjectile extends SecondaryWeaponAbility {
  ExplodeProjectile(super.weapon, super.cooldown, super.level);

  @override
  SecondaryType secondaryType = SecondaryType.explodeProjectiles;

  @override
  String get nextLevelStringDescription =>
      'Increase explosion radius and damage';

  @override
  void endAbility() {}

  @override
  void startAbilityCheck() {
    if (weapon is! ProjectileFunctionality) {
      return;
    }

    final projectile = weapon! as ProjectileFunctionality;
    if (projectile.activeProjectiles.isEmpty) {
      return;
    }

    super.startAbilityCheck();
  }

  @override
  Future<void> startAbility() async {
    final projectile = weapon! as ProjectileFunctionality;
    final projectileListCopy = [...projectile.activeProjectiles.reversed];
    final explosionList = <AreaEffect>[];
    for (final element in projectileListCopy) {
      final explosion = AreaEffect(
        sourceEntity: weapon!.entityAncestor!,
        position: element.center,
        damage: {
          weapon?.baseDamage.damageBase.keys.toList().random() ??
              DamageType.fire: (
            increasePercentOfBase(
              1,
              includeBase: true,
              customUpgradeFactor: .1,
            ).toDouble(),
            increasePercentOfBase(
              2,
              includeBase: true,
              customUpgradeFactor: .1,
            ).toDouble(),
          ),
        },
      );
      explosionList.add(explosion);

      element.killBullet();
    }

    weapon?.entityAncestor?.enviroment.addPhysicsComponent(
      explosionList..shuffle(),
    );
  }

  @override
  String get abilityDescription =>
      'Creates a firey explosion in the location of all currently active projectiles!';
}

class ShadowBlink extends SecondaryWeaponAbility with RechargeableStack {
  ShadowBlink(super.weapon, super.cooldown, super.level);

  @override
  SecondaryType secondaryType = SecondaryType.shadowBlink;

  @override
  double get rechargeTime => cooldown;

  @override
  String get nextLevelStringDescription => 'Increase charge count!';

  @override
  void endAbility() {}

  @override
  void update(double dt) {
    recharge(dt);
    super.update(dt);
  }

  @override
  void startAbilityCheck() {
    if (weapon is! MeleeFunctionality) {
      return;
    }

    // super.startAbilityCheck();
    if (hasStacks) {
      useStack();
      startAbility();
    }
  }

  @override
  void render(Canvas canvas) {
    buildProgressBar(
      canvas: canvas,
      percentProgress: rechargePercent,
      color: Colors.red,
      size: Vector2(5, 5),
    );

    super.render(canvas);
  }

  @override
  Future<void> startAbility() async {
    if (weapon is! MeleeFunctionality) {
      return;
    }

    final melee = weapon! as MeleeFunctionality;
    final player = melee.entityAncestor as Player?;
    final enemy = player?.closestEnemyToMouse;
    if (player == null || enemy == null) {
      return;
    }

    final playerPosition = player.position;
    final enemyPosition = enemy.position;

    final distance = playerPosition.distanceTo(enemyPosition);
    final direction =
        radiansBetweenPoints(Vector2(0, 1), enemyPosition - playerPosition);
    final calcPos = newPositionRad(
      playerPosition,
      direction,
      distance + melee.weaponLength / 2,
    );

    player.body.setTransform(calcPos, player.body.angle);

    final randomId = const Uuid().v4();
    player.invincible.setIncrease(randomId, true);
    player.addAttribute(
      AttributeType.empowered,
      perpetratorEntity: player,
      isTemporary: true,
      duration: 2,
    );
    weapon?.entityAncestor?.game.gameAwait(1).then((value) {
      player.invincible.removeKey(randomId);
    });
    melee.meleeAttack(
      0,
      angle: -direction - pi,
      forceCrit: true,
      attackConfiguration: const AttackConfiguration(
        customAttackLocation: SourceAttackLocation.body,
      ),
    );
  }

  @override
  String get abilityDescription =>
      'Teleport behind the enemy and crit them with your weapon!';
}

class InstantReload extends SecondaryWeaponAbility {
  InstantReload(super.weapon, super.cooldown, super.level);

  @override
  SecondaryType secondaryType = SecondaryType.instantReload;

  @override
  String get nextLevelStringDescription => 'Increase reload speed!';

  @override
  void endAbility() {}

  @override
  void startAbilityCheck() {
    if (weapon is! ReloadFunctionality) {
      return;
    }

    super.startAbilityCheck();
  }

  @override
  Future<void> startAbility() async {
    if (weapon is! ReloadFunctionality) {
      return;
    }

    final reload = weapon! as ReloadFunctionality;
    if (reload.spentAttacks == 0) {
      return;
    }
    reload.reload(instant: true);
    if (weapon?.entityAncestor is AttributeFunctionality) {
      final attribute = weapon?.entityAncestor as AttributeFunctionality?;
      attribute?.addAttribute(
        AttributeType.empowered,
        isTemporary: true,
        perpetratorEntity: weapon?.entityAncestor,
      );
    }
  }

  @override
  String get abilityDescription =>
      'Reloads your weapon instantly, empowering your next attack.';
}

class Bloodlust extends SecondaryWeaponAbility {
  Bloodlust(super.weapon, super.cooldown, super.level);

  @override
  SecondaryType secondaryType = SecondaryType.bloodlust;

  @override
  String get nextLevelStringDescription =>
      'Increase duration and damage dealt.';

  @override
  void endAbility() {
    removeBuff();
  }

  @override
  bool get endAbilityOnSecondaryRelease => false;

  void removeBuff() {
    final entity = weapon?.entityAncestor;

    entity?.damageTypeResistance.removePercentKey(id);

    entity?.damagePercentIncrease.removeKey(
      id,
    );
    entity?.essenceSteal.removeKey(
      id,
    );
  }

  @override
  void startAbilityCheck() {
    if (weapon is! MeleeFunctionality) {
      return;
    }

    super.startAbilityCheck();
  }

  TimerComponent? timer;
  final double duration = 4;

  @override
  Future<void> startAbility() async {
    if (weapon is! MeleeFunctionality) {
      return;
    }
    timer = TimerComponent(
      period: duration,
      onTick: () {
        removeBuff();
        timer?.removeFromParent();
      },
    )..addToParent(this);

    final entity = weapon?.entityAncestor;
    entity?.damageTypeResistance.setDamagePercentIncrease(
      id,
      Map.fromEntries(DamageType.values.map((e) => MapEntry(e, 1.25))),
    );

    entity?.damagePercentIncrease.setParameterPercentValue(
      id,
      increasePercentOfBase(
        .5,
        includeBase: true,
        customUpgradeFactor: .5,
      ).toDouble(),
    );
    entity?.essenceSteal.setParameterFlatValue(
      id,
      increasePercentOfBase(
        .15,
        includeBase: true,
        customUpgradeFactor: .5,
      ).toDouble(),
    );
  }

  @override
  String get abilityDescription =>
      'Increase damage dealt and gain lifesteal for a short duration, while also'
      ' increasing damage taken.';
}

class SurroundAttack extends SecondaryWeaponAbility {
  SurroundAttack(super.weapon, super.cooldown, super.level);

  @override
  SecondaryType secondaryType = SecondaryType.surroundAttack;

  @override
  String get nextLevelStringDescription =>
      'Increase duration and damage dealt.';

  @override
  void endAbility() {}

  List<double> pattern(double angle, int count) {
    var newCount = increasePercentOfBase(
      3,
      includeBase: true,
      customUpgradeFactor: 1,
    ).round();
    if (weapon is ReloadFunctionality) {
      final reload = weapon! as ReloadFunctionality;
      if ((reload.maxAttacks.parameter) > 10) {
        newCount += 3;
      }
    }
    return crossAttackSpread(count: newCount + count, initialAngle: angle);
  }

  @override
  Future<void> startAbility() async {
    weapon?.standardAttack(
      AttackConfiguration(
        holdDurationPercent: .5,
        customAttackLocation: SourceAttackLocation.body,
        customAttackSpreadPattern: {pattern},
      ),
    );
  }

  @override
  String get abilityDescription =>
      'Attack in a pattern around the player, dealing damage to all enemies hit.';
}

// class StaminaRecharge extends SecondaryWeaponAbility {
//   StaminaRecharge(super.weapon, super.cooldown, super.level);

//   @override
//   SecondaryType secondaryType = SecondaryType.instantReload;

//   @override
//   String get nextLevelStringDescription => '';

//   @override
//   void endAbility() {}

//   @override
//   Future<void> startAbility() async {
//     if (weapon?.entityAncestor is StaminaFunctionality) {
//       final stamina = weapon?.entityAncestor as StaminaFunctionality?;
//       stamina?.modifyStamina(stamina.staminaUsed);
//     }
//   }

//   @override
//   String get abilityDescription =>
//       'Reloads your weapon instantly, empowering your next attack.';
// }

class ElementalBlast extends SecondaryWeaponAbility {
  ElementalBlast(super.weapon, super.cooldown, super.level);

  @override
  SecondaryType secondaryType = SecondaryType.elementalBlast;

  @override
  String get nextLevelStringDescription => '';

  @override
  void endAbility() {}

  @override
  Future<void> startAbility() async {
    final damageTypeList = weapon?.baseDamage.damageBase.keys.toList() ?? [];
    final areaPosition = weapon?.entityAncestor?.center ?? Vector2.zero();
    final area = AreaEffect(
      position: areaPosition,
      radius: increasePercentOfBase(
        5,
        includeBase: true,
        customUpgradeFactor: .3,
      ).toDouble(),
      damage: {
        weapon?.primaryDamageType ??
            (damageTypeList.isEmpty
                ? DamageType.values.random()
                : damageTypeList.random()): (
          increasePercentOfBase(
            2,
            includeBase: true,
            customUpgradeFactor: .1,
          ).toDouble(),
          increasePercentOfBase(
            3,
            includeBase: true,
            customUpgradeFactor: .1,
          ).toDouble(),
        ),
      },
      sourceEntity: weapon!.entityAncestor!,
      collisionDelay: 0,
      onTick: (entity, areaId) {
        if (entity is MovementFunctionality) {
          entity.applyKnockback(
            amount: increasePercentOfBase(
              3500,
              includeBase: true,
              customUpgradeFactor: .35,
            ).toDouble(),
            direction: (entity.position - areaPosition).normalized(),
          );
        }
      },
    );

    weapon?.entityAncestor?.enviroment.addPhysicsComponent(
      [area],
    );
  }

  @override
  String get abilityDescription =>
      'Generates a forceful blast of energy. Knocking away enemies.';
}
