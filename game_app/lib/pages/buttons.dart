import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/attributes_enum.dart';

import '../resources/attributes.dart';
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
    Key? key,
  }) : super(key: key);

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
        color: isHighlighted ?? isHighlightedInitial
            ? buttonDownColor
            : buttonUpColor,
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
            textAlign: TextAlign.center,
          ),
        ),
      );
    });
  }
}

class CustomCard extends StatelessWidget {
  const CustomCard(
    this.attribute, {
    required this.gameRef,
    this.isHighlightedInitial = false,
    this.onTap,
    this.onTapComplete,
    this.isEndingInitial = false,
    Key? key,
  }) : super(key: key);

  final GameRouter gameRef;
  final Function? onTap;
  final Function? onTapComplete;
  final bool isHighlightedInitial;
  final Attribute attribute;
  final bool isEndingInitial;
  CustomCard copyWith({
    GameRouter? gameRef,
    Function? onTap,
    Function? onTapComplete,
    bool? isHighlightedInitial,
    bool? isEndingInitial,
    Attribute? attribute,
    Key? key,
  }) {
    return CustomCard(
      attribute ?? this.attribute,
      isEndingInitial: isEndingInitial ?? this.isEndingInitial,
      gameRef: gameRef ?? this.gameRef,
      isHighlightedInitial: isHighlightedInitial ?? this.isHighlightedInitial,
      onTap: onTap ?? this.onTap,
      onTapComplete: onTapComplete ?? this.onTapComplete,
      key: key ?? this.key,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool? isHighlighted;
    bool? isEnding;
    bool showHelp = false;

    return StatefulBuilder(builder: (context, setState) {
      isEnding ??= isEndingInitial;
      isHighlighted ??= isHighlightedInitial;

      isHighlighted = isHighlighted! || isEnding!;
      TextStyle style = defaultStyle.copyWith(
          color: isHighlighted!
              ? buttonDownColor
              : attribute.attributeEnum.rarity.color.brighten(.1),
          fontSize: 30);

      Widget card = InkWell(
          splashFactory: NoSplash.splashFactory,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onHover: (value) {
            setState(
              () {
                isHighlighted = value;
              },
            );
          },
          onTap: () async {
            if (isEnding!) return;
            setState(
              () {
                isEnding = true;
              },
            );
            if (onTap != null) {
              onTap!();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                  // color: attribute.attributeEnum.rarity.color.brighten(.9),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  gradient: LinearGradient(colors: [
                    attribute.attributeEnum.rarity.color.brighten(.98),
                    attribute.attributeEnum.rarity.color.brighten(.9),
                  ]),
                  border: Border.all(
                      color: attribute.attributeEnum.rarity.color.brighten(.15),
                      width: 3)),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 50,
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              attribute.title,
                              style: style,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.black, width: 2)),
                                child: const Icon(
                                  Icons.question_mark,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(
                                () {
                                  showHelp = !showHelp;
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!showHelp) ...[
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/${attribute.icon}',
                          filterQuality: FilterQuality.none,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          attribute.description(),
                          style:
                              style.copyWith(fontSize: (style.fontSize! * .6)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          attribute.description() +
                              attribute.description() +
                              attribute.description(),
                          style:
                              style.copyWith(fontSize: (style.fontSize! * .6)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          )
              .animate(
                target: isHighlighted! ? 1 : 0,
                onInit: (controller) {
                  if (isEnding!) {
                    controller.forward(from: 1);
                    controller.stop();
                  }
                },
              )
              .rotate(
                  begin: 0,
                  end: .005,
                  curve: Curves.easeInOut,
                  duration: .1.seconds)
              .scale(
                curve: Curves.easeInOut,
                duration: .1.seconds,
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
              ));
      return (isEnding!
          ? Animate(
              effects: const [
                  FadeEffect(begin: 1, end: 0, curve: Curves.easeInOut),
                  MoveEffect(end: Offset(0, -50), curve: Curves.easeInOut),
                ],
              onComplete: (controller) {
                if (onTapComplete != null) {
                  onTapComplete!();
                }
              },
              child: card)
          : card);
    });
  }
}
