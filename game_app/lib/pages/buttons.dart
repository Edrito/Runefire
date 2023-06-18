import 'dart:async';
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:game_app/functions/custom_mixins.dart';
import 'package:game_app/main.dart';

class CustomButton extends PositionComponent
    with HasGameRef<GameRouter>, DragCallbacks {
  CustomButton(
    this.text, {
    this.onPrimaryDownFunction,
    this.onPrimaryUpFunction,
    this.onPrimaryCancelledFunction,
    this.onSecondaryDownFunction,
    this.onSecondaryUpFunction,
    this.onSecondaryCancelledFunction,
  });

  Function(TapDownInfo)? onPrimaryDownFunction;
  Function(TapUpInfo)? onPrimaryUpFunction;
  Function()? onPrimaryCancelledFunction;
  Function(TapDownInfo)? onSecondaryDownFunction;
  Function(TapUpInfo)? onSecondaryUpFunction;
  Function()? onSecondaryCancelledFunction;
  String text;
  Color downColor = Colors.brown.shade400;
  Color upColor = Colors.red.shade400;
  late final MouseCallbackWrapper wrapper;
  bool isDown = false;

  late TextPaint textPaint;

  void updateText(String text) {
    this.text = text;
    buildText(isDown);
  }

  CaTextComponent? textComponent;
  @override
  FutureOr<void> onLoad() {
    bool isSmall = Platform.isAndroid || Platform.isIOS;
    anchor = Anchor.center;
    textPaint = TextPaint(
        style: TextStyle(
      fontSize: isSmall ? 21 : 35,
      fontFamily: "HeroSpeak",
      fontWeight: FontWeight.bold,
      shadows: const [
        BoxShadow(
            color: Colors.black12,
            offset: Offset(3, 3),
            spreadRadius: 3,
            blurRadius: 0)
      ],
    ));

    buildText(false);
    return super.onLoad();
  }

  void buildText(bool isDownValue) {
    textComponent?.removeFromParent();
    // anchor = Anchor.center;

    textComponent = CaTextComponent(
      text: text,
      // anchor: Anchor.center,
      textRenderer: textPaint.copyWith(
          (p0) => p0.copyWith(color: isDownValue ? downColor : upColor)),
      position: isDownValue ? Vector2.all(1) : Vector2.zero(),
    );
    isDown = isDownValue;
    add(textComponent!);
    size = textComponent?.size ?? size;
  }

  void onMouseMove(PointerHoverInfo info) {
    if (textComponent?.containsPoint(info.eventPosition.viewport) ?? false) {
      if (!isDown) {
        buildText(true);
      }
    } else if (isDown) {
      buildText(false);
    }
  }

  @override
  void onRemove() {
    game.mouseCallback.remove(wrapper);

    super.onRemove();
  }

  @override
  void onMount() {
    wrapper = MouseCallbackWrapper();

    wrapper.onMouseMove = onMouseMove;
    wrapper.onPrimaryDown = (event) {
      if (textComponent?.containsPoint(event.eventPosition.game) ?? false) {
        if (onPrimaryDownFunction != null) onPrimaryDownFunction!(event);
      }
    };

    wrapper.onPrimaryUp = (event) {
      if (textComponent?.containsPoint(event.eventPosition.viewport) ?? false) {
        if (onPrimaryUpFunction != null) onPrimaryUpFunction!(event);
      }
    };

    wrapper.onPrimaryCancel = () {
      if (onPrimaryCancelledFunction != null) onPrimaryCancelledFunction!();
      buildText(false);
    };

    wrapper.onSecondaryDown = (event) {
      if (textComponent?.containsPoint(event.eventPosition.game) ?? false) {
        if (onSecondaryDownFunction != null) onSecondaryDownFunction!(event);
      }
    };

    wrapper.onSecondaryUp = (event) {
      if (textComponent?.containsPoint(event.eventPosition.viewport) ?? false) {
        if (onSecondaryUpFunction != null) onSecondaryUpFunction!(event);
      }
    };

    wrapper.onSecondaryCancel = () {
      if (onSecondaryCancelledFunction != null) onSecondaryCancelledFunction!();
      buildText(false);
    };

    game.mouseCallback.add(wrapper);

    super.onMount();
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return textComponent?.containsLocalPoint(point) ?? false;
  }
}
