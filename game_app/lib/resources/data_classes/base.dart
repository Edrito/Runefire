import 'dart:math';

import 'package:flame/components.dart';

import 'package:hive/hive.dart';

import '../../entities/entity_class.dart';
import '../../main.dart';
import '../../weapons/weapon_class.dart';
import '../enums.dart';

abstract class DataClass extends HiveObject {
  DataComponent? parentComponent;
}

abstract class DataComponent extends Component with Notifier {
  DataComponent(this._dataObject) {
    _dataObject.parentComponent = this;
  }
  final DataClass _dataObject;

  DataClass get dataObject => _dataObject;
}

///When determining the parameter, the flat increase is added first
///then the percent increase is added
///
///For example, if the base parameter is 100, the flat increase is 10
///and the percent increase is 0.1, the parameter will be
///(100 + 10) * 1.1 = 121
///
///If theres a value that "gets better" with less of it, like cooldowns or attack speeds
///you would want to use a negitive flat/percent increase increase
///
///For example, if the base cooldown is 10, the flat increase is -1
///and the percent increase is -0.1, the cooldown will be
///(10 - 1) * .9 = 8.1
///
class DoubleParameterManager {
  DoubleParameterManager({
    required this.baseParameter,
    this.minParameter,
    this.maxParameter,
  });

  double? minParameter;
  double? maxParameter;

  double baseParameter;

  double get parameter {
    final returnVal =
        ((baseParameter + parameterFlatIncrease) * parameterPercentIncrease)
            .clamp(minParameter ?? double.negativeInfinity,
                maxParameter ?? double.infinity);
    return returnVal;
  }

  final Map<String, double> _parameterFlatIncrease = {};
  final Map<String, double> _parameterPercentIncrease = {};

  double get parameterFlatIncrease => _parameterFlatIncrease.values
      .fold<double>(0, (previousValue, element) => previousValue + element);

  double get parameterPercentIncrease =>
      (_parameterPercentIncrease.values.fold<double>(
          0, (previousValue, element) => previousValue + element)) +
      1;

  void setParameterFlatValue(String sourceId, double value) {
    _parameterFlatIncrease[sourceId] = value;
  }

  ///If you want to increase the parameter by %10, you would pass 0.1
  ///If you want to decrease the parameter by %10, you would pass -0.1
  void setParameterPercentValue(String sourceId, double value) {
    _parameterPercentIncrease[sourceId] = value;
  }

  void removeFlatKey(String sourceId) {
    _parameterFlatIncrease.remove(sourceId);
  }

  void removePercentKey(String sourceId) {
    _parameterPercentIncrease.remove(sourceId);
  }

  void removeKey(String sourceId) {
    removeFlatKey(sourceId);
    removePercentKey(sourceId);
  }

  @override
  String toString() {
    return parameter.toStringAsFixed(1);
  }
}

///When determining the parameter, the flat increase is added first
///then the percent increase is added
///For example, if the base parameter is 100, the flat increase is 10
///and the percent increase is 0.1, the parameter will be 121
///(100 + 10) * 1.1 = 121
class IntParameterManager {
  IntParameterManager(
      {required this.baseParameter, this.minParameter, this.maxParameter});
  int? minParameter;
  int? maxParameter;

  int baseParameter;
  int get parameter {
    final returnVal =
        ((baseParameter + parameterFlatIncrease) * parameterPercentIncrease)
            .round();
    if (minParameter == null || maxParameter == null) {
      return returnVal;
    } else {
      return returnVal.clamp(minParameter!, maxParameter!);
    }
  }

  @override
  String toString() {
    return parameter.toStringAsFixed(1);
  }

  final Map<String, int> _parameterFlatIncrease = {};
  final Map<String, double> _parameterPercentIncrease = {};

  int get parameterFlatIncrease => _parameterFlatIncrease.values
      .fold(0, (previousValue, element) => previousValue + element);
  double get parameterPercentIncrease =>
      _parameterPercentIncrease.values.fold<double>(
          0, (previousValue, element) => previousValue + element) +
      1;

  void setParameterFlatValue(String sourceId, int value) {
    _parameterFlatIncrease[sourceId] = value;
  }

  void setParameterPercentValue(String sourceId, double value) {
    _parameterPercentIncrease[sourceId] = value;
  }

  void removeFlatKey(String sourceId) {
    _parameterFlatIncrease.remove(sourceId);
  }

