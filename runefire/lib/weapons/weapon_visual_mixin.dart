


// mixin MeleeTrailEffect on MeleeFunctionality {
//   Map<MeleeAttackHandler, (List<Vector2>, List<Vector2>)> behindEffects = {};

//   final double baseBeginPercent = .4;

//   @override
//   void render(Canvas canvas) {
//     if (attacksAreActive) {
//       for (var element in activeSwings) {
//         if (!behindEffects.containsKey(element)) {
//           behindEffects[element] = (
//             [
//               newPosition(
//                       element.currentSwing.absolutePosition,
//                       -degrees(element.currentSwing.angle),
//                       length * baseBeginPercent)
//                   .clone()
//             ],
//             [
//               newPosition(element.currentSwing.absolutePosition,
//                       -degrees(element.currentSwing.angle), length)
//                   .clone()
//             ]
//           );
//         } else {
//           {
//             behindEffects[element] = (
//               [
//                 ...behindEffects[element]!.$1,
//                 newPosition(
//                         element.currentSwing.absolutePosition,
//                         -degrees(element.currentSwing.angle),
//                         length * baseBeginPercent)
//                     .clone(),
//               ],
//               [
//                 ...behindEffects[element]!.$2,
//                 newPosition(element.currentSwing.absolutePosition,
//                         -degrees(element.currentSwing.angle), length)
//                     .clone(),
//               ]
//             );
//           }
//         }
//       }
//       behindEffects.removeWhere((key, value) => !activeSwings.contains(key));
//     } else {
//       behindEffects.clear();
//     }

//     for (var element in behindEffects.entries) {
//       List<Offset> offsets = [];

//       for (var i = 0; i < element.value.$1.length - 1; i++) {
//         offsets.add(element.value.$1.elementAt(i).toOffset());
//         offsets.add(element.value.$2.elementAt(i).toOffset());
//       }
//       if (offsets.isEmpty) return;

//       canvas.drawVertices(
//           ui.Vertices(VertexMode.triangleStrip, offsets),
//           BlendMode.color,
//           BasicPalette.red.paint()
//             ..style = PaintingStyle.fill
//             ..shader = ui.Gradient.linear(offsets.first, offsets.last,
//                 [Colors.transparent, Colors.yellow])
//             ..strokeWidth = 0);
//     }

//     super.render(canvas);
//   }
// }
