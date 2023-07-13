import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/entities/entity_mixin.dart';

import 'attributes.dart';
import 'attributes_enum.dart';
import '../resources/visuals.dart';

mixin AttributeFunctionality on Entity {
  Map<AttributeEnum, Attribute> currentAttributes = {};
  Random rng = Random();

  void loadPlayerConfig(Map<String, dynamic> config) {}
  bool initalized = false;

  ///Initial Attribtes and their initial level
  ///i.e. Max Speed : Level 3
  void initAttributes(Map<AttributeEnum, int> attributesToAdd) {
    if (initalized) return;
    for (var element in attributesToAdd.entries) {
      currentAttributes[element.key] =
          element.key.buildAttribute(element.value, this, this)..applyUpgrade();
    }
    initalized = true;
  }

  void addRandomAttribute() {
    addAttributeEnum(
        AttributeEnum.values[rng.nextInt(AttributeEnum.values.length)]);
  }

  void addAttributeEnum(AttributeEnum attribute,
      {int level = 1, Entity? perpetratorEntity}) {
    if (currentAttributes.containsKey(attribute)) {
      currentAttributes[attribute]
          ?.incrementLevel(level, currentAttributes[attribute]!.maxLevel);
    } else {
      currentAttributes[attribute] = attribute.buildAttribute(
          level, this, perpetratorEntity ?? this)
        ..applyUpgrade();
    }
  }

  void clearAttributes() {
    for (var element in currentAttributes.entries) {
      element.value.removeUpgrade();
    }
    currentAttributes.clear();
    initalized = false;
  }

  void removeAttribute(AttributeEnum attributeEnum) {
    currentAttributes[attributeEnum]?.removeUpgrade();
    currentAttributes.remove(attributeEnum);
  }

  void remapAttributes() {
    List<Attribute> tempList = [];
    for (var element in currentAttributes.values) {
      if (element.upgradeApplied) {
        element.unMapUpgrade();
        tempList.add(element);
      }
    }
    for (var element in tempList) {
      element.mapUpgrade();
    }
  }

  void modifyLevel(AttributeEnum attributeEnum, [int amount = 0]) {
    if (currentAttributes.containsKey(attributeEnum)) {
      var attr = currentAttributes[attributeEnum]!;
      attr.changeLevel(amount, attr.maxLevel);
    }
  }

  List<Attribute> buildAttributeSelection() {
    List<Attribute> returnList = [];
    final potentialCandidates = AttributeEnum.values
        .where((element) => element.category != AttributeCategory.temporary)
        .toList();
    for (var i = 0; i < 3; i++) {
      final attr = potentialCandidates
          .elementAt(rng.nextInt(potentialCandidates.length));

      if (currentAttributes.containsKey(attr)) {
        returnList.add(currentAttributes[attr]!);
      } else {
        returnList.add(attr.buildAttribute(0, this, this));
      }
    }
    return returnList;
  }
}

typedef EntityOwnerFunction = Function();

mixin AttributeFunctionsFunctionality on Entity {
  List<EntityOwnerFunction> dashBeginFunctions = [];
  List<EntityOwnerFunction> dashOngoingFunctions = [];
  List<EntityOwnerFunction> dashEndFunctions = [];

  List<EntityOwnerFunction> jumpBeginFunctions = [];
  List<EntityOwnerFunction> jumpOngoingFunctions = [];
  List<EntityOwnerFunction> jumpEndFunctions = [];

  List<Function(Entity source)> onHit = [];
  List<EntityOwnerFunction> onMove = [];
  List<EntityOwnerFunction> onDeath = [];
  List<EntityOwnerFunction> onLevelUp = [];

  List<Function(HealthFunctionality other)> onTouch = [];
  List<Function(double dt)> onUpdate = [];

  @override
  void update(double dt) {
    for (var element in onUpdate) {
      element(dt);
    }
    super.update(dt);
  }
}

class StatusEffect extends PositionComponent {
  StatusEffect(this.effect, this.level);

  final StatusEffects effect;
  final int level;
  final double spriteSize = .2;

  late SpriteAnimationComponent spriteAnimationComponent;

  @override
  void onRemove() {
    print('removed');
    super.onRemove();
  }

  @override
  FutureOr<void> onLoad() async {
    size = Vector2.all(spriteSize);
    anchor = Anchor.center;

    spriteAnimationComponent = SpriteAnimationComponent(
        animation: await getEffectSprite(effect),
        size: size,
        anchor: Anchor.center);

    spriteAnimationComponent.size = size * ((level.toDouble() / 10) + 1);
    add(spriteAnimationComponent);
    return super.onLoad();
  }
}

class HoldDuration extends PositionComponent {
  HoldDuration(this.duration);

  final double duration;
  final double spriteSize = .25;

  double get percentComplete => (durationProgressed / duration).clamp(0, 1);

  double durationProgressed = 0;

  @override
  FutureOr<void> onLoad() async {
    // size = Vector2.all(spriteSize);
    // anchor = Anchor.center;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    durationProgressed += dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    // canvas.drawCircle(Offset.zero, spriteSize, BasicPalette.white.paint());
    canvas.drawCircle(
        Offset.zero,
        spriteSize,
        Paint()
          ..shader = ui.Gradient.sweep(
              Offset.zero,
              [
                percentComplete == 1 ? secondaryColor : primaryColor,
                Colors.transparent
              ],
              [percentComplete, percentComplete],

              // null,
              TileMode.clamp,
              0,
              pi * 2 * percentComplete));
    super.render(canvas);
  }
}

class EntityStatusEffectsWrapper extends PositionComponent {
  EntityStatusEffectsWrapper({super.position, super.size}) {
    anchor = Anchor.center;
  }

  ///ID, Effect
  Map<StatusEffects, StatusEffect> activeStatusEffects = {};

  ///ID, Animation
  Map<String, ReloadAnimation> reloadAnimations = {};
  HoldDuration? holdDuration;

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

    holdDuration?.removeFromParent();
    holdDuration = null;
  }

  double getXPosition(StatusEffects effect) {
    return ((effect.index + 1) / StatusEffects.values.length) * (width);
  }

  void addHoldDuration(double duration) {
    if (removedAnimations) return;
    holdDuration?.removeFromParent();
    holdDuration = HoldDuration(duration);
    holdDuration!.position.y = -.5;
    holdDuration!.position.x = width / 2;
    add(holdDuration!);
  }

  void removeHoldDuration() {
    holdDuration?.removeFromParent();
    holdDuration = null;
  }

  void addStatusEffect(StatusEffects effect, int level) {
    if (removedAnimations) return;
    activeStatusEffects[effect]?.removeFromParent();

    activeStatusEffects[effect] = (StatusEffect(effect, level));
    final posX = getXPosition(effect);
    activeStatusEffects[effect]!.position.x = posX;
    activeStatusEffects[effect]!.position.y = -.2;
    activeStatusEffects[effect]?.addToParent(this);
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
      ..addToParent(this);
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
  final sidePadding = .025;
  bool isOpaque = false;
  void toggleOpacity([bool? value]) =>
      value != null ? isOpaque = value : isOpaque = !isOpaque;

  Color get color => isSecondaryWeapon ? secondaryColor : primaryColor;

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
    final parent = this.parent as EntityStatusEffectsWrapper;
    // final parentSize = weaponAncestor.entityAncestor!.spriteWrapper.size;

    size.y = height;
    size.x = parent.width * .7;
    position.y = 0;

    if (isSecondaryWeapon) {
      position.y += -height * 2;
    }

    return super.onLoad();
  }
}
