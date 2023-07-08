import 'package:game_app/game/enviroment.dart';

import '../resources/data_classes/player_data.dart';
import 'enviroment_mixin.dart';

class MenuGame extends Enviroment with PlayerFunctionality {
  bool initAddAttempt = false;
  @override
  void onLoad() async {
    game.componentsNotifier<PlayerDataComponent>().addListener(reAddPlayer);

    super.onLoad();
  }

  @override
  void onRemove() {
    game.componentsNotifier<PlayerDataComponent>().removeListener(reAddPlayer);
    super.onRemove();
  }

  @override
  void addPlayer() {
    if (!initAddAttempt) {
      initAddAttempt = true;
      return;
    }
    if (playerAdded) return;
    super.addPlayer();
    player?.isDisplay = true;
    player?.height = 2;
  }

  void reAddPlayer() async {
    removePlayer();
    addPlayer();
  }

  void removePlayer() {
    if (playerAdded) {
      player?.removeFromParent();
      player = null;
    }
  }
}
