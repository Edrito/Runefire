import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forge2d/src/dynamics/contacts/contact.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/enviroment_interactables/expendables.dart';
import 'package:runefire/main.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import '../resources/enums.dart';
import '../entities/child_entities.dart';
import '../weapons/weapon_class.dart';
import 'attributes_structure.dart';
import '../resources/visuals.dart';

mixin AttributeFunctionality on Entity {
  Map<AttributeType, Attribute> currentAttributes = {};

  Random rng = Random();

  void loadPlayerConfig(Map<String, dynamic> config) {}
  bool initalized = false;

  ///Initial Attribtes and their initial level
  ///i.e. Max Speed : Level 3
  void initAttributes(Map<AttributeType, int> attributesToAdd) {
    if (initalized) return;
    List<AttributeType> attributeTypes = attributesToAdd.keys.toList();
    attributeTypes.sort((a, b) => a.priority.compareTo(b.priority));
    for (var element in attributeTypes) {
      currentAttributes[element] = element.buildAttribute(
          attributesToAdd[element]!, this,
          perpetratorEntity: this)
        ..applyUpgrade();
    }

    initalized = true;
  }

  void addAttribute(
    AttributeType attribute, {
    int? level,
    bool applyUpgrade = true,
    Entity? perpetratorEntity,
    DamageType? damageType,
    bool isTemporary = false,
    double? duration,
  }) {
    if (currentAttributes.containsKey(attribute)) {
      currentAttributes[attribute]?.incrementLevel(level ?? 1);
    } else {
      currentAttributes[attribute] = attribute.buildAttribute(
        level ?? 1,
        this,
        perpetratorEntity: perpetratorEntity,
        damageType: damageType,
        duration: duration,
        isTemporary: isTemporary,
      );
      if (applyUpgrade) {
        currentAttributes[attribute]?.applyUpgrade();
      }
    }
  }

  void clearAttributes() {
    for (var element in currentAttributes.entries) {
      element.value.removeUpgrade();
    }
    currentAttributes.clear();
    initalized = false;
  }

  void removeAttribute(AttributeType attributeType) {
    currentAttributes[attributeType]?.removeUpgrade();
    currentAttributes.remove(attributeType);
  }

  void remapAttributes() {
    List<Attribute> tempList = [];
    for (var element in currentAttributes.values) {
      if (element.upgradeApplied) {
        element.unMapUpgrade();
        tempList.add(element);
      }
    }

    tempList.sort(
        (a, b) => a.attributeType.priority.compareTo(b.attributeType.priority));

    for (var element in tempList) {
      element.mapUpgrade();
    }
  }

  void modifyLevel(AttributeType attributeEnum, [int amount = 0]) {
    if (currentAttributes.containsKey(attributeEnum)) {
      var attr = currentAttributes[attributeEnum]!;
      attr.changeLevel(amount);
    }
  }

  List<Attribute> buildAttributeSelection(Player player) {
    List<Attribute> returnList = [];

    int attempts = 0;

    while (returnList.length < 3 && attempts < 1000) {
      attempts++;

      final potentialCandidates = AttributeType.values
          .where((element) =>
              element.territory == AttributeTerritory.game &&
              player.currentAttributes[element]?.isMaxLevel != true &&
              !returnList
                  .any((elementD) => elementD.attributeType == element) &&
              element.attributeEligibilityTest(player))
          .toList();

      Map<AttributeRarity, double> weightings = {};
      Map<AttributeRarity, int> rarityAmounts = {
        for (var e in potentialCandidates)
          e.rarity: potentialCandidates
              .where((element) => element.rarity == e.rarity)
              .length
      };

      for (var element in rarityAmounts.entries) {
        weightings[element.key] = (element.value / potentialCandidates.length) *
            element.key.weighting;
      }

      final totalWeighting =
          weightings.values.reduce((value, element) => value + element);
      final increase = 1 / totalWeighting;
      for (var element in weightings.entries) {
        weightings[element.key] = element.value * increase;
      }

      final weightList = weightings.values.toList();
      weightList.sort();

      final random = rng.nextDouble();
      AttributeRarity rarity = AttributeRarity.standard;
      for (var element in weightList) {
        if (random < element) {
          rarity =
              weightings.keys.firstWhere((key) => weightings[key] == element);
          break;
        }
      }

      final tempPotentialCandidates =
          potentialCandidates.where((element) => element.rarity == rarity);

      if (tempPotentialCandidates.isEmpty) continue;

      final attr = tempPotentialCandidates
          .elementAt(rng.nextInt(tempPotentialCandidates.length));

      if (currentAttributes.containsKey(attr)) {
        returnList.add(currentAttributes[attr]!);
      } else {
        returnList.add(attr.buildAttribute(0, this));
      }
    }

    return returnList;
  }

  Attribute buildXpAttribute() {
    const attr = AttributeType.experienceGainPermanent;
    late Attribute returnAttrib;
    if (currentAttributes.containsKey(attr)) {
      returnAttrib = (currentAttributes[attr]!);
    } else {
      returnAttrib = (attr.buildAttribute(0, this));
    }

    return returnAttrib;
  }
}

