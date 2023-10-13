import 'dart:async' as async;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:recase/recase.dart';
import 'package:runefire/game/hud.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
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
  OptionsMenuPages currentPage = OptionsMenuPages.keyboardBindings;
  late CustomButton exitButton;
  late CustomButton keyboardBindingsButton;
  late CustomButton mainOptionsButton;

  Function? centerSetState;

  Widget buildCurrentPage() {
    return StatefulBuilder(
      builder: (BuildContext context, setState) {
        centerSetState = setState;
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    keyboardBindingsButton = CustomButton(
      "Keyboard Bindings",
      gameRef: widget.gameRef,
      onPrimary: () {
        centerSetState?.call(() {
          currentPage = OptionsMenuPages.keyboardBindings;
        });
      },
    );

    mainOptionsButton = CustomButton(
      "General",
      gameRef: widget.gameRef,
      onPrimary: () {
        centerSetState?.call(() {
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
    final List<Widget> topBarWidgets = [
      mainOptionsButton,
      keyboardBindingsButton
    ];
    // topBarWidgets[currentPage.index] = Container(
    //   decoration: BoxDecoration(
    //     border: Border.all(
    //       color: Colors.white,
    //       width: 2,
    //     ),
    //   ),
    //   child: topBarWidgets[currentPage.index],
    // );
    return Stack(
      children: [
        Positioned(
          top: 8,
          left: 0,
          right: 0,
          child: Center(
            child: Wrap(
                children: [
              for (var element in topBarWidgets) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: element,
                ),
                Text(
                  "~",
                  style: defaultStyle,
                )
              ]
            ]..removeLast()),
          ),
        ),
        Positioned.fill(
          top: menuBaseBarHeight,
          bottom: menuBaseBarHeight,
          child: Center(
            child: buildCurrentPage(),
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
  late HudScale hudScale;
  late CustomButton keyboardBindingsButton;
  late double musicVolume;
  late double sfxVolume;

  CustomButton buildHudScaleButton() {
    return CustomButton(
      "Hud Scale: ${hudScale.name.titleCase}",
      gameRef: widget.gameRef,
      rowId: 7,
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
      rowId: 6,
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
      rowId: 5,
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
  GameRouter get gameRef => widget.gameRef;

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
  void onSystemDataNotification() {
    setState(() {
      musicVolume = systemDataNotifier.single?.dataObject.musicVolume ?? 0.0;
      sfxVolume = systemDataNotifier.single?.dataObject.sfxVolume ?? 0.0;
      hudScale =
          systemDataNotifier.single?.dataObject.hudScale ?? HudScale.medium;
    });
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

  final ExternalInputType configType;
  final GameRouter gameRef;

  @override
  State<KeyboardMouseGamepadBindings> createState() =>
      _KeyboardMouseGamepadBindingsState();
}

class _KeyboardMouseGamepadBindingsState
    extends State<KeyboardMouseGamepadBindings> with SystemDataNotifier {
  final InputManager inputManager = InputManager();

  Map<String, Color> generatedColors = {};
  List<String> generatedStrings = [];
  bool isWaitingInput = false;
  ScrollController scrollController = ScrollController();

  Function(KeyEvent? event, PointerDownEvent? pointerEvent)?
      keyboardMouseCallback;

  Function(
    KeyEvent? event,
    String? gamepadEvent,
  )? gamepadCallback;

  void beginRebindKey(
      GameAction gameAction, bool firstIndex, ExternalInputType source) {
    if (isWaitingInput) return;
    setState(() {
      isWaitingInput = true;
    });
    switch (source) {
      case ExternalInputType.keyboard:
        keyboardMouseCallback =
            (KeyEvent? event, PointerDownEvent? pointerEvent) {
          if (event?.logicalKey != LogicalKeyboardKey.abort &&
              event?.logicalKey != LogicalKeyboardKey.escape) {
            if (event != null) {
              systemData.setKeyboardMapping(
                  gameAction, event.physicalKey, firstIndex);
            } else if (pointerEvent != null) {
              systemData.setMouseButtonMapping(
                  gameAction, pointerEvent.buttons, firstIndex);
            }
            generatedColors.clear();
          } else {
            systemData.setKeyboardMapping(gameAction, null, firstIndex);
            systemData.setMouseButtonMapping(gameAction, null, firstIndex);
          }
          keyboardMouseCallback = null;
          Future.delayed(.1.seconds).then((_) {
            if (!mounted) {
              isWaitingInput = false;
              return;
            }
            setState(() {
              isWaitingInput = false;
            });
          });
        };

        break;
      case ExternalInputType.gamepad:
        gamepadCallback = (KeyEvent? event, String? gamepadEvent) {
          if (event?.logicalKey != LogicalKeyboardKey.abort &&
              event?.logicalKey != LogicalKeyboardKey.escape) {
            if (gamepadEvent != null) {
              systemData.setGamepadMapping(
                  gameAction, gamepadEvent, firstIndex);
            }
            generatedColors.clear();
          } else {
            systemData.setGamepadMapping(gameAction, null, firstIndex);
          }
          keyboardMouseCallback = null;
          Future.delayed(.1.seconds).then((_) {
            if (!mounted) {
              isWaitingInput = false;
              return;
            }
            setState(() {
              isWaitingInput = false;
            });
          });
        };

        break;
      default:
    }
  }

  Widget buildRow(
      GameAction? action, int index, String one, String two, String three,
      [bool title = false]) {
    const double maxWidth = 1200;
    const double minWidth = 400;
    if (!generatedColors.containsKey(two) &&
        generatedStrings.where((element) => element == two).length > 1) {
      generatedColors[two] = colorPalette.randomBrightColor;
    }
    if (!generatedColors.containsKey(three) &&
        generatedStrings.where((element) => element == three).length > 1) {
      generatedColors[three] = colorPalette.randomBrightColor;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxWidth, minWidth: minWidth),
      child: Container(
        decoration: const BoxDecoration(
            // borderRadius: BorderRadius.circular(8),
            // color: title ? ApolloColorPalette.darkestGray.color : null,
            ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                // padding: EdgeInsets.zero,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(

                      // borderRadius: BorderRadius.circular(8),
                      color: ApolloColorPalette.mediumGray.color),
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
                padding: const EdgeInsets.all(8.0),
                // padding: EdgeInsets.zero,
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: title
                            ? null
                            : Border.all(
                                color: ApolloColorPalette.mediumGray.color,
                                width: 2,
                              ),
                        // borderRadius: BorderRadius.circular(8),
                        color: generatedColors[two] ??
                            ApolloColorPalette.deepGray.color),
                    child: title
                        ? Text(
                            two,
                            textAlign: TextAlign.center,
                            style: defaultStyle,
                          )
                        : CustomButton(
                            two,
                            rowId: index,
                            upDownColor: two == "Set binding"
                                ? (
                                    ApolloColorPalette.veryLightGray.color,
                                    ApolloColorPalette.lightGray.color,
                                  )
                                : null,
                            gameRef: widget.gameRef,
                            scrollController: scrollController,
                            onPrimary: () {
                              beginRebindKey(action!, true, widget.configType);
                            },
                          )),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                // padding: EdgeInsets.zero,
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: title
                            ? null
                            : Border.all(
                                color: ApolloColorPalette.mediumGray.color,
                                width: 2,
                              ),
                        // borderRadius: BorderRadius.circular(8),
                        color: generatedColors[three] ??
                            ApolloColorPalette.deepGray.color),
                    child: title
                        ? Text(
                            three,
                            textAlign: TextAlign.center,
                            style: defaultStyle,
                          )
                        : CustomButton(
                            three,
                            scrollController: scrollController,
                            gameRef: widget.gameRef,
                            rowId: index,
                            upDownColor: three == "Set binding"
                                ? (
                                    ApolloColorPalette.veryLightGray.color,
                                    ApolloColorPalette.lightGray.color,
                                  )
                                : null,
                            onPrimary: () {
                              beginRebindKey(action!, false, widget.configType);
                            },
                          )),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          final result = getMouseButton(mouseButtonResult);
          if (result == MouseButtons.misc) {
            return "Button: $mouseButtonResult";
          }
          return result.name.titleCase;
        }

        return "Set binding";

      case ExternalInputType.gamepad:
        break;
      default:
    }
    return "";
  }

  void newKeyboardPress(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    keyboardMouseCallback?.call(event, null);
  }

  void newPointerDownPress(PointerDownEvent event) {
    keyboardMouseCallback?.call(null, event);
  }

  @override
  void dispose() {
    InputManager().keyEventList.remove(newKeyboardPress);
    InputManager().pointerDownList.remove(newPointerDownPress);
    super.dispose();
  }

  @override
  GameRouter get gameRef => widget.gameRef;

  @override
  void initState() {
    super.initState();
    InputManager().keyEventList.add(newKeyboardPress);
    InputManager().pointerDownList.add(newPointerDownPress);
  }

  @override
  void onSystemDataNotification() {}

  @override
  Widget build(BuildContext context) {
    List<Widget> gameActionTriplets = [];
    generatedStrings.clear();
    int i = 4;

    for (var element in GameAction.values) {
      final primaryString = getStringRepresentation(element, true);
      final secondaryString = getStringRepresentation(element, false);
      if (primaryString != "Set binding") {
        generatedStrings.add(primaryString);
      }
      if (secondaryString != "Set binding") {
        generatedStrings.add(secondaryString);
      }
    }

    for (var element in GameAction.values) {
      final primaryString = getStringRepresentation(element, true);
      final secondaryString = getStringRepresentation(element, false);
      gameActionTriplets.add(
        buildRow(
          element,
          i,
          element.name.titleCase,
          primaryString,
          secondaryString,
        ),
      );
      i++;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: isWaitingInput,
            child: Column(
              children: [
                buildRow(null, 3, "Game Action", "Primary Button",
                    "Alternate Button", true),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: scrollConfiguration(context),
                    child: SingleChildScrollView(
                        controller: scrollController,
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: gameActionTriplets,
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isWaitingInput)
          Positioned.fill(
              child: Container(
            color: ApolloColorPalette.deepGray.color.withOpacity(.5),
          )).animate().fadeIn(duration: .2.seconds),
        if (isWaitingInput)
          Center(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: ApolloColorPalette.darkestGray.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ApolloColorPalette.lightGray.color,
                    width: 4,
                  )),
              child: Text(
                "Input new binding!",
                style: defaultStyle,
                textAlign: TextAlign.center,
              ),
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
mixin PlayerDataNotifier<T extends StatefulWidget> on State<T> {
  abstract final GameRouter gameRef;
  late final PlayerData playerData = gameRef.playerDataComponent.dataObject;
  late final ComponentsNotifier<PlayerDataComponent> playerDataNotifier =
      gameRef.componentsNotifier<PlayerDataComponent>();

  void onPlayerDataNotification();

  @override
  void dispose() {
    playerDataNotifier.removeListener(onPlayerDataNotification);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    playerDataNotifier.addListener(onPlayerDataNotification);
  }
}
