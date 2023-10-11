import 'dart:async' as async;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recase/recase.dart';
import 'package:runefire/game/hud.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
import '../resources/data_classes/system_data.dart';
import 'custom_button.dart';

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
  late OptionsMenuPages currentPage = OptionsMenuPages.keyboardBindings;
  late CustomButton exitButton;
  late CustomButton keyboardBindingsButton;
  late CustomButton mainOptionsButton;

  @override
  void initState() {
    super.initState();

    keyboardBindingsButton = CustomButton(
      "Keyboard Bindings",
      gameRef: widget.gameRef,
      onPrimary: () {
        setState(() {
          currentPage = OptionsMenuPages.keyboardBindings;
        });
      },
    );

    mainOptionsButton = CustomButton(
      "General",
      gameRef: widget.gameRef,
      onPrimary: () {
        setState(() {
          currentPage = OptionsMenuPages.main;
        });
      },
    );

    exitButton = CustomButton(
      "Back",
      gameRef: widget.gameRef,
      onPrimary: () {
        widget.gameRef.gameStateComponent.gameState
            .changeMainMenuPage(MenuPageType.startMenuPage);
      },
    );
  }

  Widget buildCurrentPage(OptionsMenuPages currentPage) {
    switch (currentPage) {
      case OptionsMenuPages.main:
        return OptionsMain(
          gameRef: widget.gameRef,
        );
      case OptionsMenuPages.keyboardBindings:
        return KeyboardMouseGamepadBindings(
          gameRef: widget.gameRef,
          configType: ExternalInputType.keyboard,
        );
      case OptionsMenuPages.gamepadBindings:
        return KeyboardMouseGamepadBindings(
          gameRef: widget.gameRef,
          configType: ExternalInputType.gamepad,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> topBarWidgets = [
      mainOptionsButton,
      keyboardBindingsButton
    ];
    topBarWidgets[currentPage.index] = Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: topBarWidgets[currentPage.index],
    );
    return Stack(
      children: [
        Positioned(
          top: 8,
          left: 0,
          right: 0,
          child: Center(
            child: SingleChildScrollView(
              child:
                  Row(mainAxisSize: MainAxisSize.min, children: topBarWidgets),
            ),
          ),
        ),
        Positioned.fill(
          top: menuBaseBarHeight,
          bottom: menuBaseBarHeight,
          child: Center(
            child: buildCurrentPage(currentPage),
          ),
        ),
        Positioned(
          bottom: 0,
          left: menuBaseBarWidthPadding,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: exitButton,
          ),
        ),
      ],
    );
  }
}

class OptionsMain extends StatefulWidget {
  const OptionsMain({
    super.key,
    required this.gameRef,
  });

  final GameRouter gameRef;

  @override
  State<OptionsMain> createState() => _OptionsMainState();
}

enum OptionsMenuPages {
  main,
  keyboardBindings,
  gamepadBindings,
}

class _OptionsMainState extends State<OptionsMain> with SystemDataNotifier {
  (double, double) sfxMinMax = (0, 100);
  (double, double) musicMinMax = (0, 100);
  late CustomButton keyboardBindingsButton;
  late HudScale hudScale;
  late double musicVolume;
  late double sfxVolume;

  @override
  GameRouter get gameRef => widget.gameRef;

  @override
  void onSystemDataNotification() {
    setState(() {
      musicVolume = systemDataNotifier.single?.dataObject.musicVolume ?? 0.0;
      sfxVolume = systemDataNotifier.single?.dataObject.sfxVolume ?? 0.0;
      hudScale =
          systemDataNotifier.single?.dataObject.hudScale ?? HudScale.medium;
    });
  }

  CustomButton buildHudScaleButton() {
    return CustomButton(
      "Hud Scale: ${hudScale.name.titleCase}",
      gameRef: widget.gameRef,
      onPrimary: () {
        incrementHudScale(true);
      },
      onSecondary: () {
        incrementHudScale(false);
      },
    );
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

  void incrementHudScale(bool increment) {
    int currentIndex = HudScale.values.indexOf(hudScale);
    if (increment) {
      currentIndex++;
    } else {
      currentIndex--;
    }

    currentIndex = currentIndex.clamp(0, HudScale.values.length - 1);
    systemData.setHudScale = HudScale.values[currentIndex];
  }

  void incrementMusic(bool increment) {
    if (increment) {
      musicVolume = musicVolume + 1;
    } else {
      musicVolume = musicVolume - 1;
    }
    systemData.setMusicVolume =
        (musicVolume).clamp(musicMinMax.$1, musicMinMax.$2);
  }

  void incrementSfx(bool increment) {
    if (increment) {
      sfxVolume = sfxVolume + 1;
    } else {
      sfxVolume = sfxVolume - 1;
    }
    systemData.setSFXVolume = (sfxVolume).clamp(sfxMinMax.$1, sfxMinMax.$2);
  }

  @override
  void dispose() {
    systemDataNotifier.removeListener(onSystemDataNotification);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    systemDataNotifier.addListener(onSystemDataNotification);

    musicVolume = systemData.musicVolume ?? 0.0;
    sfxVolume = systemData.sfxVolume ?? 0.0;
    hudScale =
        systemDataNotifier.single?.dataObject.hudScale ?? HudScale.medium;
    keyboardBindingsButton = CustomButton(
      "Keyboard Bindings",
      gameRef: widget.gameRef,
      onPrimary: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        // alignment: Alignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildSFXButton(),
          buildMusicButton(),
          buildHudScaleButton(),
        ],
      ),
    );
  }
}

