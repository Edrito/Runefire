// ignore_for_file: unused_import

import 'package:flame/components.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/game/enviroment.dart';
import 'package:game_app/resources/enums.dart';

void conductTests(GameEnviroment gameEnviroment) {
  Future.delayed(3.seconds).then((value) {
    gameEnviroment.player?.addBodyEntity(
        EnemyType.mushroomSpinner.build(Vector2.zero(), gameEnviroment, 1));
  });
  Future.delayed(4.seconds).then((value) {
    gameEnviroment.player?.addBodyEntity(
        EnemyType.mushroomSpinner.build(Vector2.zero(), gameEnviroment, 1));
  });
  Future.delayed(5.seconds).then((value) {
    gameEnviroment.player?.addBodyEntity(
        EnemyType.mushroomSpinner.build(Vector2.zero(), gameEnviroment, 1));
  });
}
