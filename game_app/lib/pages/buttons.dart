import 'dart:async';

import 'package:flame/components.dart';

class StartButton extends SpriteComponent {
  StartButton(this.isDown);
  bool isDown;

  @override
  FutureOr<void> onLoad() async {
    if (isDown) {
      sprite = await Sprite.load('buttons/startgame_down.png');
    } else {
      sprite = await Sprite.load('buttons/startgame_up.png');
    }
    return super.onLoad();
  }
}
