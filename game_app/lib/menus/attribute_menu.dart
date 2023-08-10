import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/functions/functions.dart';
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
                ? (customColor ?? Colors.white).brighten(.2)
                : (customColor ?? Colors.blue).darken(.5),
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
    final levelCountWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(children: [
        for (var i = 0; i < attribute.maxLevel!; i++)
          buildLevelIndicator(
              i < attribute.upgradeLevel, (i / (attribute.maxLevel! - 1))),
      ]),
    );
    return SizedBox(
      height: 250,
      width: 200,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/ui/book.png',
              fit: BoxFit.fitHeight,
              filterQuality: FilterQuality.none,
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(colors: [
                Colors.black.withOpacity(.3),
                Colors.white,
                Colors.white,
                Colors.black.withOpacity(.3)
              ], stops: const [
                0,
                0.3,
                .7,
                1
              ]).createShader(bounds);
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 30, bottom: 40, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      attribute.title,
                      style: style.copyWith(
                          color: (customColor ?? selectedColor).brighten(.2),
                          fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Builder(builder: (context) {
                    final desc = attribute.description();
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (desc.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            child: Text(
                              attribute.description(),
                              style: style.copyWith(fontSize: 16),
                            ),
                          ),
                      ],
                    );
                  }),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          left: -2,
                          top: 2,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Image.asset(
                              'assets/images/${attribute.icon}',
                              fit: BoxFit.scaleDown,
                              filterQuality: FilterQuality.none,
                              color: (customColor ?? selectedColor).darken(.5),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Image.asset(
                              'assets/images/${attribute.icon}',
                              fit: BoxFit.scaleDown,
                              filterQuality: FilterQuality.none,
                              color: customColor ?? selectedColor,
                            ),
                          ),
                        ),
                        Positioned.fill(
                            top: null,
                            bottom: -2,
                            left: -2,
                            child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(.5),
                                    BlendMode.modulate),
                                child: levelCountWidget)),
                        Positioned.fill(
                            top: null, bottom: 0, child: levelCountWidget),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 3),
                    child: Text(
                      attribute.isMaxLevel
                          ? "MAX"
                          : attribute.cost().toString(),
                      style: style.copyWith(
                          // fontStyle: FontStyle.italic,
                          fontSize: style.fontSize! * .9,
                          color: Colors.blueGrey.shade200),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
  final borderColor = ApolloColorPalette.deepBlue.color;

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
    }

    return Animate(
      effects: [
        CustomEffect(builder: (context, value, child) {
          return Container(
            color:
                ApolloColorPalette.darkestGray.color.withOpacity(.95 * value),
            child: child,
          );
        })
      ],
      child: Center(
        child: Column(
          children: [
            Expanded(
                child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
                dragDevices: {
                  // Allows to swipe in web browsers
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse
                },
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    for (var element in entries.keys)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 90,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Center(
                                    child: SizedBox(
                                      width: 400,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, bottom: 5),
                                        child: buildImageAsset(
                                            'assets/images/ui/banner.png'),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    element.name.titleCase,
                                    style: defaultStyle.copyWith(
                                        fontSize: 36,
                                        color: const Color.fromARGB(
                                            255, 202, 199, 164)),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn().moveY(),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxWidth: uiWidthMax * 1.25),
                              child: Builder(builder: (context) {
                                final children = entries[element]!;
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        alignment: WrapAlignment.center,
                                        children: children
                                            .animate(
                                                interval:
                                                    (.75 / children.length)
                                                        .seconds)
                                            .fadeIn(),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
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
                        "${playerData.experiencePoints} *icon*",
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
    );
  }
}
