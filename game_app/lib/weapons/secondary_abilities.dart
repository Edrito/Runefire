import 'package:flame/components.dart';
import 'package:game_app/entities/attributes_mixin.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../entities/entity_mixin.dart';
import '../resources/area_effects.dart';
import '../resources/enums.dart';

import '../functions/custom_mixins.dart';

abstract class SecondaryWeaponAbility extends Component with UpgradeFunctions {
  SecondaryWeaponAbility(this.weapon, this.cooldown, int? newUpgradeLevel) {
    entityStatusWrapper = weapon?.entityAncestor?.entityStatusWrapper;

    newUpgradeLevel ??= 0;
    changeLevel(newUpgradeLevel, secondaryType.maxLevel);
  }
  late final EntityStatusEffectsWrapper? entityStatusWrapper;
  Weapon? weapon;
  double cooldown;
  TimerComponent? cooldownTimer;
  bool get isCoolingDown => cooldownTimer != null;

  abstract SecondaryType secondaryType;

  String get nextLevelStringDescription;
  String get abilityDescription;

  void startAbility();

  void startAbilityCheck() {
    if (isCoolingDown || weapon?.entityAncestor == null) return;

    cooldownTimer = TimerComponent(
      period: cooldown,
      removeOnFinish: true,
      onTick: () {
        entityStatusWrapper?.removeReloadAnimation(
            weapon?.weaponId ?? "", true);
        cooldownTimer = null;
      },
    )..addToParent(this);

    entityStatusWrapper?.addReloadAnimation(
      weapon?.weaponId ?? "",
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
  RapidFire(super.weapon, super.cooldown, super.level,
      {this.baseAttackRateIncrease = 5});
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
    if ((weapon?.entityAncestor as AttackFunctionality).currentWeapon !=
        weapon) {
      cancelFire();
      return;
    }

    if (weapon is SemiAutomatic) {
      (weapon as SemiAutomatic).durationHeld =
          (weapon?.attackTickRate ?? 1) / 2;
      weapon?.attackAttempt();
      attacks++;

      (weapon as SemiAutomatic).durationHeld = 0;
    } else {
      weapon?.attackAttempt();
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

    double weaponAttackRate = weapon?.attackTickRate ?? 0;
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

  @override
  SecondaryType secondaryType = SecondaryType.reloadAndRapidFire;

  @override
  String get abilityDescription =>
      "Instantly reloads weapon and shoots at an increased attack-rate!";

  @override
  String get nextLevelStringDescription =>
      "Increases attack rate and total mags dumped";
}

///Reloads the weapon and mag dumps at a firerate of approx 5x original
class ExplodeProjectile extends SecondaryWeaponAbility {
  ExplodeProjectile(super.weapon, super.cooldown, super.level);

  @override
  SecondaryType secondaryType = SecondaryType.explodeProjectiles;

  @override
  String get nextLevelStringDescription =>
      "Increase explosion radius and damage";

  @override
  void endAbility() {}

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
      weapon?.entityAncestor?.gameEnviroment.physicsComponent.add(AreaEffect(
        sourceEntity: weapon!.entityAncestor!,
        position: element.center,
        radius: 5,
        isInstant: true,
        duration: 5,
        onTick: (entity, areaId) {
          if (entity is HealthFunctionality) {
            entity.hitCheck(areaId, [
              DamageInstance(
                  damageBase: .1,
                  damageType: DamageType.fire,
                  source: weapon!.entityAncestor!)
            ]);
          }
        },
      ));
      element.killBullet();
    }
  }

  @override
  // TODO: implement attributeDescription
  String get abilityDescription =>
      "Creates a firey explosion in the location of all currently active projectiles!";
}
