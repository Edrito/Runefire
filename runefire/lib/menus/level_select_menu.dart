import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:recase/recase.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/menus/custom_button.dart';
import 'package:runefire/resources/constants/routes.dart' as routes;
import 'package:runefire/menus/menus.dart';

class LevelMenu extends StatefulWidget {
  const LevelMenu({
    required this.gameRef,
    super.key,
  });
  final GameRouter gameRef;

  @override
  State<LevelMenu> createState() => _LevelMenuState();
}

class _LevelMenuState extends State<LevelMenu> {
  late final GameState gameState;
  late ComponentsNotifier<PlayerDataComponent> playerDataNotifer;
  late final PlayerData playerData;
  late final InfiniteScrollController pageControllerLevel;
  late final InfiniteScrollController pageControllerDifficulty;
  @override
  void dispose() {
    playerDataNotifer.removeListener(onPlayerDataNotification);
    super.dispose();
  }

  void onPlayerDataNotification() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void setSelectedLevel(int index) {
    playerData.selectedLevel = levels.elementAt(index);
    playerData.parentComponent?.notifyListeners();

    if (!playerData.selectedDifficulty.isUnlocked(
      playerData,
      gameState.systemData,
      playerData.selectedLevel,
    )) {
      setSelectedDifficulty(1);
    }
  }

  void setSelectedDifficulty(int index) {
    playerData.selectedDifficulty = GameDifficulty.values.elementAt(index);
    playerData.parentComponent?.notifyListeners();
  }

  late Iterable<GameLevel> levels;

  late int diffCenter;
  late int gameLevelCenter;

  @override
  void initState() {
    super.initState();
    gameState = widget.gameRef.gameStateComponent.gameState;
    levels = GameLevel.values.where((element) => element.name != 'menu');
    selectedLevel = gameState.playerData.selectedLevel;

    playerDataNotifer =
        widget.gameRef.componentsNotifier<PlayerDataComponent>();
    playerData = gameState.playerData;
    playerDataNotifer.addListener(onPlayerDataNotification);

    pageControllerLevel = InfiniteScrollController(
      initialItem:
          levels.toList().indexWhere((element) => element == selectedLevel),
    );
    pageControllerDifficulty = InfiniteScrollController(
      initialItem: playerData.selectedDifficulty.index,
    );
    diffCenter = pageControllerDifficulty.initialItem;
    gameLevelCenter = pageControllerLevel.initialItem;
    // pageControllerDifficulty.jumpToItem(playerData.selectedDifficulty.index);
  }

  late GameLevel selectedLevel;

