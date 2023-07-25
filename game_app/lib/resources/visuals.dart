import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'enums.dart';
import 'functions/functions.dart';

const uiWidthMax = 1300.0;

extension CustomColors on BasicPalette {
  static const PaletteEntry secondaryColorPalette =
      PaletteEntry(secondaryColor);
  static const PaletteEntry primaryColorPalette = PaletteEntry(primaryColor);
}

const Color primaryColor = ui.Color.fromARGB(255, 67, 164, 255);
const Color secondaryColor = ui.Color.fromARGB(255, 133, 210, 255);
const Color buttonDownColor = secondaryColor;
const Color buttonUpColor = primaryColor;
const Color backgroundColor1 = ui.Color.fromARGB(255, 22, 0, 5);
const Color backgroundColor2 = ui.Color.fromARGB(255, 48, 99, 158);
const Color lockedColor = ui.Color.fromARGB(255, 49, 49, 49);
const Color hoverColor = ui.Color.fromARGB(255, 0, 59, 107);
const Color unlockedColor = ui.Color.fromARGB(255, 24, 24, 24);
const Color secondaryEquippedColor = ui.Color.fromARGB(255, 163, 113, 255);
const Color levelUnlockedUnequipped = ui.Color.fromARGB(255, 62, 31, 119);

double defaultFrameDuration = .15;

Future<SpriteAnimation> getEffectSprite(StatusEffects statusEffect) async {
  SpriteAnimation spriteAnimation;

  switch (statusEffect) {
    case StatusEffects.stun:
      spriteAnimation = await buildSpriteSheet(
          4, 'status_effects/fire_effect.png', defaultFrameDuration, true);

      break;

    // case StatusEffects.slow:
    //   break;

    // case StatusEffects.burn:
    //   break;

    // case StatusEffects.freeze:
    //   break;

    // case StatusEffects.bleed:
    //   break;

    // case StatusEffects.energy:
    //   break;

    // case StatusEffects.misc:
    //   break;
    default:
      spriteAnimation = await buildSpriteSheet(
          4, 'status_effects/fire_effect.png', defaultFrameDuration, true);
  }
  return spriteAnimation;
}

final defaultStyle = TextStyle(
  fontSize: Platform.isAndroid || Platform.isIOS ? 21 : 35,
  fontFamily: "YuseiMagic",
  fontWeight: FontWeight.bold,
  color: buttonUpColor,
  shadows: const [],
);

// class BackgroundWidget extends StatefulWidget {
//   const BackgroundWidget({super.key});

//   @override
//   State<BackgroundWidget> createState() => _BackgroundWidgetState();
// }

// class _BackgroundWidgetState extends State<BackgroundWidget>
//     with WindowListener, TickerProviderStateMixin {
//   late AnimationController _controllerForeground;
//   late AnimationController _controllerBackground;

//   @override
//   void initState() {
//     super.initState();
//     windowManager.addListener(this);
//     focusNode.requestFocus();
//     _controllerBackground = AnimationController(
//       duration: const Duration(seconds: 40),
//       vsync: this,
//     )..repeat(); // Loop the animation in reverse
//     _controllerForeground = AnimationController(
//       duration: const Duration(seconds: 15),
//       vsync: this,
//     )..repeat(); // Loop the animation in reverse
//     // timer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
//     //   setState(() {});
//     // });
//   }

//   // late Timer timer;

//   void resetStars() {
//     if (!mounted) return;
//     setState(() {
//       gameSize = MediaQuery.of(context).size;
//     });
//   }

//   @override
//   void onWindowEnterFullScreen() {
//     resetStars();
//     super.onWindowEnterFullScreen();
//   }

//   @override
//   void onWindowMaximize() {
//     Future.delayed(const Duration(milliseconds: 100)).then((value) {
//       resetStars();
//     });

//     super.onWindowMaximize();
//   }

//   @override
//   void onWindowUnmaximize() {
//     Future.delayed(const Duration(milliseconds: 100)).then((value) {
//       resetStars();
//     });
//     super.onWindowUnmaximize();
//   }

//   @override
//   void onWindowLeaveFullScreen() {
//     resetStars();
//     super.onWindowEnterFullScreen();
//   }

//   @override
//   void onWindowResized() {
//     resetStars();

//     super.onWindowResize();
//   }

//   @override
//   void dispose() {
//     _controllerBackground.dispose();
//     _controllerForeground.dispose();
//     windowManager.removeListener(this);
//     super.dispose();
//   }

//   Widget buildStar(double heightThird) {
//     final yPos = rng.nextDouble() * gameSize!.height * .6;
//     var opacity = 1.0;
//     if (yPos > heightThird) {
//       opacity = 1 - (yPos - heightThird) / heightThird;
//       opacity = opacity.clamp(0, 1);
//     }

