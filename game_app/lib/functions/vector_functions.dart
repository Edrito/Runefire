import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import '../game/enviroment.dart';
import 'package:forge2d/src/settings.dart' as settings;

Vector2 vectorToGrid(Vector2 v1, Vector2 size) {
  return ((v1) - size / 2);
}

extension ScaledToDimensionVector2 on Vector2 {
  Vector2 scaledToDimension(bool scaleY, double maxLength) {
    double ratio = 1;
    if (scaleY) {
      ratio = maxLength / y;
    } else {
      ratio = maxLength / x;
    }
    return Vector2(x * ratio, y * ratio);
  }
}

Vector2 tiledObjectToOrtho(Vector2 isoPoint, TiledComponent? info) {
  double orthoX = (isoPoint.x - isoPoint.y);
  double orthoY = (isoPoint.x / 2 + isoPoint.y / 2);
  return Vector2(
      orthoX += info != null
          ? info.tileMap.map.height.toDouble() * info.tileMap.destTileSize.y
          : 0,
      orthoY);
}

bool isEntityInfrontOfHandAngle(
    Vector2 entity, Vector2 position, Vector2 positionDelta) {
  final test1 = entity - position;

  return positionDelta.dot(test1) >= 0;
}

List<Vector2> expandToBox(List<Vector2> coordinates, double distance) {
  List<Vector2> leftCoor = [];
  List<Vector2> rightCoor = [];

  for (int i = 0; i < coordinates.length - 1; i++) {
    Vector2 current = coordinates[i];
    Vector2 next = coordinates[i + 1];

    double deltaX = next.x - current.x;
    double deltaY = next.y - current.y;

    // Calculate the perpendicular vector
    double perpendicularX = -deltaY;
    double perpendicularY = deltaX;

    // Normalize the perpendicular vector
    double length =
        sqrt(perpendicularX * perpendicularX + perpendicularY * perpendicularY);
    double normalizedPerpendicularX = (perpendicularX / length) * distance;
    double normalizedPerpendicularY = (perpendicularY / length) * distance;

    Vector2 normalizedPerpendicular =
        Vector2(normalizedPerpendicularX, normalizedPerpendicularY);

    Vector2 topLeft = current.clone()..add(normalizedPerpendicular);
    Vector2 topRight = next.clone()..add(normalizedPerpendicular);
    Vector2 bottomRight = next.clone()..sub(normalizedPerpendicular);
    Vector2 bottomLeft = current.clone()..sub(normalizedPerpendicular);

    // Add the four corners to the expanded coordinates list

    rightCoor.add(topLeft);
    leftCoor.add(bottomLeft);

    // expandedCoordinates.add(topRight);
    // expandedCoordinates.add(bottomRight);
  }

  return [...rightCoor, ...leftCoor.reversed];
}

Vector2 randomizeVector2Delta(Vector2 element, double percent) {
  if (percent == 0) return element;
  percent = percent.clamp(0, 1);

  Vector2 random = Vector2.random() * 2;
  random -= Vector2.all(1);
  random *= percent;
  element *= 1 - percent;
  element = element + random;
  return element.normalized();
}

//
//                               ---.....
//                                       ***\
//    ------------🔫  becomes   ------------3 🔫
//                                       ___/
//                               ---*****
//
List<Vector2> splitVector2DeltaInCone(
    Vector2 angle, int count, double maxAngleVarianceDegrees) {
  if (count == 1) return [angle];
  List<Vector2> angles = [];

  // Convert maxAngleVariance from degrees to radians
  double maxAngleVariance = radians(maxAngleVarianceDegrees);

  // Calculate the step size for evenly spreading the angles
  double stepSize = maxAngleVariance / (count - 1);

  // Calculate the starting angle
  double startAngle = radiansBetweenPoints(angle, Vector2(0.000001, -0.0000));

  // Generate the angles
  startAngle -= maxAngleVariance / 2;

  for (int i = 0; i < count; i++) {
    double currentAngle = startAngle + (stepSize * i);

    // Convert the angle back to Vector2
    double x = cos(currentAngle);
    double y = sin(currentAngle);

    angles.add(Vector2(x, y));
  }

  return angles;
}

List<Vector2> validateChainDistances(final List<Vector2> vertices) {
  List<Vector2> returnList = [];
  for (var i = 1; i < vertices.length; i++) {
    final v1 = vertices[i - 1];
    final v2 = vertices[i];
    // If the code crashes here, it means your vertices are too close together.
    if (v1.distanceToSquared(v2) >= settings.linearSlop * settings.linearSlop) {
      returnList.add(v1);
    }
  }
  return returnList;
}

