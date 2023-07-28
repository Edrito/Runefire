import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/entities/entity_mixin.dart';

import '../resources/enums.dart';
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
    for (var element in attributesToAdd.entries) {
      currentAttributes[element.key] = element.key
          .buildAttribute(element.value, this, perpetratorEntity: this)
        ..applyUpgrade();
    }
    initalized = true;
  }

  void addAttribute(Attribute attribute,
      {int? level, bool applyUpgrade = true}) {
    if (currentAttributes.containsKey(attribute.attributeType)) {
      currentAttributes[attribute.attributeType]?.incrementLevel(level ?? 1);
    } else {
      currentAttributes[attribute.attributeType] = attribute..removeUpgrade();
      if (applyUpgrade) {
        currentAttributes[attribute.attributeType]?.applyUpgrade();
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

  void removeAttribute(AttributeType attributeEnum) {
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

  void modifyLevel(AttributeType attributeEnum, [int amount = 0]) {
    if (currentAttributes.containsKey(attributeEnum)) {
      var attr = currentAttributes[attributeEnum]!;
      attr.changeLevel(amount);
    }
  }

  List<Attribute> buildAttributeSelection() {
    List<Attribute> returnList = [];
    final potentialCandidates = AttributeType.values
        .where((element) => element.territory == AttributeTerritory.game)
        .toList();
    for (var i = 0; i < 3; i++) {
      final attr = potentialCandidates
          .elementAt(rng.nextInt(potentialCandidates.length));

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

mixin AttributeFunctionsFunctionality on Entity {
  List<Function> dashBeginFunctions = [];
  List<Function> dashOngoingFunctions = [];
  List<Function> dashEndFunctions = [];

  List<Function> jumpBeginFunctions = [];
  List<Function> jumpOngoingFunctions = [];
  List<Function> jumpEndFunctions = [];

  List<Function(Entity source)> onHit = [];
  List<Function(HealthFunctionality victim)> onKillOtherEntity = [];
  List<Function> onMove = [];
  List<Function> onDeath = [];
  List<Function> onLevelUp = [];

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
    final width = parent.width * .7;
    final x = (parent.width - width) / 2;
    size.y = height;
    size.x = parent.width * .7;
    position.y = 0;
    position.x = x;

    if (isSecondaryWeapon) {
      position.y += -height * 2;
    }

    return super.onLoad();
  }
}
