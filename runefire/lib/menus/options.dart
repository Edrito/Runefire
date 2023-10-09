import 'dart:async' as async;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/game_state_class.dart';
import '../resources/data_classes/system_data.dart';
import 'buttons.dart';

import 'menus.dart';

class OptionsMenu extends StatefulWidget {
  const OptionsMenu({
    super.key,
    required this.gameRef,
  });
  final GameRouter gameRef;

  @override
  State<OptionsMenu> createState() => _OptionsMenuState();
}

class _OptionsMenuState extends State<OptionsMenu> {
  late CustomButton hudScale;
  late CustomButton exitButton;

  late double musicVolume;
  late double sfxVolume;
  late SystemDataComponent? systemDataComponent;
  (double, double) sfxMinMax = (0, 100);
  (double, double) musicMinMax = (0, 100);

  void incrementMusic(bool increment) {
    if (increment) {
      musicVolume = musicVolume + 1;
      systemDataComponent?.dataObject.setMusicVolume =
          (musicVolume).clamp(musicMinMax.$1, musicMinMax.$2);
    } else {
      musicVolume = musicVolume - 1;
      systemDataComponent?.dataObject.setMusicVolume =
          (musicVolume).clamp(musicMinMax.$1, musicMinMax.$2);
    }
  }

  void incrementSfx(bool increment) {
    if (increment) {
      sfxVolume = sfxVolume + 1;
      systemDataComponent?.dataObject.setSFXVolume =
          (sfxVolume).clamp(sfxMinMax.$1, sfxMinMax.$2);
    } else {
      sfxVolume = sfxVolume - 1;
      systemDataComponent?.dataObject.setSFXVolume =
          (sfxVolume).clamp(sfxMinMax.$1, sfxMinMax.$2);
    }
  }

  CustomButton buildMusicButton() {
    return CustomButton(
      "Music: $musicVolume",
      gameRef: widget.gameRef,
      onPrimary: () {
        incrementMusic(true);
      },
      onPrimaryHold: () {
        incrementMusic(true);
      },
      onSecondary: () {
        incrementMusic(false);
      },
      onSecondaryHold: () {
        incrementMusic(false);
      },
    );
  }

  CustomButton buildSFXButton() {
    return CustomButton(
      "Sound Effects: $sfxVolume",
      gameRef: widget.gameRef,
      onPrimary: () {
        incrementSfx(true);
      },
      onPrimaryHold: () {
        incrementSfx(true);
      },
      onSecondary: () {
        incrementSfx(false);
      },
      onSecondaryHold: () {
        incrementSfx(false);
      },
    );
  }

  late ComponentsNotifier<SystemDataComponent> systemDataNotifier;

  @override
  void dispose() {
    systemDataNotifier.removeListener(onSystemDataNotification);
    super.dispose();
  }

  void onSystemDataNotification() {
    setState(() {
      musicVolume = systemDataNotifier.single?.dataObject.musicVolume ?? 0.0;
      sfxVolume = systemDataNotifier.single?.dataObject.sfxVolume ?? 0.0;
    });
  }

  @override
  void initState() {
    super.initState();

    systemDataComponent = widget.gameRef.systemDataComponent;
    systemDataNotifier =
        widget.gameRef.componentsNotifier<SystemDataComponent>();

    systemDataNotifier.addListener(onSystemDataNotification);

    musicVolume = systemDataComponent?.dataObject.musicVolume ?? 0.0;
    sfxVolume = systemDataComponent?.dataObject.sfxVolume ?? 0.0;

    exitButton = CustomButton(
      "Back",
      gameRef: widget.gameRef,
      onPrimary: () {
        widget.gameRef.gameStateComponent.gameState
            .changeMainMenuPage(MenuPageType.startMenuPage);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        // alignment: Alignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [buildSFXButton(), buildMusicButton(), exitButton],
      ),
    );
  }
}
