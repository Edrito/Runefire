import 'dart:async';

import 'package:flame/components.dart';
import 'package:runefire/events/event_management.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:uuid/uuid.dart';

import 'package:runefire/game/enviroment_mixin.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/enemies/enemy.dart';

enum SpawnLocation {
  inside,
  outside,
  both,
  entireMap,
  mouse,
  onPlayer,
  infrontOfPlayer,
}

extension SpawnLocationExtension on SpawnLocation {
  Vector2 grabNewPosition(GameEnviroment gameEnviroment, [double? randomize]) {
    Vector2 position;
    switch (this) {
      case SpawnLocation.both:
        position = generateRandomGamePositionInViewport(
          rng.nextBool(),
          gameEnviroment,
        );
        break;
      case SpawnLocation.inside:
        position = generateRandomGamePositionInViewport(true, gameEnviroment);

        break;
      case SpawnLocation.onPlayer:
        position = gameEnviroment.player?.center ?? Vector2.zero();
        break;
      case SpawnLocation.infrontOfPlayer:
        position = gameEnviroment.player!.center +
            gameEnviroment.player!.body.linearVelocity;
        break;
      case SpawnLocation.outside:
        position = generateRandomGamePositionInViewport(false, gameEnviroment);

        break;
      case SpawnLocation.entireMap:
        position =
            (Vector2.random() * gameEnviroment.boundsDistanceFromCenter * 2) -
                Vector2.all(gameEnviroment.boundsDistanceFromCenter);

        break;
      case SpawnLocation.mouse:
        position =
            gameEnviroment.player!.aimPosition! + gameEnviroment.player!.center;

        break;
      default:
        position = Vector2.zero();
    }

    if (randomize != null) {
      position += ((Vector2.random() * 2) - Vector2.all(1)) * randomize;
    }

    return position;
  }
}

enum OnSpawnEnd {
  instantKill,
  periodicallyKill,
  noKill,
}

abstract class GameEvent {
  GameEvent(
    this.gameEnviroment,
    this.eventManagement, {
    required this.eventBeginEnd,
    required this.eventTriggerInterval,
  }) {
    eventId = const Uuid().v4();
  }

  late final String eventId;
  final EventManagement eventManagement;
  final GameEnviroment gameEnviroment;

  bool hasCompleted = false;

  void endEvent();

  final (double, double?) eventBeginEnd;

  final (double, double) eventTriggerInterval;

  Future<void> onGoingEvent();

  void startEvent();
}

abstract class PositionEvent extends GameEvent {
  PositionEvent(
    super.gameEnviroment,
    super.eventManagement, {
    required super.eventBeginEnd,
    required super.eventTriggerInterval,
    this.spawnLocation,
    this.spawnPosition,
  });

  final SpawnLocation? spawnLocation;
  final Vector2? spawnPosition;
}
