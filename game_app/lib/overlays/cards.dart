import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/main.dart';
import 'package:game_app/attributes/attributes_structure.dart';
import '../resources/visuals.dart';

class CustomCard extends StatelessWidget {
  const CustomCard(
    this.attribute, {
    required this.gameRef,
    this.isHighlightedInitial = false,
    this.onTap,
    this.onTapComplete,
    this.isEndingInitial = false,
    this.smallCard = false,
    Key? key,
  }) : super(key: key);

  final GameRouter gameRef;
  final Function? onTap;
  final Function? onTapComplete;
  final bool isHighlightedInitial;
  final bool smallCard;
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

  final topPadding = 80.0;

  @override
  Widget build(BuildContext context) {
    bool? isHighlighted;
    bool? isEnding;
    bool showHelp = false;
    Size cardSize;

    if (smallCard) {
      cardSize = const Size(128, 48);
    } else {
      cardSize = const Size(128, 96);
    }

    return StatefulBuilder(builder: (context, setState) {
      isEnding ??= isEndingInitial;
      isHighlighted ??= isHighlightedInitial;
      final highlightColor = isHighlighted!
          ? attribute.attributeType.rarity.color.darken(.2)
          : attribute.attributeType.rarity.color.brighten(.1);
      final regularColor = Colors.grey.shade100;

      isHighlighted = isHighlighted! || isEnding!;

      TextStyle style =
          defaultStyle.copyWith(color: regularColor, fontSize: 30, shadows: []);

      List<Widget> levelIndicators = [];

      for (int i = 0; i < attribute.upgradeLevel; i++) {
        levelIndicators.add(Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            Icons.star,
            size: 25,
            color: regularColor,
          ),
        ));
      }

      for (var i = 0; i < attribute.maxLevel - attribute.upgradeLevel; i++) {
        levelIndicators.add(
          Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.star_border,
              size: 25,
              color: highlightColor,
            ),
          ),
        );
      }
      final size = MediaQuery.of(context).size;

      Widget card = ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth:
                !smallCard ? (100 * (size.width / 400)).clamp(350, 450) : 400,
            minWidth: 100),
        child: LayoutBuilder(builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final cardHeight = cardWidth * (cardSize.height / cardSize.width);

          Widget background = Positioned.fill(
              bottom: null,
              child: Image.asset(
                smallCard
                    ? 'assets/images/ui/attribute_background_mask_small.png'
                    : 'assets/images/ui/attribute_background_mask.png',
                fit: BoxFit.fitWidth,
                color: Colors.grey.shade800.withOpacity(.6),
                filterQuality: FilterQuality.none,
              ));

          Widget attributeIcon = Image.asset(
            'assets/images/${attribute.icon}',
            fit: BoxFit.fitHeight,
            color: regularColor,
            filterQuality: FilterQuality.none,
          );

          Widget slantBackground = Positioned.fill(
            child: Column(
              children: [
                const Spacer(
                  flex: 1,
                ),
                Expanded(
                  child: Container(
                    transform: Matrix4.skewY(-.15)..translate(0.0, 75.0),
                    decoration: BoxDecoration(
                      color: highlightColor.darken(.5).withOpacity(.45),
                    ),
                    height: 250,
                  ),
                ),
              ],
            ),
          );

          Widget helpIcon = Positioned(
            right: 10,
            top: 10,
            child: GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: regularColor, width: 3)),
                    child: SizedBox.square(
                      dimension: 40,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, top: 5),
                        child: Center(
                          child: Text(
                            "?",
                            style: style,
                          ),
                        ),
                      ),
                    )),
              ),
            ),
          );

          Widget title = Positioned.fill(
            top: 10,

            // right: topPadding,
            left: 0,
            right: 0,
            bottom: null,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      attributeIcon,
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          attribute.title,
                          style: style,
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!smallCard)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      height: 4,
                      color: highlightColor,
                    ),
                  )
              ],
            ),
          );

          Widget content = Positioned.fill(
            bottom: 10,
            top: smallCard ? topPadding / 1.25 : topPadding,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          if (!showHelp) ...[
                            Text(
                              attribute.description(),
                              style: style.copyWith(
                                fontSize: (style.fontSize! * .8),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ] else ...[
                            Text(
                              attribute.help(),
                              style: style.copyWith(
                                  fontSize: (style.fontSize! * .6)),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (!smallCard)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: levelIndicators,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );

          return InkWell(
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onHover: (value) {
              setState(() {
                isHighlighted = value;
              });
            },
            onTap: () {},
            child: SizedBox(
              height: cardHeight,
              child: Stack(
                children: [
                  background,
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Stack(
                        children: [
                          slantBackground,
                          // helpIcon,
                          title,
                          content
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                      bottom: null,
                      child: Image.asset(
                        smallCard
                            ? 'assets/images/ui/attribute_border_small.png'
                            : 'assets/images/ui/attribute_border.png',
                        filterQuality: FilterQuality.none,
                        color: highlightColor,
                        fit: BoxFit.fitWidth,
                      )),
                  Positioned.fill(child: GestureDetector(
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
                  )),
                  if (!smallCard)
                    Positioned(
                      right: 0,
                      top: 0,
                      left: 0,
                      bottom: cardHeight - topPadding,
                      child: SizedBox(
                        height: topPadding,
                        child: GestureDetector(
                          onTap: () {
                            setState(
                              () {
                                showHelp = !showHelp;
                              },
                            );
                          },
                        ),
                      ),
                    )
                ],
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
                  ),
            ),
          );
        }),
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
  const DisplayCards(
      {required this.cards,
      this.ending = false,
      this.loadInDuration = 1.0,
      super.key});
  final List<CustomCard> cards;
  final bool ending;
  final double loadInDuration;
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

    Future.delayed(
      widget.loadInDuration.seconds,
      () {
        loaded = true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> displayedCards = [];

    for (CustomCard card in widget.cards) {
      if (selectedCard == null) {
        if (selectedIndex != -1 && widget.cards[selectedIndex] == card) {
          card = card.copyWith(isHighlightedInitial: true);
        }
        displayedCards.add(
          card,
        );
      } else {
        if (card == selectedCard) {
          card =
              card.copyWith(isHighlightedInitial: true, isEndingInitial: true);
        }
        displayedCards.add(
          card,
        );
      }
    }

    for (var i = 0; i < displayedCards.length; i++) {
      displayedCards[i] = Padding(
        padding: const EdgeInsets.all(10),
        child: displayedCards[i],
      );
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
          child: Center(
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: displayedCards),
                  ),
                ),
                const SizedBox(
                  width: 5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
