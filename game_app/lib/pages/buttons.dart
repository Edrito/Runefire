import 'package:flutter/material.dart';
import 'package:game_app/main.dart';

import '../resources/visuals.dart';

class CustomButton extends StatefulWidget {
  const CustomButton(this.text,
      {required this.gameRef,
      this.onTap,
      this.onSecondaryTap,
      super.key,
      this.onTapDown,
      this.onTapUp,
      this.onTapCancel,
      this.onSecondaryTapDown,
      this.onSecondaryTapUp,
      this.onSecondaryTapCancel});
  final GameRouter gameRef;
  final Function? onTap;
  final Function(TapDownDetails)? onTapDown;
  final Function(TapUpDetails)? onTapUp;
  final Function? onTapCancel;
  final Function? onSecondaryTap;
  final Function(TapDownDetails)? onSecondaryTapDown;
  final Function(TapUpDetails)? onSecondaryTapUp;
  final Function? onSecondaryTapCancel;

  final String text;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  late TextStyle style;

  @override
  void initState() {
    super.initState();
    style = fontStyle;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: NoSplash.splashFactory,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onHover: (value) {
        setState(
          () {
            style =
                style.copyWith(color: value ? buttonDownColor : buttonUpColor);
          },
        );
      },
      child: Text(
        widget.text,
        style: style,
        textAlign: TextAlign.center,
      ),
      onSecondaryTap: () {
        if (widget.onSecondaryTap != null) {
          widget.onSecondaryTap!();
        }
      },
      onSecondaryTapDown: (details) {
        if (widget.onSecondaryTapDown != null) {
          widget.onSecondaryTapDown!(details);
        }
      },
      onSecondaryTapUp: (details) {
        if (widget.onSecondaryTapUp != null) {
          widget.onSecondaryTapUp!(details);
        }
      },
      onSecondaryTapCancel: () {
        if (widget.onSecondaryTapCancel != null) {
          widget.onSecondaryTapCancel!();
        }
      },
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTapCancel: () {
        if (widget.onTapCancel != null) {
          widget.onTapCancel!();
        }
      },
      onTapDown: (details) {
        if (widget.onTapDown != null) {
          widget.onTapDown!(details);
        }
      },
      onTapUp: (details) {
        if (widget.onTapUp != null) {
          widget.onTapUp!(details);
        }
      },
    );
  }
}




// class CustomButton extends PositionComponent
//     with HasGameRef<GameRouter>, DragCallbacks {
//   CustomButton(
//     this.text, {
//     this.onPrimaryDownFunction,
//     this.onPrimaryUpFunction,
//     this.onPrimaryCancelledFunction,
//     this.onSecondaryDownFunction,
//     this.onSecondaryUpFunction,
//     this.onSecondaryCancelledFunction,
//   });

//   Function(TapDownInfo)? onPrimaryDownFunction;
//   Function(TapUpInfo)? onPrimaryUpFunction;
//   Function()? onPrimaryCancelledFunction;
//   Function(TapDownInfo)? onSecondaryDownFunction;
//   Function(TapUpInfo)? onSecondaryUpFunction;
//   Function()? onSecondaryCancelledFunction;
//   String text;

//   late final MouseCallbackWrapper wrapper;
//   bool isDown = false;

//   late TextPaint textPaint;

//   void updateText(String text) {
//     this.text = text;
//     buildText(isDown);
//   }

//   CaTextComponent? textComponent;
//   @override
//   FutureOr<void> onLoad() {
//     anchor = Anchor.center;
//     textPaint = TextPaint(style: fontStyle);

//     buildText(false);
//     return super.onLoad();
//   }

//   void buildText(bool isDownValue) {
//     textComponent?.removeFromParent();
//     // anchor = Anchor.center;

//     textComponent = CaTextComponent(
//       text: text,
//       // anchor: Anchor.center,
//       textRenderer: textPaint.copyWith((p0) =>
//           p0.copyWith(color: isDownValue ? buttonDownColor : buttonUpColor)),
//       position: isDownValue ? Vector2.all(1) : Vector2.zero(),
//     );
//     isDown = isDownValue;
//     add(textComponent!);
//     size = textComponent?.size ?? size;
//   }

//   void onMouseMove(PointerHoverInfo info) {
//     if (textComponent?.containsPoint(info.eventPosition.viewport) ?? false) {
//       if (!isDown) {
//         buildText(true);
//       }
//     } else if (isDown) {
//       buildText(false);
//     }
//   }

//   @override
//   void onRemove() {
//     game.mouseCallback.remove(wrapper);

//     super.onRemove();
//   }

//   @override
//   void onMount() {
//     wrapper = MouseCallbackWrapper();

//     wrapper.onMouseMove = onMouseMove;
//     wrapper.onPrimaryDown = (event) {
//       if (textComponent?.containsPoint(event.eventPosition.game) ?? false) {
//         if (onPrimaryDownFunction != null) onPrimaryDownFunction!(event);
//       }
//     };

//     wrapper.onPrimaryUp = (event) {
//       if (textComponent?.containsPoint(event.eventPosition.viewport) ?? false) {
//         if (onPrimaryUpFunction != null) onPrimaryUpFunction!(event);
//       }
//     };

//     wrapper.onPrimaryCancel = () {
//       if (onPrimaryCancelledFunction != null) onPrimaryCancelledFunction!();
//       buildText(false);
//     };

//     wrapper.onSecondaryDown = (event) {
//       if (textComponent?.containsPoint(event.eventPosition.game) ?? false) {
//         if (onSecondaryDownFunction != null) onSecondaryDownFunction!(event);
//       }
//     };

//     wrapper.onSecondaryUp = (event) {
//       if (textComponent?.containsPoint(event.eventPosition.viewport) ?? false) {
//         if (onSecondaryUpFunction != null) onSecondaryUpFunction!(event);
//       }
//     };

//     wrapper.onSecondaryCancel = () {
//       if (onSecondaryCancelledFunction != null) onSecondaryCancelledFunction!();
//       buildText(false);
//     };

//     game.mouseCallback.add(wrapper);

//     super.onMount();
//   }

//   @override
//   bool containsLocalPoint(Vector2 point) {
//     return textComponent?.containsLocalPoint(point) ?? false;
//   }
// }
