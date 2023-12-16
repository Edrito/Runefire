import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/achievements/achievements.dart';
import 'package:runefire/main.dart';
import 'package:runefire/menus/custom_button.dart';
import 'package:runefire/menus/menus.dart';
import 'package:runefire/menus/overlays.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/game_state_class.dart';

class AchievementsMenu extends StatelessWidget {
  const AchievementsMenu({required this.gameRef, super.key});
  final GameRouter gameRef;
  @override
  Widget build(BuildContext context) {
    final playerData = gameRef.playerDataComponent.dataObject;
    final achievements = Map<Achievements, bool>.fromEntries(
      Achievements.values.map(
        (e) => MapEntry(
          e,
          playerData.unlockedAchievements.contains(e),
        ),
      ),
    );
    final widgets = <Widget>[];
    for (final element in achievements.entries) {
      final achievement = element.key;
      final unlocked = element.value;
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: HintOverlayWidget(
            OverlayMessage(
              title: achievement.getInformation[0],
              description: achievement.getInformation[1].characters
                  .map((e) => unlocked ? e : '?')
                  .join(),
              image: achievement.getImage,
            ),
            alignment: CrossAxisAlignment.start,
          ),
        ),
      );
    }
    return Stack(
      children: [
        Positioned.fill(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SizedBox(
                width: uiWidthMax / 2,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widgets
                          .animate(
                            interval: .05.seconds,
                          )
                          .moveX()
                          .fadeIn(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: menuBaseBarWidthPadding,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomButton(
              'Back',
              gameRef: gameRef,
              onPrimary: () {
                gameRef.gameStateComponent.gameState
                    .changeMainMenuPage(MenuPageType.weaponMenu);
              },
            ),
          ),
        ),
      ],
    );
  }
}
