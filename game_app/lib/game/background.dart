import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../functions/vector_functions.dart';
import '../resources/classes.dart';
import '../resources/enums.dart';

abstract class BackgroundComponent extends Component {
  late final ParallaxComponent<FlameGame> background;
  abstract final GameLevel gameLevel;
  late TiledComponent tiled;
  BackgroundComponent(this.gameRef);
  GameEnviroment gameRef;
  ObjectGroup? spawnObjects;
  Vector2? lastPlayerPosition;

  @override
  FutureOr<void> onLoad() async {
    tiled = await TiledComponent.load(
        gameLevel.getTileFilename(), Vector2(32, 16),
        priority: -500);

    spawnObjects = tiled.tileMap.getLayer<ObjectGroup>('spawn');
    Vector2 positionTest = Vector2.zero();
    if (spawnObjects != null) {
      for (var element in spawnObjects!.objects) {
        if (element.isPoint) {
          positionTest =
              tiledObjectToOrtho(Vector2(element.x, element.y), tiled);
        }
      }
    }

    parent?.add(tiled);
    // gameRef.player.loaded
    //     .whenComplete(() => gameRef.player.body.setTransform(positionTest, 0));
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
