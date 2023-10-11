import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:particle_field/particle_field.dart';
import 'package:rnd/rnd.dart';

class StarBackstripe extends StatefulWidget {
  const StarBackstripe({super.key, this.percentOfHeight = .5});

  final double percentOfHeight;

  @override
  State<StarBackstripe> createState() => _StarBackstripeState();
}

class _StarBackstripeState extends State<StarBackstripe> {
  late Size screenSize;
  late ParticleField field;

  bool firstTick = true;

  double rate = 0.1;

  Duration totalElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    field = ParticleField(
      spriteSheet: SpriteSheet(
          image: const AssetImage('assets/images/effects/star_5.png'),
          frameWidth: 16,
          frameHeight: 16,
          scale: .4,
          length: 5),
      // top left will be 0,0:
      origin: Alignment.topLeft,

      // onTick is where all the magic happens:
      onTick: (controller, elapsed, size) {
        List<Particle> particles = controller.particles;
        if (firstTick) {
          controller.particles.addAll([
            for (int i = 0; i < 500 * rate; i++)
              Particle(x: rnd(size.width), y: rnd(size.height), vx: rnd(0.1, 2))
          ]);
          firstTick = false;
        }

        // add a new particle each frame:
        if (rate > rng.nextDouble()) {
          particles.add(Particle(x: 0, y: rnd(size.height), vx: rnd(0.1, 2)));
        }
        totalElapsed += elapsed;
        bool increase = totalElapsed.inSeconds % 500 == 0;

        // update existing particles:
        for (int i = particles.length - 1; i >= 0; i--) {
          Particle particle = particles[i];
          // call update, which automatically adds vx/vy to x/y
          // add some gravity (ie. increase vertical velocity)
          // and increment the frame
          particle.update(frame: particle.frame + (increase ? 1 : 0));

          // remove particle if it's out of bounds:
          if (!size.contains(particle.toOffset())) particles.removeAt(i);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: ApolloColorPalette.darkestGray.color,
          ),
        ).animate().fadeIn(),
        Positioned.fill(child: ClipRect(child: field))
      ],
    );
  }
}

class ArrowButtonCustom extends StatefulWidget {
  const ArrowButtonCustom(
      {required this.quaterTurns,
      required this.onHoverColor,
      required this.offHoverColor,
      this.scrollController,
      this.groupId = 0,
      this.zIndex = 0,
      this.groupOrientation = Axis.vertical,
      required this.onPrimary,
      super.key});
  final int quaterTurns;
  final int groupId;
  final int zIndex;
  final Axis groupOrientation;
  final Function onPrimary;
  final Color onHoverColor;
  final Color offHoverColor;
  final ScrollController? scrollController;
  @override
  State<ArrowButtonCustom> createState() => _ArrowButtonCustomState();
}

class _ArrowButtonCustomState extends State<ArrowButtonCustom> {
  bool hovered = false;
  bool pushed = false;
  @override
  Widget build(BuildContext context) {
    Color color = hovered ? widget.onHoverColor : widget.offHoverColor;
    return CustomInputWatcher(
            onHover: (value) => setState(() {
                  hovered = value;
                }),
            zHeight: 1,
            scrollController: widget.scrollController,
            groupId: widget.groupId,
            groupOrientation: widget.groupOrientation,
            zIndex: widget.zIndex,
            onPrimary: () {
              widget.onPrimary();
              setState(() {
                pushed = true;
              });
            },
            child: RotatedBox(
              quarterTurns: widget.quaterTurns,
              child: buildImageAsset(
                ImagesAssetsUi.arrowBlack.path,
                fit: BoxFit.contain,
                color: color,
              ),
            ))
        .animate(
          target: hovered ? 1 : 0,
        )
        .scaleXY(begin: 1, end: 1.1, curve: Curves.easeIn, duration: .1.seconds)
        .animate(
          target: pushed ? 1 : 0,
          onComplete: (controller) {
            setState(() {
              pushed = false;
            });
          },
        )
        .scaleXY(
            begin: 1, end: 1.1, curve: Curves.easeIn, duration: .1.seconds);
  }
}
