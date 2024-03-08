import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/menus/custom_widgets.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:recase/recase.dart';

import 'package:runefire/main.dart';

class CharacterSwitcher extends StatefulWidget {
  const CharacterSwitcher({
    required this.gameRef,
    super.key,
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
          onHoverColor: colorPalette.primaryColor,
          offHoverColor: colorPalette.secondaryColor,
          rowId: 5,
          groupOrientation: Axis.horizontal,
          onPrimary: () {
            var currentPlayerIndex = widget
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCharacter =
        widget.gameRef.playerDataComponent.dataObject.selectedPlayer;
    final currentIsUnlocked =
        widget.gameRef.playerDataComponent.dataObject.characterUnlocked();
    return Align(
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
              width: 300,
              key: ValueKey(selectedCharacter),
              child: Column(
                children: [
                  Text(
                    currentIsUnlocked
                        ? selectedCharacter.name.titleCase
                        : '???',
                    style: defaultStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    currentIsUnlocked
                        ? selectedCharacter.characterCharacteristics
                        : selectedCharacter.howToUnlock,
                    style: defaultStyle.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ].animate().fadeIn().scale(
                      begin: const Offset(1.1, 1.1),
                      end: const Offset(1, 1),
                    ),
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
