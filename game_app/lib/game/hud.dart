import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game_app/game/player.dart';

import 'games.dart';

class GameHud extends Component with HasGameRef<GameplayGame> {
  final Player player;
  GameHud(this.player);

  @override
  FutureOr<void> onLoad() {
    positionType = PositionType.viewport;
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect((const Offset(10, 10) & const Size(100, 20)),
        Paint()..color = Colors.red);

    super.render(canvas);
  }
}
