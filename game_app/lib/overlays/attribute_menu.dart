import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/visuals.dart';
import 'package:recase/recase.dart';

import '../attributes/attributes_permanent.dart';
import '../attributes/attributes_structure.dart';
import '../resources/data_classes/player_data.dart';
import 'buttons.dart';

class AttributeTile extends StatelessWidget {
  const AttributeTile(this.attribute, this.isSelected, {super.key});
  final PermanentAttribute attribute;
  final bool isSelected;

  Widget buildLevelIndicator(bool isUnlocked, double fraction) {
    const fractionIncrease = 2;
    fraction = fractionIncrease * fraction;
    final balancedFrac = ((fraction) - (fractionIncrease / 2));
    // print(balancedFrac);
    var xTransform = -pow(balancedFrac * 2.5, 2).toDouble();
    if (balancedFrac < 0) {
      xTransform = -xTransform;
    }
    final yTransform = -(pow((balancedFrac * 5).abs(), 2).toDouble());
    const zTransform = 0.0;
    final zRotation = -balancedFrac * 1.8;
    Color? customColor = attribute.damageType?.color;

    Widget returnWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Transform(
        transform:
            Matrix4.translationValues(xTransform, yTransform, zTransform),
        child: Container(
          height: 15,
          transformAlignment: Alignment.topCenter,
          transform: Matrix4.rotationZ(zRotation),
          child: Image.asset(
            'assets/images/powerups/start.png',
            color: isUnlocked
                ? customColor ?? Colors.red
                : customColor?.darken(.5) ?? Colors.blue,
          ),
        ),
      ),
    );

    if (isUnlocked) {
      returnWidget =
          Animate(effects: const [FadeEffect()], child: returnWidget);
    }
    return Expanded(child: returnWidget);
    return returnWidget;
  }

  @override
  Widget build(BuildContext context) {
    Color? customColor = isSelected
        ? attribute.damageType?.color.brighten(1)
        : attribute.damageType?.color;
    final selectedColor = isSelected ? Colors.white : Colors.blue;
    final style = defaultStyle.copyWith(fontSize: 20, color: Colors.white);
    final count = attribute.maxLevel;

    return SizedBox.square(
      dimension: 200,
      child: Container(
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(5),
          color: selectedColor.darken(.8),
          // border: Border.all(color: Colors.grey.shade500, width: 5)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  attribute.title,
                  style: style,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/${attribute.icon}',
                        fit: BoxFit.scaleDown,
                        filterQuality: FilterQuality.none,
                        color: customColor ?? selectedColor,
                      ),
                    ),
                    Positioned.fill(
                      top: null,
                      bottom: 0,
                      child: Row(children: [
                        for (var i = 0; i < attribute.maxLevel!; i++)
                          buildLevelIndicator(i < attribute.upgradeLevel,
                              (i / (attribute.maxLevel! - 1))),
                      ]),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      attribute.description(),
                      style: style,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      attribute.isMaxLevel
                          ? "MAX"
                          : attribute.cost().toString(),
                      style: style,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AttributeUpgrader extends StatefulWidget {
  const AttributeUpgrader(
      {required this.onBack, required this.gameRef, super.key});

  final Function onBack;

  final GameRouter gameRef;

  @override
  State<AttributeUpgrader> createState() => _AttributeUpgraderState();
}

class _AttributeUpgraderState extends State<AttributeUpgrader> {
  late ComponentsNotifier<PlayerDataComponent> playerDataNotifier;
  late PlayerDataComponent playerDataComponent;
  late PlayerData playerData;

  @override
  void initState() {
    super.initState();

    playerDataComponent = widget.gameRef.playerDataComponent;
    playerDataNotifier =
        widget.gameRef.componentsNotifier<PlayerDataComponent>();
    playerData = playerDataComponent.dataObject;
    playerDataNotifier.addListener(onPlayerDataNotification);
  }

  @override
  void dispose() {
    playerDataNotifier.removeListener(onPlayerDataNotification);
    super.dispose();
  }

  void onPlayerDataNotification() {
    setState(() {});
  }

  final borderWidth = 5.0;
  final borderColor = backgroundColor2.brighten(.1);

  void selectAttribute(AttributeType attributeType) {}

  AttributeType? selectedAttribute;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Map<AttributeCategory, List<Widget>> entries = {};
    final list = AttributeType.values
        .where((element) => element.territory == AttributeTerritory.permanent)
        .toList();
    // list.sort((a, b) => a.name.compareTo(b.name));
    final listOfCat = AttributeCategory.values.toList();
    // listOfCat.sort((a, b) => a.name.compareTo(b.name));
    for (var element in listOfCat) {
      final tempList = list.where((elementD) => elementD.category == element);
      if (tempList.isEmpty) continue;

      entries[element] = tempList.map((e) {
        int level =
            playerDataComponent.dataObject.unlockedPermanentAttributes[e] ?? 0;
        return InkWell(
          onTap: () {
            setState(() {
              selectedAttribute = e;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AttributeTile(
                e.buildAttribute(level, null) as PermanentAttribute,
                selectedAttribute == e),
          ),
        );
      }).toList();

      // final attribute = element.buildAttribute(
      //   level,
      //   null,
      // );
      // if (attribute is! PermanentAttribute) continue;
      // entries.add(InkWell(
      //     onTap: () {
      //       setState(() {
      //         selectedAttribute = element;
      //       });
      //     },
      //     child: Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: AttributeTile(attribute, selectedAttribute == element),
      //     )));
    }

    return Animate(
      effects: [
        CustomEffect(builder: (context, value, child) {
          return Container(
            color: backgroundColor1.brighten(.1).withOpacity(.9 * value),
            child: child,
          );
        })
      ],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: uiWidthMax * 1.25),
          child: Container(
            // width: size.width * .9,
            // height: size.height * .9,
            // decoration: BoxDecoration(
            //   border: Border.all(color: borderColor, width: borderWidth),
            //   color: backgroundColor2.brighten(.1).withOpacity(.75),
            // ),
            child: Column(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var element in entries.keys)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  element.name.titleCase,
                                  style: defaultStyle.copyWith(fontSize: 40),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      alignment: WrapAlignment.center,
                                      children: entries[element]!,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                )),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: CustomButton(
                            "Back",
                            gameRef: widget.gameRef,
                            onTap: () => widget.onBack(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: CustomButton(
                            "Unlock",
                            gameRef: widget.gameRef,
                            onTap: () {
                              final result = playerData
                                  .unlockPermanentAttribute(selectedAttribute);
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "${playerData.experiencePoints} 🟦",
                            style: defaultStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
