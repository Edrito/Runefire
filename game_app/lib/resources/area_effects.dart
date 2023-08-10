import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/constants/physics_filter.dart';
import 'package:game_app/resources/functions/custom_mixins.dart';
import 'package:uuid/uuid.dart';

import '../entities/entity_class.dart';
import '../main.dart';
import 'data_classes/base.dart';

enum DurationType { instant, temporary, permanent }

class AreaEffect extends BodyComponent<GameRouter>
    with ContactCallbacks, BasicSpriteLifecycle {
  ///Use [damage] if you want to deal damage to entities in the area
  ///Declare a custom area if you are making multiple areas and want
  ///to prevent enemies getting super spammed with deeps
  AreaEffect({
    this.spawnAnimation,
    this.playAnimation,
    this.endAnimation,
    this.durationType = DurationType.instant,
    this.duration = 5,
    String? areaId,
    this.tickRate = 1,
    this.size = 3,
    this.damage,
    this.onTick,
    required this.position,
    required this.sourceEntity,
    this.isSolid = false,
    this.randomlyFlipped = false,
  }) {
    assert(onTick != null || damage != null);

    size *= sourceEntity.areaSizePercentIncrease.parameter;
    duration *= sourceEntity.durationPercentIncrease.parameter;

    this.areaId = areaId ?? const Uuid().v4();
  }
  Map<DamageType, (double, double)>? damage;

  @override
  bool randomlyFlipped;
  @override
  SpriteAnimation? spawnAnimation;
  @override
  SpriteAnimation? playAnimation;
  @override
  SpriteAnimation? endAnimation;

  @override
  DurationType durationType;

  @override
  double size;

  double duration;
  late String areaId;
  double tickRate;
  Function(Entity entity, String areaId)? onTick;
  Vector2 position;
  Entity sourceEntity;
  bool isSolid;
  late TimerComponent aliveTimer;

  late CircleComponent circleComponent;

  Map<Entity, TimerComponent> affectedEntities = {};
  bool isKilled = false;

  @override
  Future<void> onLoad() {
    if (durationType == DurationType.temporary) {
      aliveTimer = TimerComponent(
        period: duration,
        removeOnFinish: true,
        repeat: false,
        onTick: () {
          killArea();
        },
      )..addToParent(this);
    }

    if (playAnimation == null) {
      circleComponent = CircleComponent(
          radius: size,
          anchor: Anchor.center,
          paint: BasicPalette.red.withAlpha(100).paint());
      add(circleComponent);
    }

    return super.onLoad();
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! Entity) return;
    if (other == sourceEntity) return;
    if (affectedEntities.containsKey(other)) return;
    if (durationType == DurationType.instant) {
      doOnTick(other);
    } else {
      affectedEntities[other] = TimerComponent(
          period: tickRate,
          repeat: true,
          onTick: () {
            doOnTick(other);
          })
        ..addToParent(this)
        ..onTick();
    }

    super.beginContact(other, contact);
  }

  bool aliveForOneTick = false;

  void doOnTick(Entity entity) {
    if (isKilled) return;
    if (damage != null && entity is HealthFunctionality) {
      entity.takeDamage(areaId,
          damageCalculations(entity, damage!, damageKind: DamageKind.area));
    }
    onTick?.call(entity, areaId);
  }

  void instantChecker() {
    if (!isKilled && durationType == DurationType.instant && body.isActive) {
      if (aliveForOneTick) {
        killArea();
      }
      aliveForOneTick = true;
    }
  }

  @override
  void update(double dt) {
    instantChecker();
    super.update(dt);
  }

  void killArea() {
    isKilled = true;
    affectedEntities.clear();
    killSprite();
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is! Entity) return;
    if (durationType == DurationType.instant) return;
    affectedEntities[other]?.removeFromParent();
    affectedEntities.remove(other);

    super.endContact(other, contact);
  }

  @override
  Body createBody() {
    // priority = 0;
    late CircleShape shape;

    shape = CircleShape();
    shape.radius = size * .45;
    renderBody = false;
    final filter = Filter();
    filter.categoryBits = attackCategory;
    if (sourceEntity.isPlayer) {
      filter.maskBits = enemyCategory;
    } else {
      if (sourceEntity.affectsAllEntities) {
        filter.maskBits = 0xFFFF;
      } else {
        filter.maskBits = playerCategory;
      }
    }

    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        isSensor: !isSolid,
        filter: filter);
    final bodyDef = BodyDef(
      position: position,
      allowSleep: false,
      userData: this,
      type: BodyType.static,
      fixedRotation: true,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
