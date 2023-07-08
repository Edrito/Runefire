import 'package:flame/components.dart';
import 'package:game_app/entities/entity_mixin.dart';

import '../main.dart';
import '../overlays/cards.dart';
import 'attributes_enum.dart';

abstract class TemporaryAttribute extends Attribute {
  TemporaryAttribute(
      {required super.level, required super.entity, super.applyNow = false});

  abstract double duration;
  TimerComponent? currentTimer;
  abstract int uniqueId;

  @override
  void remapAttribute() {
    currentTimer?.timer.reset();
    super.remapAttribute();
  }

  @override
  void applyAttribute() {
    if (currentTimer != null) {
      currentTimer?.timer.reset();
    } else {
      currentTimer = TimerComponent(
          period: duration,
          onTick: () {
            removeAttribute();
            entity.removeAttribute(attributeEnum);
          },
          removeOnFinish: true)
        ..addToParent(entity);
    }
    if (!isApplied) {
      mapAttribute();
      isApplied = true;
    }
  }

  @override
  void removeAttribute() {
    if (isApplied) {
      currentTimer?.removeFromParent();
      currentTimer = null;
      unmapAttribute();
      isApplied = false;
    }
  }
}

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
      ((factor ?? 0) * base) * (level + (level == maxLevel ? 1 : 0));

  void applyAttribute() {
    if (!isApplied) {
      mapAttribute();
      isApplied = true;
    }
  }

  void remapAttribute() {
    if (isApplied) {
      unmapAttribute();
    }
    mapAttribute();
  }

  void removeAttribute() {
    if (isApplied) {
      unmapAttribute();
      isApplied = false;
    }
  }

  void mapAttribute();
  void unmapAttribute();

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
      gameRef: gameRouter,
      onTap: onTap,
      onTapComplete: onTapComplete,
    );
  }
}

class TopSpeedAttribute extends Attribute {
  TopSpeedAttribute(
      {required super.level, required super.entity, super.applyNow});

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
      element.attackTickRateIncrease += increase(element.baseAttackTickRate);
    }
  }

  @override
  void unmapAttribute() {
    if (entity is! AttackFunctionality) return;
    var attack = entity as AttackFunctionality;
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
