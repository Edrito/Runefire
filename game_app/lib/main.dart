import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game/games.dart';

void main() {
  GameplayGame currentGame;
  runApp(ProviderScope(child: Consumer(builder: (context, ref, _) {
    // Game currentGame = getCurrentGameClass(ref.watch(currentGameStateProvider));
    currentGame = GameplayGame();

    return GameWidget(
      game: currentGame,
    );
  })));
}
