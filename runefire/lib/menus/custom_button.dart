import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/main.dart';
import 'package:runefire/menus/options.dart';

import 'package:runefire/resources/visuals.dart';

class CustomButton extends StatefulWidget {
  const CustomButton(
    this.text, {
    required this.gameRef,
    this.onPrimary,
    this.onPrimaryUp,
    this.onPrimaryHold,
    this.onSecondary,
    this.onSecondaryUp,
    this.onSecondaryHold,
    this.upDownColor,
    this.scrollController,
    this.hoverWidget,
    this.zHeight = 0,
    this.zIndex = 0,
    this.rowId = 0,
    this.fontSize,
    super.key,
  });
  final (Color, Color)? upDownColor;
  final GameRouter gameRef;
  final Function()? onPrimary;
  final Function()? onPrimaryHold;
  final Function()? onPrimaryUp;
  final Function()? onSecondary;
  final Function()? onSecondaryUp;
  final Widget? hoverWidget;
  final Function()? onSecondaryHold;
  final ScrollController? scrollController;
  final String text;
  final int rowId;
  final int zHeight;
  final int zIndex;
  final double? fontSize;
  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final style = defaultStyle.copyWith(
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
      zHeight: widget.zHeight,
      onPrimary: () => widget.onPrimary?.call(),
      onPrimaryUp: () => widget.onPrimaryUp?.call(),
      onPrimaryHold: () => widget.onPrimaryHold?.call(),
      onSecondary: () => widget.onSecondary?.call(),
      onSecondaryUp: () => widget.onSecondaryUp?.call(),
      onSecondaryHold: () => widget.onSecondaryHold?.call(),
      rowId: widget.rowId,
      zIndex: widget.zIndex,
      hoverWidget: widget.hoverWidget,
      scrollController: widget.scrollController,
      child: Padding(
        padding: !isHovered
            ? const EdgeInsets.all(
                4,
              )
            : const EdgeInsets.only(
                left: 8,
                top: 8,
              ),
        child: Text(
          widget.text,
          key: ValueKey(widget.text),
          style: style.copyWith(fontSize: widget.fontSize),
        ),
      ),
    );
  }
}
