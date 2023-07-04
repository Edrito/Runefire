import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/resources/powerups.dart';

import '../pages/buttons.dart';
import 'attributes_enum.dart';

abstract class Attribute {
  Attribute({required this.level, required this.entity, bool applyNow = true}) {
    level = level.clamp(0, maxLevel);
    if (applyNow) {
      applyAttribute();
    }
  }

  bool get isTemporary => this is TemporaryAttribute;

  String description();
  abstract String icon;
  abstract String title;
  double? factor;

  int level;
  AttributeFunctionality entity;
  bool isApplied = false;

  int get remainingLevels => maxLevel - level;

  int maxLevel = 5;

  ///Default increase is multiplying the baseParameter by [factor]%
  ///then multiplying it again by the level of the attribute
  ///with an additional level for max level
  double increase(double base) =>
      (factor ?? 0 * base) * (level + (level == maxLevel ? 1 : 0));

  void applyAttribute() {
    if (!isApplied) {
      mapAttribute();
      isApplied = true;
    }
  }

  void removeAttribute() {
    if (isApplied) {
      unmapAttribute();
      isApplied = false;
    }
  }

  void mapAttribute();
  void unmapAttribute();

  void update(double dt) {}
  AttributeEnum get attributeEnum;

  ///Increase or decrease the level based on the input value
  void incrementLevel(int value) {
    removeAttribute();
    level += value;
    level = level.clamp(0, maxLevel);
    applyAttribute();
  }

  CustomCard buildWidget({Function? onTap, Function? onTapComplete}) {
    return CustomCard(
      this,
      gameRef: entity.gameRef,
      onTap: onTap,
      onTapComplete: onTapComplete,
    );
  }
}

class TopSpeedAttribute extends Attribute {
  TopSpeedAttribute(
      {required super.level, required super.entity, super.applyNow});

  @override
  AttributeCategory attributeType = AttributeCategory.mobility;

  @override
  AttributeEnum attributeEnum = AttributeEnum.topSpeed;

  @override
  double get factor => .05;

  @override
  int get maxLevel => 5;

  @override
  void mapAttribute() {
    if (entity is! MovementFunctionality) return;
    var move = entity as MovementFunctionality;
    move.speedIncrease += increase(move.baseSpeed);
  }

  @override
  void unmapAttribute() {
    if (entity is! MovementFunctionality) return;
    var move = entity as MovementFunctionality;
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
      {required super.level, required super.entity, super.applyNow});

  @override
  AttributeEnum attributeEnum = AttributeEnum.attackRate;

  @override
  double get factor => .05;

  @override
  int get maxLevel => 10;

  @override
  void mapAttribute() {
    if (entity is! AttackFunctionality) return;
    var attack = entity as AttackFunctionality;
    for (var element in attack.carriedWeapons.values) {
      element.attackRateIncrease += increase(element.baseAttackRate);
    }
  }

  @override
  void unmapAttribute() {
    if (entity is! AttackFunctionality) return;
    var attack = entity as AttackFunctionality;
    for (var element in attack.carriedWeapons.values) {
      element.attackRateIncrease -= increase(element.baseAttackRate);
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
