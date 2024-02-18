import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/functions.dart';

class HealingFont extends AreaEffect with UpgradeFunctions {
  HealingFont({
    required this.upgradeLevel,
    required super.position,
    required GameEnviroment gameEnviroment,
  }) : super(
          sourceEntity: gameEnviroment.god!,
          radius: 4,
          duration: 5,
          durationType: DurationType.permanent,
          collisionDelay: 1,
          tickRate: 1,
          isSolid: false,
        );
  double healingDone = 0;
  @override
  int upgradeLevel;

  late final double healingAmount = increasePercentOfBase(
    5,
    customUpgradeFactor: .5,
    includeBase: true,
  ).toDouble();

  late final double maxHealingAmount = increasePercentOfBase(
    100,
    customUpgradeFactor: .5,
    includeBase: true,
  ).toDouble();

  @override
  Future<void> onLoad() {
    onTick = (entity, areaId) {
      if (entity is HealthFunctionality) {
        entity.heal(healingAmount);
      }
      if (entity.isPlayer) {
        healingDone += healingAmount;
        if (healingAmount > maxHealingAmount) {
          killArea();
        }
      }
    };
    return super.onLoad();
  }
}

class VineTrap extends AreaEffect with UpgradeFunctions {
  VineTrap({
    required this.upgradeLevel,
    required super.position,
    required GameEnviroment gameEnviroment,
  }) : super(
          sourceEntity: gameEnviroment.god!,
          radius: 6,
          duration: 5,
          durationType: DurationType.permanent,
          collisionDelay: 1,
          tickRate: 1,
          isSolid: false,
        );
  double slowingDone = 0;
  @override
  int upgradeLevel;

  late final double slowAmount = increasePercentOfBase(
    -.125,
    customUpgradeFactor: .1,
    includeBase: true,
  ).toDouble();

  final double maxSlowDegree = -.75;

  late final double maxSlowAmount = increasePercentOfBase(
    -10,
    customUpgradeFactor: .5,
    includeBase: true,
  ).toDouble();

  @override
  void onExit(Entity other) {
    currentSlowAmounts.remove(other);
    if (other is MovementFunctionality) {
      other.speed.removeKey(areaId);
    }
  }

  Map<Entity, double> currentSlowAmounts = {};

  @override
  Future<void> onLoad() {
    onTick = (entity, areaId) {
      if (entity is MovementFunctionality) {
        currentSlowAmounts[entity] =
            ((currentSlowAmounts[entity] ?? 0) + slowAmount)
                .clamp(maxSlowDegree, 0);
        entity.speed
            .setParameterPercentValue(areaId, currentSlowAmounts[entity]!);
      }
      slowingDone += slowAmount;

      if (slowingDone < maxSlowAmount) {
        killArea();
      }
    };
    return super.onLoad();
  }
}

class MushroomSpores extends AreaEffect with UpgradeFunctions {
  MushroomSpores({
    required this.upgradeLevel,
    required super.position,
    required GameEnviroment gameEnviroment,
  }) : super(
          sourceEntity: gameEnviroment.god!,
          radius: 1.5,
          duration: 5,
          durationType: DurationType.permanent,
          collisionDelay: 1,
          tickRate: 1,
          isSolid: false,
        );
  @override
  int upgradeLevel;

  @override
  void onExit(Entity other) {
    currentSlowAmounts.remove(other);
    if (other is MovementFunctionality) {
      other.speed.removeKey(areaId);
    }
  }

  Map<Entity, double> currentSlowAmounts = {};

  @override
  Future<void> onLoad() {
    onTick = (entity, areaId) {
      if (entity is Player) {
        entity.hitCheck(
          areaId,
          damageCalculations(
            sourceEntity,
            entity,
            {
              DamageType.magic: (
                increasePercentOfBase(
                  5,
                  customUpgradeFactor: .5,
                  includeBase: true,
                ).toDouble(),
                increasePercentOfBase(
                  10,
                  customUpgradeFactor: .5,
                  includeBase: true,
                ).toDouble(),
              ),
            },
            sourceAttack: this,
            damageKind: DamageKind.area,
          ),
        );

        killArea();
      }
    };
    return super.onLoad();
  }
}
