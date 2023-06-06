import 'dart:async';
import '../resources/classes.dart';
import 'main_game.dart';

class HomeRoom extends GameEnviroment {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  GameLevel level = GameLevel.home;
}
