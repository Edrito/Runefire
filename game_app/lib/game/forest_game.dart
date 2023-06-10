import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:game_app/entities/enemy.dart';
import 'package:game_app/entities/player.dart';
import '../resources/classes.dart';
import '../resources/enums.dart';
import 'background.dart';

extension PositionProvider on Player {
  Vector2 get position => body.worldCenter;
}

class ForestGame extends GameEnviroment {
  late EnemyManagement enemyManagement;
  late BackgroundComponent forestBackground;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    forestBackground = level.buildBackground(this);
    add(forestBackground);
    enemyManagement = EnemyManagement(this);
    add(enemyManagement);
  }

  @override
  GameLevel level = GameLevel.forest;
}

class ForestBackground extends BackgroundComponent {
  ForestBackground(super.gameRef);

  @override
  GameLevel get gameLevel => GameLevel.forest;
}