  void removePercentKey(String sourceId) {
    _parameterPercentIncrease.remove(sourceId);
  }

  void removeKey(String sourceId) {
    removeFlatKey(sourceId);
    removePercentKey(sourceId);
  }
}

class BoolParameterManager {
  BoolParameterManager(
      {required this.baseParameter, this.isFoldOfIncreases = true});
  bool baseParameter;
  bool isFoldOfIncreases;
  final Map<String, bool> _parameterIncrease = {};
  bool get parameter {
    if (isFoldOfIncreases) {
      return boolAbilityDecipher();
    } else {
      return _parameterIncrease.values.contains(true) || baseParameter;
    }
  }

  void setIncrease(String sourceId, bool increase) {
    _parameterIncrease[sourceId] = increase;
  }

  void removeIncrease(String sourceId) {
    _parameterIncrease.remove(sourceId);
  }

  bool boolAbilityDecipher() {
    if (_parameterIncrease.isEmpty) {
      return baseParameter;
    }
    return [baseParameter, ..._parameterIncrease.values].fold<int>(
            0,
            (previousValue, element) =>
                previousValue + ((element) ? 0 : (element ? 1 : -1))) >
        0;
  }

  void removeKey(String sourceId) {
    _parameterIncrease.remove(sourceId);
  }
}

class DamageParameterManager {
  DamageParameterManager({required this.damageBase});
  Random rng = Random();
  final Map<DamageType, (double, double)> damageBase;

  ///Min damage is added to min damage calculation, same with max
  final Map<String, Map<DamageType, (double, double)>> _damageFlatIncrease = {};

  ///Min damage is added to min damage calculation, same with max
  final Map<String, Map<DamageType, (double, double)>> _damagePercentIncrease =
      {};

  void setDamagePercentIncrease(
      String sourceId, DamageType damageType, double min, double max) {
    _damagePercentIncrease[sourceId] = {damageType: (min, max)};
  }

  void setDamageFlatIncrease(
      String sourceId, DamageType damageType, double min, double max) {
    _damageFlatIncrease[sourceId] = {damageType: (min, max)};
  }

  void removePercentKey(String sourceId) {
    _damagePercentIncrease.remove(sourceId);
  }

  void removeFlatKey(String sourceId) {
    _damageFlatIncrease.remove(sourceId);
  }

  void removeKey(String sourceId) {
    removeFlatKey(sourceId);
    removePercentKey(sourceId);
  }

  Map<DamageType, (double, double)> get damageFlatIncrease {
    final Map<DamageType, (double, double)> returnMap = {};

    for (var stringElement in _damageFlatIncrease.entries) {
      final tempMap = stringElement.value;
      for (var element in tempMap.entries) {
        returnMap[element.key] = (
          (returnMap[element.key]?.$1 ?? 0) + (element.value.$1),
          (returnMap[element.key]?.$2 ?? 0) + (element.value.$2)
        );
      }
    }
    return returnMap;
  }

  Map<DamageType, (double, double)> get damagePercentIncrease {
    final Map<DamageType, (double, double)> returnMap = {};

    for (var stringElement in _damagePercentIncrease.entries) {
      final tempMap = stringElement.value;
      for (var element in tempMap.entries) {
        returnMap[element.key] = (
          (returnMap[element.key]?.$1 ?? 1) + (element.value.$1),
          (returnMap[element.key]?.$2 ?? 1) + (element.value.$2)
        );
      }
    }
    return returnMap;
  }
}

class StatusEffectPercentParameterManager {
  StatusEffectPercentParameterManager({required this.statusEffectPercentBase});
  Random rng = Random();
  final Map<StatusEffects, double> statusEffectPercentBase;

  ///Min damage is added to min damage calculation, same with max
  final Map<String, Map<StatusEffects, double>> _statusEffectPercentIncrease =
      {};

  void setDamagePercentIncrease(
      String sourceId, StatusEffects statusEffect, double increase) {
    _statusEffectPercentIncrease[sourceId] = {statusEffect: increase};
  }

  void increaseAllPercent(String sourceId, double increase) {
    _statusEffectPercentIncrease[sourceId] = {};
    for (var element in StatusEffects.values) {
      _statusEffectPercentIncrease[sourceId]?[element] = increase;
    }
  }

