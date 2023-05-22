import 'package:game_app/providers.dart';
import 'game/games.dart';

dynamic getCurrentGameClass(CurrentGameState gameState) {
  switch (gameState) {
    case CurrentGameState.transition:
      break;
    case CurrentGameState.gameplay:
      return GameplayGame();
    default:
    // return MainMenuGame();
  }
}