mixin AttributeFunctionsFunctionality on Entity, ContactCallbacks {
  @override
  void update(double dt) {
    for (var element in [...onUpdate]) {
      element(dt);
    }
    processHeadEntities(_headEntities, .5, dt);
    processBodyEntities(_bodyComponents, height.parameter * 1.3, dt);
    super.update(dt);
  }

  final List<Function> dashBeginFunctions = [];
  final List<Function> dashOngoingFunctions = [];
  final List<Function> dashEndFunctions = [];
  final List<ChildEntity> _headEntities = [];

  int get numHeadEntities => _headEntities.length;

  final List<ChildEntity> _bodyComponents = [];

  PositionComponent? headEntityWrapper;
  double speedHead = .5;
  double previousHeadAngle = 0;

  PositionComponent? bodyEntityWrapper;
  double speedBody = .25;
  Map<double, double> previousBodyAngle = {1: 0};

  void processBodyEntities(
      List<ChildEntity> bodyEntities, double distance, double dt) {
    if (bodyEntities.isEmpty) return; // Avoid division by zero

    Vector2 offsetPosition = bodyEntityWrapper!.absolutePosition + center;
    Set<double> distanceSteps = bodyEntities.fold<Set<double>>(
        {}, (previousValue, element) => {...previousValue, element.distance});

    for (var distanceStep in distanceSteps) {
      List<ChildEntity> tempBodies = bodyEntities
          .where((element) => element.distance == distanceStep)
          .toList();

      int numEntities = tempBodies.length;
      double angleStep = 2 * pi / numEntities;
      double currentAngle = (previousBodyAngle[distanceStep] ?? 0) +
          (dt * (tempBodies.first.rotationSpeed ?? speedBody));

      for (int i = 0; i < numEntities; i++) {
        final body = tempBodies[i];

        double x = distance * cos(currentAngle);
        double y = distance * sin(currentAngle);
        if (body.isLoaded) {
          body.setTransform((Vector2(x, y) * distanceStep) + offsetPosition, 0);
        }
        currentAngle += angleStep;
      }
      previousBodyAngle[distanceStep] = currentAngle;
    }
  }

  void removeBodyEntity(String entityId) {
    final index =
        _bodyComponents.indexWhere((element) => element.entityId == entityId);
    if (index == -1) return;
    final entityToRemove = _bodyComponents[index];
    entityToRemove.removeFromParent();
    _bodyComponents.removeAt(index);
  }

  void addBodyEntity(ChildEntity entity) {
    bodyEntityWrapper ??= PositionComponent()..addToParent(this);

    _bodyComponents.add(entity);
    if (entity.parent == null) enviroment.addPhysicsComponent([entity]);
  }

  void processHeadEntities(
      List<ChildEntity> entities, double distance, double dt) {
    if (entities.isEmpty) return; // Avoid division by zero

    int numEntities = entities.length;
    double angleStep = 2 * pi / numEntities;
    double currentAngle = previousHeadAngle += dt * speedHead;
    Vector2 offsetPosition = headEntityWrapper!.absolutePosition + center;

    for (int i = 0; i < numEntities; i++) {
      if (numEntities != 1) {
        double x = distance * cos(currentAngle);
        double y = distance * sin(currentAngle);
        if (entities[i].isLoaded) {
          entities[i].setTransform(Vector2(x * 2, y * .75) + offsetPosition, 0);
        }
        currentAngle += angleStep;
      } else {
        if (entities[i].isLoaded) {
          entities[i].setTransform(Vector2.zero() + offsetPosition, 0);
        }
      }
    }

    previousHeadAngle = currentAngle;
  }

  void removeAllHeadEntities() {
    for (var element in _headEntities) {
      element.removeFromParent();
    }
    _headEntities.clear();
  }

  void removeHeadEntity(String entityId) {
    final index =
        _headEntities.indexWhere((element) => element.entityId == entityId);
    if (index == -1) return;
    final entityToRemove = _headEntities[index];
    entityToRemove.removeFromParent();
    _headEntities.removeAt(index);
  }

  void addHeadEntity(ChildEntity entity) {
    headEntityWrapper ??= PositionComponent(
      position: Vector2(0, height.parameter * -2),
    )..addToParent(this);

    _headEntities.add(entity);
    if (entity.parent == null) enviroment.addPhysicsComponent([entity]);
  }

  final List<Function> _pulseFunctions = [];
  TimerComponent? pulseTimer;

  DoubleParameterManager pulsePeriod =
      DoubleParameterManager(baseParameter: 3, minParameter: 0.5);
  bool finishPulseTimer = false;

  void _checkFinishTimer() {
    if (finishPulseTimer) {
      pulseTimer?.removeFromParent();
      pulseTimer = null;
      finishPulseTimer = false;
    }
  }

  void addPulseFunction(Function function) {
    pulseTimer ??= TimerComponent(
        period: pulsePeriod.parameter,
        repeat: true,
        onTick: () async {
          _checkFinishTimer();
          for (var element in _pulseFunctions) {
            await Future.delayed(.1.seconds).then((_) {
              element();
            });
            _checkFinishTimer();
            pulseTimer?.timer.reset();
          }
        })
      ..addToParent(this);
    _pulseFunctions.add(function);
    finishPulseTimer = false;
  }

  void removePulseFunction(Function function) {
    _pulseFunctions.remove(function);
    if (_pulseFunctions.isEmpty) {
      finishPulseTimer = true;
    }
  }

  final List<Function> jumpBeginFunctions = [];
  final List<Function> jumpOngoingFunctions = [];
  final List<Function> jumpEndFunctions = [];

  final List<OnHitDef> onHitByProjectile = [];
  // final List<OnHitProjectileDef> onHitByMelee = [];
  final List<OnHitDef> onHitByOtherEntity = [];

  final List<OnHitDef> onHitOtherEntity = [];
  final List<OnHitDef> onDamageOtherEntity = [];
  final List<Function(DamageInstance instance)> onKillOtherEntity = [];
  final List<Function(DamageInstance instance)> onHeal = [];
  final List<Function(double stamina)> onStaminaModified = [];

  final List<Function(Expendable item)> onItemPickup = [];
  final List<Function(Expendable item)> onExpendableUsed = [];
  final List<Function> onLevelUp = [];

  final List<Function> onMove = [];
  final List<Function(DamageInstance deathInstance)> onDeath = [];
  final List<Function(Weapon weapon)> onAttack = [];
  final List<Function(ReloadFunctionality weapon)> onReloadComplete = [];
  final List<Function(ReloadFunctionality weapon)> onReload = [];
  final List<Function(DamageInstance instance)> onDodge = [];
  final List<Function(HealthFunctionality other)> onTouch = [];

  final List<Function(double dt)> onUpdate = [];

  @override
  void beginContact(Object other, Contact contact) {
    if (other is HealthFunctionality) {
      touchFunctions(other);
    }
    super.beginContact(other, contact);
  }

  void touchFunctions(HealthFunctionality other) {
    for (var element in onTouch) {
      element(other);
    }
  }

  bool onDamageOtherEntityFunctions(DamageInstance damage) {
    bool returnVal = false;
    for (var element in onDamageOtherEntity) {
      returnVal = element(damage) || returnVal;
    }
    return returnVal;
  }

  void onHitFunctions(DamageInstance damage) {
    for (var element in onHitOtherEntity) {
      element(damage);
    }
  }
}

