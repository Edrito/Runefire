import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CurrentGameState { mainMenu, transition, gameplay }

final currentGameStateProvider =
    Provider<CurrentGameState>((ref) => CurrentGameState.mainMenu);
