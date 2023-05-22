import 'dart:async';

import 'package:flame/components.dart';

import 'characters.dart';

class Player extends SpriteComponent {
  final CharacterType characterType;
  Player(this.characterType);

  @override
  FutureOr<void> onLoad() async {
    switch (characterType) {
      case CharacterType.wizard:
        sprite = await Sprite.load('wizard.png');
        size = sprite!.srcSize / 10;
        anchor = Anchor.center;
        break;
      default:
    }

    return super.onLoad();
  }
}
