import 'package:flame/components.dart';
import 'package:game_app/entities/attributes_mixin.dart';
import 'package:game_app/entities/entity_mixin.dart';

import '../entities/entity.dart';
import '../main.dart';
import '../overlays/cards.dart';
import 'area_effects.dart';
import 'attributes_enum.dart';
import 'enums.dart';
import '../functions/custom_mixins.dart';

abstract class TemporaryAttribute extends Attribute {
  TemporaryAttribute(
      {required super.level,
      required super.victimEntity,
      required super.perpetratorEntity});

  abstract double duration;
  TimerComponent? currentTimer;
  abstract int uniqueId;

  @override
  void reMapUpgrade() {
    currentTimer?.timer.reset();
    super.reMapUpgrade();
  }

  @override
  void applyUpgrade() {
    if (currentTimer != null) {
      currentTimer?.timer.reset();
    } else {
      currentTimer = TimerComponent(
          period: duration,
          onTick: () {
            removeUpgrade();
            victimEntity.removeAttribute(attributeEnum);
          },
          removeOnFinish: true)
        ..addToParent(victimEntity);
    }
    if (!isApplied) {
      mapUpgrade();
      isApplied = true;
    }
  }

  @override
  void removeUpgrade() {
    if (isApplied) {
      currentTimer?.removeFromParent();
      currentTimer = null;
      unMapUpgrade();
      isApplied = false;
    }
  }
}

abstract class Attribute with UpgradeFunctions {
  Attribute(
      {int level = 0,
      required this.victimEntity,
      required this.perpetratorEntity}) {
    upgradeLevel = level.clamp(0, maxLevel);
    // if (applyNow) {
    //   applyAttribute();
    // }
  }

  bool get isTemporary => this is TemporaryAttribute;

  String description();
  String help() {
    return "An increase of ${((factor ?? 0) * 100)}% of your base attribute with an additional ${((factor ?? 0) * 100)}% at max level.";
  }

  abstract String icon;
  abstract String title;
  double? factor;

  AttributeFunctionality victimEntity;
  Entity perpetratorEntity;
  bool isApplied = false;

  int get remainingLevels => maxLevel - upgradeLevel;

  int maxLevel = 5;

  ///Default increase is multiplying the baseParameter by [factor]%
  ///then multiplying it again by the level of the attribute
  ///with an additional level for max level
  double increase(double base) =>
      ((factor ?? 0) * base) *
      (upgradeLevel + (upgradeLevel == maxLevel ? 1 : 0));

  AttributeEnum get attributeEnum;

  ///Increase or decrease the level based on the input value

  CustomCard buildWidget({Function? onTap, Function? onTapComplete}) {
    return CustomCard(
      this,
      gameRef: gameRouter,
      onTap: onTap,
      onTapComplete: onTapComplete,
    );
  }
}

class TopSpeedAttribute extends Attribute {
  TopSpeedAttribute(
      {required super.level,
      required super.victimEntity,
      required super.perpetratorEntity});

  @override
  AttributeEnum attributeEnum = AttributeEnum.topSpeed;

  @override
  double get factor => .05;

  @override
  int get maxLevel => 5;

  @override
  void mapUpgrade() {
    if (victimEntity is! MovementFunctionality) return;
    var move = victimEntity as MovementFunctionality;
    move.speedIncrease += increase(move.baseSpeed);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! MovementFunctionality) return;
    var move = victimEntity as MovementFunctionality;
    move.speedIncrease -= increase(move.baseSpeed);
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
      element.attackTickRateIncrease += increase(element.baseAttackTickRate);
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttackFunctionality) return;
    var attack = victimEntity as AttackFunctionality;
    for (var element in attack.carriedWeapons.values) {
      element.attackTickRateIncrease -= increase(element.baseAttackTickRate);
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

class ExplosiveDashAttribute extends Attribute {
  ExplosiveDashAttribute(
      {required super.level,
      required super.victimEntity,
      required super.perpetratorEntity});

  @override
  AttributeEnum attributeEnum = AttributeEnum.explosiveDash;

  @override
  double get factor => .25;

  @override
  int get maxLevel => 5;

  double baseSize = .5;

  void onDash() {
    final explosion = AreaEffect(
      sourceEntity: victimEntity,
      position: victimEntity.center,
      radius: baseSize + increase(baseSize),
      isInstant: false,
      duration: victimEntity.damageDuration,
      onTick: (entity, areaId) {
        if (entity is HealthFunctionality) {
          entity.hitCheck(areaId, [
            DamageInstance(
                damageBase: increase(1),
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
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attributeFunctions = victimEntity as AttributeFunctionsFunctionality;
    attributeFunctions.dashBeginFunctions.add(onDash);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attributeFunctions = victimEntity as AttributeFunctionsFunctionality;
    attributeFunctions.dashBeginFunctions.remove(onDash);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Explosive Dash!";

  @override
  String description() {
    if (remainingLevels != 1) {
      return "Never skip leg day.";
    } else {
      return "Max Level";
    }
  }
}
