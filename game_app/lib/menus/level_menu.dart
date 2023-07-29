import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/game_state_class.dart';
import 'package:game_app/resources/visuals.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:recase/recase.dart';
import '../resources/data_classes/player_data.dart';
import 'buttons.dart';
import '../resources/constants/routes.dart' as routes;
import 'menus.dart';

class LevelMenu extends StatefulWidget {
  const LevelMenu({
    super.key,
    required this.gameRef,
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
    if (!mounted) return;
    setState(() {});
  }

  void setSelectedLevel(int index) {
    playerData.selectedLevel = levels.elementAt(index);
    playerData.parentComponent?.notifyListeners();
    pageControllerLevel.animateToItem(index);
  }

  void setSelectedDifficulty(int index) {
    playerData.selectedDifficulty = GameDifficulty.values.elementAt(index);
    playerData.parentComponent?.notifyListeners();
    pageControllerDifficulty.animateToItem(index);
  }

  late Iterable<GameLevel> levels;
  @override
  void initState() {
    super.initState();
    gameState = widget.gameRef.gameStateComponent.gameState;
    levels = GameLevel.values.where((element) => element.name != "menu");
    selectedLevel = gameState.playerData.selectedLevel;

    playerDataNotifer =
        widget.gameRef.componentsNotifier<PlayerDataComponent>();
    playerData = gameState.playerData;
    playerDataNotifer.addListener(onPlayerDataNotification);

    pageControllerLevel = InfiniteScrollController(
        initialItem:
            levels.toList().indexWhere((element) => element == selectedLevel));
    pageControllerDifficulty = InfiniteScrollController(
        initialItem: playerData.selectedDifficulty.index);

    pageControllerDifficulty.jumpToItem(playerData.selectedDifficulty.index);
  }

  late GameLevel selectedLevel;

  Widget buildTile(GameLevel? level, GameDifficulty? difficulty, int index) {
    bool isHovering = false;
    bool isLevel = level != null;

    return StatefulBuilder(builder: (context, setstate) {
      bool isSelected = (level == selectedLevel) ||
          (difficulty == playerData.selectedDifficulty);
      Color hoverColor = isSelected
          ? Colors.white
          : isHovering
              ? buttonDownColor
              : buttonUpColor;
      return SizedBox(
        height: 200,
        width: 250,
        child: InkWell(
          radius: 10,
          onHover: (value) {
            setstate(
              () {
                isHovering = value;
              },
            );
          },
          onTap: () {
            if (isLevel) {
              setSelectedLevel(index);
            } else {
              setSelectedDifficulty(index);
            }
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: hoverColor, width: 6),
                bottom: BorderSide(color: hoverColor, width: 6),
                right: BorderSide(color: hoverColor, width: 6),
              ),
              color: (isSelected ? gameState.portalColor() : Colors.black)
                  .withOpacity(.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                level?.name.titleCase ?? difficulty?.name.titleCase ?? "",
                style: defaultStyle.copyWith(color: hoverColor),
              ),
            ),
          ),
        ),
      );
    });
  }

  Function? exitFunction;

  void onExit() {
    if (exitFunction != null) {
      exitFunction!();
    }
  }

  Widget buildPicker(bool isLevel) {
    return ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          return const LinearGradient(colors: [
            Colors.transparent,
            Colors.black,
            // Colors.black,
            Colors.transparent
          ], stops: [
            .2,
            .5,
            .8,
          ], begin: Alignment.bottomCenter, end: Alignment.topCenter)
              .createShader(bounds);
        },
        child: Align(
          child: SizedBox(
            width: 450,
            child: InfiniteCarousel.builder(
              scrollBehavior:
                  ScrollConfiguration.of(context).copyWith(dragDevices: {
                // Allows to swipe in web browsers
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse
              }, scrollbars: false),
              itemCount: isLevel ? levels.length : GameDifficulty.values.length,
              itemExtent: 120,
              center: true,
              velocityFactor: 0.2,
              // onIndexChanged: (index) {
              //   setSelectedLevel(index);
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
                    child: buildTile(element, null, itemIndex),
                  );
                } else {
                  final element = GameDifficulty.values.elementAt(itemIndex);

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: buildTile(null, element, itemIndex),
                  );
                }
              },
            ),
          ),
        ));
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

    return Stack(
      children: [
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: buildPicker(true)),
              const Spacer(),
              Expanded(child: buildPicker(false)),
            ],
          ),
        ),
        Positioned.fill(
          top: null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: CustomButton(
                  "Back",
                  gameRef: widget.gameRef,
                  onTap: () {
                    setState(() {
                      exitFunction = () {
                        widget.gameRef.gameStateComponent.gameState
                            .changeMainMenuPage(MenuPageType.weaponMenu);
                      };
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: CustomButton(
                  "Begin",
                  gameRef: widget.gameRef,
                  onTap: () {
                    setState(() {
                      exitFunction = () {
                        widget.gameRef.gameStateComponent.gameState
                            .toggleGameStart(routes.gameplay);
                      };
                    });
                  },
                ),
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