// Function to calculate the delta
Vector2 calculateDelta(
    Vector2 bulletPosition, Vector2 playerPosition, Vector2 playerAim) {
  // Calculate the direction vector from the bullet to the player
  Vector2 directionToPlayer = playerPosition - bulletPosition;

  // Normalize the direction
  Vector2 normalizedDirectionToPlayer = directionToPlayer.normalized();

  // Calculate the delta vector
  Vector2 delta = playerAim - normalizedDirectionToPlayer;

  return delta;
}

Vector2 rotateVector2(Vector2 vector, double rad) {
  // Convert degrees to radians

  // Calculate the sine and cosine of the angle
  double cosine = cos(rad);
  double sine = sin(rad);

  // Perform the rotation using the rotation matrix
  double x = vector[0] * cosine - vector[1] * sine;
  double y = vector[0] * sine + vector[1] * cosine;

  // Return the rotated vector
  return Vector2(x, y);
}

// List<Vector2> generateRandomDeltas(
//     Vector2 initialDelta, int numSplines, double magnitude, int controlPoints) {
//   List<Vector2> deltaList = [];
//   Vector2 currentDelta = initialDelta.clone();
//   Vector2 direction = initialDelta.normalized();
//   Vector2 perpendicular = calcPerpindicular(initialDelta);

//   for (int i = 0; i < numSplines; i++) {
//     Random random = Random();

//     Vector2 controlPoint1 = currentDelta +
//         direction * magnitude +
//         perpendicular * (random.nextDouble() * magnitude - magnitude / 2);
//     Vector2 endPoint = controlPoint1 +
//         direction * magnitude +
//         perpendicular * (random.nextDouble() * magnitude - magnitude / 2);

//     for (int j = 1; j <= controlPoints; j++) {
//       double t = j.toDouble() / (controlPoints + 1);
//       double oneMinusT = 1 - t;
//       double tt = t * t;
//       double oneMinusTT = oneMinusT * oneMinusT;

//       double x = oneMinusTT * currentDelta.x +
//           2 * oneMinusT * t * controlPoint1.x +
//           tt * endPoint.x;

//       double y = oneMinusTT * currentDelta.y +
//           2 * oneMinusT * t * controlPoint1.y +
//           tt * endPoint.y;
//       deltaList.add(Vector2(x, y)..multiply(Vector2(.8, direction.x)));
//     }

//     currentDelta = endPoint;
//   }

//   return deltaList;
// }

Vector2 generateRandomGamePositionUsingViewport(
    bool internal, GameEnviroment gameRef) {
  const paddingDouble = 10.0;
  final padding = Vector2.all(paddingDouble);
  final random = Vector2.random();

  Vector2 initalArea = gameRef.gameCamera.viewport.size;
  Vector2 area = Vector2.zero();
  if (internal) {
    area = initalArea + (padding * 2);
    area = Vector2(random.x * area.x, random.y * area.y);
    area -= padding;
  } else {
    Random rng = Random();

    final side = rng.nextInt(4);
    // const side = 1;

    if (side == 0 || side == 2) {
      area = Vector2(initalArea.x, initalArea.y / 2);
      area = Vector2(random.x * area.x, random.y * area.y);

      area.y -= side == 0
          ? (initalArea.y / 2) + paddingDouble
          : -(initalArea.y + paddingDouble);
    } else {
      area = Vector2(initalArea.y / 2, initalArea.y * 2);
      area = Vector2(random.x * area.x, random.y * area.y);

      area.x -= side == 3
          ? (initalArea.y / 2) + paddingDouble
          : -(initalArea.x + paddingDouble);
      area.y -= initalArea.y / 2;
    }
  }

  return (vectorToGrid(area, gameRef.gameCamera.viewport.size) / 15) +
      gameRef.gameCamera.viewfinder.position;
}

double radiansBetweenPoints(Vector2 v1, Vector2 v2) {
  final a = v1.x * v2.x + v1.y * v2.y; // Calculate dot product
  final b = v1.length * v2.length;

  // Avoid division by zero error and handle floating point error
  if (b == 0.0) return 0.0;

  final ratio = (a / b).clamp(-1.0, 1.0);

  // Compute the angle in radians
  double tempRadians = acos(ratio);

  // Use cross product to check orientation
  double crossProduct = v1.x * v2.y - v1.y * v2.x;
  if (crossProduct > 0) {
    tempRadians = -tempRadians;
  }

  if (tempRadians < 0) {
    tempRadians = tempRadians + 2 * pi;
  }

  return tempRadians;
}

Vector2 newPosition(Vector2 origin, double angleInDegrees, double distance) {
  // Convert angle from degrees to radians
  double angleInRadians = radians(angleInDegrees);
  // Calculate new position
  double newX = origin.x + distance * sin(angleInRadians);
  double newY = origin.y + distance * cos(angleInRadians);

  // Return new position
  return Vector2(newX, newY);
}
