import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

Vector2 calcPerpindicular(Vector2 vector) {
  return Vector2(-vector.y, vector.x);
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

List<Vector2> generateRandomDeltas(
    Vector2 initialDelta, int numSplines, double magnitude, int controlPoints) {
  List<Vector2> deltaList = [];
  Vector2 currentDelta = initialDelta.clone();
  Vector2 direction = initialDelta.normalized();
  Vector2 perpendicular = calcPerpindicular(initialDelta);

  for (int i = 0; i < numSplines; i++) {
    Random random = Random();

    Vector2 controlPoint1 = currentDelta +
        direction * magnitude +
        perpendicular * (random.nextDouble() * magnitude - magnitude / 2);
    Vector2 endPoint = controlPoint1 +
        direction * magnitude +
        perpendicular * (random.nextDouble() * magnitude - magnitude / 2);

    for (int j = 1; j <= controlPoints; j++) {
      double t = j.toDouble() / (controlPoints + 1);
      double oneMinusT = 1 - t;
      double tt = t * t;
      double oneMinusTT = oneMinusT * oneMinusT;

      double x = oneMinusTT * currentDelta.x +
          2 * oneMinusT * t * controlPoint1.x +
          tt * endPoint.x;

      double y = oneMinusTT * currentDelta.y +
          2 * oneMinusT * t * controlPoint1.y +
          tt * endPoint.y;
      deltaList.add(Vector2(x, y)..multiply(Vector2(.8, direction.x)));
    }

    currentDelta = endPoint;
  }

  return deltaList;
}

Vector2 generateRandomGamePositionUsingViewport(
    bool internal, Forge2DGame gameRef) {
  const paddingDouble = 150.0;
  final padding = Vector2.all(paddingDouble);
  final random = Vector2.random();

  Vector2 initalArea = gameRef.camera.viewport.effectiveSize;
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

  return gameRef.screenToWorld(area);
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
