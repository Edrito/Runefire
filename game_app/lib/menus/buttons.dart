import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/main.dart';
import 'package:game_app/menus/options.dart';

import '../resources/visuals.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
    this.text, {
    required this.gameRef,
    this.isHighlightedInitial = false,
    this.onTap,
    this.onSecondaryTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.upDownColor,
    Key? key,
  }) : super(key: key);
  final (Color, Color)? upDownColor;
  final GameRouter gameRef;
  final Function? onTap;
  final Function(TapDownDetails)? onTapDown;
  final Function(TapUpDetails)? onTapUp;
  final Function? onTapCancel;
  final Function? onSecondaryTap;
  final Function(TapDownDetails)? onSecondaryTapDown;
  final Function(TapUpDetails)? onSecondaryTapUp;
  final Function? onSecondaryTapCancel;
  final bool isHighlightedInitial;
  final String text;

  CustomButton copyWith({
    GameRouter? gameRef,
    Function? onTap,
    Function(TapDownDetails)? onTapDown,
    Function(TapUpDetails)? onTapUp,
    Function? onTapCancel,
    (Color, Color)? upDownColor,
    Function? onSecondaryTap,
    Function(TapDownDetails)? onSecondaryTapDown,
    Function(TapUpDetails)? onSecondaryTapUp,
    Function? onSecondaryTapCancel,
    bool? isHighlightedInitial,
    String? text,
    Key? key,
  }) {
    return CustomButton(
      text ?? this.text,
      gameRef: gameRef ?? this.gameRef,
      isHighlightedInitial: isHighlightedInitial ?? this.isHighlightedInitial,
      onTap: onTap ?? this.onTap,
      upDownColor: upDownColor ?? this.upDownColor,
      onTapDown: onTapDown ?? this.onTapDown,
      onTapUp: onTapUp ?? this.onTapUp,
      onTapCancel: onTapCancel ?? this.onTapCancel,
      onSecondaryTap: onSecondaryTap ?? this.onSecondaryTap,
      onSecondaryTapDown: onSecondaryTapDown ?? this.onSecondaryTapDown,
      onSecondaryTapUp: onSecondaryTapUp ?? this.onSecondaryTapUp,
      onSecondaryTapCancel: onSecondaryTapCancel ?? this.onSecondaryTapCancel,
      key: key ?? this.key,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool? isHighlighted;
    return StatefulBuilder(builder: (context, setstate) {
      TextStyle style = defaultStyle.copyWith(
        color: upDownColor != null
            ? isHighlighted ?? isHighlightedInitial
                ? upDownColor!.$2
                : upDownColor!.$1
            : isHighlighted ?? isHighlightedInitial
                ? colorPalette.primaryColor
                : colorPalette.secondaryColor,
      );
      return InkWell(
        splashFactory: NoSplash.splashFactory,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onHover: (value) {
          setstate(
            () {
              isHighlighted = value;
            },
          );
        },
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        onTapCancel: () {
          if (onTapCancel != null) {
            onTapCancel!();
          }
        },
        onTapDown: (details) {
          if (onTapDown != null) {
            onTapDown!(details);
          }
        },
        onTapUp: (details) {
          if (onTapUp != null) {
            onTapUp!(details);
          }
        },
        onSecondaryTap: () {
          if (onSecondaryTap != null) {
            onSecondaryTap!();
          }
        },
        onSecondaryTapDown: (details) {
          if (onSecondaryTapDown != null) {
            onSecondaryTapDown!(details);
          }
        },
        onSecondaryTapUp: (details) {
          if (onSecondaryTapUp != null) {
            onSecondaryTapUp!(details);
          }
        },
        onSecondaryTapCancel: () {
          if (onSecondaryTapCancel != null) {
            onSecondaryTapCancel!();
          }
        },
        child: Padding(
          padding: isHighlighted ?? isHighlightedInitial
              ? const EdgeInsets.all(3)
              : const EdgeInsets.only(
                  right: 6,
                  bottom: 6,
                ),
          child: Text(
            text,
            style: style,
            // textAlign: TextAlign.center,
          ),
        ),
      );
    });
  }
}

