import 'dart:async';
import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/visuals.dart';

import '../main.dart';
import '../menus/menus.dart';
import '../resources/enums.dart';
import '../resources/functions/functions.dart';
import '../resources/game_state_class.dart';
import 'enviroment.dart';

class SpriteShadows extends Component {
  SpriteShadows(
    this.env,
  ) : super(priority: backgroundPriority + 1);
  late final Paint shadowPaint = colorPalette
      .buildPaint(ApolloColorPalette.darkestGray.color.withOpacity(.25));

  Enviroment env;
  @override
  void render(Canvas canvas) {
    final viewPortSize = Vector2.zero();
    final Vector2 temp = Vector2.zero();
    for (var element in env.activeEntites) {
      final double heightPar = element.spriteSize.y;
      temp.setFrom((((element.center)) + viewPortSize));
      temp.y += heightPar * .5;
      canvas.drawOval(
          Rect.fromCenter(
              center: temp.toOffset(),
              width: heightPar * .7,
              height: heightPar * .25),
          shadowPaint);
    }

    super.render(canvas);
  }
}

abstract class BackgroundComponent extends ParallaxComponent<GameRouter> {
  BackgroundComponent(this.gameReference);
  Enviroment gameReference;
}

class Forge2DComponent extends Component {}

class BlankBackground extends BackgroundComponent {
  BlankBackground(super.gameReference);

  @override
  FutureOr<void> onLoad() async {
    final backgroundLayer = await game.loadParallaxLayer(
      ParallaxImageData('background/blank.png'),
      filterQuality: FilterQuality.none,
      fill: LayerFill.none,
      repeat: ImageRepeat.repeat,
    );

    parallax = Parallax(
      [
        backgroundLayer,
      ],
    );

    anchor = Anchor.center;
    priority = backgroundPriority;

    positionType = PositionType.viewport;

    size = size / 50;
    return super.onLoad();
  }
}

class CaveBackground extends StatefulWidget {
  const CaveBackground({
    super.key,
    required this.gameRef,
  });
  final GameRouter gameRef;

  @override
  State<CaveBackground> createState() => _CaveBackgroundState();
}

class _CaveBackgroundState extends State<CaveBackground> {
  late ComponentsNotifier<PlayerDataComponent> playerDataNotifer;
  late ComponentsNotifier<GameStateComponent> gameStateNotifier;
  late final PlayerData playerData;
  late final GameState gameState;

  final List<String> runes = [
    ImagesAssetsRunes.rune1.path,
    ImagesAssetsRunes.rune2.path,
    ImagesAssetsRunes.rune3.path,
    ImagesAssetsRunes.rune4.path,
    ImagesAssetsRunes.rune5.path,
    ImagesAssetsRunes.rune6.path,
    ImagesAssetsRunes.rune7.path,
    ImagesAssetsRunes.rune8.path,
  ];

  late async.Timer changeRuneTimer;

  @override
  void dispose() {
    playerDataNotifer.removeListener(onNotifier);
    gameStateNotifier.removeListener(onNotifier);
    changeRuneTimer.cancel();
    super.dispose();
  }

  void onNotifier() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    playerDataNotifer =
        widget.gameRef.componentsNotifier<PlayerDataComponent>();
    gameStateNotifier = widget.gameRef.componentsNotifier<GameStateComponent>();

    playerDataNotifer.addListener(onNotifier);
    gameStateNotifier.addListener(onNotifier);
    gameState = widget.gameRef.gameStateComponent.gameState;

    playerData = gameState.playerData;
    widget.gameRef.gameStateComponent.gameState.centerBackgroundKey =
        GlobalKey();

