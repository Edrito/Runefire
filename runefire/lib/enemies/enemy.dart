import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:runefire/enemies/enemy_mixin.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/events/event_management.dart';

import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/constants/physics_filter.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/attributes/attributes_mixin.dart';

abstract class Enemy extends Entity
    with
        BaseAttributes,
        // ContactCallbacks,
        UpgradeFunctions,
        AttributeFunctionality,
        AttributeCallbackFunctionality,
        HealthFunctionality,
        DropItemFunctionality {
  Enemy({
    required super.initialPosition,
    required super.enviroment,
    required super.eventManagement,
    required int upgradeLevel,
  }) {
    this.upgradeLevel = upgradeLevel;

    priority = entityPriority;

    applyUpgrade();
  }

  @override
  int? maxLevel;

  abstract EnemyType enemyType;

  final double maxDistanceFromPlayer = 25;

  @override
  Filter? filter = Filter()
    ..categoryBits = enemyCategory
    ..maskBits = projectileCategory +
        playerCategory +
        enemyCategory +
        areaEffectCategory +
        sensorCategory +
        swordCategory;
  // @override
  // Filter? filter = Filter()
  //   ..categoryBits = enemyCategory
  //   ..maskBits = projectileCategory + enemyCategory;
  TimerComponent? shooter;
  double shotFreq = 1;

  @override
  EntityType entityType = EntityType.enemy;
}
