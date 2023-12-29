import 'dart:math';

import 'package:flame/components.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:hive/hive.dart';

import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/main.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/resources/enums.dart';

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
    required double baseParameter,
    this.minParameter,
    this.maxParameter,
    this.parentParameterManager,
  }) : _baseParameter = baseParameter {
    parentParameterManager?.addListener((parameter) {
      _parameterFlatIncrease.addAll(
        parentParameterManager!._parameterFlatIncrease,
      );
      _parameterPercentIncrease.addAll(
        parentParameterManager!._parameterPercentIncrease,
      );
    });
  }

  double? minParameter;
  double? maxParameter;

  DoubleParameterManager? parentParameterManager;

  double _baseParameter;

  double get baseParameter => _baseParameter;

  set baseParameter(double value) {
    _baseParameter = value;
    _listeners.forEach((element) {
      element(parameter);
    });
  }

  double get parameter {
    final returnVal =
        ((baseParameter + parameterFlatIncrease) * parameterPercentIncrease)
            .clamp(
      minParameter ?? double.negativeInfinity,
      maxParameter ?? double.infinity,
    );
    return returnVal;
  }

  final List<Function(double parameter)> _listeners = [];
  void addListener(Function(double parameter) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(double parameter) listener) {
    _listeners.remove(listener);
  }

  final Map<String, double> _parameterFlatIncrease = {};
  final Map<String, double> _parameterPercentIncrease = {};

  double get parameterFlatIncrease => _parameterFlatIncrease.values
      .fold<double>(0, (previousValue, element) => previousValue + element);

  double get parameterPercentIncrease =>
      _parameterPercentIncrease.values.fold<double>(
        1,
        (previousValue, element) => previousValue * (element + 1),
      );

  void setParameterFlatValue(String sourceId, double value) {
    _parameterFlatIncrease[sourceId] = value;
    _listeners.forEach((element) {
      element(parameter);
    });
  }

  ///If you want to increase the parameter by %10, you would pass 0.1
  ///If you want to decrease the parameter by %10, you would pass -0.1
  void setParameterPercentValue(String sourceId, double value) {
    _parameterPercentIncrease[sourceId] = value;
    _listeners.forEach((element) {
      element(parameter);
    });
  }

  void removeFlatKey(String sourceId) {
    _parameterFlatIncrease.remove(sourceId);
    _listeners.forEach((element) {
      element(parameter);
    });
  }

  void removePercentKey(String sourceId) {
    _parameterPercentIncrease.remove(sourceId);
    _listeners.forEach((element) {
      element(parameter);
    });
  }

  void removeKey(String sourceId) {
    if (_parameterFlatIncrease.containsKey(sourceId)) {
      removeFlatKey(sourceId);
    }

    if (_parameterPercentIncrease.containsKey(sourceId)) {
      removePercentKey(sourceId);
    }
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
  IntParameterManager({
    required int baseParameter,
    this.minParameter,
    this.maxParameter,
  }) : _baseParameter = baseParameter;
  int? minParameter;
  int? maxParameter;

  int _baseParameter;

  int get baseParameter => _baseParameter;

  set baseParameter(int value) {
    _baseParameter = value;
    _listeners.forEach((element) {
      element(parameter);
    });
  }

  double get doubleParameter {
    final returnVal =
        (baseParameter + parameterFlatIncrease) * parameterPercentIncrease;
    if (minParameter == null || maxParameter == null) {
      return returnVal;
    } else {
      return returnVal.clamp(minParameter!, maxParameter!).toDouble();
    }
  }

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

  final List<Function(int parameter)> _listeners = [];
  void addListener(Function(int parameter) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(int parameter) listener) {
    _listeners.remove(listener);
  }

  final Map<String, int> _parameterFlatIncrease = {};
  final Map<String, double> _parameterPercentIncrease = {};

  int get parameterFlatIncrease => _parameterFlatIncrease.values
      .fold(0, (previousValue, element) => previousValue + element);
  double get parameterPercentIncrease =>
      _parameterPercentIncrease.values.fold<double>(
        0,
        (previousValue, element) => previousValue + element,
      ) +
      1;

  void setParameterFlatValue(String sourceId, int value) {
    _parameterFlatIncrease[sourceId] = value;
    _listeners.forEach((element) {
      element(parameter);
    });
  }

  void setParameterPercentValue(String sourceId, double value) {
    _parameterPercentIncrease[sourceId] = value;
    _listeners.forEach((element) {
      element(parameter);
    });
  }

  void removeFlatKey(String sourceId) {
    _parameterFlatIncrease.remove(sourceId);
    _listeners.forEach((element) {
      element(parameter);
    });
  }

  void removePercentKey(String sourceId) {
    _parameterPercentIncrease.remove(sourceId);
    _listeners.forEach((element) {
      element(parameter);
    });
  }

  void removeKey(String sourceId) {
    if (_parameterPercentIncrease.containsKey(sourceId)) {
      removePercentKey(sourceId);
    }
    if (_parameterFlatIncrease.containsKey(sourceId)) {
      removeFlatKey(sourceId);
    }
  }
}

