// ignore_for_file: unused_import

import 'package:flame/components.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/game/enviroment.dart';
import 'package:game_app/game/event_management.dart';
import 'package:game_app/game/expendables.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/enums.dart';

import 'entities/child_entities.dart';

void conductTests(GameEnviroment gameEnviroment) {
  // Future.delayed(1.seconds).then((value) {
  //   gameEnviroment.player?.pickupExpendable(
  //       ExpendableType.fearEnemies.build(gameEnviroment.player!));
  // });

  // for (var element in ExpendableType.values) {
  //   Future.delayed(1.seconds).then((value) {
  //     gameEnviroment.physicsComponent.add(InteractableExpendable(
  //         expendableType: element,
  //         initialPosition: SpawnLocation.inside.grabNewPosition(gameEnviroment),
  //         gameEnviroment: gameEnviroment));
  //   });
  // }

  // for (var i = 0; i < 30; i++) {
  //   Future.delayed((3 + (i * .1)).seconds).then((value) {
  //     gameEnviroment.player?.addBodyEntity(TeslaCrystal(
  //         initialPosition: Vector2.zero(),
  //         parentEntity: gameEnviroment.player!,
  //         distance: rng.nextInt(3).toDouble() / 2,
  //         enviroment: gameEnviroment,
  //         upgradeLevel: 1));
  //   });
  // }
}
