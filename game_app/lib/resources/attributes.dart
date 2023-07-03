import 'package:game_app/entities/entity_mixin.dart';

import '../entities/entity.dart';
import '../pages/buttons.dart';
import 'attributes_enum.dart';

abstract class Attribute {
  Attribute(this._level, this.entity, [bool applyNow = true]) {
    _level = _level.clamp(0, maxLevel);
    if (applyNow) {
      applyAttribute();
    }
  }

  String description();
  abstract String icon;
  abstract String title;
  double? factor;

  int _level;
  Entity entity;
  bool isApplied = false;

  int get remainingLevels => maxLevel - _level;

  int maxLevel = 5;

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
  AttributeType get attributeType;
  AttributeEnum get attributeEnum;

  ///Increase or decrease the level based on the input value
  void incrementLevel(int value) {
    removeAttribute();
    _level += value;
    _level = _level.clamp(0, maxLevel);
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
  TopSpeedAttribute(super.level, super.entity, super.applyNow);

  @override
  AttributeType attributeType = AttributeType.mobility;

  @override
  AttributeEnum attributeEnum = AttributeEnum.topSpeed;

  @override
  double get factor => .05;

  @override
  int get maxLevel => 4;

  double get increase => factor * (_level + (_level == maxLevel ? 1 : 0));

  @override
  void mapAttribute() {
    if (entity is! MovementFunctionality) return;
    var move = entity as MovementFunctionality;
    move.speedIncrease += increase;
  }

  @override
  void unmapAttribute() {
    if (entity is! MovementFunctionality) return;
    var move = entity as MovementFunctionality;
    move.speedIncrease -= increase;
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
  AttackRateAttribute(super.level, super.entity, super.applyNow);

  @override
  AttributeType attributeType = AttributeType.attack;

  @override
  AttributeEnum attributeEnum = AttributeEnum.attackRate;

  @override
  double get factor => .05;

  @override
  int get maxLevel => 10;

  double increase(double baseAttackRate) =>
      (factor * baseAttackRate) * (_level + (_level == maxLevel ? 1 : 0));

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