//     return Positioned(
//         left: rng.nextDouble() * gameSize!.width,
//         top: yPos,
//         child: Container(
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.white
//                 .withOpacity(opacity - (opacity * .5 * rng.nextDouble())),
//           ),
//           width: 3 + (rng.nextDouble() * 2),
//           height: 3 + (rng.nextDouble() * 2),
//         )
//             .animate()
//             .moveY(
//                 duration: 3.seconds,
//                 curve: Curves.easeInOutCubic,
//                 begin: 40 * rng.nextDouble(),
//                 end: 0)
//             .fadeIn(curve: Curves.easeInOutCubic, duration: 3.seconds));
//   }

//   FocusNode focusNode = FocusNode();
//   Size? gameSize;

//   @override
//   Widget build(BuildContext context) {
//     gameSize ??= MediaQuery.of(context).size;
//     final heightThird = gameSize!.height / 3;
//     return KeyboardListener(
//       focusNode: focusNode,
//       child: Stack(children: [
//         Container(
//           decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                   colors: [Colors.pink, backgroundColor1],
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.topCenter)),
//         ),
//         for (var i = 0; i < 100; i++) buildStar(heightThird),
//         Positioned.fill(
//             child: Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxHeight: 500, maxWidth: 500),
//             child: Container(
//               alignment: Alignment.center,
//               height: heightThird * 2,
//               width: heightThird * 2,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(colors: [
//                   unlockedColor.brighten(.2),
//                   primaryColor,
//                   // Colors.transparent,
//                 ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
//               ),
//             ),
//           ),
//         )
//                 .animate(
//                   onComplete: (controller) => controller
//                       .reverse()
//                       .then((value) => controller.forward()),
//                 )
//                 .moveY(
//                     duration: 3.seconds,
//                     curve: Curves.easeInOutCubic,
//                     begin: 3,
//                     end: 0)
//                 .animate()
//                 .fadeIn(curve: Curves.easeInOutCubic, duration: 2.seconds)),
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: AnimatedBuilder(
//             animation: _controllerBackground,
//             builder: (context, child) {
//               final waveOffset = _controllerBackground.value * pi * 2;
//               return ClipPath(
//                 clipper: WaveClipper(waveOffset, false),
//                 child: Container(
//                   decoration: BoxDecoration(
//                       gradient: LinearGradient(colors: [
//                     secondaryColor.darken(.7),
//                     secondaryColor.darken(.3),
//                   ], stops: const [
//                     .1,
//                     .6
//                   ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
//                 ),
//               );
//             },
//           ),
//         ),
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: AnimatedBuilder(
//             animation: _controllerForeground,
//             builder: (context, child) {
//               final waveOffset = _controllerForeground.value * pi * 2;
//               return ClipPath(
//                 clipper: WaveClipper(waveOffset, true),
//                 child: Container(
//                   // height: heightThird,
//                   decoration: BoxDecoration(
//                       gradient: LinearGradient(colors: [
//                     primaryColor.darken(.5),
//                     primaryColor.darken(.1),
//                   ], stops: const [
//                     0,
//                     .3
//                   ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
//                 ),
//               );
//             },
//           ),
//         ),
//       ]),
//     );
//   }
// }

// class WaveClipper extends CustomClipper<Path> {
//   final double offset;

//   WaveClipper(this.offset, this.isForeground);
//   bool isForeground;
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.moveTo(0, size.height / 2);
//     for (double x = 0; x <= size.width; x++) {
//       final y = (size.height / 1.2) -
//           (isForeground ? 0 : size.height / 10) +
//           sin(offset + x * (isForeground ? 0.004 : 0.003)) *
//               (isForeground ? 40 : 60);
//       path.lineTo(x, y);
//     }
//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(WaveClipper oldClipper) => true;
// }

void buildProgressBar(
    {required Canvas canvas,
    required double percentProgress,
    required Color color,
    required Vector2 size,
    double widthOfBar = .2,
    double heightOfBar = .5,
    double padding = .1,
    double peak = 1.2,
    double growth = 5,
    double loadInPercent = 1.0}) {
  final noXpPaint = Paint()
    ..shader = ui.Gradient.linear(Offset.zero, Offset(size.x, 0),
        [Colors.grey.shade900, Colors.grey.shade700]);
  final xpPaint = Paint()
    ..shader = ui.Gradient.linear(
        Offset.zero, Offset(size.x, 0), [color.brighten(.2), color]);

  final amountOfBars = (size.x / (widthOfBar + padding)).floor();
  final iteration = (size.x - padding / 2) / amountOfBars;
  final xpCutOff = percentProgress * amountOfBars;

  for (var i = 0; i < amountOfBars; i++) {
    final iRatio = i / amountOfBars;
    if (iRatio > loadInPercent) continue;
    final ratio = iRatio * peak;
    final isXpBar = xpCutOff > i;
    canvas.drawRect(
        (Offset((padding / 2) + (iteration * i), 0) &
            Size(
              widthOfBar,
              (heightOfBar / 3) + heightOfBar * pow(ratio, growth),
            )),
        isXpBar ? xpPaint : noXpPaint);
  }
}