class KeyboardMouseGamepadBindings extends StatefulWidget {
  const KeyboardMouseGamepadBindings({
    super.key,
    required this.gameRef,
    required this.configType,
  });

  final GameRouter gameRef;
  final ExternalInputType configType;
  @override
  State<KeyboardMouseGamepadBindings> createState() =>
      _KeyboardMouseGamepadBindingsState();
}

class _KeyboardMouseGamepadBindingsState
    extends State<KeyboardMouseGamepadBindings> with SystemDataNotifier {
  final InputManager inputManager = InputManager();

  String getStringRepresentation(GameAction key, bool firstIndex) {
    switch (widget.configType) {
      case ExternalInputType.keyboard:
        final keyBoardMappings = systemData.keyboardMappings[key];
        final mouseMappings = systemData.mouseButtonMappings[key];
        PhysicalKeyboardKey? keyBoardResult =
            (firstIndex ? keyBoardMappings?.$1 : keyBoardMappings?.$2);
        if (keyBoardResult != null) {
          return keyBoardResult.debugName.toString().titleCase;
        }
        int? mouseButtonResult =
            firstIndex ? mouseMappings?.$1 : mouseMappings?.$2;

        if (mouseButtonResult != null) {
          return getMouseButton(mouseButtonResult).name.titleCase;
        }

        return "";

      case ExternalInputType.gamepad:
        break;
      default:
    }
    return "aaa";
  }

  void newKeyboardPress(KeyEvent event) {}

  void newPointerDownPress(PointerDownEvent event) {}

  @override
  GameRouter get gameRef => widget.gameRef;

  @override
  void onSystemDataNotification() {}

  ScrollController scrollController = ScrollController();

  Widget buildRow(String one, String two, String three, [bool title = false]) {
    const double maxWidth = 1200;
    const double minWidth = 400;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxWidth, minWidth: minWidth),
      child: Container(
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(8),
          color: title ? ApolloColorPalette.darkestGray.color : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                // padding: const EdgeInsets.all(8.0),
                padding: EdgeInsets.zero,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: ApolloColorPalette.offWhite.color,
                        width: 2,
                      ),
                      // borderRadius: BorderRadius.circular(8),
                      color: ApolloColorPalette.deepGray.color),
                  child: Text(
                    one,
                    style:
                        defaultStyle.copyWith(color: colorPalette.primaryColor),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                // padding: const EdgeInsets.all(8.0),
                padding: EdgeInsets.zero,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: ApolloColorPalette.offWhite.color,
                        width: 2,
                      ),
                      // borderRadius: BorderRadius.circular(8),
                      color: ApolloColorPalette.deepGray.color),
                  child: Text(
                    two,
                    style: defaultStyle,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                // padding: const EdgeInsets.all(8.0),
                padding: EdgeInsets.zero,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: ApolloColorPalette.offWhite.color,
                        width: 2,
                      ),
                      // borderRadius: BorderRadius.circular(8),
                      color: ApolloColorPalette.deepGray.color),
                  child: Text(
                    three,
                    style: defaultStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> gameActionTriplets = [];

    for (var element in GameAction.values) {
      gameActionTriplets.add(
        buildRow(
          element.name.titleCase,
          getStringRepresentation(element, true),
          getStringRepresentation(element, false),
        ),
      );
    }

    return Column(
      children: [
        buildRow("Game Action", "Primary Button", "Alternate Button", true),
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: ScrollConfiguration(
            behavior: scrollConfiguration(context),
            child: SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ApolloColorPalette.offWhite.color,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: gameActionTriplets,
                  ),
                )),
          ),
        ),
      ],
    );
  }
}

mixin SystemDataNotifier<T extends StatefulWidget> on State<T> {
  abstract final GameRouter gameRef;
  late final SystemData systemData = gameRef.systemDataComponent.dataObject;
  late final ComponentsNotifier<SystemDataComponent> systemDataNotifier =
      gameRef.componentsNotifier<SystemDataComponent>();

  void onSystemDataNotification();

  @override
  void dispose() {
    systemDataNotifier.removeListener(onSystemDataNotification);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    systemDataNotifier.addListener(onSystemDataNotification);
  }
}