  Widget buildTile(
    GameLevel? level,
    GameDifficulty? difficulty,
    int index,
    InfiniteScrollController scrollController,
  ) {
    var isHovering = false;
    final isLevel = level != null;

    return StatefulBuilder(
      builder: (context, setstate) {
        final isSelected = (level == selectedLevel) ||
            (difficulty == playerData.selectedDifficulty);
        final isUnlocked = isLevel
            ? level.isUnlocked(playerData, gameState.systemData)
            : difficulty!.isUnlocked(
                playerData,
                gameState.systemData,
                playerData.selectedLevel,
              );

        late final Color color;
        if (!isUnlocked) {
          color = (isHovering
              // ? ApolloColorPalette.lightGray.color
              ? ApolloColorPalette.pink.color
              : ApolloColorPalette.mediumGray.color);
        } else {
          color = isSelected
              ? (ApolloColorPalette.offWhite.color)
              : isHovering
                  // ? colorPalette.primaryColor
                  ? ApolloColorPalette.pink.color
                  : colorPalette.secondaryColor;
        }
        final rowId = index;
        return SizedBox(
          height: 200,
          width: 250,
          child: CustomInputWatcher(
            onHover: (value) {
              setstate(
                () {
                  isHovering = value;
                },
              );
            },
            scrollController: scrollController,
            rowId: rowId,
            onPrimaryUp: () {
              if (!isUnlocked) {
                return;
              }
              if (isLevel) {
                setSelectedLevel(index);
              } else {
                setSelectedDifficulty(index);
              }
              (isLevel ? pageControllerLevel : pageControllerDifficulty)
                  .jumpToItem(
                index,
              );
            },
            onPrimary: () {},
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: color, width: 6),
                  bottom: BorderSide(color: color, width: 6),
                  top: BorderSide(color: color, width: 6),
                  right: BorderSide(color: color, width: 6),
                ),
                color: (isSelected
                        ? gameState.portalColor().darken(.5)
                        : Colors.black)
                    .withOpacity(1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  level?.name.titleCase ?? difficulty?.name.titleCase ?? '',
                  style: defaultStyle.copyWith(color: color),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Function? exitFunction;

  void onExit() {
    if (exitFunction != null) {
      exitFunction!.call();
    }
  }

  Widget buildPicker(bool isLevel) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black,
            // Colors.black,
            Colors.transparent,
          ],
          stops: [
            .2,
            .5,
            .8,
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(bounds);
      },
      child: Align(
        child: SizedBox(
          width: 450,
          child: InfiniteCarousel.builder(
            scrollBehavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
              scrollbars: false,
            ),
            itemCount: isLevel ? levels.length : GameDifficulty.values.length,
            itemExtent: 120,
            // onIndexChanged: (index) {
            //   if (isLevel) {
            //     gameLevelCenter = index;
            //   } else {
            //     diffCenter = index;
            //   }
            //   setState(() {});
            // },
            controller:
                isLevel ? pageControllerLevel : pageControllerDifficulty,
            axisDirection: Axis.vertical,
            loop: false,
            itemBuilder: (context, itemIndex, realIndex) {
              if (isLevel) {
                final element = levels.elementAt(itemIndex);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: buildTile(
                    element,
                    null,
                    itemIndex,
                    isLevel ? pageControllerLevel : pageControllerDifficulty,
                  ),
                );
              } else {
                final element = GameDifficulty.values.elementAt(itemIndex);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: buildTile(
                    null,
                    element,
                    itemIndex,
                    isLevel ? pageControllerLevel : pageControllerDifficulty,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    selectedLevel = gameState.playerData.selectedLevel;
    // final screenSize = MediaQuery.of(context).size;

    // final key = gameState.centerBackgroundKey;

    // if (key.currentContext != null) {
    //   final box = key.currentContext!.findRenderObject() as RenderBox;
    //   // final pos = box.localToGlobal(Offset.zero);
    //   width = box.size.width;
    // } else {
    // }
    final difficultyDescription =
        playerData.selectedDifficulty.difficultyDescription;
    return Stack(
      children: [
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: buildPicker(true)),
              Expanded(
                child: Column(
                  key: Key(playerData.selectedDifficulty.name),
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var i = 0; i < difficultyDescription.length; i++)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          difficultyDescription[i],
                          style: defaultStyle.copyWith(fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().fadeIn().moveY(begin: 5),
                    const SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
              Expanded(child: buildPicker(false)),
            ],
          ),
        ),
        Positioned.fill(
          top: null,
          child: Row(
            children: [
              const SizedBox(
                width: menuBaseBarWidthPadding,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: CustomButton(
                  'Back',
                  zHeight: 1,
                  rowId: 666,
                  gameRef: widget.gameRef,
                  onPrimary: () {
                    setState(() {
                      exitFunction = () {
                        widget.gameRef.gameStateComponent.gameState
                            .changeMainMenuPage(MenuPageType.weaponMenu);
                      };
                    });
                  },
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: CustomButton(
                  'Begin',
                  zHeight: 1,
                  rowId: 666,
                  gameRef: widget.gameRef,
                  onPrimary: () {
                    setState(() {
                      exitFunction = () {
                        widget.gameRef.gameStateComponent.gameState
                            .toggleGameStart(routes.gameplay);
                      };
                    });
                  },
                ),
              ),
              const SizedBox(
                width: menuBaseBarWidthPadding,
              ),
            ],
          ),
        ),
      ],
    )
        .animate(
          target: exitFunction != null ? 1 : 0,
          onComplete: (controller) {
            onExit();
          },
        )
        .fadeOut();
  }
}
