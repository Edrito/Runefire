import 'dart:math';

import 'package:game_app/entities/entity.dart';

import '../resources/attributes.dart';
import '../resources/attributes_enum.dart';

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
          element.key.buildAttribute(element.value, this)..applyAttribute();
    }
    initalized = true;
  }

  void addRandomAttribute() {
    addAttributeEnum(
        AttributeEnum.values[rng.nextInt(AttributeEnum.values.length)]);
  }

  void addAttributeEnum(AttributeEnum attribute, [int level = 1]) {
    if (currentAttributes.containsKey(attribute)) {
      currentAttributes[attribute]?.incrementLevel(level);
    } else {
      currentAttributes[attribute] = attribute.buildAttribute(level, this)
        ..applyAttribute();
    }
  }

  void addAttribute(Attribute attribute, [int level = 1]) {
    if (currentAttributes.containsKey(attribute.attributeEnum)) {
      currentAttributes[attribute.attributeEnum]?.incrementLevel(level);
    } else {
      currentAttributes[attribute.attributeEnum] = attribute..applyAttribute();
    }
  }

  void clearAttributes() {
    for (var element in currentAttributes.entries) {
      element.value.removeAttribute();
    }
    currentAttributes.clear();
    initalized = false;
  }

  void removeAttribute(AttributeEnum attributeEnum) {
    if (currentAttributes.containsKey(attributeEnum)) {
      currentAttributes[attributeEnum]?.removeAttribute();
      currentAttributes.remove(attributeEnum);
    }
  }

  void remapAttributes() {
    List<Attribute> tempList = [];
    for (var element in currentAttributes.values) {
      if (element.isApplied) {
        element.unmapAttribute();
        tempList.add(element);
      }
    }
    for (var element in tempList) {
      element.mapAttribute();
    }
  }

  void modifyLevel(AttributeEnum attributeEnum, [int amount = 0]) {
    if (currentAttributes.containsKey(attributeEnum)) {
      var attr = currentAttributes[attributeEnum]!;
      attr.incrementLevel(amount);
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
        returnList.add(attr.buildAttribute(0, this));
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

  List<Function(Entity owner, Entity source)> onHit = [];

  List<EntityOwnerFunction> onMove = [];
  List<EntityOwnerFunction> onDeath = [];
  List<EntityOwnerFunction> onLevelUp = [];
}
