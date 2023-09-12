import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/main.dart';
import 'package:game_app/attributes/attributes_structure.dart';
import 'package:game_app/menus/overlays.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/functions/functions.dart';
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
  final Function(DamageType? damageType)? onTap;
  final Function? onTapComplete;
  final bool isHighlightedInitial;
  final bool smallCard;
  final Attribute attribute;
  final bool isEndingInitial;
  CustomCard copyWith({
    GameRouter? gameRef,
    Function(DamageType? damageType)? onTap,
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

  final topPadding = 90.0;

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

      final border = Image.asset(
        smallCard
            ? 'assets/images/ui/attribute_border_small.png'
            : 'assets/images/ui/attribute_border.png',
        filterQuality: FilterQuality.none,
        color: highlightColor.darken(.7),
        fit: BoxFit.fitWidth,
      );

      bool hasDamageTypeSelector = attribute.allowedDamageTypes.isNotEmpty &&
          attribute.damageType == null;

      isHighlighted = isHighlighted! || isEnding!;

      TextStyle style =
          defaultStyle.copyWith(color: regularColor, fontSize: 30, shadows: []);

      List<Widget> levelIndicators = [];
      if (attribute.maxLevel != null) {
        for (int i = 0; i < attribute.upgradeLevel; i++) {
          levelIndicators.add(Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.circle,
              size: 25,
              color: highlightColor.darken(.4),
            ),
          ));
        }

        for (var i = 0; i < attribute.maxLevel! - attribute.upgradeLevel; i++) {
          levelIndicators.add(
            Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.circle_outlined,
                size: 25,
                color: highlightColor.darken(.2),
              ),
            ),
          );
        }
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
                color: Colors.grey.shade900.withOpacity(.85),
                filterQuality: FilterQuality.none,
              ));

          Widget attributeIcon = buildImageAsset(
            'assets/images/${attribute.icon}',
            fit: BoxFit.contain,
            color: attribute.damageType?.color ?? regularColor,
          );

          // Widget slantBackground = const Positioned.fill(
          //   child: Column(
          //     children: [
          //       Spacer(
          //         flex: 1,
          //       ),
          //       // Expanded(
          //       //   child: Container(
          //       //     transform: Matrix4.skewY(-.15)..translate(0.0, 75.0),
          //       //     decoration: BoxDecoration(
          //       //       color: highlightColor.darken(.5).withOpacity(.45),
          //       //     ),
          //       //     height: 250,
          //       //   ),
          //       // ),
          //     ],
          //   ),
          // );

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

          Widget title = Positioned(
            // top: 10,
            height: topPadding,
            left: 0,
            right: 0,
            bottom: null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Center(
                child: Text(
                  attribute.title,
                  style: style.copyWith(color: highlightColor.brighten(.3)),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
          );

          Widget content = Positioned(
            // bottom: 10,
            height: cardHeight - (smallCard ? topPadding / 1.15 : topPadding),
            // top: ,
            width: cardWidth,
            bottom: 0,

            child: Container(
              color:
                  // smallCard ? null :
                  highlightColor.withOpacity(.05),
              child: Padding(
                padding: smallCard
                    ? const EdgeInsets.symmetric(horizontal: 20, vertical: 5)
                    : const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: smallCard
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              attribute.description(),
                              style: style.copyWith(
                                fontSize: (style.fontSize! * .75),
                                color: style.color!.darken(.1),
                                fontWeight: FontWeight.w200,
                              ),
                              textAlign:
                                  smallCard ? TextAlign.center : TextAlign.left,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Flexible(
                            child: Container(
                              alignment: Alignment.center,
                              child: SizedBox.expand(
                                child: Padding(
                                  padding: smallCard
                                      ? const EdgeInsets.all(2)
                                      : const EdgeInsets.all(12.0),
                                  child: attributeIcon,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!smallCard)
                      SizedBox(
                        height: 50,
                        child: !hasDamageTypeSelector && attribute.maxLevel != 1
                            ? Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: levelIndicators,
                                  ),
                                ),
                              )
                            : null,
                      )
                  ],
                ),
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
                          // slantBackground,
                          // helpIcon,
                          title,
                          content
                        ],
                      ),
                    ),
                  ),
                  if (!hasDamageTypeSelector)
                    Positioned.fill(child: GestureDetector(
                      onTap: () async {
                        if (isEnding!) return;
                        setState(
                          () {
                            isEnding = true;
                          },
                        );
                        onTap?.call(null);
                      },
                    ))
                  else
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(35),
                            bottomRight: Radius.circular(35)),
                        child: DamageTypeSelector(attribute.allowedDamageTypes,
                            (p0) {
                          if (isEnding!) return;
                          setState(
                            () {
                              isEnding = true;
                            },
                          );
                          onTap?.call(p0);
                        }),
                      ),
                    ),
                  Positioned.fill(
                      bottom: null,
                      child: IgnorePointer(
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: buildImageAsset(
                              smallCard
                                  ? 'assets/images/ui/attribute_border_small.png'
                                  : 'assets/images/ui/attribute_border.png',
                              fit: BoxFit.fitWidth,
                              color: highlightColor.darken(.85),
                            )),
                      )),
                  Positioned.fill(
                      bottom: null,
                      child: IgnorePointer(
                        child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: buildImageAsset(
                              smallCard
                                  ? 'assets/images/ui/attribute_border_small.png'
                                  : 'assets/images/ui/attribute_border.png',
                              fit: BoxFit.fitWidth,
                              color: highlightColor.darken(.7),
                            )),
                      )),
                  Positioned.fill(
                      bottom: null,
                      child: IgnorePointer(
                        child: buildImageAsset(
                          smallCard
                              ? 'assets/images/ui/attribute_border_small.png'
                              : 'assets/images/ui/attribute_border.png',
                          fit: BoxFit.fitWidth,
                          color: highlightColor.darken(.4),
                        ),
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
                      end: .001,
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
                  selectedCard?.onTap!(
                      selectedCard?.attribute.allowedDamageTypes.first);
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
                  child: ScrollConfiguration(
                    behavior: scrollConfiguration(context),
                    child: SingleChildScrollView(
                      child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          children: displayedCards),
                    ),
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
