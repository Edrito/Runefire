import 'dart:async';

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/main.dart';
import 'package:runefire/menus/options.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:particle_field/particle_field.dart';
import 'package:rnd/rnd.dart';

class ExperiencePointsIndicator extends StatefulWidget {
  const ExperiencePointsIndicator(this.gameRef, {super.key});
  final GameRouter gameRef;
  @override
  State<ExperiencePointsIndicator> createState() =>
      _ExperiencePointsIndicatorState();
}

class _ExperiencePointsIndicatorState extends State<ExperiencePointsIndicator>
    with PlayerDataNotifier {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text(
            '${playerData.experiencePoints}',
            style: defaultStyle,
          )
              .animate(
                key: ValueKey(playerData.experiencePoints),
              )
              .shimmer(),
        ),
        buildImageAsset(
          ImagesAssetsExperience.all.path,
          fit: BoxFit.fitHeight,
        ),
      ],
    );
  }

  @override
  // TODO: implement gameRef
  GameRouter get gameRef => widget.gameRef;

  @override
  void onPlayerDataNotification() {
    setState(() {});
  }
}

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
        length: 5,
      ),
      // top left will be 0,0:
      origin: Alignment.topLeft,

      // onTick is where all the magic happens:
      onTick: (controller, elapsed, size) {
        final particles = controller.particles;
        if (firstTick) {
          controller.particles.addAll([
            for (int i = 0; i < 500 * rate; i++)
              Particle(
                x: rnd(size.width),
                y: rnd(size.height),
                vx: rnd(0.1, 2),
              ),
          ]);
          firstTick = false;
        }

        // add a new particle each frame:
        if (rate > rng.nextDouble()) {
          particles.add(Particle(y: rnd(size.height), vx: rnd(0.1, 2)));
        }
        totalElapsed += elapsed;
        final increase = totalElapsed.inSeconds % 500 == 0;

        // update existing particles:
        for (var i = particles.length - 1; i >= 0; i--) {
          final particle = particles[i];
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
        Positioned.fill(child: ClipRect(child: field)),
      ],
    );
  }
}

class ArrowButtonCustom extends StatefulWidget {
  const ArrowButtonCustom({
    required this.quaterTurns,
    required this.onHoverColor,
    required this.offHoverColor,
    required this.onPrimary,
    this.scrollController,
    this.rowId = 0,
    this.zIndex = 0,
    this.groupOrientation = Axis.vertical,
    super.key,
  });
  final int quaterTurns;
  final int rowId;
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
    final color = hovered ? widget.onHoverColor : widget.offHoverColor;
    return CustomInputWatcher(
      onHover: (value) => setState(() {
        hovered = value;
      }),
      zHeight: 1,
      scrollController: widget.scrollController,
      rowId: widget.rowId,
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
      ),
    )
        .animate(
          target: hovered ? 1 : 0,
        )
        .scaleXY(
          begin: 1,
          end: 1.25,
          curve: Curves.easeIn,
          duration: .1.seconds,
        )
        .animate(
          target: pushed ? 1 : 0,
          onComplete: (controller) {
            setState(() {
              pushed = false;
            });
          },
        )
        .scaleXY(
          begin: 1,
          end: 1.25,
          curve: Curves.easeIn,
          duration: .1.seconds,
        );
  }
}

class ElementalPowerBack extends StatefulWidget {
  const ElementalPowerBack(
    this.damageType,
    this.powerLevel, {
    super.key,
  });
  final DamageType damageType;
  final double powerLevel;

  @override
  State<ElementalPowerBack> createState() => _ElementalPowerBackState();
}

class _ElementalPowerBackState extends State<ElementalPowerBack> {
  late Size screenSize;
  late ParticleField field;

  bool firstTick = true;

  double rate = 0.05;

  Duration totalElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    final info = switch (widget.damageType) {
      DamageType.fire => ImagesAssetsDamageEffects.fire,
      DamageType.energy => ImagesAssetsDamageEffects.energy,
      //frost
      DamageType.frost => ImagesAssetsDamageEffects.frost,
      //magic
      DamageType.magic => ImagesAssetsDamageEffects.magic,
      //physical
      DamageType.physical => ImagesAssetsDamageEffects.physical,
      //psychic
      DamageType.psychic => ImagesAssetsDamageEffects.psychic,
      //healing
      DamageType.healing => ImagesAssetsDamageEffects.magic,
    };
    const increaseSpeed = .05;
    field = ParticleField(
      spriteSheet: SpriteSheet(
        image: AssetImage(info.path),
        frameWidth: info.size!.$2.round(),
        frameHeight: info.size!.$2.round(),
        length: info.potentialFrameCount ?? 1,
        scale: 3,
      ),
      // top left will be 0,0:
      origin: Alignment.bottomLeft,

      // onTick is where all the magic happens:
      onTick: (controller, elapsed, size) {
        final particles = controller.particles;
        if (firstTick) {
          controller.particles.addAll([
            for (int i = 0; i < 200 * rate; i++)
              Particle(
                x: rnd(size.width),
                y: -rnd(size.height),
                vy: -rnd(0.1, 1),
              ),
          ]);
          firstTick = false;
        }

        // add a new particle each frame:
        if (rate > rng.nextDouble()) {
          particles.add(
            Particle(
              x: rnd(size.width),
              vy: -rnd(widget.powerLevel, .5 + (widget.powerLevel * 4)),
            ),
          );
        }
        totalElapsed += elapsed;
        var increase = false;
        // update existing particles:
        for (var i = particles.length - 1; i >= 0; i--) {
          increase = rng.nextDouble() < increaseSpeed;
          final particle = particles[i];
          // call update, which automatically adds vx/vy to x/y
          // add some gravity (ie. increase vertical velocity)
          // and increment the frame
          particle.update(frame: particle.frame + (increase ? 1 : 0));

          // remove particle if it's out of bounds:
          if (particle.y.abs() > size.height) {
            particles.removeAt(i);
          }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: ColoredBox(
                  color: widget.damageType.color.brighten(.3),
                ),
              ),
              Expanded(
                flex: 2,
                child: ColoredBox(
                  color: widget.damageType.color,
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: widget.damageType.color.darken(.3),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(child: ClipRect(child: field)),
      ],
    );
  }
}
