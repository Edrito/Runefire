import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:game_app/game/enemies.dart';
import 'package:game_app/game/player.dart';
import '../functions/vector_functions.dart';
import '../resources/interactable.dart';
import '../resources/classes.dart';

extension PositionProvider on Player {
  Vector2 get position => body.worldCenter;
}

enum GameLevel { space, forest, home }

enum InputType {
  keyboard,
  mouseMove,
  aimJoy,
  moveJoy,
  tapClick,
  mouseDrag,
  mouseDragStart,
  ai,
}

class MainGame extends GameEnviroment {
  late EnemyManagement enemyManagement;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    enemyManagement = EnemyManagement(this);

    add(enemyManagement);

    final tempImage = (await Sprite.load('portal/1.png')).image;
    add(InteractableComponent(
        generateRandomGamePositionUsingViewport(true, this),
        SpriteAnimationComponent(
            animation: SpriteSheet(
                    image: tempImage,
                    srcSize: Vector2(tempImage.size.x / 4, tempImage.size.y))
                .createAnimation(
              row: 0,
              stepTime: 1,
            ),
            size: Vector2.all(15),
            anchor: Anchor.center), () {
      print('he');
    }, true, "Open"));
  }

  @override
  GameLevel level = GameLevel.forest;
}
