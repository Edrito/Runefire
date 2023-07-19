import 'package:game_app/attributes/attributes_mixin.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/attributes/temporary_attributes.dart';
import 'package:uuid/uuid.dart';

import '../entities/entity.dart';
import '../main.dart';
import '../overlays/cards.dart';
import '../weapons/weapon_mixin.dart';
import '../resources/area_effects.dart';
import 'attributes_enum.dart';
import '../resources/enums.dart';
import '../resources/functions/custom_mixins.dart';

///Status effect, increase in levels, abilities etc
///Different classes that are applied to an Entity that may be sourced
///from a level up, a enemy attack, a weapon, a potion etc
///The attribute is applied to the victimEntity
///The perpetratorEntity may be a source of a negitive attribute
abstract class Attribute with UpgradeFunctions {
  Attribute(
      {int level = 0,
      required this.victimEntity,
      this.perpetratorEntity,
      this.damageType,
      this.statusEffect}) {
    upgradeLevel = level.clamp(0, maxLevel);
    attributeId = const Uuid().v4();
  }

  bool hasRandomDamageType = false;
  bool hasRandomStatusEffect = false;
  DamageType? damageType;
  StatusEffects? statusEffect;
  bool get isTemporary => this is TemporaryAttribute;

  String description();
  String help() {
    return "An increase of ${((factor ?? 0) * 100)}% of your base attribute with an additional ${((factor ?? 0) * 100)}% at max level.";
  }

  late String attributeId;
  abstract String icon;
  abstract String title;
  double? factor;

  AttributeFunctionality victimEntity;
  Entity? perpetratorEntity;

  int get remainingLevels => maxLevel - upgradeLevel;

  int maxLevel = 5;

  ///Default increase is multiplying the baseParameter by [factor]%
  ///then multiplying it again by the level of the attribute
  ///with an additional level for max level
  double increaseFlat(double base) =>
      ((factor ?? 0) * base) *
      (upgradeLevel + (upgradeLevel == maxLevel ? 1 : 0));

  double increasePercent() =>
      (factor ?? 0) * (upgradeLevel + (upgradeLevel == maxLevel ? 1 : 0));

  AttributeEnum get attributeEnum;

  ///Increase or decrease the level based on the input value

  CustomCard buildWidget(
      {Function? onTap, Function? onTapComplete, bool small = false}) {
    return CustomCard(
      this,
      gameRef: gameRouter,
      onTap: onTap,
      onTapComplete: onTapComplete,
      smallCard: small,
    );
  }
}

class TopSpeedAttribute extends Attribute {
  TopSpeedAttribute(
      {required super.level,
      required super.victimEntity,
      required super.perpetratorEntity});

  @override
  AttributeEnum attributeEnum = AttributeEnum.speed;

  @override
  double get factor => .05;

  @override
  int get maxLevel => 5;

  @override
  void mapUpgrade() {
    if (victimEntity is! MovementFunctionality) return;
    var move = victimEntity as MovementFunctionality;
    move.speed.setParameterPercentValue(attributeId, increasePercent());
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! MovementFunctionality) return;
    var move = victimEntity as MovementFunctionality;
    move.speed.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Speed Increase";

  @override
  String description() {
    if (remainingLevels != 1) {
      return "Increase your top speed!";
    } else {
      return "Max Level";
    }
  }
}

class AttackRateAttribute extends Attribute {
  AttackRateAttribute(
      {required super.level,
      required super.victimEntity,
      required super.perpetratorEntity});

  @override
  AttributeEnum attributeEnum = AttributeEnum.attackRate;

  @override
  double get factor => .05;

  @override
  int get maxLevel => 10;

  @override
  void mapUpgrade() {
    if (victimEntity is! AttackFunctionality) return;
    var attack = victimEntity as AttackFunctionality;
    for (var element in attack.carriedWeapons.values) {
      element.attackTickRate.setParameterFlatValue(
          attributeId, -increaseFlat(element.attackTickRate.baseParameter));
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttackFunctionality) return;
    var attack = victimEntity as AttackFunctionality;
    for (var element in attack.carriedWeapons.values) {
      element.attackTickRate.removeKey(attributeId);
    }
  }

  @override
  String icon = "attributes/attackRate.png";

  @override
  String title = "Attack Rate Increase";

  @override
  String description() {
    if (remainingLevels != 1) {
      return "Increase your attack rate!";
    } else {
      return "Max Level";
    }
  }
}

class ExplosionEnemyDeathAttribute extends Attribute {
  ExplosionEnemyDeathAttribute(
      {required super.level,
      required super.victimEntity,
      required super.perpetratorEntity});

  @override
  AttributeEnum attributeEnum = AttributeEnum.enemyExplosion;

  @override
  double get factor => .25;

  @override
  int get maxLevel => 5;

  double baseSize = .5;

  void onKill(HealthFunctionality other) {
    final explosion = AreaEffect(
      sourceEntity: victimEntity,
      position: other.center,
      radius: baseSize + increaseFlat(baseSize),
      isInstant: false,
      duration: victimEntity.durationPercentIncrease.parameter,
      onTick: (entity, areaId) {
        if (entity is HealthFunctionality) {
          entity.hitCheck(areaId, [
            DamageInstance(
                damageBase: increaseFlat(1),
                damageType: DamageType.fire,
                source: entity)
          ]);
        }
      },
    );
    victimEntity.gameEnviroment.physicsComponent.add(explosion);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttackFunctionality) return;
    final attributeFunctions = victimEntity as AttackFunctionality;
    for (var element in attributeFunctions.carriedWeapons.values) {
      if (element is AttributeWeaponFunctionsFunctionality) {
        element.onKill.add(onKill);
      }
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttackFunctionality) return;
    final attributeFunctions = victimEntity as AttackFunctionality;
    for (var element in attributeFunctions.carriedWeapons.values) {
      if (element is AttributeWeaponFunctionsFunctionality) {
        element.onKill.remove(onKill);
      }
    }
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Enemies Explode";

  @override
  String description() {
    if (remainingLevels != 1) {
      return "Something in that ammunition...";
    } else {
      return "Max Level";
    }
  }
}
