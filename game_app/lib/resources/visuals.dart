import 'dart:io';
import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:window_manager/window_manager.dart';
import '../main.dart';

const Color buttonDownColor = Color.fromARGB(255, 58, 58, 58);
const Color buttonUpColor = Color.fromARGB(255, 239, 80, 114);
const Color backgroundColor1 = Color.fromARGB(255, 22, 0, 20);
const Color backgroundColor2 = Color.fromARGB(255, 158, 48, 147);
const Color unlockedColor = Color.fromARGB(255, 122, 89, 118);
const Color equippedColor = Color.fromARGB(255, 204, 131, 197);
const Color lockedColor = Color.fromARGB(255, 61, 36, 58);

final defaultStyle = TextStyle(
  fontSize: Platform.isAndroid || Platform.isIOS ? 21 : 35,
  fontFamily: "HeroSpeak",
  fontWeight: FontWeight.bold,
  color: buttonUpColor,
  shadows: const [
    BoxShadow(
        color: Colors.black12,
        offset: Offset(3, 3),
        spreadRadius: 3,
        blurRadius: 0)
  ],
);

class BackgroundWidget extends StatefulWidget {
  const BackgroundWidget({super.key});

  @override
  State<BackgroundWidget> createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<BackgroundWidget>
    with WindowListener, TickerProviderStateMixin {
  late AnimationController _controllerForeground;
  late AnimationController _controllerBackground;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    focusNode.requestFocus();
    _controllerBackground = AnimationController(
      duration: const Duration(seconds: 40),
      vsync: this,
    )..repeat(); // Loop the animation in reverse
    _controllerForeground = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(); // Loop the animation in reverse
    // timer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
    //   setState(() {});
    // });
  }

  // late Timer timer;

  @override
  void onWindowResized() {
    setState(() {
      gameSize = null;
    });

    super.onWindowResized();
  }

  Widget buildStar(double heightThird) {
    final yPos = rng.nextDouble() * gameSize!.height * .8;
    var opacity = 1.0;
    if (yPos > heightThird) {
      opacity = 1 - (yPos - heightThird) / heightThird;
      opacity = opacity.clamp(0, 1);
    }

    return Positioned(
        left: rng.nextDouble() * gameSize!.width,
        top: yPos,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(opacity),
          ),
          width: 3 + (rng.nextDouble() * 2),
          height: 3 + (rng.nextDouble() * 2),
        )
            .animate()
            .moveY(
                duration: 3.seconds,
                curve: Curves.easeInOutCubic,
                begin: 40 * rng.nextDouble(),
                end: 0)
            .fadeIn(curve: Curves.easeInOutCubic, duration: 3.seconds));
  }

  FocusNode focusNode = FocusNode();
  Size? gameSize;

  @override
  Widget build(BuildContext context) {
    gameSize ??= MediaQuery.of(context).size;
    final heightThird = gameSize!.height / 3;
    return KeyboardListener(
      focusNode: focusNode,
      child: Stack(children: [
        Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.pink, backgroundColor1],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter)),
        ),
        for (var i = 0; i < 50; i++) buildStar(heightThird),

        Positioned.fill(
            child: Center(
          child: Container(
            alignment: Alignment.center,
            height: heightThird * 2,
            width: heightThird * 2,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [
                  backgroundColor1.brighten(.5),
                  Colors.pink,
                ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
          ),
        )
                .animate(
                  onComplete: (controller) => controller
                      .reverse()
                      .then((value) => controller.forward()),
                )
                .moveY(
                    duration: 3.seconds,
                    curve: Curves.easeInOutCubic,
                    begin: 3,
                    end: 0)
                .animate()
                .fadeIn(curve: Curves.easeInOutCubic, duration: 2.seconds)),

        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedBuilder(
            animation: _controllerBackground,
            builder: (context, child) {
              final waveOffset = _controllerBackground.value * pi * 2;
              return ClipPath(
                clipper: WaveClipper(waveOffset, false),
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    const Color.fromARGB(255, 73, 26, 48),
                    const Color.fromARGB(255, 213, 0, 99).darken(.5),
                  ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedBuilder(
            animation: _controllerForeground,
            builder: (context, child) {
              final waveOffset = _controllerForeground.value * pi * 2;
              return ClipPath(
                clipper: WaveClipper(waveOffset, true),
                child: Container(
                  // height: heightThird,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                    Color.fromARGB(255, 122, 48, 70),
                    Color.fromARGB(255, 124, 30, 50)
                  ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
                ),
              );
            },
          ),
        ),

        // ClipPath(
        //   clipper: WaveClipper(),
        //   child: Container(color: Colors.blue),
        // ),
      ]),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double offset;

  WaveClipper(this.offset, this.isForeground);
  bool isForeground;
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height / 2);
    for (double x = 0; x <= size.width; x++) {
      final y = (size.height / 1.2) -
          (isForeground ? 0 : size.height / 10) +
          sin(offset + x * (isForeground ? 0.004 : 0.003)) *
              (isForeground ? 40 : 60);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) => true;
}
