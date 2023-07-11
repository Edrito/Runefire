import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/main.dart';
import 'package:game_app/attributes/attributes_enum.dart';

import '../attributes/attributes.dart';
import '../resources/visuals.dart';

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
      final highlightColor = isHighlighted!
          ? attribute.attributeEnum.rarity.color.darken(.4)
          : attribute.attributeEnum.rarity.color.brighten(.1);

      isHighlighted = isHighlighted! || isEnding!;

      TextStyle style = defaultStyle.copyWith(
          color: highlightColor.brighten(.1), fontSize: 30, shadows: []);

      List<Widget> levelIndicators = [];

      for (int i = 0; i < attribute.upgradeLevel; i++) {
        levelIndicators.add(Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  transform: Matrix4.skewX(-.4)..translate(5.0),
                  height: 20,
                  width: 20,
                  color: highlightColor.brighten(.5),
                ))
            // Padding(
            //   padding: const EdgeInsets.all(2),
            //   child: Icon(
            //     Icons.star,
            //     color: highlightColor,
            //     size: 20,
            //   ),
            // ),
            );
      }

      for (var i = 0; i < attribute.maxLevel - attribute.upgradeLevel; i++) {
        levelIndicators.add(
          Padding(
              padding: const EdgeInsets.all(2),
              child: Container(
                transform: Matrix4.skewX(-.4)..translate(5.0),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: highlightColor.brighten(.5), width: 2)),
                height: 20,
                width: 20,
                // color: highlightColor,
              )

              // Icon(
              //   Icons.star_outline,
              //   color: ,
              //   size: 20,
              // ),
              ),
        );
      }

      Widget card = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 500),
        child: InkWell(
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
                  // borderRadius: const BorderRadius.all(Radius.circular(20)),
                  gradient: LinearGradient(colors: [
                    highlightColor.brighten(.98),
                    highlightColor.brighten(.85),
                  ]),
                  // border: Border.all(
                  //     color: highlightColor.brighten(.15), width: 3),
                ),
                child: Stack(
                  children: [
                    if (!showHelp)
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/${attribute.icon}',
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: Column(
                        children: [
                          const Spacer(
                            flex: 1,
                          ),
                          Expanded(
                            child: ClipRect(
                              child: Container(
                                transform: Matrix4.skewY(-.2)
                                  ..translate(0.0, 75.0),
                                decoration: BoxDecoration(
                                  color: highlightColor.darken(.5),
                                ),
                                height: 250,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: Row(
                            // crossAxisAlignment: CrossAxisAlignment.start,
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
                              GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: highlightColor, width: 2)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, top: 5),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            "?",
                                            style: style,
                                          ),
                                        ),
                                      )),
                                ),
                                onTap: () {
                                  setState(
                                    () {
                                      showHelp = !showHelp;
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        if (!showHelp) ...[
                          const Spacer(
                            flex: 2,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      attribute.description(),
                                      style: style.copyWith(
                                          fontSize: (style.fontSize! * .6),
                                          color: highlightColor.brighten(.5)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 80,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        children: levelIndicators,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                attribute.help(),
                                style: style.copyWith(
                                    fontSize: (style.fontSize! * .6)),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
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
                )),
      );
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
    })
        .animate(
          onPlay: (controller) => controller.forward(from: rng.nextDouble()),
          onComplete: (controller) =>
              controller.reverse().then((value) => controller.forward()),
        )
        .moveY(end: 4, curve: Curves.easeInOut, duration: 1.seconds);
  }
}

class DisplayCards extends StatefulWidget {
  const DisplayCards({required this.cards, this.ending = false, super.key});
  final List<CustomCard> cards;
  final bool ending;
  @override
  State<DisplayCards> createState() => _DisplayCardsState();
}

class _DisplayCardsState extends State<DisplayCards>
    with TickerProviderStateMixin {
  int selectedIndex = -1;
  FocusNode focusNode = FocusNode();
  CustomCard? selectedCard;
  bool loaded = false;
  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> displayedCards = [];

    for (CustomCard card in widget.cards) {
      if (selectedCard == null) {
        if (selectedIndex != -1 && widget.cards[selectedIndex] == card) {
          card = card.copyWith(isHighlightedInitial: true);
        }
        displayedCards.add(Padding(
          padding: const EdgeInsets.all(10),
          child: card,
        ));
      } else {
        if (card == selectedCard) {
          card =
              card.copyWith(isHighlightedInitial: true, isEndingInitial: true);
        }
        displayedCards.add(Padding(
          padding: const EdgeInsets.all(10),
          child: card,
        ));
      }
    }

    return IgnorePointer(
      ignoring: selectedCard != null,
      child: Listener(
        onPointerDown: (event) {
          selectedIndex = -1;
        },
        child: KeyboardListener(
          focusNode: focusNode,
          autofocus: true,
          onKeyEvent: (value) {
            if (value is KeyUpEvent ||
                value is KeyRepeatEvent ||
                widget.ending ||
                !loaded) return;
            if (value.logicalKey == LogicalKeyboardKey.enter ||
                value.logicalKey == LogicalKeyboardKey.space) {
              if (selectedIndex != -1) {
                setState(() {
                  selectedCard = widget.cards[selectedIndex];
                  selectedCard?.onTap!();
                });
              }
            } else if (value.logicalKey == LogicalKeyboardKey.keyA ||
                value.logicalKey == LogicalKeyboardKey.arrowLeft) {
              setState(() {
                selectedIndex--;
                if (selectedIndex < 0) {
                  selectedIndex = widget.cards.length - 1;
                }
              });
            } else if (value.logicalKey == LogicalKeyboardKey.keyD ||
                value.logicalKey == LogicalKeyboardKey.arrowRight) {
              setState(() {
                selectedIndex++;
                if (selectedIndex > widget.cards.length - 1) {
                  selectedIndex = 0;
                }
              });
            }
          },
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: displayedCards
                  .animate(onComplete: (_) => loaded = true)
                  .fadeIn(
                    duration: .2.seconds,
                    curve: Curves.decelerate,
                  )
                  .moveY(
                      duration: .2.seconds,
                      curve: Curves.decelerate,
                      begin: 50,
                      end: 0)),
        ),
      ),
    );
  }
}
