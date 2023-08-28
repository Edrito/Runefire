import 'dart:async' as async;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/game_state_class.dart';
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

class IncrementingButton extends StatefulWidget {
  const IncrementingButton(
      {required this.button,
      required this.minMax,
      required this.leadingText,
      required this.onValueChange,
      required this.initValue,
      super.key});
  final CustomButton button;
  final String leadingText;
  final (double, double) minMax;
  final double initValue;
  final Function(double value) onValueChange;

  @override
  State<IncrementingButton> createState() => _IncrementingButtonState();
}

class _IncrementingButtonState extends State<IncrementingButton> {
  late double value;
  bool? incrementing;
  late async.Timer timer;

  late CustomButton newButton;

  set increment(double value) {
    var newValue =
        (this.value + value).clamp(widget.minMax.$1, widget.minMax.$2);
    this.value = newValue;
    widget.onValueChange(newValue);
    setState(() {
      newButton = newButton.copyWith(text: "${widget.leadingText} $newValue");
    });
  }

  @override
  void initState() {
    super.initState();
    value = widget.initValue;

    newButton = widget.button.copyWith(onTapDown: (_) {
      widget.button.onTapDown?.call(_);
      incrementing = true;
    }, onTapUp: (_) {
      widget.button.onTapUp?.call(_);
      incrementing = null;
    }, onTapCancel: () {
      widget.button.onTapCancel?.call();
      incrementing = null;
    }, onSecondaryTapCancel: () {
      widget.button.onSecondaryTapCancel?.call();
      incrementing = null;
    }, onSecondaryTapDown: (_) {
      widget.button.onSecondaryTapDown?.call(_);
      incrementing = false;
    }, onSecondaryTapUp: (_) {
      widget.button.onSecondaryTapUp?.call(_);
      incrementing = null;
    });

    timer = async.Timer.periodic(
      const Duration(milliseconds: 50),
      (_) {
        if (incrementing == true) {
          increment = 1;
        } else if (incrementing == false) {
          increment = -1;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return newButton;
  }
}

class _OptionsMenuState extends State<OptionsMenu> {
  late IncrementingButton sfxButton;
  late IncrementingButton musicButton;
  late IncrementingButton hudScale;
  late CustomButton exitButton;

  late double musicVolume;
  late double sfxVolume;
  late SystemDataComponent? systemDataComponent;

  IncrementingButton buildMusicButton() {
    return IncrementingButton(
      leadingText: "Music: ",
      key: GlobalKey(),
      initValue: musicVolume,
      button: CustomButton(
        "Music: $musicVolume",
        gameRef: widget.gameRef,
      ),
      minMax: (0, 100),
      onValueChange: (value) {
        systemDataComponent?.dataObject.setMusicVolume = value;
      },
    );
  }

  IncrementingButton buildSFXButton() {
    return IncrementingButton(
      leadingText: "Sound Effects: ",
      key: GlobalKey(),
      initValue: sfxVolume,
      button: CustomButton(
        "Sound Effects: $sfxVolume",
        gameRef: widget.gameRef,
      ),
      minMax: (0, 100),
      onValueChange: (value) {
        systemDataComponent?.dataObject.setSFXVolume = value;
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

    sfxButton = buildSFXButton();
    musicButton = buildMusicButton();

    exitButton = CustomButton(
      "Back",
      gameRef: widget.gameRef,
      onTap: () {
        widget.gameRef.gameStateComponent.gameState
            .changeMainMenuPage(MenuPageType.startMenuPage);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          Expanded(
            child: DisplayButtons(
              // alignment: Alignment.center,
              buttons: [sfxButton, musicButton, exitButton],
            ),
          ),
        ],
      ),
    );
  }
}
