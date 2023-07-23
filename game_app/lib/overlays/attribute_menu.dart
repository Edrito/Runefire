import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/attributes/attributes.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/visuals.dart';

import 'package:recase/recase.dart';
import '../attributes/attributes_enum.dart';
import '../resources/data_classes/player_data.dart';
import 'buttons.dart';

class AttributeTile extends StatelessWidget {
  const AttributeTile(this.attribute, this.isSelected, {super.key});
  final Attribute attribute;
  final bool isSelected;

  Widget buildLevelIndicator(bool isUnlocked, double fraction) {
    const fractionIncrease = 2;
    fraction = fractionIncrease * fraction;
    final balancedFrac = ((fraction) - (fractionIncrease / 2));
    print(balancedFrac);
    var xTransform = -pow(balancedFrac * 2.5, 2).toDouble();
    if (balancedFrac < 0) {
      xTransform = -xTransform;
    }
    final yTransform = -(pow((balancedFrac * 5).abs(), 2).toDouble());
    const zTransform = 0.0;
    final zRotation = -balancedFrac * 1.8;

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
            color: isUnlocked ? Colors.red : Colors.blue,
          ),
        ),
      ),
    );

    if (isUnlocked) {
      returnWidget =
          Animate(effects: const [FadeEffect()], child: returnWidget);
    }
    return Expanded(child: returnWidget);
  }

  @override
  Widget build(BuildContext context) {
    final style = defaultStyle.copyWith(
        fontSize: 18, color: isSelected ? Colors.red : Colors.blue);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.green.withOpacity(.5),
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                attribute.attributeType.name.titleCase,
                style: style,
              ),
            ),
            Container(
              child: Image.asset(
                'assets/images/${attribute.icon}',
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.none,
              ),
            ),
            Row(children: [
              for (var i = 0; i < attribute.maxLevel; i++)
                buildLevelIndicator(
                    i < attribute.upgradeLevel, (i / (attribute.maxLevel - 1))),
            ]),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                attribute.cost().toString(),
                style: style,
              ),
            )
          ],
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
    List<Widget> entries = [];

    for (var element in AttributeType.values.where(
        (element) => element.territory == AttributeTerritory.permanent)) {
      int level =
          playerDataComponent.dataObject.unlockedPermanentAttributes[element] ??
              0;
      final attribute = element.buildAttribute(
        level,
        null,
        null,
      );
      entries.add(InkWell(
          onTap: () {
            setState(() {
              selectedAttribute = element;
            });
          },
          child: AttributeTile(attribute, selectedAttribute == element)));
    }

    return Animate(
      effects: [
        CustomEffect(builder: (context, value, child) {
          return Container(
            color: backgroundColor1.brighten(.1).withOpacity(.6 * value),
            child: child,
          );
        })
      ],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: uiWidthMax),
          child: Container(
            width: size.width * .9,
            height: size.height * .9,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: borderWidth),
              color: backgroundColor2.brighten(.1).withOpacity(.75),
            ),
            child: Column(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      children: entries,
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
                              final result =
                                  playerData.unlockAttribute(selectedAttribute);
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
