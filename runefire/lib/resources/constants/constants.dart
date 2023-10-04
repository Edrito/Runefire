import 'dart:ui';

import 'package:runefire/game/hud.dart';

const smallCardSize = Size(128, 48);
const largeCardSize = Size(128, 96);

//Entity
const hitAnimationLimit = 3;
const closeBodiesSensorRadius = 4.0;

//Projectiles
const projectileHomingSpeedIncrease = 7.5;
const projectileBigSizeThreshold = 2.0;

//Laser Chain
const laserCheckPointsFrequency = 10;
const laserLineAngleThreshold = .05;

//UI

const uiWidthMax = 1700.0;

const double menuBaseBarHeight = 75;
const double menuBaseBarWidthPadding = 50;

int getHeightScaleStep(double height) => (height / 200).round().clamp(1, 10);

const double portalBaseSize = 150.0;
