import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/main.dart';
import 'package:runefire/menus/custom_widgets.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/data_classes/system_data.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:recase/recase.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:runefire/attributes/attributes_permanent.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/menus/custom_button.dart';

class PermanentAttributeTile extends StatelessWidget {
  const PermanentAttributeTile({
    required this.attribute,
    required this.isHovered,
    required this.isSelected,
    super.key,
  });
  final bool isHovered;
  final bool isSelected;
  final PermanentAttribute attribute;

  Widget buildLevelIndicator({required bool isUnlocked}) {
    final customColor = attribute.damageType?.color;
    final isMaxLevel = attribute.isMaxLevel;
    Widget returnWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Container(
        height: 32,
        transformAlignment: Alignment.topCenter,
        child: Text(
          '|',
          style: defaultStyle.copyWith(
            color: !isUnlocked || isMaxLevel
                ? (customColor ?? colorPalette.primaryColor).darken(.4)
                : customColor,
            fontSize: 32,
          ),
        ),
      ),
    );

    if (isUnlocked) {
      returnWidget =
          Animate(effects: const [FadeEffect()], child: returnWidget);
    }
    return returnWidget;
  }

  @override
  Widget build(BuildContext context) {
    final isMaxLevel = attribute.isMaxLevel;

    var customColor = isSelected
        ? ApolloColorPalette.offWhite.color
        : attribute.damageType?.color;
    var selectedColor = isSelected
        ? ApolloColorPalette.pink.color
        : colorPalette.secondaryColor;
    if (isMaxLevel) {
      selectedColor = (customColor ?? colorPalette.primaryColor).darken(.4);
      customColor = selectedColor;
    }

    final style = defaultStyle.copyWith(
      fontSize: 20,
      color: ApolloColorPalette.offWhite.color,
    );
    final icon =
        'assets/images/ui/permanent_attributes/${attribute.attributeType.category.name}.png';
    final levelCountWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < attribute.maxLevel!; i++)
            buildLevelIndicator(
              isUnlocked: i < attribute.upgradeLevel,
            ),
        ],
      ),
    );

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
              return LinearGradient(
                colors: [
                  ApolloColorPalette.darkestGray.color.withOpacity(.1),
                  ApolloColorPalette.offWhite.color,
                  ApolloColorPalette.offWhite.color,
                  ApolloColorPalette.darkestGray.color.withOpacity(.1),
                ],
                stops: const [
                  0,
                  0.25,
                  .75,
                  1,
                ],
              ).createShader(bounds);
            },
            child: Padding(
              padding: const EdgeInsets.only(
                top: 30,
                bottom: 40,
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      attribute.title,
                      style: style.copyWith(
                        color: customColor ?? selectedColor,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final desc = attribute.description();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (desc.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              child: Text(
                                desc,
                                style: style.copyWith(
                                  fontSize: 16,
                                  color: customColor ?? selectedColor,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          left: -4,
                          bottom: 32,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: buildImageAsset(
                              icon,
                              color: customColor ?? selectedColor,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          bottom: 32,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: buildImageAsset(icon, fit: BoxFit.contain),
                          ),
                        ),
                        Positioned.fill(
                          top: null,
                          child: levelCountWidget,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 3),
                    child: Text(
                      attribute.isMaxLevel
                          ? 'MAX'
                          : attribute.cost().toString(),
                      style: style.copyWith(
                        // fontStyle: FontStyle.italic,
                        fontSize: style.fontSize! * .9,
                        color: customColor ?? selectedColor,
                      ),
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
          duration: .1.seconds,
        )
        .rotate(
          begin: 0,
          end: .005,
          curve: Curves.easeIn,
          duration: .1.seconds,
        );
  }
}

class AttributeUpgrader extends StatefulWidget {
  const AttributeUpgrader({
    required this.onBack,
    required this.gameRef,
    super.key,
  });

  final GameRouter gameRef;
  final Function() onBack;

  @override
  State<AttributeUpgrader> createState() => _AttributeUpgraderState();
}

class _AttributeUpgraderState extends State<AttributeUpgrader> {
  final borderColor = ApolloColorPalette.deepBlue.color;
  final borderWidth = 5.0;

  late PlayerData playerData;
  late PlayerDataComponent playerDataComponent;
  late ComponentsNotifier<PlayerDataComponent> playerDataNotifier;
  ScrollController scrollController = ScrollController();

  AttributeType? hoveredAttribute;
  AttributeType? selectedAttribute;

  void onPlayerDataNotification() {
    setState(() {});
  }

  void selectAttribute(AttributeType attributeType) {}

  @override
  void dispose() {
    playerDataNotifier.removeListener(onPlayerDataNotification);

    InputManager().removeKeyListener(onKeyEvent);
    InputManager().removeGamepadEventListener(onGamepadEvent);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    playerDataComponent = widget.gameRef.playerDataComponent;
    playerDataNotifier =
        widget.gameRef.componentsNotifier<PlayerDataComponent>();
    playerData = playerDataComponent.dataObject;
    playerDataNotifier.addListener(onPlayerDataNotification);

    InputManager().addKeyListener(onKeyEvent);
    InputManager().addGamepadEventListener(onGamepadEvent);
  }

  void onKeyEvent(KeyEvent event) {
    if (event is! KeyUpEvent) {
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      unlockAttribute();
    }
  }

  void onGamepadEvent(GamepadEvent event) {
    if (event.pressState != PressState.released) {
      return;
    }

    if (event.button == GamepadButtons.buttonA ||
        event.button == GamepadButtons.buttonStart) {
      unlockAttribute();
    }
  }

  //TODO Add undo button
  List<AttributeType> previousUnlockedAttributes = [];

  void unlockAttribute() {
    final result = playerData
        .unlockPermanentAttribute(selectedAttribute ?? hoveredAttribute);
    if (result) {
      previousUnlockedAttributes.add(selectedAttribute ?? hoveredAttribute!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final entries = <AttributeCategory, List<Widget>>{};
    final list = AttributeType.values
        .where((element) => element.territory == AttributeTerritory.permanent)
        .toList();
    final listOfCat = AttributeCategory.values.toList();
    var i = 0;
    for (final element in listOfCat) {
      final tempList = list.where((elementD) => elementD.category == element);
      if (tempList.isEmpty) {
        continue;
      }

      entries[element] = tempList.map((e) {
        final level =
            playerDataComponent.dataObject.unlockedPermanentAttributes[e] ?? 0;

        final attr = e.buildAttribute(level, null, builtForInfo: true)
            as PermanentAttribute;
        Function? setStateMiniCopy;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomInputWatcher(
            rowId: i,
            scrollController: scrollController,
            zIndex: 1,
            onPrimary: () {
              setState(() {
                selectedAttribute = e;
              });
            },
            onHover: (isHover) {
              if (!isHover && hoveredAttribute == e) {
                setStateMiniCopy?.call(() {
                  hoveredAttribute = null;
                });
              } else if (isHover) {
                setStateMiniCopy?.call(() {
                  hoveredAttribute = e;
                });
              }
            },
            child: StatefulBuilder(
              builder: (context, setStateMini) {
                setStateMiniCopy ??= setStateMini;
                return PermanentAttributeTile(
                  attribute: attr,
                  isHovered: hoveredAttribute == e,
                  isSelected: selectedAttribute == e,
                );
              },
            ),
          ),
        );
      }).toList();
      i++;
    }

    return Animate(
      effects: [
        CustomEffect(
          builder: (context, value, child) {
            return Container(
              color:
                  ApolloColorPalette.darkestGray.color.withOpacity(.95 * value),
              child: child,
            );
          },
        ),
      ],
      child: Center(
        child: Column(
          children: [
            Expanded(
              child: ScrollConfiguration(
                behavior: scrollConfiguration(context),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      for (final element in entries.keys)
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
                                            left: 15,
                                            bottom: 5,
                                          ),
                                          child: buildImageAsset(
                                            ImagesAssetsUi.banner.path,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    child: Text(
                                      element.name.titleCase,
                                      style: defaultStyle.copyWith(
                                        fontSize: 36,
                                        color:
                                            ApolloColorPalette.offWhite.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn().moveY(),
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: uiWidthMax * 1.25,
                                ),
                                child: Builder(
                                  builder: (context) {
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
                                                          .seconds,
                                                )
                                                .fadeIn(),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: menuBaseBarHeight,
              child: Row(
                children: [
                  const SizedBox(
                    width: menuBaseBarWidthPadding,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CustomButton(
                        'Back',
                        zIndex: 1,
                        zHeight: 10,
                        rowId: 500,
                        gameRef: widget.gameRef,
                        onPrimary: () => widget.onBack(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: CustomButton(
                          'Unlock',
                          zIndex: 1,
                          zHeight: 10,
                          rowId: 500,
                          gameRef: widget.gameRef,
                          onPrimary: () {
                            unlockAttribute();
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExperiencePointsIndicator(widget.gameRef),
                  ),
                  const SizedBox(
                    width: menuBaseBarWidthPadding,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
