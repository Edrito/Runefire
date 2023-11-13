import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/menus/overlays.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/resources/constants/physics_filter.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/resources/data_classes/system_data.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:uuid/uuid.dart';

import 'package:runefire/player/player.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/game/enviroment.dart';

class ExitPortal extends InteractableComponent {
  @override
  String displayedTextString = 'Exit';

  @override
  late SpriteAnimationComponent spriteComponent;
  Player player;

  ExitPortal({
    required super.initialPosition,
    required super.gameEnviroment,
    required this.player,
  });

  @override
  Future<void> onLoad() async {
    final animation = await spriteAnimations.exitPortalBlue1;
    spriteComponent = SpriteAnimationComponent(
      animation: animation,
      anchor: Anchor.center,
      size: animation.frames.first.sprite.srcSize..scaledToHeight(player),
    );
    return super.onLoad();
  }

  @override
  void interact() {
    player.winGame(this);
  }
}

abstract class InteractableComponent extends BodyComponent<GameRouter>
    with ContactCallbacks {
  InteractableComponent({
    required this.initialPosition,
    required this.gameEnviroment,
  }) {
    id = const Uuid().v4();
    priority = backgroundPickupPriority;
  }
  late String id;
  final GameEnviroment gameEnviroment;
  abstract String displayedTextString;
  abstract SpriteAnimationComponent spriteComponent;

  void interact();

  Vector2 initialPosition;

  TextComponent? displayedText;

  // List<Player> currentPlayers = [];
  Set<LogicalKeyboardKey> keysPressedPhysical = {};

  @override
  Future<void> onLoad() {
    // spriteComponent.size.scaleTo(radius * 2);
    add(spriteComponent);
    priority = backgroundObjectPriority;
    return super.onLoad();
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Player) {
      other.addCloseInteractableComponents(this);
    }

    super.beginContact(other, contact);
  }

  void toggleDisplay({bool isOn = true}) {
    if (isOn) {
      final key = game.systemDataComponent.dataObject
          .getBinding(GameAction.interact, InputManager());
      displayedText ??= TextComponent(
        text: "${key == null ? "" : "$key ~ "}$displayedTextString",
        anchor: Anchor.center,
        // position: Vector2.all(5),
        textRenderer: TextPaint(
          style: defaultStyle.copyWith(
            fontSize: .4,

            shadows: [colorPalette.buildShadow(ShadowStyle.lightGame)],
            // color: Colors.red.shade100,
          ),
        ),
      )..addToParent(this);
    } else {
      displayedText?.removeFromParent();
      displayedText = null;
    }
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is Player) {
      other.removeCloseInteractable(this);
    }

    super.endContact(other, contact);
  }

  @override
  Body createBody() {
    late CircleShape shape;
    shape = CircleShape();
    shape.radius = spriteComponent.size.x / 2;
    renderBody = false;
    final fixtureDef = FixtureDef(
      shape,
      userData: {'type': FixtureType.body, 'object': this},
      isSensor: true,
      filter: Filter()
        ..categoryBits = interactableCategory
        ..maskBits = playerCategory,
    );

    final bodyDef = BodyDef(
      userData: this,
      position: initialPosition,
      fixedRotation: true,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
