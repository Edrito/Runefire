import 'package:game_app/entities/entity_mixin.dart';

import '../entities/entity.dart';

enum AttributeType {
  mobility,
  projectile,
  magic,
  melee,
  defence,
  offense,
  attack
}

enum AttributeEnum {
  maxSpeed,
}

extension AllAttributesExtension on AttributeEnum {
  Attribute buildAttribute(int level, Entity entity) {
    switch (this) {
      case AttributeEnum.maxSpeed:
        return MaxSpeedAttribute(level, entity);
    }
  }
}

abstract class Attribute {
  Attribute(this._level, this.entity) {
    _level = _level.clamp(0, maxLevel);
  }

  String description();
  abstract String icon;
  abstract String title;

  int _level;
  Entity entity;
  bool isApplied = false;
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

  ///Increase or decrease the level based on the input value
  void incrementLevel(int value) {
    removeAttribute();
    _level += value;
    _level = _level.clamp(0, maxLevel);
    applyAttribute();
  }
}

class MaxSpeedAttribute extends Attribute {
  MaxSpeedAttribute(super.level, super.entity);

  @override
  AttributeType attributeType = AttributeType.mobility;

  double factor = .05;

  @override
  void mapAttribute() {
    if (Entity is! MovementFunctionality) return;
    var move = Entity as MovementFunctionality;
    move.speedIncreasePercent += factor * (_level + _level == maxLevel ? 1 : 0);
  }

  @override
  void unmapAttribute() {
    if (Entity is! MovementFunctionality) return;
    var move = Entity as MovementFunctionality;
    move.speedIncreasePercent -= factor * (_level + _level == maxLevel ? 1 : 0);
  }

  @override
  String icon = "";

  @override
  String title = "";

  @override
  String description() {
    return "";
  }
}
