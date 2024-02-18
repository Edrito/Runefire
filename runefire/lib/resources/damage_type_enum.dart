import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/main.dart';
import 'package:runefire/menus/custom_widgets.dart';
import 'package:runefire/menus/pause_menu.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/visuals.dart';

enum DamageType {
  physical,
  magic,
  fire,
  psychic,
  energy,
  frost,
  healing;

  static Iterable<DamageType> get getValuesWithoutHealing =>
      values.where((element) => element != DamageType.healing);
}

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

  Future<SpriteAnimation> get particleEffect {
    switch (this) {
      case DamageType.physical:
        return spriteAnimations.damageTypePhysicalEffect1;
      case DamageType.energy:
        return spriteAnimations.damageTypeEnergyEffect1;

      case DamageType.psychic:
        return spriteAnimations.damageTypePsychicEffect1;
      case DamageType.magic:
        return spriteAnimations.damageTypeMagicEffect1;
      case DamageType.fire:
        return spriteAnimations.damageTypeFireEffect1;
      case DamageType.frost:
        return spriteAnimations.damageTypeFrostEffect1;
      case DamageType.healing:
        return spriteAnimations.damageTypePhysicalEffect1;
    }
  }

  List<(double, String)> buildElementalPowerBonus() {
    return [
      for (final attribute in AttributeType.values.where(
        (element) =>
            element.autoAssigned && element.elementalRequirement.contains(this),
      ))
        (
          attribute.elementalRequirementValue(this),
          attribute.buildAttribute(0, null, builtForInfo: true).description()
        ),
    ]..sort((b, a) => a.$1.compareTo(b.$1));
  }
}

class ElementalPowerListDisplay extends StatelessWidget {
  const ElementalPowerListDisplay({
    required this.player,
    required this.damageType,
    super.key,
  });
  final DamageType damageType;
  final Player player;

  bool playerHasUnlocked(double value, DamageType damageType) {
    return (player.elementalPower[damageType] ?? 0) >= value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: LayoutBuilder(
            builder: (context, straints) {
              final powerLevel = player.elementalPower[damageType] ?? 0;
              return Column(
                children: [
                  Expanded(
                    child: Container(
                      color: ApolloColorPalette.darkestGray.color,
                    ),
                  ),
                  SizedBox(
                    height: straints.maxHeight * powerLevel,
                    // color: damageType.color,
                    width: 50,
                    child: ElementalPowerBack(damageType, powerLevel),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: Container(
            color: ApolloColorPalette.darkestGray.color,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final element in damageType.buildElementalPowerBonus())
                    Builder(
                      builder: (context) {
                        final color = playerHasUnlocked(element.$1, damageType)
                            ? damageType.color
                            : colorPalette.primaryColor;
                        final style = defaultStyle.copyWith(color: color);
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.square,
                                    color: color,
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                    '${element.$1 * 100}%',
                                    style: style.copyWith(
                                      fontSize: style.fontSize! / 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                element.$2,
                                style: style.copyWith(
                                  fontSize: style.fontSize! / 2,
                                ),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
