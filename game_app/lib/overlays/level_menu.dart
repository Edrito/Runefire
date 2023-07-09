import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/visuals.dart';
import 'package:recase/recase.dart';
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
  GameLevel selectedLevel = GameLevel.values.first;

  Widget buildTile(GameLevel level) {
    bool isHovering = false;

    return StatefulBuilder(builder: (context, setstate) {
      bool isSelected = level == selectedLevel;
      Color hoverColor = isSelected
          ? Colors.blue
          : isHovering
              ? buttonDownColor
              : buttonUpColor;
      return SizedBox.square(
        dimension: 200,
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
            setState(() {
              selectedLevel = level;
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: hoverColor, width: 6),
                bottom: BorderSide(color: hoverColor, width: 6),
                right: BorderSide(color: hoverColor, width: 6),
              ),
              // borderRadius: const BorderRadius.all(Radius.circular(5))
              // color: isSelected ? Colors.blue : hoverColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                level.name.titleCase,
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

  @override
  Widget build(BuildContext context) {
    List<Widget> levels = [];

    for (var element
        in GameLevel.values.where((element) => element.name != "menu")) {
      levels.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: buildTile(element),
      ));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: levels
                .animate(interval: .1.seconds)
                .moveY(
                    begin: 20,
                    curve: Curves.fastEaseInToSlowEaseOut,
                    duration: 1.seconds)
                .fadeIn(
                    curve: Curves.fastEaseInToSlowEaseOut, duration: 1.seconds),
          ),
        ),
        const Spacer(),
        Row(
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
                      changeMainMenuPage(MenuPages.weaponMenu);
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
                      toggleGameStart(routes.gameplay);
                    };
                  });
                },
              ),
            ),
          ],
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
