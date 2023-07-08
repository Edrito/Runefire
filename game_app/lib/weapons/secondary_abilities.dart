import 'package:flame/components.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../entities/entity_mixin.dart';
import '../resources/area_effects.dart';
import '../resources/enums.dart';

abstract class SecondaryWeaponAbility extends Component {
  SecondaryWeaponAbility(this.weapon, this.cooldown);

  Weapon weapon;
  double cooldown;
  TimerComponent? cooldownTimer;
  ReloadAnimation? reloadAnimation;
  bool get isCoolingDown => cooldownTimer != null;

  void removeCooldownTimer() {
    cooldownTimer?.removeFromParent();
    cooldownTimer = null;
  }

  void removeReloadAnimation() {
    reloadAnimation?.removeFromParent();
    reloadAnimation = null;
  }

  void startAbility();

  void startAbilityCheck() {
    if (isCoolingDown || weapon.entityAncestor == null) return;

    reloadAnimation = ReloadAnimation(cooldown, weapon.entityAncestor!, true)
      ..addToParent(weapon.entityAncestor!);

    cooldownTimer = TimerComponent(
      period: cooldown,
      removeOnFinish: true,
      onTick: () {
        removeCooldownTimer();
      },
    )..addToParent(this);

    startAbility();
  }

  void endAbility();
}

///Reloads the weapon and mag dumps at a firerate of approx 5x original
class RapidFire extends SecondaryWeaponAbility {
  RapidFire(super.weapon, super.cooldown, {this.baseAttackRateIncrease = 5});
  TimerComponent? rapidFireTimer;
  bool get isCurrentlyRunning => rapidFireTimer != null;

  double get attackRateIncrease =>
      (baseAttackRateIncrease + attackRateIncreaseIncrease)
          .clamp(2, double.infinity);
  double baseAttackRateIncrease;
  double attackRateIncreaseIncrease = 0;

  int get loops => baseLoops + loopsIncrease;
  int baseLoops = 1;
  int loopsIncrease = 0;
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
    final reload = weapon as ReloadFunctionality;
    if ((weapon.entityAncestor as AttackFunctionality).currentWeapon !=
        weapon) {
      cancelFire();
      return;
    }

    if (weapon is SemiAutomatic) {
      (weapon as SemiAutomatic).durationHeld = weapon.attackTickRate / 2;
      weapon.attackAttempt();
      attacks++;

      (weapon as SemiAutomatic).durationHeld = 0;
    } else {
      weapon.attackAttempt();
    }
    if (reload.remainingAttacks == 1 && completedLoops != loops) {
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
  void startAbility() async {
    if (isCurrentlyRunning) return;

    double weaponAttackRate = weapon.attackTickRate;
    if (weapon is! ReloadFunctionality) {
      return;
    }

    final reload = weapon as ReloadFunctionality;

    if (reload.isReloading) {
      reload.stopReloading();
    } else {
      reload.spentAttacks = 0;
    }
    rapidFireTimer = TimerComponent(
      repeat: true,
      period: weaponAttackRate / attackRateIncrease,
      autoStart: true,
      onTick: onTick,
    );
    add(rapidFireTimer!);
  }

  int completedLoops = 0;
}

///Reloads the weapon and mag dumps at a firerate of approx 5x original
class ExplodeProjectile extends SecondaryWeaponAbility {
  ExplodeProjectile(super.weapon, super.cooldown);

  @override
  void endAbility() {
    // TODO: implement endAbility
  }

  @override
  void startAbilityCheck() {
    if (weapon is! ProjectileFunctionality) return;

    final projectile = weapon as ProjectileFunctionality;
    if (projectile.activeProjectiles.isEmpty) return;

    super.startAbilityCheck();
  }

  @override
  void startAbility() async {
    final projectile = weapon as ProjectileFunctionality;
    final projectileListCopy = [...projectile.activeProjectiles.reversed];
    for (var element in projectileListCopy) {
      await Future.delayed(const Duration(milliseconds: 20));
      weapon.entityAncestor?.gameEnviroment.physicsComponent.add(AreaEffect(
        sourceEntity: weapon.entityAncestor!,
        position: element.center,
        radius: 5,
        isInstant: true,
        duration: 5,
        onTick: (entity, areaId) {
          if (entity is HealthFunctionality) {
            entity.hitCheck(areaId,
                [DamageInstance(damageBase: .1, damageType: DamageType.fire)]);
          }
        },
      ));
      element.killBullet();
    }
  }
}