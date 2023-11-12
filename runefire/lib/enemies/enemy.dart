import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:runefire/enemies/enemy_mixin.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/events/event_management.dart';

import '../resources/functions/custom.dart';
import '../resources/constants/physics_filter.dart';
import '../resources/enums.dart';
import '../resources/constants/priorities.dart';
import '../attributes/attributes_mixin.dart';

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

    priority = enemyPriority;

    applyUpgrade();
  }

  @override
  int? maxLevel;

  abstract EnemyType enemyType;

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
