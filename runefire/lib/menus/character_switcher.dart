import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/menus/custom_widgets.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:recase/recase.dart';

import '../main.dart';

class CharacterSwitcher extends StatefulWidget {
  const CharacterSwitcher({
    super.key,
    required this.gameRef,
  });
  final GameRouter gameRef;

  @override
  State<CharacterSwitcher> createState() => _CharacterSwitcherState();
}

class _CharacterSwitcherState extends State<CharacterSwitcher> {
  Widget arrowButton({required bool isLeft}) {
    return Center(
      child: SizedBox(
          height: 50,
          child: ArrowButtonCustom(
            onHoverColor: colorPalette.secondaryColor,
            offHoverColor: colorPalette.primaryColor,
            key: UniqueKey(),
            onTap: () {
              int currentPlayerIndex = widget
                  .gameRef.playerDataComponent.dataObject.selectedPlayer.index;
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
              widget.gameRef.playerDataComponent.dataObject.selectedPlayer =
                  CharacterType.values[currentPlayerIndex];
              widget.gameRef.playerDataComponent.notifyListeners();
            },
            quaterTurns: isLeft ? 3 : 1,
          )),
    );
  }

  bool leftArrowHover = false;
  bool rightArrowHover = false;

  @override
  Widget build(BuildContext context) {
    bool currentIsUnlocked =
        widget.gameRef.playerDataComponent.dataObject.characterUnlocked();
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 100,
        child: Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            arrowButton(isLeft: true),
            const Spacer(),
            SizedBox(
              width: 250,
              child: Column(
                children: [
                  Text(
                    currentIsUnlocked
                        ? widget.gameRef.playerDataComponent.dataObject
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
            const Spacer(),
            arrowButton(isLeft: false),
          ],
        ),
      ),
    );
  }
}
