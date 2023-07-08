import 'dart:async' as async;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game_app/main.dart';
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
  late CustomButton sfxButton;
  late CustomButton musicButton;
  late CustomButton exitButton;

  late double musicVolume;
  bool? incrementingMusic;
  late double sfxVolume;
  bool? incrementingSFX;
  late SystemDataComponent? systemDataComponent;

  String get buildMusicString => "Music: ${musicVolume.round()}";
  String get buildSFXString => "Sound Effects: ${sfxVolume.round()}";

  set incrementSFX(double value) {
    var newValue = (sfxVolume + value);
    // if (newValue > 100) newValue = 0;
    // if (newValue < 0) newValue = 100;

    systemDataComponent?.dataObject.setSFXVolume = newValue.clamp(0, 100);
  }

  set incrementMusic(double value) {
    var newValue = (musicVolume + value);
    // if (newValue > 100) newValue = 0;
    // if (newValue < 0) newValue = 100;
    systemDataComponent?.dataObject.setMusicVolume = (newValue).clamp(0, 100);
  }

  CustomButton buildMusicButton() {
    return CustomButton(buildMusicString, gameRef: widget.gameRef,
        onTapDown: (_) {
      // incrementMusic = 1;
      incrementingMusic = true;
    }, onTapUp: (_) {
      incrementingMusic = null;
    }, onTapCancel: () {
      incrementingMusic = null;
    }, onSecondaryTapCancel: () {
      incrementingMusic = null;
    }, onSecondaryTapDown: (_) {
      // incrementMusic = -1;
      incrementingMusic = false;
    }, onSecondaryTapUp: (_) {
      incrementingMusic = null;
    });
  }

  CustomButton buildSFXButton() {
    return CustomButton(buildSFXString, gameRef: widget.gameRef,
        onTapDown: (_) {
      // incrementSFX = 1;

      incrementingSFX = true;
    }, onTapUp: (_) {
      incrementingSFX = null;
    }, onTapCancel: () {
      incrementingSFX = null;
    }, onSecondaryTapCancel: () {
      incrementingSFX = null;
    }, onSecondaryTapDown: (_) {
      // incrementSFX = -1;
      incrementingSFX = false;
    }, onSecondaryTapUp: (_) {
      incrementingSFX = null;
    });
  }

  late async.Timer timer;
  late ComponentsNotifier<SystemDataComponent> systemDataNotifier;

  @override
  void dispose() {
    systemDataNotifier.removeListener(onSystemDataNotification);
    timer.cancel();
    super.dispose();
  }

  void onSystemDataNotification() {
    setState(() {
      musicVolume = systemDataNotifier.single?.dataObject.musicVolume ?? 0.0;
      sfxVolume = systemDataNotifier.single?.dataObject.sfxVolume ?? 0.0;

      sfxButton = buildSFXButton();
      musicButton = buildMusicButton();
    });
  }

  @override
  void initState() {
    super.initState();
    timer = async.Timer.periodic(
      const Duration(milliseconds: 50),
      (_) {
        if (incrementingMusic == true) {
          incrementMusic = 1;
        } else if (incrementingMusic == false) {
          incrementMusic = -1;
        }
        if (incrementingSFX == true) {
          incrementSFX = 1;
        } else if (incrementingSFX == false) {
          incrementSFX = -1;
        }
      },
    );

    systemDataComponent = widget.gameRef.systemDataComponent;
    systemDataNotifier =
        widget.gameRef.componentsNotifier<SystemDataComponent>();

    systemDataNotifier.addListener(onSystemDataNotification);

    musicVolume = systemDataComponent?.dataObject.musicVolume ?? 0.0;
    sfxVolume = systemDataComponent?.dataObject.sfxVolume ?? 0.0;

    sfxButton = buildSFXButton();
    musicButton = buildMusicButton();

    exitButton = CustomButton(
      "Back",
      gameRef: widget.gameRef,
      onTap: () {
        changeMainMenuPage(MenuPages.startMenuPage);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DisplayButtons(
      buttons: [sfxButton, musicButton, exitButton],
    );
  }
}
