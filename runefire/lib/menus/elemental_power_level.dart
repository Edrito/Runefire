// ignore_for_file: join_return_with_assignment

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:recase/recase.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/menus/custom_button.dart';
import 'package:runefire/menus/custom_widgets.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/visuals.dart';

class TotalPowerGraph extends StatefulWidget {
  const TotalPowerGraph({
    required this.player,
    this.showTitle = true,
    this.zHeight = 0,
    super.key,
  });
  final Player player;
  final bool showTitle;
  final int zHeight;
  @override
  State<TotalPowerGraph> createState() => _TotalPowerGraphState();
}

class _TotalPowerGraphState extends State<TotalPowerGraph> {
  Map<DamageType, GlobalKey> overlayKeys = {};

  Widget buildBar(double percent, DamageType damageType) {
    Widget returnWidget;
    overlayKeys[damageType] ??= GlobalKey<CustomInputWatcherState>();

    final size = ImagesAssetsUi.elementalColumn.size!;
    final height = size.$2 * 2;
    final width = height * (size.$1 / size.$2);
    final padding = width * .25;
    var hovered = false;
    returnWidget = StatefulBuilder(
      builder: (context, ss) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: CustomInputWatcher(
            hoverWidget: SizedBox(
              key: overlayKeys[damageType],
              height: 600,
              width: 400,
              child: ElementalPowerListDisplay(
                damageType: damageType,
                player: widget.player,
              ),
            ),
            rowId: 10,
            zHeight: widget.zHeight ?? 0,
            onHover: (isHover) {
              ss(() => hovered = isHover);
            },
            child: SizedBox(
              width: width * 1.5,
              child: Row(
                children: [
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      damageType.name.titleCase,
                      style: defaultStyle.copyWith(
                        fontSize: 32,
                        color: hovered
                            ? damageType.color.darken(.5)
                            : damageType.color,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: height,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned.fill(
                            right: 6,
                            child: buildImageAsset(
                              ImagesAssetsUi.elementalColumn.path,
                              fit: BoxFit.fitHeight,
                              color: damageType.color.darken(.5),
                            ),
                          ),
                          Positioned(
                            height: height - padding * 2,
                            width: width - (padding * 2),
                            bottom: padding,
                            child: SizedBox.expand(
                              child: ColoredBox(
                                color: ApolloColorPalette.darkestGray.color,
                              ),
                            ),
                          ),
                          Positioned(
                            height: (height - (padding * 2)) * percent,
                            width: width - (padding * 2),
                            bottom: width * .25,
                            child: SizedBox.expand(
                              child: ElementalPowerBack(damageType, percent),
                            ),
                          ),
                          Positioned.fill(
                            child: buildImageAsset(
                              ImagesAssetsUi.elementalColumn.path,
                              fit: BoxFit.fitHeight,
                              color:
                                  hovered ? damageType.color.darken(.5) : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return returnWidget;
  }

  bool showWidget = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final collapse = size.height < 900;
    if (!collapse) {
      showWidget = false;
    }
    return Column(
      children: [
        if (collapse)
          CustomButton(
            "${showWidget ? 'Hide' : 'Show'} Elemental Power",
            rowId: 10,
            zHeight: widget.zHeight ?? 0,
            gameRef: widget.player.game,
            onPrimary: () => setState(() => showWidget = !showWidget),
          ),
        if (showWidget || !collapse)
          SizedBox(
            child: Container(
              color: !showWidget
                  ? Colors.transparent
                  : ApolloColorPalette.darkestGray.color,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (widget.showTitle)
                      Text(
                        'Elemental Power',
                        style: defaultStyle,
                      ),
                    Row(
                      children: [
                        for (final type
                            in DamageType.values.toList()
                              ..remove(DamageType.healing))
                          buildBar(
                            widget.player.elementalPower[type] ?? 0,
                            type,
                          ),
                      ].animate(interval: .2.seconds).moveY(begin: 50).fadeIn(),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
