// import 'dart:async';
// import 'package:flame/components.dart';
// import 'package:flame/extensions.dart';
// import 'package:flame/sprite.dart';
// import 'package:flame_tiled/flame_tiled.dart';
// import 'package:game_app/game/background.dart';
// import '../resources/enums.dart';
// import '/resources/overlays.dart' as overlays;

// import '../functions/vector_functions.dart';
// import '../resources/interactable.dart';
// import '/resources/routes.dart' as routes;
// import 'enviroment.dart';

// class HomeRoom extends GameEnviroment {
//   @override
//   GameLevel level = GameLevel.home;
//   late BackgroundComponent homeBackground;

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();

//     homeBackground = level.buildBackground(this);
//     add(homeBackground);
//   }
// }

// class HomeBackground extends BackgroundComponent {
//   HomeBackground(super.gameReference);

//   late final ObjectGroup? portalObjects;
//   late final ObjectGroup? objects;

//   @override
//   FutureOr<void> onLoad() async {
//     await super.onLoad();

//     portalObjects = tiled.tileMap.getLayer<ObjectGroup>('portals');
//     objects = tiled.tileMap.getLayer<ObjectGroup>('objects');

//     if (portalObjects != null) {
//       final tempImage = (await Sprite.load('portal/1.png')).image;
//       for (var element in portalObjects!.objects) {
//         bool first = true;
//         Vector2 positionTest = Vector2.zero();

//         if (element.isPoint) {
//           positionTest =
//               tiledObjectToOrtho(Vector2(element.x, element.y), tiled);

//           add(InteractableComponent(
//               positionTest,
//               SpriteAnimationComponent(
//                   animation: SpriteSheet(
//                           image: tempImage,
//                           srcSize:
//                               Vector2(tempImage.size.x / 4, tempImage.size.y))
//                       .createAnimation(
//                     row: 0,
//                     stepTime: 1,
//                   ),
//                   size: Vector2.all(15),
//                   anchor: Anchor.bottomCenter,
//                   playing: first), () {
//             gameReference.gameRef.router.pushReplacementNamed(routes.gameplay);
//           }, true, "Open"));
//         }
//       }
//     }
//     if (objects != null) {
//       final weaponRackPoint = objects!.objects
//           .firstWhere((element) => element.name == "weaponRack");
//       final tempImage = (await Sprite.load('weapon_upgrade.png')).image;
//       Vector2 positionTest = tiledObjectToOrtho(
//           Vector2(weaponRackPoint.x, weaponRackPoint.y), tiled);

//       add(InteractableComponent(
//           positionTest,
//           SpriteAnimationComponent(
//               position: Vector2.all(10),
//               animation: SpriteSheet(
//                       image: tempImage,
//                       srcSize: Vector2(tempImage.size.x, tempImage.size.y))
//                   .createAnimation(
//                 row: 0,
//                 stepTime: 1,
//               ),
//               size: Vector2(50, 75),
//               anchor: Anchor.bottomCenter,
//               playing: false), () {
//         gameReference.gameRef.overlays.add(overlays.weaponModifyMenu.key);
//       }, true, "Upgrade"));
//     }
//   }

//   @override
//   GameLevel get gameLevel => GameLevel.home;
// }
