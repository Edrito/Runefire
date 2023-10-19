import 'package:flutter/material.dart';
import 'package:runefire/resources/visuals.dart';

enum DamageType { physical, magic, fire, psychic, energy, frost, healing }

extension DamageTypeExtension on DamageType {
  Color get color {
    switch (this) {
      case DamageType.physical:
        return Colors.white;
      case DamageType.energy:
        return ApolloColorPalette.yellow.color;
      case DamageType.psychic:
        return ApolloColorPalette.purple.color;
      case DamageType.magic:
        return ApolloColorPalette.lightBlue.color;
      case DamageType.fire:
        return ApolloColorPalette.orange.color;
      case DamageType.frost:
        return ApolloColorPalette.lightCyan.color;
      case DamageType.healing:
        return ApolloColorPalette.lightGreen.color;
    }
  }
}
