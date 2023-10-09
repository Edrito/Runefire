import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/visuals.dart';
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
    final zRotation = -balancedFrac;
    Color? customColor = attribute.damageType?.color;
    bool isMaxLevel = attribute.isMaxLevel;

    Widget returnWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Transform(
        transform:
            Matrix4.translationValues(xTransform, yTransform, zTransform),
        child: Container(
          height: 15,
          transformAlignment: Alignment.topCenter,
          transform: Matrix4.rotationZ(zRotation),
          child: buildImageAsset(
              isUnlocked
                  ? ImagesAssetsPermanentAttributes.rune.path
                  : ImagesAssetsPermanentAttributes.runeLocked.path,
              fit: BoxFit.contain,
              color: isMaxLevel
                  ? (customColor ?? colorPalette.primaryColor).darken(.4)
                  : null),
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
    late Function setState;
    bool isMaxLevel = attribute.isMaxLevel;
    Color? customColor = isSelected
        ? attribute.damageType?.color.brighten(1)
        : attribute.damageType?.color;
    Color selectedColor = isSelected
        ? ApolloColorPalette.offWhite.color
        : colorPalette.secondaryColor;

    if (isMaxLevel) {
      selectedColor = (customColor ?? colorPalette.primaryColor).darken(.4);
      customColor = selectedColor;
    }

    final style = defaultStyle.copyWith(
        fontSize: 20, color: ApolloColorPalette.offWhite.color);
    String icon =
        'assets/images/ui/permanent_attributes/${attribute.attributeType.category.name}.png';
    final levelCountWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(children: [
        for (var i = 0; i < attribute.maxLevel!; i++)
          buildLevelIndicator(
              i < attribute.upgradeLevel, (i / (attribute.maxLevel! - 1))),
      ]),
    );
    bool isHovered = false;
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          isHovered = true && !isMaxLevel;
        });
      },
      onExit: (event) {
        setState(() {
          isHovered = false;
        });
      },
      child: StatefulBuilder(builder: (context, ss) {
        setState = ss;
        return SizedBox(
          height: 250,
          width: 200,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  ImagesAssetsUi.book.path,
                  fit: BoxFit.fitHeight,
                  filterQuality: FilterQuality.none,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(colors: [
                    ApolloColorPalette.darkestGray.color.withOpacity(.1),
                    ApolloColorPalette.offWhite.color,
                    ApolloColorPalette.offWhite.color,
                    ApolloColorPalette.darkestGray.color.withOpacity(.1)
                  ], stops: const [
                    0,
                    0.25,
                    .75,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: Text(
                          attribute.title,
                          style: style.copyWith(
                              color: (customColor ?? selectedColor),
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
                                  style: style.copyWith(
                                      fontSize: 16,
                                      color: (customColor ?? selectedColor)),
                                ),
                              ),
                          ],
                        );
                      }),
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              left: -4,
                              bottom: 32,
                              top: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: buildImageAsset(icon,
                                    color: (customColor ?? selectedColor),
                                    fit: BoxFit.contain),
                              ),
                            ),
                            Positioned.fill(
                              bottom: 32,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child:
                                    buildImageAsset(icon, fit: BoxFit.contain),
                              ),
                            ),
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
                              color: (customColor ?? selectedColor)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
            .animate(target: isHovered ? 1 : 0)
            .scaleXY(
                begin: 1,
                end: 1.025,
                curve: Curves.easeIn,
                duration: .1.seconds)
            .rotate(
                begin: 0,
                end: .005,
                curve: Curves.easeIn,
                duration: .1.seconds);
      }),
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

        final attr = e.buildAttribute(level, null) as PermanentAttribute;
        bool isMaxLevel = attr.isMaxLevel;
        return InkWell(
          onTap: isMaxLevel
              ? null
              : () {
                  setState(() {
                    selectedAttribute = e;
                  });
                },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AttributeTile(attr, selectedAttribute == e),
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
              behavior: scrollConfiguration(context),
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
                                            ImagesAssetsUi.banner.path),
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
                                        // shadows: [
                                        //   colorPalette
                                        //       .buildShadow(ShadowStyle.medium)
                                        // ],
                                        color:
                                            ApolloColorPalette.offWhite.color),
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
            SizedBox(
              height: menuBaseBarHeight,
              child: Row(
                children: [
                  const SizedBox(
                    width: menuBaseBarWidthPadding,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CustomButton(
                          "Back",
                          gameRef: widget.gameRef,
                          onPrimary: () => widget.onBack(),
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
                          onPrimary: () {
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(),
                          Center(
                            child: Text(
                              "${playerData.experiencePoints}",
                              style: defaultStyle,
                            ),
                          ),
                          buildImageAsset(ImagesAssetsExperience.all.path,
                              fit: BoxFit.fitHeight)
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: menuBaseBarWidthPadding,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
