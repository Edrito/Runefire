import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/menus/options.dart';
import 'package:runefire/menus/overlays.dart';
import 'package:runefire/menus/pause_menu.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:numerus/numerus.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/menus/custom_button.dart';

class GameWinDisplay extends StatefulWidget {
  const GameWinDisplay(this.gameRef, {super.key});
  final GameRouter gameRef;
  @override
  State<GameWinDisplay> createState() => _GameWinDisplayState();
}

class _GameWinDisplayState extends State<GameWinDisplay> {
  FocusNode node = FocusNode();
  late final GameEnviroment env;
  late final GameState gameState;
  late final GameRouter gameRouter;
  bool displayStats = false;

  bool fetchAttributeLogicChecker(Attribute element, bool isTemp) {
    final tempChecker = (element.attributeType.territory ==
                AttributeTerritory.statusEffect &&
            isTemp) ||
        (element.attributeType.territory != AttributeTerritory.statusEffect &&
            !isTemp);

    final permanentChecker =
        element.attributeType.territory != AttributeTerritory.permanent;
    return tempChecker && permanentChecker;
  }

  @override
  void initState() {
    super.initState();
    node.requestFocus();
    gameRouter = widget.gameRef;
    gameState = gameRouter.gameStateComponent.gameState;
    env = gameState.currentEnviroment! as GameEnviroment;
  }

  final Size cardSize = const Size(128, 96);
  bool testHoverTest = false;
  bool optionsEnabled = false;
  @override
  Widget build(BuildContext context) {
    final entries = env.player?.currentAttributes;

    final nonTempEntries = entries
            ?.where((element) => fetchAttributeLogicChecker(element, false))
            .toList() ??
        [];

    nonTempEntries.sort(
      (a, b) =>
          a.attributeType.rarity.index.compareTo(b.attributeType.rarity.index),
    );

    nonTempEntries.sort((b, a) => a.upgradeLevel.compareTo(b.upgradeLevel));

    return Container(
      color: ApolloColorPalette.darkestGray.color.withOpacity(.8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 900),
          child: Column(
            children: [
              CustomButton(
                displayStats ? 'Hide Stats' : 'Show Stats',
                gameRef: gameRouter,
                rowId: 1,
                onPrimary: () {
                  setState(() {
                    displayStats = !displayStats;
                  });
                },
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: displayStats
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: OverlayWidgetDisplay(
                                  gameRouter,
                                  child: StatsDisplay(
                                    gameRef: gameRouter,
                                    statStrings:
                                        env.player?.buildStatStrings(false),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: OverlayWidgetDisplay(
                                  gameRouter,
                                  child: EndGameDisplay(
                                    gameRef: widget.gameRef,
                                    player: gameState.currentPlayer!,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: OverlayWidgetDisplay(
                            gameRouter,
                            child: AttributeDisplay(
                              gameRef: gameRouter,
                              attributes: nonTempEntries,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomButton(
                'Continue',
                gameRef: gameRouter,
                upDownColor: (
                  colorPalette.primaryColor.brighten(.5),
                  colorPalette.primaryColor
                ),
                rowId: 5,
                onPrimary: () {
                  gameState.resumeGame();
                  gameState.endGame(EndGameState.win);
                },
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }
}

class EndGameDisplay extends StatefulWidget {
  const EndGameDisplay({
    required this.gameRef,
    required this.player,
    super.key,
  });
  final GameRouter gameRef;
  final Player player;
  @override
  State<EndGameDisplay> createState() => _EndGameDisplayState();
}

class _EndGameDisplayState extends State<EndGameDisplay> {
  static const double duration = .25;
  static const int textTicksPerSecond = 30;
  final Map<String, (Timer, double)> timers = {};

  void initExperienceEntryTimer(
    EndGameExperienceEntry data,
    Function statefulSetState,
  ) {
    timers[data.label] ??= (
      Timer.periodic((duration / (duration * textTicksPerSecond)).seconds,
          (timer) {
        final previousScore = timers[data.label]!.$2;

        if (!mounted || previousScore >= data.amount) {
          timer.cancel();
          if (mounted) {
            statefulSetState(() {
              timers[data.label] = (timer, data.amount);
              numberAnimationCompleteAnimation[data.label] = true;
            });
            if (timers.values.fold(
              true,
              (previousValue, element) => previousValue && !element.$1.isActive,
            )) {
              setState(() {
                totalWidget =
                    buildTextWidget(totalEntry).animate().moveX().fadeIn();
              });
            }
          }

          return;
        }
        statefulSetState(() {
          timers[data.label] = (
            timer,
            previousScore + (data.amount / (duration * textTicksPerSecond))
          );
        });
      }),
      0
    );
  }

  Map<String, bool> numberAnimationCompleteAnimation = {};

  Widget buildTextWidget(EndGameExperienceEntry data) {
    return StatefulBuilder(
      builder: (context, setStateBuilder) {
        initExperienceEntryTimer(data, setStateBuilder);
        numberAnimationCompleteAnimation[data.label] ??= false;
        final number = timers[data.label]?.$2.toStringAsFixed(1) ?? '0';
        var style = defaultStyle;
        if (data.damageType != null) {
          style = style.copyWith(color: data.damageType!.color);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                data.label,
                style: style,
              ),
            ),
            Text(
              number,
              style: style,
            )
                .animate(
                  target:
                      (numberAnimationCompleteAnimation[data.label] ?? false)
                          ? 1
                          : 0,
                  onComplete: (controller) => controller.reverse(),
                )
                .scaleXY(
                  begin: 1,
                  end: 1.2,
                  duration: .1.seconds,
                  curve: Curves.easeInOut,
                ),
            if (data.rating != null) ...[
              // const SizedBox(
              //   width: 12,
              // ),
              // SizedBox.square(
              //   dimension: 64,
              //   child: buildImageAsset(
              //     ImagesAssetsExperience.all.path,
              //     fit: BoxFit.fitHeight,
              //   ),
              // ),
              const SizedBox(
                width: 64,
              ),
              Container(
                transform: Matrix4.identity()..rotateZ(12 * 3.1415927 / 180),
                child: Text(
                  data.rating!,
                  style: style.copyWith(
                    fontSize: style.fontSize! * 3,
                    color: colorPalette.secondaryColor,
                  ),
                )
                    .animate(
                      target: (numberAnimationCompleteAnimation[data.label] ??
                              false)
                          ? 1
                          : 0,
                    )
                    .scaleXY(
                      begin: 3,
                      end: 1,
                      duration: .5.seconds,
                      curve: Curves.bounceOut,
                    )
                    .fadeIn(),
              ),
            ],
          ],
        );
      },
    );
  }

  late final Timer addEntryTimer;

  List<EndGameExperienceEntry> statsToAdd = [];
  List<Widget> widgetsToDisplay = [];
  Widget? totalWidget;

  late final EndGameExperienceEntry totalEntry;

  @override
  void initState() {
    super.initState();
    statsToAdd = widget.player.buildEndGameEntries();
    totalEntry = statsToAdd
        .removeAt(statsToAdd.indexWhere((element) => element.isTotal));
    addEntryTimer = Timer.periodic(.2.seconds, (timer) {
      if ((timer.tick - 1) >= statsToAdd.length || !mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        widgetsToDisplay.add(buildTextWidget(statsToAdd[timer.tick - 1]));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ScrollConfiguration(
            behavior: scrollConfiguration(context),
            child: SingleChildScrollView(
              child: Column(
                children: widgetsToDisplay.animate().moveX().fadeIn(),
              ),
            ),
          ),
        ),
        if (totalWidget != null) totalWidget!,
      ],
    );
  }
}