class BoolParameterManager {
  BoolParameterManager({
    required bool baseParameter,
    this.isFoldOfIncreases = true,
  }) : _baseParameter = baseParameter;
  bool _baseParameter;

  bool get baseParameter => _baseParameter;

  set baseParameter(bool value) {
    _baseParameter = value;
    _listeners.forEach((element) {
      element(parameter);
    });
  }

  bool isFoldOfIncreases;
  final Map<String, bool> _parameterIncrease = {};
  bool get parameter {
    if (isFoldOfIncreases) {
      return boolAbilityDecipher();
    } else {
      return _parameterIncrease.values.contains(true) || baseParameter;
    }
  }

  final List<Function(bool parameter)> _listeners = [];
  void addListener(Function(bool parameter) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(bool parameter) listener) {
    _listeners.remove(listener);
  }

  void setIncrease(String sourceId, bool increase) {
    _parameterIncrease[sourceId] = increase;
    _listeners.forEach((element) {
      element(parameter);
    });
  }

  void removeIncrease(String sourceId) {
    _parameterIncrease.remove(sourceId);
    _listeners.forEach((element) {
      element(parameter);
    });
  }

  bool boolAbilityDecipher() {
    if (_parameterIncrease.isEmpty) {
      return baseParameter;
    }
    return [baseParameter, ..._parameterIncrease.values].fold<int>(
          0,
          (previousValue, element) => previousValue + (element ? 1 : -1),
        ) >=
        0;
  }

  void removeKey(String sourceId) {
    _parameterIncrease.remove(sourceId);
  }
}

class DamageParameterManager {
  DamageParameterManager({required this.damageBase});
  Random rng = Random();
  Map<DamageType, (double, double)> damageBase;

  ///Min damage is added to min damage calculation, same with max
  final Map<String, Map<DamageType, (double, double)>> _damageFlatIncrease = {};

  ///Min damage is added to min damage calculation, same with max
  final Map<String, Map<DamageType, (double, double)>> _damagePercentIncrease =
      {};

  void setDamagePercentIncrease(
    String sourceId,
    DamageType damageType,
    double min,
    double max,
  ) {
    _damagePercentIncrease[sourceId] = {damageType: (min, max)};
  }

  void setDamageFlatIncrease(
    String sourceId,
    DamageType damageType,
    double min,
    double max,
  ) {
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
    final returnMap = <DamageType, (double, double)>{};

    for (final stringElement in _damageFlatIncrease.entries) {
      final tempMap = stringElement.value;
      for (final element in tempMap.entries) {
        returnMap[element.key] = (
          (returnMap[element.key]?.$1 ?? 0) + (element.value.$1),
          (returnMap[element.key]?.$2 ?? 0) + (element.value.$2)
        );
      }
    }
    return returnMap;
  }

