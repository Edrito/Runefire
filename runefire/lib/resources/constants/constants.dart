import 'dart:ui';

import 'package:runefire/game/hud.dart';

const smallCardSize = Size(128, 48);
const largeCardSize = Size(128, 96);

//Entity
const hitAnimationLimit = 3;
const closeBodiesSensorRadius = 4.0;
const enemyTextMaxActive = 20;

//Projectiles
const projectileHomingSpeedIncrease = 7.5;
const projectileBigSizeThreshold = 1.0;

const defaultTtl = 2.5;

//Laser Chain
const laserCheckPointsFrequency = 10;
const laserLineAngleThreshold = .05;
const defaultProjectileVelocity = 25.0;

//UI

//Level up select delay
const levelUpSelectDelay = Duration(seconds: 1);

const uiWidthMax = 1700.0;

const double menuBaseBarHeight = 75;
const double menuBaseBarWidthPadding = 50;

int getHeightScaleStep(double height) => (height / 200).round().clamp(1, 10);

const double portalBaseSize = 150.0;

const int triggerDeadZone = 30;
const double gamepadCursorSpeed = 10;

List<String> endGameMessages = [
  "I've found you...",
  'Hmmm?',
  "You're not supposed to be here...",
  "You can't escape.",
  "You're mine now.",
  "You're not going anywhere.",
  "You're not going to make it.",
];
