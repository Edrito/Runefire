import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game_app/game/player.dart';

import 'games.dart';

class GameHud extends Component {
  final Player player;
  GameHud(this.player);
  int fps = 0;
  late final TextComponent fpsCounter;

  @override
  FutureOr<void> onLoad() {
    positionType = PositionType.viewport;
    fpsCounter = TextComponent(
        anchor: Anchor.topLeft,
        position: Vector2((findParent() as GameplayGame).canvasSize.x - 50, 5),
        text: fps.toString());
    add(fpsCounter);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (dt != 0) {
      fps = (1 / dt).round();
    }
    fpsCounter.text = fps.toString();
    fpsCounter.position.x = (findParent() as GameplayGame).canvasSize.x - 50;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect((const Offset(10, 10) & const Size(100, 10)),
        Paint()..color = Colors.grey);
    canvas.drawRect((const Offset(10, 25) & const Size(100, 10)),
        Paint()..color = Colors.grey);
    canvas.drawRect((const Offset(10, 10) & const Size(50, 10)),
        Paint()..color = Colors.red);
    canvas.drawRect((const Offset(10, 25) & const Size(70, 10)),
        Paint()..color = Colors.yellow);
    super.render(canvas);
  }
}
