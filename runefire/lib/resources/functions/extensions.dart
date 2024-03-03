import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/weapons/weapon_class.dart';

mixin UpdateFunctionsThenRemove on Component {
  final List<void Function(double dt)> _updateFunctions = [];

  void addTemporaryUpdateFunction(void Function(double dt) function) {
    _updateFunctions.add(function);
  }

  @override
  void update(double dt) {
    for (final function in _updateFunctions) {
      function(dt);
    }
    _updateFunctions.clear();
    super.update(dt);
  }
}

extension SizeExtension on SpriteAnimation {
  Vector2 getGameScaledSize(
    Entity? entity, {
    Weapon? weapon,
    Enviroment? env,
    double? amount,
  }) {
    final size = frames.firstOrNull?.sprite.srcSize.clone() ?? Vector2.zero();
    return size
      ..scaledToHeight(
        entity,
        weapon: weapon,
        env: env,
        amount: amount,
      );
  }
}

extension MapExpanded on List<Widget> {
  List<Expanded> mapExpanded() {
    return map((e) => Expanded(child: e)).toList();
  }
}
