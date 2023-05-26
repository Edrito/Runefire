import 'dart:math';

import 'package:flame/components.dart';

double angleBetweenPoints(Vector2 p1, Vector2 p2, Vector2 origin) {
  Vector2 v1 = p1 - origin; // Create a vector from origin to point 1
  Vector2 v2 = p2 - origin; // Create a vector from origin to point 2

  final a = v1.x * v2.x + v1.y * v2.y; // Calculate dot product
  final b = v1.length * v2.length;

  // Avoid division by zero error and handle floating point error
  if (b == 0.0) return 0.0;

  final ratio = (a / b).clamp(-1.0, 1.0);

  // Compute the angle in radians
  double radians = acos(ratio);

  // Use cross product to check orientation
  double crossProduct = v1.x * v2.y - v1.y * v2.x;
  if (crossProduct < 0) {
    radians = -radians;
  }

  // Convert to degrees
  var degrees = radians * 180.0 / pi;
  // degrees += 180;
  return degrees;
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
