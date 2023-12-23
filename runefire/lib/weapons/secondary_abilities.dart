import 'package:flame/components.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/resources/enums.dart';

import 'package:runefire/resources/functions/custom.dart';

abstract class SecondaryWeaponAbility extends Component with UpgradeFunctions {
  SecondaryWeaponAbility(this.weapon, this.cooldown, int? newUpgradeLevel) {
    entityStatusWrapper = weapon?.entityAncestor?.entityStatusWrapper;

    newUpgradeLevel ??= 0;
    maxLevel = secondaryType.maxLevel;
    changeLevel(newUpgradeLevel);
  }
  late final EntityStatusEffectsWrapper? entityStatusWrapper;
  Weapon? weapon;
  double cooldown;
  TimerComponent? cooldownTimer;
  bool get isCoolingDown => cooldownTimer != null;

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

    cooldownTimer = TimerComponent(
      period: cooldown,
      removeOnFinish: true,
      onTick: () {
        entityStatusWrapper?.removeReloadAnimation(
          weapon?.weaponId ?? '',
          true,
        );
        cooldownTimer = null;
      },
    )..addToParent(this);

    entityStatusWrapper?.addReloadAnimation(
      weapon?.weaponId ?? '',
      cooldown,
      cooldownTimer!,
      true,
    );

    startAbility();
  }

  void endAbility();
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
    final reload = weapon! as ReloadFunctionality;
    if ((weapon!.entityAncestor! as AttackFunctionality).currentWeapon !=
        weapon) {
      cancelFire();
      return;
    }

    if (weapon is SemiAutomatic) {
      weapon?.attackAttempt(.5);
      attacks++;
    } else {
      weapon?.attackAttempt();
    }
    if (reload.remainingAttacks == 1 && completedLoops != baseLoops) {
      reload.spentAttacks = 0;
      completedLoops++;
      return;
    }

    reload.reloadCheck();
    if (reload.isReloading) {
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

    final weaponAttackRate = weapon?.attackTickRate.parameter ?? 0;
    if (weapon is! ReloadFunctionality) {
      return;
    }

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
  SecondaryType secondaryType = SecondaryType.reloadAndRapidFire;

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
    for (final element in projectileListCopy) {
      Future.delayed(const Duration(milliseconds: 10)).then((value) {
        final explosion = AreaEffect(
          sourceEntity: weapon!.entityAncestor!,
          position: element.center,
          damage: {DamageType.fire: (2, 5)},
        );

        weapon?.entityAncestor?.enviroment.addPhysicsComponent([explosion]);
      });

      element.killBullet();
    }
  }

  @override
  // TODO: implement attributeDescription
  String get abilityDescription =>
      'Creates a firey explosion in the location of all currently active projectiles!';
}
