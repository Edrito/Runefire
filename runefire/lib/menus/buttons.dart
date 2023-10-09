import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/main.dart';
import 'package:runefire/menus/options.dart';

import '../resources/visuals.dart';

class CustomButton extends StatefulWidget {
  const CustomButton(this.text,
      {required this.gameRef,
      this.onPrimary,
      this.onPrimaryUp,
      this.onPrimaryHold,
      this.onSecondary,
      this.axis = Axis.vertical,
      this.onSecondaryUp,
      this.onSecondaryHold,
      this.upDownColor,
      super.key});
  final (Color, Color)? upDownColor;
  final GameRouter gameRef;
  final Function()? onPrimary;
  final Function()? onPrimaryHold;
  final Function()? onPrimaryUp;
  final Function()? onSecondary;
  final Function()? onSecondaryUp;
  final Function()? onSecondaryHold;
  final String text;
  final Axis axis;
  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    TextStyle style = defaultStyle.copyWith(
      color: widget.upDownColor != null
          ? isHovered
              ? widget.upDownColor!.$2
              : widget.upDownColor!.$1
          : isHovered
              ? colorPalette.primaryColor
              : colorPalette.secondaryColor,
    );
    return CustomInputWatcher(
      onHover: (value) {
        setState(
          () {
            isHovered = value;
          },
        );
      },
      groupOrientation: widget.axis,
      onPrimary: () => widget.onPrimary?.call(),
      onPrimaryUp: () => widget.onPrimaryUp?.call(),
      onPrimaryHold: () => widget.onPrimaryHold?.call(),
      onSecondary: () => widget.onSecondary?.call(),
      onSecondaryUp: () => widget.onSecondaryUp?.call(),
      onSecondaryHold: () => widget.onSecondaryHold?.call(),
      child: Padding(
        padding: isHovered
            ? const EdgeInsets.all(3)
            : const EdgeInsets.only(
                right: 6,
                bottom: 6,
              ),
        child: Text(
          widget.text,
          key: ValueKey(widget.text),
          style: style,
        ),
      ),
    );
  }
}