class StatusEffect extends PositionComponent {
  StatusEffect(this.effect, this.level);

  final StatusEffects effect;
  final int level;
  final double spriteSize = .7;

  late SpriteAnimationComponent spriteAnimationComponent;

  @override
  FutureOr<void> onLoad() async {
    size = Vector2.all(spriteSize);
    anchor = Anchor.center;

    spriteAnimationComponent = SpriteAnimationComponent(
        animation: await getEffectSprite(effect),
        size: size,
        anchor: Anchor.center);

    spriteAnimationComponent.size = size * ((level.toDouble() / 30) + 1);
    add(spriteAnimationComponent);
    return super.onLoad();
  }
}

// class HoldDuration extends PositionComponent {
//   HoldDuration(this.duration);

//   final double duration;
//   final double spriteSize = .25;

//   double get percentComplete => (durationProgressed / duration).clamp(0, 1);

//   double durationProgressed = 0;

//   @override
//   FutureOr<void> onLoad() async {
//     // size = Vector2.all(spriteSize);
//     // anchor = Anchor.center;

//     return super.onLoad();
//   }

//   @override
//   void update(double dt) {
//     durationProgressed += dt;
//     super.update(dt);
//   }

//   @override
//   void render(Canvas canvas) {
//     // canvas.drawCircle(Offset.zero, spriteSize, BasicPalette.white.paint());
//     canvas.drawCircle(
//         Offset.zero,
//         spriteSize,
//         Paint()
//           ..shader = ui.Gradient.sweep(
//               Offset.zero,
//               [
//                 percentComplete == 1
//                     ? ApolloColorPalette().secondaryColor
//                     : ApolloColorPalette().primaryColor,
//                 Colors.transparent
//               ],
//               [percentComplete, percentComplete],