class DisplayButtons extends StatefulWidget {
  const DisplayButtons(
      {required this.buttons, this.alignment = Alignment.center, super.key});
  final List<Widget> buttons;
  final Alignment alignment;

  @override
  State<DisplayButtons> createState() => _DisplayButtonsState();
}

class _DisplayButtonsState extends State<DisplayButtons> {
  int selectedIndex = -1;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> displayedButtons = [];

    for (Widget button in widget.buttons) {
      late Widget newButton;
      if (selectedIndex != -1 && widget.buttons[selectedIndex] == button) {
        newButton = button is CustomButton
            ? button.copyWith(isHighlightedInitial: true)
            : button is IncrementingButton
                ? button.button.copyWith(isHighlightedInitial: true)
                : const SizedBox();
      } else {
        newButton = button;
      }
      displayedButtons.add(Align(
        alignment: widget.alignment,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: newButton,
        ),
      ));
    }

    return Listener(
      onPointerDown: (event) {
        selectedIndex = -1;
      },
      child: KeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: (value) {
          if (value is KeyRepeatEvent || !loaded) return;

          if (selectedIndex != -1) {
            final button = widget.buttons[selectedIndex];
            if (value.logicalKey == LogicalKeyboardKey.arrowLeft ||
                value.logicalKey == LogicalKeyboardKey.keyA) {
              if (button is CustomButton) {
                value is KeyDownEvent
                    ? button.onSecondaryTapDown?.call(TapDownDetails())
                    : button.onSecondaryTapUp
                        ?.call(TapUpDetails(kind: PointerDeviceKind.unknown));
              }
              // else if (button is IncrementingButton) {
              //   value is KeyDownEvent
              //       ? button.newButton.onSecondaryTapDown?.call(TapDownDetails())
              //       : button.newButton.onSecondaryTapUp
              //           ?.call(TapUpDetails(kind: PointerDeviceKind.unknown));
              // }
            }

            if (value.logicalKey == LogicalKeyboardKey.arrowRight ||
                value.logicalKey == LogicalKeyboardKey.keyD) {
              if (button is CustomButton) {
                value is KeyDownEvent
                    ? button.onTapDown?.call(TapDownDetails())
                    : button.onTapUp
                        ?.call(TapUpDetails(kind: PointerDeviceKind.unknown));
              }
              // else if (button is IncrementingButton) {
              //   value is KeyDownEvent
              //       ? button.newButton.onTapDown?.call(TapDownDetails())
              //       : button.newButton.onTapUp
              //           ?.call(TapUpDetails(kind: PointerDeviceKind.unknown));
              // }
            }

            if (value.logicalKey == LogicalKeyboardKey.space ||
                value.logicalKey == LogicalKeyboardKey.enter) {
              if (button is CustomButton && value is KeyDownEvent) {
                button.onTap?.call();
              } else if (button is IncrementingButton &&
                  value is KeyDownEvent) {
                button.button.onTap?.call();
              }
            }
          }

          if (value is! KeyDownEvent) return;

          if ((value.logicalKey == LogicalKeyboardKey.keyW ||
              value.logicalKey == LogicalKeyboardKey.arrowUp)) {
            setState(() {
              selectedIndex--;
              if (selectedIndex < 0) {
                selectedIndex = widget.buttons.length - 1;
              }
            });
          } else if (value.logicalKey == LogicalKeyboardKey.keyS ||
              value.logicalKey == LogicalKeyboardKey.arrowDown) {
            setState(() {
              selectedIndex++;
              if (selectedIndex > widget.buttons.length - 1) {
                selectedIndex = 0;
              }
            });
          }
        },
        child: SizedBox(
          // alignment: widget.alignment,
          width: 300,
          child: ListView(
            shrinkWrap: true,
            children: displayedButtons
                .animate(onComplete: (_) => loaded = true)
                .fadeIn(curve: Curves.easeInOut, duration: .4.seconds),
          ),
        ),
      ),
    );
  }
}