  Map<StatusEffects, double> get statusEffectPercentIncrease {
    final Map<StatusEffects, double> returnMap = {};

    for (var stringElement in _statusEffectPercentIncrease.entries) {
      final tempMap = stringElement.value;
      for (var element in tempMap.entries) {
        returnMap[element.key] = (returnMap[element.key] ?? 1) + element.value;
      }
    }
    return returnMap;
  }

  void removePercentKey(String sourceId) {
    _statusEffectPercentIncrease.remove(sourceId);
  }
}

class DamagePercentParameterManager {
  DamagePercentParameterManager({required this.damagePercentBase});
  Random rng = Random();
  final Map<DamageType, double> damagePercentBase;

  ///Min damage is added to min damage calculation, same with max
  final Map<String, Map<DamageType, double>> _damagePercentIncrease = {};

  void setDamagePercentIncrease(
      String sourceId, DamageType damageType, double increase) {
    _damagePercentIncrease[sourceId] = {damageType: increase};
  }

  Map<DamageType, double> get damagePercentIncrease {
    final Map<DamageType, double> returnMap = {};

    for (var stringElement in _damagePercentIncrease.entries) {
      final tempMap = stringElement.value;
      for (var element in tempMap.entries) {
        returnMap[element.key] = (returnMap[element.key] ?? 1) + element.value;
      }
    }
    return returnMap;
  }

  void removePercentKey(String sourceId) {
    _damagePercentIncrease.remove(sourceId);
  }
}

DamageInstance damageCalculations(
  Entity source,
  Map<DamageType, (double, double)> damageBase, {
  DamageParameterManager? damageSource,
  Weapon? sourceWeapon,
  DamageKind damageKind = DamageKind.regular,
  StatusEffects? statusEffect,
}) {
  Map<DamageType, double> returnMap = {};

  for (MapEntry<DamageType, (double, double)> element in damageBase.entries) {
    var min = element.value.$1;
    var max = element.value.$2;

    final damageFlatIncrease = damageSource?.damageFlatIncrease;
    if (damageFlatIncrease?.containsKey(element.key) ?? false) {
      min += damageFlatIncrease![element.key]?.$1 ?? 0;
      max += damageFlatIncrease[element.key]?.$2 ?? 0;
    }
    final damagePercentIncrease = damageSource?.damagePercentIncrease;
    if (damagePercentIncrease?.containsKey(element.key) ?? false) {
      min *= damagePercentIncrease![element.key]?.$1 ?? 1;
      max *= damagePercentIncrease[element.key]?.$2 ?? 1;
    }

    final percentIncreaseValue =
        source.damageTypePercentIncrease.damagePercentIncrease[element.key] ??
            1;

    returnMap[element.key] =
        ((rng.nextDouble() * (max - min)) + min) * percentIncreaseValue;
  }

  final returnInstance = DamageInstance(
      source: source, damageMap: returnMap, sourceWeapon: sourceWeapon);

  double weaponTypeIncrease = 1;

  if (sourceWeapon != null) {
    switch (sourceWeapon.weaponType.attackType) {
      case AttackType.melee:
        weaponTypeIncrease = source.meleeDamagePercentIncrease.parameter;

        break;
      case AttackType.projectile:
        weaponTypeIncrease = source.projectileDamagePercentIncrease.parameter;

        break;
      case AttackType.magic:
        weaponTypeIncrease = source.spellDamagePercentIncrease.parameter;

        break;
    }
  }

  double statusEffectIncrease = 1;
  if (statusEffect != null) {
    statusEffectIncrease = source.statusEffectsPercentIncrease
        .statusEffectPercentIncrease[statusEffect] ??= 1;
  }

  double damageKindIncrease = 1;
  switch (damageKind) {
    case DamageKind.area:
      damageKindIncrease = source.areaDamagePercentIncrease.parameter;
      break;
    case DamageKind.dot:
      damageKindIncrease = source.tickDamageIncrease.parameter;
    default:
  }

  double totalDamageIncrease = source.damagePercentIncrease.parameter;

  double rngCrit = rng.nextDouble();
  double critDamageIncrease = 1;
  bool isCrit = false;
  if (rngCrit <= source.critChance.parameter) {
    isCrit = true;
    critDamageIncrease = source.critDamage.parameter;
  }
  returnInstance.increaseByPercent(totalDamageIncrease *
      critDamageIncrease *
      weaponTypeIncrease *
      statusEffectIncrease *
      damageKindIncrease);
  returnInstance.isCrit = isCrit;
  return returnInstance;
}
