import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/menus/custom_button.dart';
import 'package:runefire/menus/custom_widgets.dart';
import 'package:runefire/menus/elemental_power_level.dart';
import 'package:runefire/menus/menus.dart';
import 'package:runefire/menus/pause_menu.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:recase/recase.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/menus/attribute_card.dart';
import 'package:runefire/menus/components_notifier_builder.dart';

class AttributeSelection extends StatefulWidget {
  const AttributeSelection(this.gameRouter, {super.key});
  final GameRouter gameRouter;
  @override
  State<AttributeSelection> createState() => _AttributeSelectionState();
}

class _AttributeSelectionState extends State<AttributeSelection> {
  late final GameRouter gameRouter = widget.gameRouter;
  late final Player? player = GameState().currentPlayer;
  late final List<Attribute> currentAttributeSelection =
      player?.buildAttributeSelection() ?? [];

  final ScrollController scrollController = ScrollController();

  late final Attribute xpAttribute = player!.buildXpAttribute();
  @override
  void initState() {
    assert(player != null, 'Player should not be null, if leveling up!');
    cardSelected[xpAttribute] ??= false;
    for (final element in currentAttributeSelection) {
      cardSelected[element] ??= false;
    }
    Future.delayed(levelUpSelectDelay)
        .then((value) => allowSelection.complete());
    super.initState();
  }

  Completer allowSelection = Completer();

  bool ignoring = false;
  static const double loadInDuration = .2;
  static const double exitAnimationDuration = .2;

  CustomCard buildWidget({
    required Attribute attribute,
    required Function(DamageType? damageType) onTap,
    bool small = false,
  }) {
    return CustomCard(
      attribute,
      gameRef: GameState().gameRouter,
      rowId: small ? 3 : 1,
      onPrimary: onTap,
      smallCard: small,
    );
  }

  void onSelectAttribute(Attribute attribute, {DamageType? damageType}) {
    if (!allowSelection.isCompleted) {
      return;
    }
    setState(() {
      ignoring = true;
      cardSelected[attribute] = true;
      player?.addAttribute(attribute.attributeType, damageType: damageType);
      Future.delayed(exitAnimationDuration.seconds).then((value) {
        onAnimationComplete();
      });
    });
  }

  bool get selectionFinished =>
      cardSelected.entries.any((element) => element.value);

  Map<Attribute, bool> cardSelected = {};

  void onAnimationComplete() {
    gameRouter.resumeEngine();

    Future.delayed(exitAnimationDuration.seconds).then(
      (value) => {
        gameRouter.gameStateComponent.gameState.resumeGame(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final buildWidgets = <Widget>[];
    late Widget xpCardWidget;

    for (final element in currentAttributeSelection) {
      final Widget card = buildWidget(
        attribute: element,
        onTap: (damageType) {
          onSelectAttribute(element, damageType: damageType);
        },
      )
          .animate(
            target: cardSelected[element] ?? false ? 1 : 0,
          )
          .fadeOut()
          .moveY(end: -50);
      buildWidgets.add(card);
    }

    xpCardWidget = buildWidget(
      attribute: xpAttribute,
      onTap: (damageType) {
        onSelectAttribute(xpAttribute, damageType: damageType);
      },
      small: true,
    )
        .animate(
          target: cardSelected[xpAttribute] ?? false ? 1 : 0,
        )
        .fadeOut()
        .moveY();

    return Animate(
      effects: [
        FadeEffect(
          duration: exitAnimationDuration.seconds,
          begin: 1,
          end: 0,
          curve: Curves.easeInOut,
        ),
      ],
      target: selectionFinished ? 1 : 0,
      autoPlay: false,
      child: Material(
        color: ApolloColorPalette.darkestGray.color.withOpacity(.75),
        child: IgnorePointer(
          ignoring: ignoring,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  right: 0,
                  left: 0,
                  height: size.height * .6,
                  child: const StarBackstripe(
                    percentOfHeight: .6,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      'Choose an attribute',
                      textAlign: TextAlign.center,
                      style: defaultStyle.copyWith(fontSize: 60),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: ScrollConfiguration(
                      behavior: scrollConfiguration(context),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              runAlignment: WrapAlignment.center,
                              spacing: 16,
                              runSpacing: 16,
                              children: [...buildWidgets]
                                  .animate(
                                    interval: (loadInDuration / 3).seconds,
                                  )
                                  .fadeIn(
                                    duration: loadInDuration.seconds,
                                    curve: Curves.decelerate,
                                  )
                                  .moveY(
                                    duration: loadInDuration.seconds,
                                    curve: Curves.decelerate,
                                    begin: 50,
                                    end: 0,
                                  ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: xpCardWidget,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  top: null,
                  left: null,
                  right: null,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: TotalPowerGraph(
                      player: player!,
                      showTitle: false,
                      zHeight: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
