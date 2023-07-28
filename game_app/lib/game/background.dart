import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/resources/constants/priorities.dart';

import '../main.dart';
import '../resources/enums.dart';
import 'enviroment.dart';

abstract class BackgroundComponent extends ParallaxComponent<GameRouter> {
  abstract final GameLevel gameLevel;
  BackgroundComponent(this.gameReference);
  Enviroment gameReference;
}

class Forge2DComponent extends Component {}

class BlankBackground extends BackgroundComponent {
  BlankBackground(super.gameReference);

  @override
  GameLevel get gameLevel => GameLevel.menu;

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

class CaveBackground extends StatelessWidget {
  const CaveBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final smallestDimension =
        size.width < size.height ? size.width : size.height;
    final ring = Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/background/innerRingPatterns.png',
            filterQuality: FilterQuality.none,
            color: const Color.fromARGB(255, 86, 179, 255),
            fit: BoxFit.fill,
          ).animate(
            onComplete: (controller) {
              controller.forward(from: 0);
            },
          ).rotate(begin: 0, end: -pi, duration: 180.seconds),
        ),
        Positioned.fill(
          child: Image.asset(
            'assets/images/background/outerRing.png',
            color: const Color.fromARGB(255, 86, 179, 255),
            filterQuality: FilterQuality.none,
            fit: BoxFit.fill,
          ).animate(
            onComplete: (controller) {
              controller.forward(from: 0);
            },
          ).rotate(begin: 0, end: -pi, duration: 1800.seconds),
        ),
        Positioned.fill(
          child: Image.asset(
            'assets/images/background/outerRingPatterns.png',
            filterQuality: FilterQuality.none,
            color: const Color.fromARGB(255, 86, 179, 255),
            fit: BoxFit.fill,
          ).animate(
            onComplete: (controller) {
              controller.forward(from: 0);
            },
          ).rotate(begin: 0, end: pi, duration: 180.seconds),
        ),
      ],
    );
    return Stack(children: [
      Positioned.fill(
        child: Image.asset(
          'assets/images/background/cave.png',
          filterQuality: FilterQuality.none,
          fit: BoxFit.cover,
        ),
      ),
      Positioned.fill(
        left: -5,
        top: 5,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
              Colors.blue.shade900.withOpacity(.5), BlendMode.modulate),
          child: Center(
              child: SizedBox.square(
                      dimension: smallestDimension * 0.5, child: ring)
                  .animate()
                  .fadeIn()),
        ),
      ),
      Positioned.fill(
          child: ShaderMask(
        blendMode: BlendMode.modulate,
        shaderCallback: (bounds) {
          return const LinearGradient(
                  colors: [Colors.blue, Colors.white],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter)
              .createShader(bounds);
        },
        child: Center(
            child:
                SizedBox.square(dimension: smallestDimension * 0.5, child: ring)
                    .animate()
                    .fadeIn()),
      )),
      Positioned.fill(
          child: Opacity(
        opacity: .4,
        child: Center(
            child:
                SizedBox.square(dimension: smallestDimension * 0.5, child: ring)
                    .animate()
                    .blur(begin: const Offset(5, 5), end: const Offset(40, 1))),
      )),
      Positioned.fill(
          child: Opacity(
        opacity: .2,
        child: Center(
            child: SizedBox.square(
                    dimension: smallestDimension * 0.5, child: ring)
                .animate()
                .blur(begin: const Offset(5, 5), end: const Offset(40, 40))),
      )),
    ]);
  }
}
