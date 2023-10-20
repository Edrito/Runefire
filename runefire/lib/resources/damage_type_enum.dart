import 'package:flutter/material.dart';
import 'package:runefire/main.dart';
import 'package:runefire/menus/custom_widgets.dart';
import 'package:runefire/menus/pause_menu.dart';
import 'package:runefire/player/player.dart';
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

  List<(double, String)> buildElementalPowerBonus() {
    List<(double, String)> returnList = [];

    switch (this) {
      case DamageType.physical:
        returnList.addAll([]);
        break;
      case DamageType.energy:
        returnList.addAll([]);
        break;
      case DamageType.psychic:
        returnList.addAll([]);
        break;
      case DamageType.magic:
        returnList.addAll([]);
        break;
      case DamageType.fire:
        returnList.addAll([
          (
            .6,
            "Fire spreads, when an enemy dies from a fire-based attack, nearby enemies may get burnt."
          ),
          (
            .25,
            "Fire spreads, when an enemy dies from a fire-based attack, nearby enemies may get burnt."
          ),
          (
            .1,
            "Fire spreads, when an enemy dies from a fire-based attack, nearby enemies may get burnt."
          ),
        ]);
        break;
      case DamageType.frost:
        returnList.addAll([]);
        break;
      default:
    }

    return returnList;
  }
}

class ElementalPowerListDisplay extends StatelessWidget {
  const ElementalPowerListDisplay(
      {required this.player, required this.damageType, super.key});
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
          child: LayoutBuilder(builder: (context, straints) {
            final powerLevel = (player.elementalPower[damageType] ?? 0);
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
                  child: ElementalPowerBack(damageType),
                ),
              ],
            );
          }),
        ),
        Expanded(
          child: Container(
            color: ApolloColorPalette.darkestGray.color,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var element in damageType.buildElementalPowerBonus())
                    Builder(builder: (context) {
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
                                  Icons.circle,
                                  color: color,
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Text(
                                  "${element.$1 * 100}%",
                                  style: style,
                                ),
                              ],
                            ),
                            Text(
                              element.$2,
                              style:
                                  style.copyWith(fontSize: style.fontSize! / 2),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    })
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