//               // null,
//               TileMode.clamp,
//               0,
//               pi * 2 * percentComplete));
//     super.render(canvas);
//   }
// }

class EntityStatusEffectsWrapper {
  EntityStatusEffectsWrapper({required this.entity});
  Entity entity;
  late double width = entity.entityAnimationsGroup.width * 1.5;

  ///ID, Effect
  Map<StatusEffects, StatusEffect> activeStatusEffects = {};

  ///ID, Animation
  Map<String, ReloadAnimation> reloadAnimations = {};

  SpriteAnimationComponent? markerAnimation;

  bool removedAnimations = false;

  void removeAllAnimations() {
    removedAnimations = true;
    for (var element in activeStatusEffects.values) {
      element.removeFromParent();
    }
    activeStatusEffects.clear();

    for (var element in reloadAnimations.values) {
      element.removeFromParent();
    }
    reloadAnimations.clear();
    removeMarked();
    // holdDuration?.removeFromParent();
    // holdDuration = null;
  }

  void removeMarked() {
    markerAnimation?.removeFromParent();
    markerAnimation = null;
  }

  double getXPosition(StatusEffects effect) {
    return (((effect.index) / StatusEffects.values.length) * (width)) -
        width / 2;
  }

  // void addHoldDuration(double duration) {
  //   if (removedAnimations) return;
  //   holdDuration?.removeFromParent();
  //   holdDuration = HoldDuration(duration);
  //   holdDuration!.position.y = -.5;
  //   holdDuration!.position.x = width / 2;
  //   add(holdDuration!);
  // }

  // void removeHoldDuration() {
  //   holdDuration?.removeFromParent();
  //   holdDuration = null;
  // }

