import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:runefire/resources/constants/physics_filter.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:uuid/uuid.dart';

import '../player/player.dart';
import '../resources/enums.dart';
import '../game/enviroment.dart';

abstract class InteractableComponent extends BodyComponent<GameRouter>
    with ContactCallbacks {
  InteractableComponent(
      {required this.initialPosition, required this.gameEnviroment}) {
    id = const Uuid().v4();
    priority = backgroundPickupPriority;
  }
  late String id;
  final GameEnviroment gameEnviroment;
  abstract String displayedTextString;
  abstract SpriteAnimationComponent spriteComponent;

  double radius = 1;

  void interact();

  Vector2 initialPosition;

  TextComponent? displayedText;

  // List<Player> currentPlayers = [];
  Set<PhysicalKeyboardKey> keysPressedPhysical = {};

  @override
  Future<void> onLoad() {
    spriteComponent.size.scaleTo(radius * 2);
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

  void toggleDisplay(bool isOn) {
    if (isOn) {
      displayedText ??= TextComponent(
        text: "E - $displayedTextString",
        // anchor: Anchor.center,
        // position: Vector2.all(5),
        textRenderer: TextPaint(
            style: defaultStyle.copyWith(
          fontSize: .4,

          shadows: const [
            BoxShadow(
                color: Colors.black,
                offset: Offset(2, 2),
                spreadRadius: 2,
                blurRadius: 1)
          ],
          // color: Colors.red.shade100,
        )),
      )..addToParent(spriteComponent);
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
    shape.radius = radius;
    renderBody = false;
    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        isSensor: true,
        filter: Filter()
          ..categoryBits = interactableCategory
          ..maskBits = playerCategory);

    final bodyDef = BodyDef(
      userData: this,
      position: initialPosition,
      type: BodyType.static,
      fixedRotation: true,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
