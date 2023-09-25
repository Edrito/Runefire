import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/functions/functions.dart';

import '../../game/enviroment.dart';
import 'package:forge2d/src/settings.dart' as settings;

Vector2 shiftCoordinatesToCenter(Vector2 v1, Vector2 size) {
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

    rightCoor.add(topRight);
    leftCoor.add(bottomRight);

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

Vector2 calculateInterpolatedVector(
    Vector2 vector1, Vector2 vector2, double factor) {
  double angle1 = atan2(vector1.y, vector1.x);
  double angle2 = atan2(vector2.y, vector2.x);

  double deltaAngle = angle2 - angle1;

  // Normalize deltaAngle to be within -pi and pi
  deltaAngle = normalizeAngle(deltaAngle);

  // Calculate the interpolated angle
  double interpolatedAngle = angle1 + (deltaAngle * factor);

  // Normalize interpolatedAngle to be within -pi and pi
  interpolatedAngle = normalizeAngle(interpolatedAngle);

  // Calculate the length of the interpolated vector
  double length = (vector2 - vector1).length * factor;

  // Calculate the x and y components of the interpolated vector
  double x = cos(interpolatedAngle) * length;
  double y = sin(interpolatedAngle) * length;

  // Create the interpolated vector
  Vector2 interpolatedVector = Vector2(x, y);

  return interpolatedVector;
}

// Function to normalize an angle to be within -pi and pi
double normalizeAngle(double angle) {
  while (angle < -pi) {
    angle += 2 * pi;
  }

  while (angle > pi) {
    angle -= 2 * pi;
  }

  return angle;
}

//
//                               ---.....
//                                       ***\
//    ------------🔫  becomes   ------------3 🔫
//                                       ___/
//                               ---*****
//
List<Vector2> splitVector2DeltaIntoArea(
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

List<double> splitRadInCone(
    double angle, int count, double maxAngleVarianceDegrees) {
  if (count == 1) return [angle];
  List<double> angles = [];

  // Convert maxAngleVariance from degrees to radians
  double maxAngleVariance = radians(maxAngleVarianceDegrees);

  // Calculate the step size for evenly spreading the angles
  double stepSize = maxAngleVariance / (count - 1);

  // Calculate the starting angle

  // Generate the angles
  angle -= maxAngleVariance / 2;

  for (int i = 0; i < count; i++) {
    double currentAngle = angle + (stepSize * i);

    angles.add(currentAngle);
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

Vector2 generateRandomGamePositionInViewport(
    bool internal, Enviroment gameRef) {
  const paddingDouble = 1.0;
  final padding = Vector2.all(paddingDouble);
  final random = Vector2.random();

  Vector2 initalArea =
      gameRef.gameCamera.viewport.size / gameRef.gameCamera.viewfinder.zoom;
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

  return (area -
      ((gameRef.gameCamera.viewport.size / gameRef.gameCamera.viewfinder.zoom) /
          2) +
      gameRef.gameCamera.viewfinder.position);
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

Vector2 newPositionRad(Vector2 origin, double rad, double distance) {
  // Convert angle from degrees to radians
  // Calculate new position
  double newX = origin.x + distance * sin(rad);
  double newY = origin.y + distance * cos(rad);

  // Return new position
  return Vector2(newX, newY);
}

List<Vector2> triangleZoomEffect(
  double baseWidth,
  double height,
  Vector2 previousPoint,
  Vector2 currentPoint,
  double bendFactor,
) {
  // Calculate the midpoint between the previous and current points
  Vector2 midPoint = (previousPoint + currentPoint) / 2;

  // Calculate the control point that creates the bending effect
  Vector2 controlPoint = midPoint + Vector2(bendFactor, 0);

  // Calculate the remaining points of the triangle
  Vector2 vertexA = previousPoint;
  Vector2 vertexB = controlPoint;
  Vector2 vertexC = currentPoint;

  // Calculate the offset for the base width
  double halfBaseWidth = baseWidth / 2;

  // Calculate the height offset
  double heightOffset = height / 2;

  // Adjust the triangle vertices based on the base width and height
  vertexA.x -= halfBaseWidth;
  vertexA.y -= heightOffset;
  vertexB.x -= halfBaseWidth;
  vertexB.y -= heightOffset;
  vertexC.x -= halfBaseWidth;
  vertexC.y -= heightOffset;

  // Return the triangle vertices as a list
  return [vertexA, vertexB, vertexC];
}

// List<Vector2> bezierInterpolation(List<Vector2> points, {int smoothness = 2}) {
//   final List<Vector2> result = [];
//   final int n = points.length;
//   final List<double> t = List.generate(smoothness, (i) => i / (smoothness - 1));

//   for (int i = 0; i < n - 1; i++) {
//     final Vector2 p0 = points[i];
//     final Vector2 p1 = points[i + 1];
//     final List<Vector2> controlPoints = [p0, p0, p1, p1];

//     for (int j = 1; j <= smoothness; j++) {
//       final double tVal = t[j - 1];
//       double xVal = 0;
//       double yVal = 0;

//       for (int k = 0; k < 4; k++) {
//         final double coeff = pow(1 - tVal, 3 - k).toDouble() * pow(tVal, k);
//         xVal += coeff * controlPoints[k].x;
//         yVal += coeff * controlPoints[k].y;
//       }

//       result.add(Vector2(xVal, yVal));
//     }
//   }

//   return result;
// }

List<(Vector2, Vector2)> separateIntoAnglePairs(List<Vector2> vectors) {
  List<(Vector2, Vector2)> anglePairs = [];
  if (vectors.length < 2) {
    return anglePairs;
  }

  for (int i = 1; i < vectors.length; i++) {
    Vector2 vector1 = vectors[i - 1];
    Vector2 vector2 = vectors[i];

    double angle = atan2(vector2.y - vector1.y, vector2.x - vector1.x);

    angle = roundDouble(angle, 3);

    if (i == 1) {
      anglePairs.add((vector1, vector2));
      continue;
    }

    double previousAngle = atan2(anglePairs.last.$2.y - anglePairs.last.$1.y,
        anglePairs.last.$2.x - anglePairs.last.$1.x);

    previousAngle = roundDouble(previousAngle, 3);
    if (angle != previousAngle) {
      anglePairs.add((vector1, vector2));
    } else {
      anglePairs.last = (anglePairs.last.$1, vector2);
    }
  }

  return anglePairs;
}

List<Set<Vector2>> turnPairsIntoBoxes(
    List<(Vector2, Vector2)> anglePairs, double size) {
  List<Set<Vector2>> boxes = [];

  for ((Vector2, Vector2) pair in anglePairs) {
    Vector2 vector1 = pair.$1;
    Vector2 vector2 = pair.$2;

    Vector2 perpendicular1 =
        Vector2(vector1.y - vector2.y, vector2.x - vector1.x).normalized() *
            size;
    Vector2 perpendicular2 =
        Vector2(vector2.y - vector1.y, vector1.x - vector2.x).normalized() *
            size;

    Vector2 p1 = vector1 + perpendicular1;
    Vector2 p2 = vector1 - perpendicular1;
    Vector2 p3 = vector2 - perpendicular2;
    Vector2 p4 = vector2 + perpendicular2;

    boxes.add({p1, p2, p3, p4});
  }

  return boxes;
}

List<Vector2> generateLightning(
  Set<Vector2> points, // List of Vector2 points
  {
  required double amplitude, // Amplitude of the lightning effect
  required double frequency, // Frequency of the lightning effect
  required double currentAngle,
}) {
  final List<Vector2> lightningPoints = [];
  double angleBetweenPoints = 0;
  double increase = 1;

  // Iterate through the original points
  for (int i = 0; i < points.length - 1; i++) {
    final Vector2 start = points.elementAt(i);
    final Vector2 end = points.elementAt(i + 1);
    if (i == 0) {}
    angleBetweenPoints = radiansBetweenPoints(start, end);
    // Calculate the number of segments between two points
    final int numSegments = (start.distanceTo(end) / frequency).ceil();

    // Generate intermediate points along the line segment
    for (int j = 1; j < numSegments; j++) {
      increase = 1 -
          pow((((j - 1 - (numSegments / 2)) / numSegments).abs() * .9), .7)
              .toDouble();
      final double t = j / numSegments;
      final double x = lerpDouble(start.x, end.x, t)!;
      final double y = lerpDouble(start.y, end.y, t)!;

      // Apply a random displacement for the lightning effect
      // final double offsetX = rng.nextDouble() * amplitude;
      // final double offsetY = rng.nextDouble() * amplitude;
      lightningPoints.add(newPositionRad(
          Vector2(x, y),
          -(i == 0 ? currentAngle : (angleBetweenPoints + (pi / 2))) +
              (rng.nextBool() ? pi / 2 : (-pi / 2)),
          (rng.nextDouble() * amplitude * increase)));

      // Add the point to the lightning list with displacement
      // lightningPoints.add(Vector2(
      //     x
      //     //  + offsetX
      //     ,
      //     y
      //     // + offsetY
      //     ));
    }
  }

  // Add the last point from the original list
  lightningPoints.add(newPositionRad(
      points.last,
      (angleBetweenPoints + (pi / 2)) + (rng.nextBool() ? pi / 2 : (-pi / 2)),
      rng.nextDouble() * amplitude * increase));

  return lightningPoints;
}

Set<Vector2> generateCurvePoints(Set<Vector2> points, double percent) {
  Set<Vector2> result = {};

  for (int i = 0; i < points.length - 1; i++) {
    final Vector2 start = points.elementAt(i);
    final Vector2 end = points.elementAt(i + 1);

    Vector2 direction = end - start;
    // double angle = start.angleTo(end);

    if (i == 0) {
      // Add the first point to the result list
      result.add(start);
    }

    // if (angle >= minAngle) {
    // Calculate the control point (midpoint)
    Vector2 point1 = start + (direction * percent);
    Vector2 point2 = start + (direction * (1 - percent));

    result.add(point1);
    result.add(point2);
    result.add(end);
  }

  return result;
}

Vector2 bezier(Vector2 controlPoint, Vector2 offset, Vector2 end) {
  // Calculate the two control points for the quadratic Bezier curve
  Vector2 controlPoint1 = controlPoint + offset;
  Vector2 controlPoint2 = controlPoint - offset;

  // Return the quadratic Bezier curve
  return controlPoint1 * 0.5 + controlPoint2 * 0.5;
}