  void addMarkedStatus() async {
    if (removedAnimations) return;
    markerAnimation = SpriteAnimationComponent(
        animation: await getEffectSprite(StatusEffects.marked),
        size: Vector2.all(16) * entity.height.parameter.toDouble(),
        anchor: Anchor.center);

    // markerAnimation!.position.y = -entity.height.parameter * .75;
    // markerAnimation!.position.x = width / -2;
    entity.add(markerAnimation!);
  }

  void addStatusEffect(StatusEffects effect, int level) {
    if (removedAnimations) return;
    activeStatusEffects[effect]?.removeFromParent();

    activeStatusEffects[effect] = (StatusEffect(effect, level));
    final posX = getXPosition(effect);
    activeStatusEffects[effect]!.position.x = posX;
    activeStatusEffects[effect]!.position.y = -.2 - (entity.entityHeight);
    activeStatusEffects[effect]?.addToParent(entity);
  }

  void removeStatusEffect(StatusEffects statusEffects) {
    activeStatusEffects[statusEffects]?.removeFromParent();
    activeStatusEffects.remove(statusEffects);
  }

  void addReloadAnimation(
      String sourceId, double duration, TimerComponent timer,
      [bool isSecondary = false]) {
    if (removedAnimations) return;
    String key = generateKey(sourceId, isSecondary);

    final entry = reloadAnimations[key];

    if (entry != null) {
      removeReloadAnimation(sourceId, isSecondary);
    }

    reloadAnimations[key] = ReloadAnimation(duration, isSecondary, timer)
      ..addToParent(entity);
  }

  String generateKey(String sourceId, bool isSecondary) =>
      "${sourceId}_$isSecondary";

  void removeReloadAnimation(String sourceId, bool isSecondary) {
    String key = generateKey(sourceId, isSecondary);
    reloadAnimations[key]?.removeFromParent();
    reloadAnimations.remove(key);
  }

  void hideReloadAnimations(String sourceId) {
    for (bool isSecondary in [true, false]) {
      final key = generateKey(sourceId, isSecondary);
      reloadAnimations[key]?.toggleOpacity(true);
    }
  }

  void showReloadAnimations(String sourceId) {
    if (removedAnimations) return;
    for (bool isSecondary in [true, false]) {
      final key = generateKey(sourceId, isSecondary);
      reloadAnimations[key]?.toggleOpacity(false);
    }
  }

  void removeAllReloads() {
    for (var element in reloadAnimations.entries) {
      element.value.removeFromParent();
    }
    reloadAnimations.clear();
  }
}

class ReloadAnimation extends PositionComponent {
  ReloadAnimation(this.duration, this.isSecondaryWeapon, this.timer);
  late final TimerComponent timer;
  double duration;
  bool isSecondaryWeapon;
  @override
  final height = .06;
  final barWidth = .05;
  final sidePadding = .04;
  bool isOpaque = false;
  void toggleOpacity([bool? value]) =>
      value != null ? isOpaque = value : isOpaque = !isOpaque;

  Color get color => isSecondaryWeapon
      ? colorPalette.secondaryColor
      : colorPalette.primaryColor;

  double get percentReloaded => (timer.timer.current) / duration;

  @override
  render(Canvas canvas) {
    if (!isOpaque) {
      buildProgressBar(
          canvas: canvas,
          percentProgress: percentReloaded,
          color: color,
          size: size,
          heightOfBar: height,
          widthOfBar: barWidth,
          padding: sidePadding,
          peak: 1,
          growth: 0);
    }

    super.render(canvas);
  }

  @override
  FutureOr<void> onLoad() {
    final parent = this.parent as Player;
    // final parentSize = weaponAncestor.entityAncestor!.spriteWrapper.size;
    final width = parent.entityStatusWrapper.width * .7;
    // final x = (parent.entityStatusWrapper.width - width) / 2;
    size.y = height;
    size.x = parent.entityStatusWrapper.width * .7;
    position.y = -parent.entityHeight * .75;
    position.x = width / -2;

    if (isSecondaryWeapon) {
      position.y += -height * 2;
    }

    return super.onLoad();
  }
}