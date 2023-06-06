import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/main.dart';

import '../game/player.dart';

class InteractableComponent extends BodyComponent<GameRouter>
    with ContactCallbacks, KeyboardHandler {
  InteractableComponent(this.initialPosition, this.spriteComponent,
      this.onInteract, this.useKey, this.displayedTextString);
  String displayedTextString;
  SpriteAnimationComponent spriteComponent;
  bool useKey;
  Function onInteract;
  Vector2 initialPosition;
  CircleComponent? displayedText;

  List<Player> currentPlayers = [];
  Set<PhysicalKeyboardKey> keysPressedPhysical = {};

  @override
  Future<void> onLoad() {
    add(spriteComponent);
    priority = -200;
    return super.onLoad();
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (currentPlayers.isEmpty) return super.onKeyEvent(event, keysPressed);
    if (!event.repeat) {
      if (keysPressedPhysical.contains(event.physicalKey)) {
        keysPressedPhysical.remove(event.physicalKey);
      } else {
        keysPressedPhysical.add(event.physicalKey);
      }
    }
    if (event.physicalKey == PhysicalKeyboardKey.keyE &&
        keysPressedPhysical.contains(event.physicalKey)) {
      onInteract();
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! Player) return;
    currentPlayers.add(other);
    displayedText ??= CircleComponent(
        anchor: Anchor.center,
        radius: 5,
        position: Vector2(0, -spriteComponent.size.y))
      ..add(TextComponent(
        text: displayedTextString,
        anchor: Anchor.center,
        position: Vector2.all(5),
        textRenderer: TextPaint(
            style: TextStyle(
          fontSize: 5,
          shadows: const [
            BoxShadow(
                color: Colors.black,
                offset: Offset(0, 0),
                spreadRadius: 3,
                blurRadius: 1)
          ],
          color: Colors.red.shade100,
        )),
      ));

    add(displayedText!);

    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    currentPlayers.remove(other);
    if (currentPlayers.isEmpty) {
      displayedText?.removeFromParent();
      displayedText = null;
    }
    super.endContact(other, contact);
  }

  @override
  Body createBody() {
    late CircleShape shape;
    shape = CircleShape();
    shape.radius = spriteComponent.size.x;
    renderBody = false;
    final fixtureDef = FixtureDef(shape,
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
