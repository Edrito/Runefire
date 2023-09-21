import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/resources/functions/custom.dart';

import '../main.dart';
import '../menus/menus.dart';
import '../resources/enums.dart';
import '../resources/functions/functions.dart';
import '../resources/game_state_class.dart';
import 'enviroment.dart';

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

  @override
  void dispose() {
    playerDataNotifer.removeListener(onNotifier);
    gameStateNotifier.removeListener(onNotifier);
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
  }

  Widget buildPortalImage(MenuPageType menuPage, GameLevel selectedLevel) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(500),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              selectedLevel.levelImage,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
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

  final bigPortalSize = 1.0;
  final smallPortalSize = .7;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final smallestDimension =
        size.width < size.height ? size.width : size.height;

    selectedMenuPage = gameState.currentMenuPage;
    selectedLevel = gameState.playerData.selectedLevel;
    final portalImage = buildPortalImage(selectedMenuPage!, selectedLevel!);

    Widget buildWidget(BuildContext context, double value, Widget child) {
      final portalColor =
          gameState.basePortalColor.mergeWith(gameState.portalColor(), value);

      final portalSize = (smallestDimension * smallPortalSize) +
          (smallestDimension * (bigPortalSize - smallPortalSize) * value);

      Widget ring = Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
                  child: buildImageAsset(
            'assets/images/background/innerRingPatterns.png',
            fit: BoxFit.fill,
            color: portalColor,
          ).animate(
            onComplete: (controller) {
              controller.forward(from: 0);
            },
          ).rotate(begin: 0, end: -1, duration: 180.seconds))
              .animate(
                target: menuPageIsLevel ? 1 : 0,
              )
              .blurXY(
                end: 20,
                curve: Curves.easeInCirc,
                duration: 1.seconds,
              )
              .rotate(curve: Curves.easeInCirc, duration: 1.seconds, end: 1),
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
              child: buildImageAsset(
            'assets/images/background/outerRing.png',
            fit: BoxFit.fill,
            color: portalColor,
          )
              // .animate(
              //   onComplete: (controller) {
              //     controller.forward(from: 0);
              //   },
              // ).rotate(
              //     begin: 0,
              //     end: 1,
              //     duration: menuPageIsLevel ? 4.seconds : 180.seconds),
              ),
          Positioned.fill(
            child: buildImageAsset(
              'assets/images/background/outerRingPatterns.png',
              color: portalColor,
              fit: BoxFit.fill,
            ).animate(
              onComplete: (controller) {
                controller.forward(from: 0);
              },
            ).rotate(
                begin: 0,
                end: -1,
                duration: menuPageIsLevel ? 18.seconds : 360.seconds),
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
          bottom: (size.height / 2 - portalSize / 2) - 5,
          child: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                  portalColor.withOpacity(.8), BlendMode.modulate),
              child: Center(
                  child: SizedBox.square(dimension: portalSize, child: ring)),
            ),
          ),
        ),
        // Align(
        //   alignment: Alignment.center,
        //   child: ColorFiltered(
        //     colorFilter: ColorFilter.mode(
        //         portalColor.darken(.6).withOpacity(.5), BlendMode.modulate),
        //     child: Center(
        //         child: SizedBox.square(dimension: portalSize, child: ring)),
        //   ),
        // ),
        Positioned(
          bottom: size.height / 2 - portalSize / 2,
          // child: ShaderMask(
          //   blendMode: BlendMode.modulate,
          //   shaderCallback: (bounds) {
          //     return LinearGradient(colors: [
          //       ApolloColorPalette.lightBlue.color.brighten(.6),
          //       Colors.white
          //     ], begin: Alignment.bottomCenter, end: Alignment.topCenter)
          //         .createShader(bounds);
          //   },
          child: Center(
              key: gameState.centerBackgroundKey,
              child: SizedBox.square(dimension: portalSize, child: ring)),
          // )
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
                          end: const Offset(80, .1))),
            )),
        Positioned(
            bottom: size.height / 2 - portalSize / 2,
            child: Opacity(
              opacity: .1,
              child: Center(
                  child: SizedBox.square(dimension: portalSize, child: ring)
                      .animate()
                      .blur(
                          begin: const Offset(0, 0),
                          end: const Offset(40, 40))),
            )),
      ]);
    }

    return Animate(
      target: menuPageIsLevel ? 1 : 0,
      effects: [
        CustomEffect(
          duration: menuPageIsLevel ? 1.5.seconds : .75.seconds,
          curve: Curves.easeInOutCirc,
          builder: (context, value, child) {
            return buildWidget(context, value, child);
          },
        )
      ],
    );
  }
}
