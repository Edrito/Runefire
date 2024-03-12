import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/attributes/attributes_structure.dart';
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
import 'package:runefire/resources/visuals.dart';

class HealingFont extends AreaEffect with UpgradeFunctions {
  HealingFont({
    required this.upgradeLevel,
    required super.position,
    required GameEnviroment gameEnviroment,
  }) : super(
          sourceEntity: gameEnviroment.god!,
          radius: 3,
          duration: 5,
          durationType: DurationType.permanent,
          collisionDelay: 1,
          tickRate: 1,
          isSolid: false,
          customColor: DefaultAreaEffectColor.green,
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

enum DefaultAreaEffectColor { brown, blue, green, red, spore }

class VineTrap extends AreaEffect with UpgradeFunctions {
  VineTrap({
    required this.upgradeLevel,
    required super.position,
    required GameEnviroment gameEnviroment,
  }) : super(
          sourceEntity: gameEnviroment.god!,
          radius: 4,
          duration: 5,
          durationType: DurationType.permanent,
          collisionDelay: 1,
          tickRate: 2,
          isSolid: false,
          customColor: DefaultAreaEffectColor.brown,
        );
  int slowingDone = 0;
  @override
  int upgradeLevel;

  @override
  void onExit(Entity other) {
    currentSlowAmounts.remove(other);
    if (other is MovementFunctionality) {
      other.speed.removeKey(areaId);
    }
  }

  final maxSlowAmount = 100;

  Map<Entity, double> currentSlowAmounts = {};

  @override
  Future<void> onLoad() {
    onTick = (entity, areaId) {
      if (entity is AttributeFunctionality) {
        entity.addAttribute(
          AttributeType.slow,
          perpetratorEntity: entity.gameEnviroment.god,
          isTemporary: true,
        );
        slowingDone++;
      }

      if (slowingDone > maxSlowAmount) {
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
          radius: 1,
          duration: 5,
          durationType: DurationType.permanent,
          collisionDelay: 1,
          customColor: DefaultAreaEffectColor.spore,
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
  Future<void> onLoad() async {
    onTick = (entity, areaId) {
      if (entity is Player) {
        entity.hitCheck(
          areaId,
          damageCalculations(
            sourceEntity,
            entity,
            {
              DamageType.fire: (
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
    await super.onLoad();
  }
}