    const flickerFreq = .5;
    changeRuneTimer = async.Timer.periodic(3.seconds, (timer) async {
      if (!mounted) return;
      if (runes.length >= 2) {
        List<Future> futures = [];

        while (flickerFreq > rng.nextDouble()) {
          futures.add(//
              Future.delayed(rng.nextDouble().seconds).then((value) {
            //
            var index1 = rng.nextInt(runes.length);
            var index2 = rng.nextInt(runes.length);

            // Ensure that the two indices are not the same
            while (index1 == index2) {
              index2 = rng.nextInt(runes.length);
            }

            // Swap the elements at the random indices
            var temp = runes[index1];
            runes[index1] = runes[index2];
            runes[index2] = temp;
            if (mounted) {
              setState(() {});
            }
          }));
        }

        await Future.wait(futures);
      }
    });
  }

  Widget buildPortalImage(MenuPageType menuPage, GameLevel selectedLevel) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(500),
      child: Stack(
        children: [
          Positioned.fill(
            child: buildImageAsset(
              selectedLevel.levelImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            left: 400,
            child: Center(
              child: Container(
                height: double.infinity,
                width: 20,
                color: Colors.grey.withOpacity(.2),
                transform: Matrix4.skewX(-.5),
              ),
            ).animate().fadeIn().moveX(
                begin: -200,
                end: 70,
                curve: Curves.easeOutCubic,
                duration: 2.seconds),
          ),
          Positioned.fill(
            left: 200,
            child: Center(
              child: Container(
                height: double.infinity,
                width: 80,
                color: Colors.grey.withOpacity(.1),
                transform: Matrix4.skewX(-.5),
              ),
            ).animate().fadeIn().moveX(
                begin: -150,
                end: 68,
                curve: Curves.easeOutCubic,
                duration: 2.seconds),
          )
        ],
      ),
    )
        .animate(
          target: menuPageIsLevel ? 1 : 0,
        )
        .rotate(
            delay: .5.seconds,
            begin: -.1,
            curve: Curves.easeInOutCubicEmphasized,
            duration: menuPageIsLevel ? 2.seconds : .5.seconds)
        .fadeIn(
            delay: .5.seconds,
            curve: menuPageIsLevel ? Curves.ease : Curves.ease,
            begin: 0,
            duration: menuPageIsLevel ? 1.seconds : 1.seconds);
  }

  GameLevel? selectedLevel;
  MenuPageType? selectedMenuPage;
  bool get menuPageIsLevel => gameState.menuPageIsLevel;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final smallestDimension =
        size.width < size.height ? size.width : size.height;
    final scale = getHeightScaleStep(smallestDimension);

    selectedMenuPage = gameState.currentMenuPage;
    selectedLevel = gameState.playerData.selectedLevel;
    final portalImage = buildPortalImage(selectedMenuPage!, selectedLevel!);

    Widget buildWidget(BuildContext context, double value, Widget child) {
      final portalColor =
          gameState.basePortalColor.mergeWith(gameState.portalColor(), value);

      // final portalSize = (smallestDimension * smallPortalSize) +
      //     (smallestDimension * (bigPortalSize - smallPortalSize) * value);
      final double portalSize = portalBaseSize * scale * ((value / 4) + 1);
      // final innerRingWidget = buildImageAsset(
      //   'assets/images/background/innerRingPatterns.png',
      //   fit: BoxFit.fill,
      //   color: portalColor,
      // );

      List<Widget> runeWidgets = [];

      for (var i = 0; i < runes.length; i++) {
        final rune = runes[i];
        final runeSize = (smallestDimension * .1);
        final runeWidget = Transform.rotate(
          angle: (2 * pi) * (i / runes.length),
          origin: Offset(0, portalSize / 4),
          child: SizedBox(
            width: runeSize,
            height: portalSize / 2,
            child: Align(
              alignment: const Alignment(0, .15),
              child: SizedBox.square(
                  dimension: runeSize,
                  child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          portalColor.withOpacity(value), BlendMode.srcATop),
                      child: buildImageAsset(
                        rune,
                        fit: BoxFit.contain,
                        // color: portalColor,
                      ))
                  // .animate().rotate(
                  //     begin: 0,
                  //     end: 1,
                  //     duration: menuPageIsLevel ? 4.seconds : 180.seconds),
                  ),
            ),
          ),
        );

        runeWidgets.add(runeWidget);
      }

      final innerRingWidget = Positioned(
          top: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (Widget ringPiece in runeWidgets) ringPiece,
            ],
          ).animate(
            onComplete: (controller) {
              controller.forward(from: 0);
            },
          ).rotate(
            begin: 0,
            end: -1,
            alignment: Alignment.bottomCenter,
            duration: 180.seconds,
          ));

      Widget ring = Stack(
        alignment: Alignment.center,
        children: [
          innerRingWidget,
          Animate(
            // key: UniqueKey(),
            effects: const [
              // FadeEffect(duration: .75.seconds, curve: Curves.fastOutSlowIn)
            ],
            target: menuPageIsLevel ? 1 : 0,
            child: Positioned.fill(
                child: Center(
                    child: SizedBox.square(
                        dimension: portalSize * .675, child: portalImage))),
          ),
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                  portalColor.withOpacity(value), BlendMode.srcATop),
              child: buildImageAsset(
                'assets/images/background/outerRing.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned.fill(
            child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                    portalColor.withOpacity(value), BlendMode.srcATop),
                child: buildImageAsset(
                  'assets/images/background/outerRingPatterns.png',
                  fit: BoxFit.fill,
                )).animate(
              onComplete: (controller) {
                controller.forward(from: 0);
              },
            ).rotate(
                begin: 0,
                end: -1,
                duration: menuPageIsLevel ? 18.seconds : 320.seconds),
          ),
        ],
      )
          .animate(
            onComplete: (controller) =>
                controller.reverse().then((value) => controller.forward()),
          )
          .moveY(
              begin: -6, end: 6, duration: 4.seconds, curve: Curves.easeInOut);

      return Stack(alignment: Alignment.center, children: [
        Positioned.fill(
          child: buildImageAsset(
            'assets/images/background/cave.png',
          ),
        ),
        Positioned(
          bottom: (size.height / 2 - portalSize / 2) - 10,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                  ApolloColorPalette.darkestBlue.color.withOpacity(.2),
                  BlendMode.srcIn),
              child: Center(
                  child: SizedBox.square(dimension: portalSize, child: ring)),
            ),
          ),
        ),
        Positioned(
            bottom: size.height / 2 - portalSize / 2,
            child: Opacity(
              opacity: .2,
              child: Center(
                  child: SizedBox.square(dimension: portalSize, child: ring)
                      .animate()
                      .blur(
                          begin: const Offset(0, 0),
                          end: const Offset(.1, 80))),
            )),
        Positioned(
            bottom: size.height / 2 - portalSize / 2,
            child: Opacity(
              opacity: .1,
              child: Center(
                  child: SizedBox.square(dimension: portalSize, child: ring)
                      .animate()
                      .blur(begin: Offset.zero, end: const Offset(40, 40))),
            )),
        Positioned(
          bottom: size.height / 2 - portalSize / 2,
          child: Center(
              key: gameState.centerBackgroundKey,
              child: SizedBox.square(dimension: portalSize, child: ring)),
        ),
      ]);
    }

    return Animate(
      target: menuPageIsLevel ? 1 : 0,
      effects: [
        CustomEffect(
          duration: menuPageIsLevel ? 1.5.seconds : .75.seconds,
          curve: Curves.easeInOutCirc,
          end: 1,
          builder: (context, value, child) {
            return buildWidget(context, value, child);
          },
        )
      ],
    );
  }
}
