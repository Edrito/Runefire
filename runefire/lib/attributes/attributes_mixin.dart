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
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/weapons/weapon_mixin.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:runefire/resources/enums.dart';
import 'package:runefire/entities/child_entities.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/resources/visuals.dart';

mixin AttributeFunctionality on Entity {
  Map<AttributeType, Attribute> currentAttributes = {};
  bool initalized = false;
  Random rng = Random();

  void addAttribute(
    AttributeType attribute, {
    int? level,
    bool applyUpgrade = true,
    Entity? perpetratorEntity,
    DamageType? damageType,
    bool isTemporary = false,
    double? duration,
  }) {
    //Already has it
    if (currentAttributes.containsKey(attribute)) {
      currentAttributes[attribute]?.incrementLevel(level ?? 1);

      //Doesnt have it
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

  List<Attribute> buildAttributeSelection() {
    if (!isPlayer) {
      return [];
    }

    final player = this as Player;
    final returnList = <Attribute>[];
    var elementalDamageTypeForced = player.shouldForceElementalAttribute();
    var attempts = 0;

    while (returnList.length < 3 && attempts < 1000) {
      attempts++;
      var potentialCandidates = <AttributeType>[
        ...player.attributesToGrabDebug,
      ];
      player.attributesToGrabDebug.clear();
      if (potentialCandidates.isEmpty) {
        potentialCandidates = AttributeType.values
            .where(
              (element) =>
                  //Attribute is game attribute and not permanenet
                  element.territory == AttributeTerritory.game &&
                  //Player is not max level

                  player.currentAttributes[element]?.isMaxLevel != true &&
                  //if forced selection is active, only show those attributes
                  element.attributeMeetsForcedElementalRequest(
                    player,
                    elementalDamageTypeForced,
                  ) &&
                  //we dont already have this attribute
                  !returnList
                      .any((elementD) => elementD.attributeType == element) &&
                  //
                  element.isEligible(player),
            )
            .toList();
      }

      if (elementalDamageTypeForced != null && potentialCandidates.isEmpty) {
        elementalDamageTypeForced = null;
        continue;
      }

      final weightings = <AttributeRarity, double>{};
      final rarityAmounts = <AttributeRarity, int>{
        for (final e in potentialCandidates)
          e.rarity: potentialCandidates
              .where((element) => element.rarity == e.rarity)
              .length,
      };

      for (final element in rarityAmounts.entries) {
        weightings[element.key] = (element.value / potentialCandidates.length) *
            element.key.weighting;
      }

      final totalWeighting =
          weightings.values.reduce((value, element) => value + element);
      final increase = 1 / totalWeighting;
      for (final element in weightings.entries) {
        weightings[element.key] = element.value * increase;
      }

      final weightList = weightings.values.toList();
      weightList.sort();

      final random = rng.nextDouble();
      var rarity = AttributeRarity.standard;
      for (final element in weightList) {
        if (random < element) {
          rarity =
              weightings.keys.firstWhere((key) => weightings[key] == element);
          break;
        }
      }

      final tempPotentialCandidates =
          potentialCandidates.where((element) => element.rarity == rarity);

      if (tempPotentialCandidates.isEmpty) {
        continue;
      }

      final attr = tempPotentialCandidates
          .elementAt(rng.nextInt(tempPotentialCandidates.length));

      if (currentAttributes.containsKey(attr)) {
        returnList.add(currentAttributes[attr]!);
      } else {
        returnList.add(
          attr.buildAttribute(
            0,
            this,
            perpetratorEntity: this,
          ),
        );
      }
    }

    return returnList;
  }

  Attribute buildXpAttribute() {
    const attr = AttributeType.experienceGainPermanent;
    late Attribute returnAttrib;
    if (currentAttributes.containsKey(attr)) {
      returnAttrib = currentAttributes[attr]!;
    } else {
      returnAttrib = attr.buildAttribute(0, this);
    }

    return returnAttrib;
  }

  void clearAttributes() {
    for (final element in currentAttributes.entries) {
      element.value.removeUpgrade();
    }
    currentAttributes.clear();
    initalized = false;
  }

  ///Initial Attribtes and their initial level
  ///i.e. Max Speed : Level 3
  void initAttributes(Map<AttributeType, int> attributesToAdd) {
    if (initalized) {
      return;
    }
    final attributeTypes = attributesToAdd.keys.toList();
    attributeTypes.sort((a, b) => a.priority.compareTo(b.priority));
    for (final element in attributeTypes) {
      currentAttributes[element] = element.buildAttribute(
        attributesToAdd[element]!,
        this,
        perpetratorEntity: this,
      )..applyUpgrade();
    }

    initalized = true;
  }

  void loadPlayerConfig(Map<String, dynamic> config) {}

  void modifyLevel(AttributeType attributeEnum, [int amount = 0]) {
    if (currentAttributes.containsKey(attributeEnum)) {
      final attr = currentAttributes[attributeEnum]!;
      attr.changeLevel(amount);
    }
  }

  void remapAttributes() {
    final tempList = <Attribute>[];
    for (final element in currentAttributes.values) {
      if (element.upgradeApplied) {
        element.unMapUpgrade();
        tempList.add(element);
      }
    }

    tempList.sort(
      (a, b) => a.attributeType.priority.compareTo(b.attributeType.priority),
    );

    for (final element in tempList) {
      element.mapUpgrade();
    }
  }

  void removeAttribute(AttributeType attributeType) {
    currentAttributes[attributeType]?.removeUpgrade();
    currentAttributes.remove(attributeType);
  }
}

mixin AttributeCallbackFunctionality on Entity, ContactCallbacks {
  final List<AttachedToBodyChildEntity> _bodyComponents = [];
  final List<AttachedToBodyChildEntity> _headEntities = [];
  final List<Function> _pulseFunctions = [];

  final List<Function(double stamina)> onStaminaModified = [];
  final List<Function(Expendable item)> onItemPickup = [];
  final List<Function(Expendable item)> onExpendableUsed = [];
  final List<Function(Weapon weapon)> onAttack = [];
  final List<Function(ReloadFunctionality weapon)> onReloadComplete = [];
  final List<Function(ReloadFunctionality weapon)> onReload = [];
  final List<Function(double dt)> onUpdate = [];
  final List<Function()> dashBeginFunctions = [];
  final List<Function()> dashEndFunctions = [];
  final List<Function()> dashOngoingFunctions = [];
  final List<Function()> jumpBeginFunctions = [];
  final List<Function()> jumpEndFunctions = [];
  final List<Function()> jumpOngoingFunctions = [];
  final List<Function()> onLevelUp = [];
  final List<Function()> onMove = [];
  final List<Function(Weapon weapon)> onSpentAttack = [];
  final List<Function(DamageInstance instance)> onDodge = [];
  final List<Function(HealthFunctionality other)> onTouch = [];
  final List<Function(DamageInstance instance)> onHeal = [];
  final List<Function(DamageInstance instance)> onKillOtherEntity = [];
  final List<OnHitDef> onHitByOtherEntity = [];
  final List<OnHitDef> onHitByProjectile = [];
  final List<OnHitDef> onHitOtherEntity = [];

  bool finishPulseTimer = false;
  //Only called when damage is 100% going to be applied
  final List<OnHitDef> onPostDamageOtherEntity = [];

  ///If return true, then damage is cancelled
  final List<OnHitDef> onPreDamageOtherEntity = [];

  Map<double, double> previousBodyAngle = {1: 0};

  double previousHeadAngle = 0;

  DoubleParameterManager pulsePeriod =
      DoubleParameterManager(baseParameter: 3, minParameter: 0.5);

  double speedBody = .25;
  double speedHead = .5;

  PositionComponent? bodyEntityWrapper;
  PositionComponent? headEntityWrapper;
  TimerComponent? pulseTimer;

  int get numHeadEntities => _headEntities.length;

  void addBodyEntity(AttachedToBodyChildEntity entity) {
    bodyEntityWrapper ??= PositionComponent()..addToParent(this);

    _bodyComponents.add(entity);
    if (entity.parent == null) {
      enviroment.addPhysicsComponent([entity]);
    }
  }

  void addHeadEntity(AttachedToBodyChildEntity entity) {
    headEntityWrapper ??= PositionComponent(
      position: Vector2(0, spriteHeight * -2),
    )..addToParent(this);

    _headEntities.add(entity);
    if (entity.parent == null) {
      enviroment.addPhysicsComponent([entity]);
    }
  }

  void addPulseFunction(Function function) {
    pulseTimer ??= TimerComponent(
      period: pulsePeriod.parameter,
      repeat: true,
      onTick: () async {
        _checkFinishTimer();
        for (final element in _pulseFunctions) {
          await Future.delayed(.1.seconds).then((_) {
            element();
          });
          _checkFinishTimer();
          pulseTimer?.timer.reset();
        }
      },
    )..addToParent(this);
    _pulseFunctions.add(function);
    finishPulseTimer = false;
  }

  bool onPreDamageOtherEntityFunctions(DamageInstance damage) {
    var returnVal = false;
    for (final element in onPreDamageOtherEntity) {
      returnVal = element(damage) || returnVal;
    }
    return returnVal;
  }

  void removeAllHeadEntities() {
    for (final element in _headEntities) {
      element.removeFromParent();
    }
    _headEntities.clear();
  }

  void removeBodyEntity(String entityId) {
    final index =
        _bodyComponents.indexWhere((element) => element.entityId == entityId);
    if (index == -1) {
      return;
    }
    final entityToRemove = _bodyComponents[index];
    entityToRemove.removeFromParent();
    _bodyComponents.removeAt(index);
  }

  void removeHeadEntity(String entityId) {
    final index =
        _headEntities.indexWhere((element) => element.entityId == entityId);
    if (index == -1) {
      return;
    }
    final entityToRemove = _headEntities[index];
    entityToRemove.removeFromParent();
    _headEntities.removeAt(index);
  }

  void removePulseFunction(Function function) {
    _pulseFunctions.remove(function);
    if (_pulseFunctions.isEmpty) {
      finishPulseTimer = true;
    }
  }

  void touchFunctions(HealthFunctionality other) {
    for (final element in onTouch) {
      element(other);
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is HealthFunctionality) {
      touchFunctions(other);
    }
    super.beginContact(other, contact);
  }

  @override
  void update(double dt) {
    for (final element in [...onUpdate]) {
      element(dt);
    }
    _processHeadEntities(_headEntities, .5, dt);
    _processBodyEntities(_bodyComponents, spriteHeight * 1.3, dt);
    super.update(dt);
  }

  void _checkFinishTimer() {
    if (finishPulseTimer) {
      pulseTimer?.removeFromParent();
      pulseTimer = null;
      finishPulseTimer = false;
    }
  }

  void _processBodyEntities(
    List<AttachedToBodyChildEntity> bodyEntities,
    double distance,
    double dt,
  ) {
    if (bodyEntities.isEmpty) {
      return; // Avoid division by zero
    }

    final offsetPosition = bodyEntityWrapper!.absolutePosition + center;
    final distanceSteps = bodyEntities.fold<Set<double>>(
      {},
      (previousValue, element) => {...previousValue, element.distance},
    );

    for (final distanceStep in distanceSteps) {
      final tempBodies = bodyEntities
          .where((element) => element.distance == distanceStep)
          .toList();

      final numEntities = tempBodies.length;
      final angleStep = 2 * pi / numEntities;
      var currentAngle = (previousBodyAngle[distanceStep] ?? 0) +
          (dt * (tempBodies.first.rotationSpeed ?? speedBody));

      for (var i = 0; i < numEntities; i++) {
        final body = tempBodies[i];

        final x = distance * cos(currentAngle);
        final y = distance * sin(currentAngle);
        if (body.isLoaded) {
          body.setTransform((Vector2(x, y) * distanceStep) + offsetPosition, 0);
        }
        currentAngle += angleStep;
      }
      previousBodyAngle[distanceStep] = currentAngle;
    }
  }

  void _processHeadEntities(
    List<AttachedToBodyChildEntity> entities,
    double distance,
    double dt,
  ) {
    if (entities.isEmpty) {
      return; // Avoid division by zero
    }

    final numEntities = entities.length;
    final angleStep = 2 * pi / numEntities;
    var currentAngle = previousHeadAngle += dt * speedHead;
    final offsetPosition = headEntityWrapper!.absolutePosition + center;

    for (var i = 0; i < numEntities; i++) {
      if (numEntities != 1) {
        final x = distance * cos(currentAngle);
        final y = distance * sin(currentAngle);
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
      anchor: Anchor.center,
    );

    spriteAnimationComponent.size = size * ((level.toDouble() / 30) + 1);
    add(spriteAnimationComponent);
    return super.onLoad();
  }
}

class EntityStatusEffectsWrapper {
  EntityStatusEffectsWrapper({required this.entity});

  ///ID, Effect
  Map<StatusEffects, StatusEffect> activeStatusEffects = {};

  Entity entity;

  ///ID, Animation
  Map<String, ReloadAnimation> reloadAnimations = {};

  bool removedAnimations = false;
  late double width = entity.entityAnimationsGroup.width * 1.5;

  SpriteAnimationComponent? markerAnimation;

  Future<void> addMarkedStatus() async {
    if (removedAnimations) {
      return;
    }
    final sprite = await getEffectSprite(StatusEffects.marked);
    markerAnimation = SpriteAnimationComponent(
      animation: sprite,
      size: sprite.frames.first.sprite.srcSize..scaledToHeight(entity),
      anchor: Anchor.center,
    );

    entity.add(markerAnimation!);
  }

  void addReloadAnimation(
    String sourceId,
    double duration,
    TimerComponent timer, [
    bool isSecondary = false,
  ]) {
    if (removedAnimations) {
      return;
    }
    final key = generateKey(sourceId, isSecondary);

    final entry = reloadAnimations[key];

    if (entry != null) {
      removeReloadAnimation(sourceId, isSecondary);
    }

    reloadAnimations[key] = ReloadAnimation(duration, isSecondary, timer)
      ..addToParent(entity);
  }

  void addStatusEffect(StatusEffects effect, int level) {
    if (removedAnimations) {
      return;
    }
    activeStatusEffects[effect]?.removeFromParent();

    activeStatusEffects[effect] = StatusEffect(effect, level);
    final posX = getXPosition(effect);
    activeStatusEffects[effect]!.position.x = posX;
    activeStatusEffects[effect]!.position.y = -.2 - (entity.spriteHeight);
    activeStatusEffects[effect]?.addToParent(entity);
  }

  String generateKey(String sourceId, bool isSecondary) =>
      '${sourceId}_$isSecondary';

  double getXPosition(StatusEffects effect) {
    return (((effect.index) / StatusEffects.values.length) * width) - width / 2;
  }

  void hideReloadAnimations(String sourceId) {
    for (final isSecondary in [true, false]) {
      final key = generateKey(sourceId, isSecondary);
      reloadAnimations[key]?.toggleOpacity(true);
    }
  }

  void removeAllAnimations() {
    removedAnimations = true;
    for (final element in activeStatusEffects.values) {
      element.removeFromParent();
    }
    activeStatusEffects.clear();

    for (final element in reloadAnimations.values) {
      element.removeFromParent();
    }
    reloadAnimations.clear();
    removeMarked();
    // holdDuration?.removeFromParent();
    // holdDuration = null;
  }

  void removeAllReloads() {
    for (final element in reloadAnimations.entries) {
      element.value.removeFromParent();
    }
    reloadAnimations.clear();
  }

  void removeMarked() {
    markerAnimation?.removeFromParent();
    markerAnimation = null;
  }

  void removeReloadAnimation(String sourceId, bool isSecondary) {
    final key = generateKey(sourceId, isSecondary);
    reloadAnimations[key]?.removeFromParent();
    reloadAnimations.remove(key);
  }

  void removeStatusEffect(StatusEffects statusEffects) {
    activeStatusEffects[statusEffects]?.removeFromParent();
    activeStatusEffects.remove(statusEffects);
  }

  void showReloadAnimations(String sourceId) {
    if (removedAnimations) {
      return;
    }
    for (final isSecondary in [true, false]) {
      final key = generateKey(sourceId, isSecondary);
      reloadAnimations[key]?.toggleOpacity(false);
    }
  }
}

class ReloadAnimation extends PositionComponent {
  ReloadAnimation(this.duration, this.isSecondaryWeapon, this.timer);

  final barWidth = .05;
  final sidePadding = .04;
  late final TimerComponent timer;

  double duration;
  bool isOpaque = false;
  bool isSecondaryWeapon;

  @override
  final height = .06;

  Color get color => isSecondaryWeapon
      ? colorPalette.secondaryColor
      : colorPalette.primaryColor;

  double get percentReloaded => (timer.timer.current) / duration;

  void toggleOpacity([bool? value]) =>
      value != null ? isOpaque = value : isOpaque = !isOpaque;

  @override
  FutureOr<void> onLoad() {
    final parent = this.parent! as Player;
    // final parentSize = weaponAncestor.entityAncestor!.spriteWrapper.size;
    final width = parent.entityStatusWrapper.width * .7;
    // final x = (parent.entityStatusWrapper.width - width) / 2;
    size.y = height;
    size.x = parent.entityStatusWrapper.width * .7;
    position.y = -parent.spriteHeight * .75;
    position.x = width / -2;

    if (isSecondaryWeapon) {
      position.y += -height * 2;
    }

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
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
        growth: 0,
      );
    }

    super.render(canvas);
  }
}
