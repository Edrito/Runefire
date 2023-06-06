import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:game_app/game/player.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../functions/vector_functions.dart';
import '../resources/interactable.dart';
import '../resources/classes.dart';
import 'main_game.dart';
import '/resources/routes.dart' as routes;

class BackgroundComponent extends Component {
  late final ParallaxComponent<FlameGame> background;
  late final GameLevel gameLevel;
  late final Player player;
  late TiledComponent tiled;
  BackgroundComponent(this.gameRef, this.gameLevel);
  GameEnviroment gameRef;
  ObjectGroup? objects;
  Vector2? lastPlayerPosition;

  @override
  FutureOr<void> onLoad() async {
    switch (gameLevel) {
      case GameLevel.home:
        tiled = await TiledComponent.load('home-room.tmx', Vector2(32, 16),
            priority: -500);
        break;
      default:
        tiled = await TiledComponent.load(
            'isometric-sandbox-map.tmx', Vector2(32, 16),
            priority: -500);
    }

    objects = tiled.tileMap.getLayer<ObjectGroup>('objects');
    final tempImage = (await Sprite.load('portal/1.png')).image;
    bool first = true;
    Vector2 positionTest = Vector2.zero();
    if (objects != null) {
      for (var element in objects!.objects) {
        if (element.isPoint) {
          positionTest =
              tiledObjectToOrtho(Vector2(element.x, element.y), tiled);
          // test = rotateVector2(test, radians(108.5));
          // print(test);

          add(InteractableComponent(
              positionTest,
              SpriteAnimationComponent(
                  animation: SpriteSheet(
                          image: tempImage,
                          srcSize:
                              Vector2(tempImage.size.x / 4, tempImage.size.y))
                      .createAnimation(
                    row: 0,
                    stepTime: 1,
                  ),
                  size: Vector2.all(15),
                  anchor: Anchor.bottomCenter,
                  playing: first), () {
            gameRef.game.router.pushReplacementNamed(routes.gameplay);
          }, true, "Open"));
        } else {}

        first = false;
      }
    }
    player = gameRef.player;
    // tiled.anchor = Anchor.center;

    parent?.add(tiled);
    player.loaded.whenComplete(() => player.body.setTransform(positionTest, 0));
    return super.onLoad();
  }
}

class Forge2DComponent extends Component {}

class Ball extends BodyComponent {
  Ball(this.position);
  Vector2 position;

  @override
  Body createBody() {
    final shape = CircleShape()..radius = 5;

    final bodyRef =
        BodyDef(type: BodyType.dynamic, userData: this, position: position);
    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.5,
      density: 0.2,
    );
    return world.createBody(bodyRef)..createFixture(fixtureDef);
  }
}
