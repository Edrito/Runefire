import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/main.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/menus/overlays.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/functions.dart';
import '../resources/visuals.dart';

class CustomCard extends StatefulWidget {
  const CustomCard(
    this.attribute, {
    required this.gameRef,
    this.onPrimary,
    this.rowId = 0,
    this.smallCard = false,
    this.groupOrientation = Axis.horizontal,
    this.scrollController,
    Key? key,
  }) : super(key: key);
  final ScrollController? scrollController;
  final GameRouter gameRef;
  final Function(DamageType? damageType)? onPrimary;
  final bool smallCard;
  final Attribute attribute;
  final Axis groupOrientation;
  final int rowId;

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  final topPadding = 90.0;

  bool isHovered = false;
  bool showHelp = false;
  late final Size cardSize = widget.smallCard ? smallCardSize : largeCardSize;

  @override
  Widget build(BuildContext context) {
    final highlightColor = isHovered
        ? widget.attribute.attributeType.rarity.color.darken(.2)
        : widget.attribute.attributeType.rarity.color.brighten(.1);
    final regularColor = Colors.grey.shade100;

    bool hasDamageTypeSelector =
        widget.attribute.allowedDamageTypes.isNotEmpty &&
            widget.attribute.damageType == null;

    TextStyle style =
        defaultStyle.copyWith(color: regularColor, fontSize: 30, shadows: []);

    List<Widget> levelIndicators = [];

    if (widget.attribute.maxLevel != null) {
      for (int i = 0; i < widget.attribute.upgradeLevel; i++) {
        levelIndicators.add(Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            Icons.circle,
            size: 25,
            color: highlightColor.darken(.4),
          ),
        ));
      }

      for (var i = 0;
          i < widget.attribute.maxLevel! - widget.attribute.upgradeLevel;
          i++) {
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
          maxWidth: !widget.smallCard
              ? (100 * (size.width / 400)).clamp(350, 450)
              : 400,
          minWidth: 100),
      child: LayoutBuilder(builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = cardWidth * (cardSize.height / cardSize.width);

        Widget background = Positioned.fill(
            bottom: null,
            child: Image.asset(
              widget.smallCard
                  ? 'assets/images/ui/attribute_background_mask_small.png'
                  : 'assets/images/ui/attribute_background_mask.png',
              fit: BoxFit.fitWidth,
              color: Colors.grey.shade900.withOpacity(.85),
              filterQuality: FilterQuality.none,
            ));

        Widget attributeIcon = buildImageAsset(
          'assets/images/${widget.attribute.icon}',
          fit: BoxFit.contain,
          color: widget.attribute.damageType?.color ?? regularColor,
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
                widget.attribute.title,
                style: style.copyWith(color: highlightColor.brighten(.3)),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.clip,
              ),
            ),
          ),
        );

        Widget content = Positioned(
          height:
              cardHeight - (widget.smallCard ? topPadding / 1.15 : topPadding),
          width: cardWidth,
          bottom: 0,
          child: Container(
            color: highlightColor.withOpacity(.05),
            child: Padding(
              padding: widget.smallCard
                  ? const EdgeInsets.symmetric(horizontal: 20, vertical: 5)
                  : const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: widget.smallCard
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            widget.attribute.description(),
                            style: style.copyWith(
                              fontSize: (style.fontSize! * .75),
                              color: style.color!.darken(.1),
                              fontWeight: FontWeight.w200,
                            ),
                            textAlign: widget.smallCard
                                ? TextAlign.center
                                : TextAlign.left,
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
                                padding: widget.smallCard
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
                  if (!widget.smallCard)
                    SizedBox(
                      height: 50,
                      child: !hasDamageTypeSelector &&
                              widget.attribute.maxLevel != 1
                          ? Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
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

        return CustomInputWatcher(
          scrollController: widget.scrollController,
          rowId: widget.rowId,
          onHover: (value) {
            setState(() {
              isHovered = value;
            });
          },
          onPrimary: () {
            if (!hasDamageTypeSelector) {
              widget.onPrimary?.call(null);
            }
          },
          child: SizedBox(
            height: cardHeight,
            child: Stack(
              children: [
                background,
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: Stack(
                      children: [title, content],
                    ),
                  ),
                ),
                if (hasDamageTypeSelector)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(35),
                          bottomRight: Radius.circular(35)),
                      child: DamageTypeSelector(
                        widget.attribute.allowedDamageTypes,
                        (p0) {
                          widget.onPrimary?.call(p0);
                        },
                        scrollController: widget.scrollController,
                      ),
                    ),
                  ),
                Positioned.fill(
                    bottom: null,
                    child: IgnorePointer(
                      child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: buildImageAsset(
                            widget.smallCard
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
                            widget.smallCard
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
                        widget.smallCard
                            ? 'assets/images/ui/attribute_border_small.png'
                            : 'assets/images/ui/attribute_border.png',
                        fit: BoxFit.fitWidth,
                        color: highlightColor.darken(.4),
                      ),
                    )),
              ],
            )
                .animate(
                  target: isHovered ? 1 : 0,
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
    return card
        .animate(
          onPlay: (controller) => controller.forward(from: rng.nextDouble()),
          onComplete: (controller) =>
              controller.reverse().then((value) => controller.forward()),
        )
        .moveY(end: 4, curve: Curves.easeInOut, duration: 1.seconds);
  }
}
