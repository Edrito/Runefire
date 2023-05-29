import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game/games.dart';

void main() async {
  GameplayGame currentGame;
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();

  await Flame.device.fullScreen();

  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          // Game currentGame = getCurrentGameClass(ref.watch(currentGameStateProvider));
          currentGame = GameplayGame();

          return GameWidget(
            game: currentGame,
            overlayBuilderMap: {
              'PauseMenu': (context, _) {
                return Center(
                  child: SizedBox.square(
                    dimension: 100,
                    child: ElevatedButton(
                      child: const Text("Resume"),
                      onPressed: () {
                        currentGame.overlays.remove('PauseMenu');
                        currentGame.resumeEngine();
                      },
                    ),
                  ),
                );
              },
            },
          );
        },
      ),
    ),
  );
}