  Map<DamageType, (double, double)> get damagePercentIncrease {
    final returnMap = <DamageType, (double, double)>{};

    for (final stringElement in _damagePercentIncrease.entries) {
      final tempMap = stringElement.value;
      for (final element in tempMap.entries) {
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
    String sourceId,
    StatusEffects statusEffect,
    double increase,
  ) {
    _statusEffectPercentIncrease[sourceId] = {statusEffect: increase};
  }

  void increaseAllPercent(String sourceId, double increase) {
    _statusEffectPercentIncrease[sourceId] = {};
    for (final element in StatusEffects.values) {
      _statusEffectPercentIncrease[sourceId]?[element] = increase;
    }
  }

  Map<StatusEffects, double> get statusEffectPercentIncrease {
    final returnMap = <StatusEffects, double>{};

    for (final stringElement in _statusEffectPercentIncrease.entries) {
      final tempMap = stringElement.value;
      for (final element in tempMap.entries) {
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
    String sourceId,
    Map<DamageType, double> damageMap,
  ) {
    _damagePercentIncrease[sourceId] = {
      if (_damagePercentIncrease[sourceId] != null)
        ..._damagePercentIncrease[sourceId]!,
      ...damageMap,
    };
  }

  Map<DamageType, double> get damagePercentIncrease {
    final returnMap = <DamageType, double>{};

    for (final stringElement in _damagePercentIncrease.entries) {
      final tempMap = stringElement.value;
      for (final element in tempMap.entries) {
        returnMap[element.key] = (returnMap[element.key] ?? 1) + element.value;
      }
    }
    return returnMap;
  }

  void removePercentKey(String sourceId) {
    _damagePercentIncrease.remove(sourceId);
  }
}

///[sourceAttack] represents the source object that did the damage
///examples are
///[Entity] for status effects and touch damage
///[MeleeAttackHitbox] for melee attacks
///[Projectile] for projectiles
DamageInstance damageCalculations(
  Entity source,
  HealthFunctionality victim,
  Map<DamageType, (double, double)> damageBase, {
  required dynamic sourceAttack,
  DamageParameterManager? damageSource,
  Weapon? sourceWeapon,
  bool forceCrit = false,
  DamageKind damageKind = DamageKind.regular,
  StatusEffects? statusEffect,
}) {
  final returnMap = <DamageType, double>{};
  damageBase = {...damageBase, ...source.flatDamageIncrease.damageFlatIncrease};

  for (final element in source.flatDamageIncrease.damageFlatIncrease.entries) {
    damageBase.update(
      element.key,
      (value) => (value.$1 + element.value.$1, value.$2 + element.value.$2),
      ifAbsent: () => element.value,
    );
  }

  for (final element in damageBase.entries) {
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

    final percentIncreaseValue = source.damageTypeDamagePercentIncrease
            .damagePercentIncrease[element.key] ??
        1;

    returnMap[element.key] =
        ((rng.nextDouble() * (max - min)) + min) * percentIncreaseValue;
  }

  final returnInstance = DamageInstance(
    source: source,
    damageMap: returnMap,
    sourceAttack: sourceAttack,
    victim: victim,
    sourceWeapon: sourceWeapon,
  );

  var weaponTypeIncrease = 1.0;

  if (sourceWeapon != null) {
    switch (sourceWeapon.weaponType.attackType) {
      case AttackType.melee:
        weaponTypeIncrease = source.meleeDamagePercentIncrease.parameter;

        break;
      case AttackType.guns:
        weaponTypeIncrease = source.projectileDamagePercentIncrease.parameter;

        break;
      case AttackType.magic:
        weaponTypeIncrease = source.spellDamagePercentIncrease.parameter;

        break;
    }
  }

  var statusEffectIncrease = 1.0;
  if (statusEffect != null) {
    statusEffectIncrease = source.statusEffectsPercentIncrease
        .statusEffectPercentIncrease[statusEffect] ??= 1;
  }

  var damageKindIncrease = 1.0;
  switch (damageKind) {
    case DamageKind.area:
      damageKindIncrease = source.areaDamagePercentIncrease.parameter;
      break;
    case DamageKind.dot:
      damageKindIncrease = source.tickDamageIncrease.parameter;
    default:
  }

  final totalDamageIncrease = source.damagePercentIncrease.parameter;

  returnInstance.increaseByPercent(
    totalDamageIncrease *
        weaponTypeIncrease *
        statusEffectIncrease *
        damageKindIncrease,
  );

  returnInstance.checkCrit(forceCrit);

  return returnInstance;
}
