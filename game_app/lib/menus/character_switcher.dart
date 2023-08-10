import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/visuals.dart';
import 'package:recase/recase.dart';

import '../main.dart';

class CharacterSwitcher extends StatelessWidget {
  const CharacterSwitcher({
    super.key,
    required this.gameRef,
  });
  final GameRouter gameRef;

  Widget arrowButton({required bool isLeft}) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (BuildContext context, setState) {
        Color color = isHovered ? Colors.white : Colors.grey;

        return InkWell(
          splashFactory: NoSplash.splashFactory,
          onHover: (value) => setState(() {
            isHovered = value;
          }),
          onTap: () {
            int currentPlayerIndex =
                gameRef.playerDataComponent.dataObject.selectedPlayer.index;
            if (isLeft) {
              currentPlayerIndex--;
            } else {
              currentPlayerIndex++;
            }
            if (currentPlayerIndex >= CharacterType.values.length) {
              currentPlayerIndex = 0;
            } else if (currentPlayerIndex < 0) {
              currentPlayerIndex = CharacterType.values.length - 1;
            }
            gameRef.playerDataComponent.dataObject.selectedPlayer =
                CharacterType.values[currentPlayerIndex];
            gameRef.playerDataComponent.notifyListeners();
          },
          child: Icon(
            isLeft ? Icons.arrow_left : Icons.arrow_right,
            color: color,
            size: 150,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool currentIsUnlocked =
        gameRef.playerDataComponent.dataObject.characterUnlocked();
    return Align(
      alignment: Alignment.center,
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          arrowButton(isLeft: true),
          Row(
            children: [
              SizedBox(
                width: 250,
                child: Column(
                  children: [
                    Text(
                      currentIsUnlocked
                          ? gameRef.playerDataComponent.dataObject
                              .selectedPlayer.name.titleCase
                          : "???",
                      style: defaultStyle,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Information about character\nIf is unlocked, stats\nif hidden, how to unlock",
                      style: defaultStyle.copyWith(fontSize: 18),
                      textAlign: TextAlign.center,
                    )
                  ].animate().fadeIn(),
                ),
              ),
            ],
          ),
          arrowButton(isLeft: false),
        ],
      ),
    );
  }
}
