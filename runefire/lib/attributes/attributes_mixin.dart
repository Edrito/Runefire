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
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/main.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/extensions.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/weapons/weapon_mixin.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:runefire/resources/enums.dart';
import 'package:runefire/entities/hidden_child_entities/child_entities.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:uuid/uuid.dart';

mixin AttributeFunctionality on Entity {
  final Map<AttributeType, Attribute> _currentAttributes = {};

  bool initalized = false;
  Random rng = Random();

  List<AttributeType> get currentAttributeTypes =>
      _currentAttributes.keys.toList();

  List<Attribute> get currentAttributes => _currentAttributes.values.toList();

  void addAttribute(
    AttributeType attribute, {
    int? level,
    bool applyUpgrade = true,
    Entity? perpetratorEntity,
    DamageType? damageType,
    double? duration,
    bool isTemporary = false,
  }) {
    //Already has it
    if (_currentAttributes.containsKey(attribute)) {
      _currentAttributes[attribute]?.incrementLevel(level ?? 1);

      //Doesnt have it
    } else {
      _currentAttributes[attribute] = attribute.buildAttribute(
        level ?? 1,
        this,
        perpetratorEntity: perpetratorEntity,
        damageType: damageType,
        duration: duration,
        isTemporary: isTemporary || duration != null,
      );
      if (applyUpgrade) {
        _currentAttributes[attribute]?.applyUpgrade();
      }
    }
  }

  List<Attribute> buildAttributeSelection() {
    if (!isPlayer) {
      return [];
    }

    final player = this as Player;
    final returnList = <Attribute>[];
    var elementalDamageTypeForced =
        player.shouldForceElementalAttributeSelection();
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
                  !element.autoAssigned &&
                  //Player is not max level
                  player._currentAttributes[element]?.isMaxLevel != true &&
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

      if (_currentAttributes.containsKey(attr)) {
        returnList.add(_currentAttributes[attr]!);
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
    if (_currentAttributes.containsKey(attr)) {
      returnAttrib = _currentAttributes[attr]!;
    } else {
      returnAttrib = attr.buildAttribute(0, this);
    }

    return returnAttrib;
  }

  void clearAttributes() {
    for (final element in _currentAttributes.entries) {
      element.value.removeUpgrade();
    }
    _currentAttributes.clear();
    initalized = false;
  }

  Attribute? getAttribute(AttributeType attribute) {
    if (_currentAttributes.containsKey(attribute)) {
      return _currentAttributes[attribute]!;
    }
    return null;
  }

  bool hasAnyAttribute(List<AttributeType> attributes) =>
      attributes.any(_currentAttributes.containsKey);

  bool hasAttribute(AttributeType attribute) =>
      _currentAttributes.containsKey(attribute);

  ///Initial Attribtes and their initial level
  ///i.e. Max Speed : Level 3
  void initAttributes(Map<AttributeType, int> attributesToAdd) {
    if (initalized) {
      return;
    }
    final attributeTypes = attributesToAdd.keys.toList();
    attributeTypes.sort((a, b) => a.priority.compareTo(b.priority));
    for (final element in attributeTypes) {
      _currentAttributes[element] = element.buildAttribute(
        attributesToAdd[element]!,
        this,
        perpetratorEntity: this,
      )..applyUpgrade();
    }

    initalized = true;
  }

  void loadPlayerConfig(Map<String, dynamic> config) {}

  void modifyLevel(AttributeType attributeEnum, [int amount = 0]) {
    if (_currentAttributes.containsKey(attributeEnum)) {
      final attr = _currentAttributes[attributeEnum]!;
      attr.changeLevel(amount);
    }
  }

  void remapAttributes() {
    final tempList = <Attribute>[];
    for (final element in _currentAttributes.values) {
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
    _currentAttributes[attributeType]?.removeUpgrade();
    _currentAttributes.remove(attributeType);
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
  final List<Function()> dashBeginFunctions = [];
  final List<Function()> dashEndFunctions = [];
  final List<Function()> dashOngoingFunctions = [];
  final List<Function()> jumpBeginFunctions = [];
  final List<Function()> jumpEndFunctions = [];
  final List<Function(double percentComplete)> jumpOngoingFunctions = [];
  final List<Function()> onLevelUp = [];
  final List<Function()> onMove = [];
  final List<Function(Weapon weapon)> onSpentAttack = [];
  final List<Function(DamageInstance instance)> onDodge = [];
  final List<Function(HealthFunctionality other)> onTouch = [];
  final List<Function(DamageInstance instance)> onHeal = [];
  final List<Function(DamageInstance instance)> onKillOtherEntity = [];
  final List<OnHitDef> onDamageTaken = [];
  final List<OnHitDef> onHitByOtherEntity = [];
  final List<OnHitDef> onHitByProjectile = [];
  final List<OnHitDef> onHitOtherEntity = [];
  late final pulseFunctionId = const Uuid().v4();

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

  // @override
  // Future<void> onLoad() {
  //   pulsePeriod.addListener(rebuildPulseTimer);
  //   return super.onLoad();
  // }

  // @override
  // void onRemove() {
  //   pulsePeriod.removeListener(rebuildPulseTimer);
  //   super.onRemove();
  // }

  // void rebuildPulseTimer(double newPeriod) {
  //   gameEnviroment.eventManagement.removeAiTimer(id: pulseFunctionId);
  //   gameEnviroment.eventManagement.addAiTimer(
  //     (function: _onPulse, id: pulseFunctionId, time: newPeriod),
  //   );
  // }

  void addPulseFunction(Function function) {
    _pulseFunctions.add(function);
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
    _processPulseFunctions(dt);
    _processHeadEntities(_headEntities, .5, dt);
    _processBodyEntities(_bodyComponents, spriteHeight * 1.3, dt);
    super.update(dt);
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

  double previousPulsePassed = 0;

  void _processPulseFunctions(double dt) {
    if (_pulseFunctions.isEmpty || functionsPerforming) {
      return;
    }

    previousPulsePassed += dt;

    if (previousPulsePassed > pulsePeriod.parameter) {
      previousPulsePassed = 0;
      _performPulses();
    }
  }

  bool functionsPerforming = false;

  Future<void> _performPulses() async {
    functionsPerforming = true;
    for (final element in [..._pulseFunctions]) {
      await game.gameAwait(pulsePeriod.parameter / _pulseFunctions.length);
      element.call();
    }
    functionsPerforming = false;
  }
}

// class StatusEffect extends SpriteAnimationComponent {
//   StatusEffect(this.effect, this.level);

//   final StatusEffects effect;
//   final int level;
//   final double spriteSize = .7;

//   @override
//   FutureOr<void> onLoad() async {
//     size = Vector2.all(spriteSize);
//     anchor = Anchor.center;

//     switch (effect) {
//       case StatusEffects.burn:

//         break;
//       default:
//     }

//     size = size * ((level.toDouble() / 30) + 1);
//     return super.onLoad();
//   }
// }

typedef AnimationItem = ({
  double? duration,
  SpriteAnimation animation,
  SpriteAnimationComponent component,
  String id,
  int xPosition
});

typedef AnimationItemTwo = ({
  double? duration,
  SimpleStartPlayEndSpriteAnimationComponent component,
});

class EntityVisualEffectsWrapper {
  EntityVisualEffectsWrapper({required this.entity}) {
    entity.onUpdate.add(onUpdate);
  }

  final Map<String, AnimationItemTwo> _activeBodyItems = {};
  final Map<String, double> _activeBodyTimers = {};
  final Map<String, AnimationItem> _activeGroundItems = {};
  final Map<String, double> _activeGroundTimers = {};
  final Map<String, AnimationItem> _activeStatusBarItems = {};
  final Map<String, double> _activeStatusBarTimers = {};

  int currentHitAnimations = 0;
  Entity entity;

  ///ID, Animation
  Map<String, ReloadAnimation> reloadAnimations = {};

  bool removedAnimations = false;
  late double width = entity.entityAnimationsGroup.width * 1.5;

  Future<void> addBodyAnimation({
    required String id,
    required SimpleStartPlayEndSpriteAnimationComponent component,
    double? duration,
    bool followEntity = true,
    double yOffset = 0,
    bool moveDirection = false,
  }) async {
    if ((!entity.isFlipped && !moveDirection) ||
        (moveDirection && entity.body.linearVelocity.x < 0)) {
      component.flipHorizontallyAroundCenter();
    }
    if (followEntity) {
      component.position = Vector2(0, yOffset);
      entity.add(component);
    } else {
      component.position = Vector2(
        entity.center.x,
        entity.center.y + yOffset,
      );
      entity.enviroment.add(component);
    }

    _activeBodyItems[id] = (duration: duration, component: component);
    _activeBodyTimers[id] = 0;
  }

  Future<void> addGroundAnimation({
    required SpriteAnimation animation,
    required String id,
    double? duration,
    bool followEntity = true,
    double yOffset = 0,
    bool moveDirection = false,
  }) async {
    final size = animation.frames.first.sprite.srcSize;

    size.scaledToHeight(entity);

    final sprite = SpriteAnimationComponent(
      anchor: Anchor.center,
      size: size,
      animation: animation,
    );
    if ((!entity.isFlipped && !moveDirection) ||
        (moveDirection && entity.body.linearVelocity.x < 0)) {
      sprite.flipHorizontallyAroundCenter();
    }
    if (followEntity) {
      sprite.position = Vector2(0, yOffset);
      entity.add(sprite);
    } else {
      sprite.position = Vector2(entity.center.x, entity.center.y + yOffset);
      entity.enviroment.add(sprite);
    }
    if (!sprite.animation!.loop) {
      sprite.animationTicker?.completed
          .then((value) => sprite.removeFromParent());
    } else {
      _activeGroundItems[id] = (
        duration: duration,
        component: sprite,
        animation: animation,
        id: id,
        xPosition: 0,
      );
      _activeGroundTimers[id] = 0;
    }
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

  Future<void> addStatusBarItem({
    required String id,
    required int xPosition,
    double? duration,
    SpriteAnimation? animation,
    SpriteAnimationComponent? component,
  }) async {
    assert(animation != null || component != null, 'gotta add something');
    if (removedAnimations) {
      return;
    }

    _activeStatusBarItems[id] = (
      duration: duration,
      component: (component ??
          SpriteAnimationComponent(
            animation: animation,
            size: animation!.getGameScaledSize(entity),
            anchor: Anchor.center,
          ))
        ..addToParent(entity),
      animation: animation ??
          (await component!.loaded.then((value) => component.animation!)),
      id: id,
      xPosition: xPosition,
    );
    _activeStatusBarTimers[id] = 0;
    rePositionStatusBarItems();
  }

  Future<void> addStatusEffect(StatusEffects effect, int level) async {
    if (removedAnimations || effect.otherEffect) {
      return;
    }
    if (effect.isStatusBar) {
      SpriteAnimation animation;
      switch (effect) {
        case StatusEffects.chill:
          animation = await spriteAnimations.damageTypeFrostEffect1;
        case StatusEffects.empowered:
          animation = await spriteAnimations.statusEffectsEmpowered1;

          break;
        case StatusEffects.confused:
          animation = await spriteAnimations.damageTypePsychicEffect1;

        case StatusEffects.fear:
          animation = await spriteAnimations.statusEffectFearEffect1;

        case StatusEffects.stun:
          animation = await spriteAnimations.statusEffectStunEffect1;
        case StatusEffects.slow:
          animation = await spriteAnimations.statusEffectsSlow1;

        default:
          animation = await spriteAnimations.damageTypePsychicEffect1;
      }
      addStatusBarItem(
        animation: animation,
        id: effect.toString(),
        xPosition: effect.index,
      );
    } else {
      switch (effect) {
        case StatusEffects.burn:
          addBodyAnimation(
            id: effect.toString(),
            component: SimpleStartPlayEndSpriteAnimationComponent(
              spawnAnimation: await spriteAnimations.burnEffectStart1,
              playAnimation: await spriteAnimations.burnEffect1,
              durationType: DurationType.permanent,
              endAnimation: await spriteAnimations.burnEffectEnd1,
            ),
            yOffset: entity.spriteHeight * .1,
          );
          break;
        case StatusEffects.electrified:
          addBodyAnimation(
            id: effect.toString(),
            component: SimpleStartPlayEndSpriteAnimationComponent(
              playAnimation: await spriteAnimations.statusEffectElectrified1,
              durationType: DurationType.permanent,
            ),
            yOffset: entity.spriteHeight * .1,
          );
        case StatusEffects.bleed:
          addBodyAnimation(
            id: effect.toString(),
            component: SimpleStartPlayEndSpriteAnimationComponent(
              playAnimation: await spriteAnimations.statusEffectBleedEffect1,
              durationType: DurationType.permanent,
            ),
            yOffset: entity.spriteHeight * .1,
          );
        case StatusEffects.marked:
          final sprite = await spriteAnimations.markedEffect1;

          addBodyAnimation(
            component: SimpleStartPlayEndSpriteAnimationComponent(
              playAnimation: sprite,
              durationType: DurationType.permanent,
              fadeOut: false,
              customSize: sprite.getGameScaledSize(entity),
            ),
            id: effect.toString(),
          );
        default:
      }
    }
  }

  Future<void> applyHitAnimation(
    SpriteAnimation animation,
    Vector2 sourcePosition, [
    Color? color,
  ]) async {
    if (animation.loop || currentHitAnimations > hitAnimationLimit) {
      return;
    }
    currentHitAnimations++;
    final hitSize = animation.frames.first.sprite.srcSize;
    hitSize.scaledToHeight(entity);
    final thisHeight = entity.spriteHeight;
    final sprite = SpriteAnimationComponent(
      anchor: Anchor.center,
      size: hitSize,
      animation: animation,
    );
    if (color != null) {
      sprite.paint = colorPalette.buildProjectile(
        color: color,
        projectileType: ProjectileType.paintBullet,
        lighten: false,
      );
    }
    sprite.position = Vector2(
      (rng.nextDouble() * thisHeight / 3) - thisHeight / 6,
      (sourcePosition - entity.center)
          .y
          .clamp(thisHeight * -.5, thisHeight * .5),
    );

    entity.add(sprite);
    sprite.animationTicker?.completed.then((value) {
      sprite.removeFromParent();

      currentHitAnimations--;
    });
  }

  String generateKey(String sourceId, bool isSecondary) =>
      '${sourceId}_$isSecondary';

  void hideReloadAnimations(String sourceId) {
    for (final isSecondary in [true, false]) {
      final key = generateKey(sourceId, isSecondary);
      reloadAnimations[key]?.toggleOpacity(true);
    }
  }

  void onUpdate(double dt) {
    for (final entry in [..._activeStatusBarTimers.entries]) {
      _activeStatusBarTimers[entry.key] = entry.value + dt;
      if (_activeStatusBarItems[entry.key] == null) {
        removeStatusBarItem(entry.key);
      } else if (_activeStatusBarItems[entry.key]!.duration == null) {
        continue;
      } else if (entry.value >
          (_activeStatusBarItems[entry.key]?.duration ?? -1.0)) {
        removeStatusBarItem(entry.key);
      }
    }

    for (final entry in [..._activeGroundTimers.entries]) {
      _activeGroundTimers[entry.key] = entry.value + dt;
      if (_activeGroundItems[entry.key] == null) {
        removeGroundItem(entry.key);
      } else if (_activeGroundItems[entry.key]!.duration == null) {
        continue;
      } else if (entry.value >
          (_activeGroundItems[entry.key]?.duration ?? -1.0)) {
        removeGroundItem(entry.key);
      }
    }
    for (final entry in [..._activeBodyTimers.entries]) {
      _activeBodyTimers[entry.key] = entry.value + dt;
      if (_activeBodyItems[entry.key] == null) {
        removeBodyItem(entry.key);
      } else if (_activeBodyItems[entry.key]!.duration == null) {
        continue;
      } else if (entry.value >
          (_activeBodyItems[entry.key]?.duration ?? -1.0)) {
        removeBodyItem(entry.key);
      }
    }
  }

  void rePositionStatusBarItems() {
    final keys = _activeStatusBarItems.keys.toList();
    if (keys.isEmpty) {
      return;
    }
    keys.sort(
      (a, b) => _activeStatusBarItems[a]!
          .xPosition
          .compareTo(_activeStatusBarItems[b]!.xPosition),
    );

    // Calculate total width of all items
    const maxItemsPerRow = 4;

    // Constants for stacking
    const rowSpacing = .75; // Adjust this for vertical spacing between rows
    var rowNumber = 0;
    // Position items with stacking
    for (var i = 0; i < keys.length; i++) {
      final item = _activeStatusBarItems[keys[i]]!;
      rowNumber = i ~/ maxItemsPerRow;
      final itemsThisRow =
          (keys.length - (rowNumber * maxItemsPerRow)).clamp(0, maxItemsPerRow);

      // Calculate starting X position (centered)

      final totalWidth = item.component.size.x * (itemsThisRow + 1);
      final startX = -(totalWidth / 2) + (item.component.size.x / 4);

      final y = -entity.spriteHeight -
          (rowSpacing * rowNumber.clamp(0, 20)); // Calculate row

      final x = startX +
          ((i % maxItemsPerRow) * item.component.size.x) +
          (item.component.size.x / 2);

      item.component.position = Vector2(x, y);
    }
  }

  void removeAllAnimations() {
    removedAnimations = true;

    for (final element in [..._activeStatusBarItems.entries]) {
      removeStatusBarItem(element.key);
    }
    for (final element in [..._activeGroundItems.entries]) {
      removeGroundItem(element.key);
    }
    for (final element in [..._activeBodyItems.entries]) {
      removeBodyItem(element.key);
    }
    for (final element in [...reloadAnimations.values]) {
      element.removeFromParent();
    }
    reloadAnimations.clear();
    // holdDuration?.removeFromParent();
    // holdDuration = null;
  }

  void removeAllReloads() {
    for (final element in reloadAnimations.entries) {
      element.value.removeFromParent();
    }
    reloadAnimations.clear();
  }

  void removeBodyItem(String id) {
    _activeBodyItems[id]?.component.triggerEnding();
    _activeBodyItems.remove(id);
  }

  void removeGroundItem(String id) {
    _activeGroundItems[id]?.component.removeFromParent();
    _activeGroundItems.remove(id);
  }

  void removeReloadAnimation(String sourceId, bool isSecondary) {
    final key = generateKey(sourceId, isSecondary);
    reloadAnimations[key]?.removeFromParent();
    reloadAnimations.remove(key);
  }

  void removeStatusBarItem(String id) {
    _activeStatusBarItems[id]?.component.removeFromParent();
    _activeStatusBarItems.remove(id);
    rePositionStatusBarItems();
  }

  void removeStatusEffect(StatusEffects statusEffects) {
    removeStatusBarItem(statusEffects.toString());
    removeBodyItem(statusEffects.toString());
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
    final width = parent.entityVisualEffectsWrapper.width * .7;
    // final x = (parent.entityStatusWrapper.width - width) / 2;
    size.y = height;
    size.x = parent.entityVisualEffectsWrapper.width * .7;
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
