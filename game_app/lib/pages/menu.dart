import 'dart:io';
import 'dart:math';
import 'dart:async' as async;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_app/main.dart';
import '../resources/data_classes/system_data.dart';
import 'buttons.dart';
import '/resources/routes.dart' as routes;
import 'package:flutter_animate/flutter_animate.dart';

enum MenuPages { startMenuPage, options, pauseMenu }

extension MainMenuPagesExtension on MenuPages {
  Widget buildPage(GameRouter gameRef) {
    Random rng = Random();
    switch (this) {
      case MenuPages.options:
        return OptionsMenu(
          gameRef: gameRef,
          key: Key(rng.nextDouble().toString()),
        );
      case MenuPages.startMenuPage:
        return StartMenu(
          key: Key(rng.nextDouble().toString()),
          gameRef: gameRef,
        );
      default:
        return OptionsMenu(
          key: Key(rng.nextDouble().toString()),
          gameRef: gameRef,
        );
    }
  }
}

// class PauseMenuPage extends MenuScreen {
//   late CustomButtonTwo continueButtonComponent;
//   late CustomButtonTwo mainMenuButtonComponent;

//   @override
//   Future<void> onLoad() async {
//     // anchor = Anchor.center;

//     continueButtonComponent = CustomButtonTwo(
//       "Continue",
//       onPrimaryDownFunction: (p0) {
//         game.resumeEngine();
//         removeWithAnimations();
//       },
//     );
//     mainMenuButtonComponent =
//         CustomButtonTwo("Exit to Menu", onPrimaryDownFunction: (_) {
//       game.router.pushReplacementNamed(routes.mainMenu);
//       game.resumeEngine();
//       removeWithAnimations();
//     });

//     buttons.add(continueButtonComponent);
//     buttons.add(mainMenuButtonComponent);

//     return super.onLoad();
//   }
// }

// class OptionsMenuPage extends MenuScreen {
//   late CustomButtonTwo sfxButtonComponent;
//   late CustomButtonTwo musicButtonComponent;
//   late CustomButtonTwo exitButtonComponent;

//   late double musicVolume;
//   bool? incrementingMusic;
//   late double sfxVolume;
//   bool? incrementingSFX;
//   late SystemDataComponent? systemDataComponent;

//   String get buildMusicString => "Music: ${musicVolume.round()}";
//   String get buildSFXString => "Sound Effects: ${sfxVolume.round()}";

//   set incrementSFX(double value) {
//     var newValue = (sfxVolume + value);
//     // if (newValue > 100) newValue = 0;
//     // if (newValue < 0) newValue = 100;

//     systemDataComponent?.dataObject.setSFXVolume = newValue.clamp(0, 100);
//   }

//   set incrementMusic(double value) {
//     var newValue = (musicVolume + value);
//     // if (newValue > 100) newValue = 0;
//     // if (newValue < 0) newValue = 100;
//     systemDataComponent?.dataObject.setMusicVolume = (newValue).clamp(0, 100);
//   }

//   @override
//   Future<void> onLoad() async {
//     systemDataComponent = gameRef.systemDataComponent;
//     final systemDataNotifier =
//         gameRef.componentsNotifier<SystemDataComponent>();

//     systemDataNotifier.addListener(() {
//       musicVolume = systemDataNotifier.single?.dataObject.musicVolume ?? 0.0;
//       sfxVolume = systemDataNotifier.single?.dataObject.sfxVolume ?? 0.0;

//       sfxButtonComponent.updateText(buildSFXString);
//       musicButtonComponent.updateText(buildMusicString);
//     });

//     musicVolume = systemDataComponent?.dataObject.musicVolume ?? 0.0;
//     sfxVolume = systemDataComponent?.dataObject.sfxVolume ?? 0.0;

//     sfxButtonComponent = buildSFXButton();
//     musicButtonComponent = buildMusicButton();

//     exitButtonComponent = CustomButtonTwo(
//       "Back",
//       onPrimaryDownFunction: (_) {
//         ancestor.changePage(MenuPages.startMenuPage);
//       },
//     );
//     buttons.add(sfxButtonComponent);
//     buttons.add(musicButtonComponent);
//     buttons.add(exitButtonComponent);

//     return super.onLoad();
//   }

//   @override
//   void update(double dt) {
//     if (incrementingMusic == true) {
//       incrementMusic = 1;
//     } else if (incrementingMusic == false) {
//       incrementMusic = -1;
//     }

//     if (incrementingSFX == true) {
//       incrementSFX = 1;
//     } else if (incrementingSFX == false) {
//       incrementSFX = -1;
//     }
//     super.update(dt);
//   }

// }

class StartMenu extends StatefulWidget {
  const StartMenu({
    super.key,
    required this.gameRef,
  });
  final GameRouter gameRef;

  @override
  State<StartMenu> createState() => _StartMenuState();
}

class _StartMenuState extends State<StartMenu> {
  late CustomButtonTwo startButtonComponent;
  late CustomButtonTwo exitButtonComponent;
  late CustomButtonTwo optionsButtonComponent;

  @override
  void initState() {
    super.initState();
    startButtonComponent = CustomButtonTwo(
      "Start Game",
      gameRef: widget.gameRef,
      onTap: () {
        toggleGameStart(routes.gameplay);
      },
    );
    optionsButtonComponent =
        CustomButtonTwo("Options", gameRef: widget.gameRef, onTap: () {
      changeMainMenuPage(MenuPages.options);
    });
    exitButtonComponent =
        CustomButtonTwo("Exit", gameRef: widget.gameRef, onTap: () {
      exit(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DisplayButtons(
      buttons: [
        startButtonComponent,
        optionsButtonComponent,
        exitButtonComponent
      ],
    );
  }
}

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
  late CustomButtonTwo sfxButton;
  late CustomButtonTwo musicButton;
  late CustomButtonTwo exitButton;

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

  CustomButtonTwo buildMusicButton() {
    return CustomButtonTwo(buildMusicString, gameRef: widget.gameRef,
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

  CustomButtonTwo buildSFXButton() {
    return CustomButtonTwo(buildSFXString, gameRef: widget.gameRef,
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

    exitButton = CustomButtonTwo(
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

class DisplayButtons extends StatefulWidget {
  const DisplayButtons({required this.buttons, super.key});
  final List<CustomButtonTwo> buttons;

  @override
  State<DisplayButtons> createState() => _DisplayButtonsState();
}

class _DisplayButtonsState extends State<DisplayButtons> {
  int selectedIndex = -1;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> displayedButtons = [];

    for (CustomButtonTwo button in widget.buttons) {
      if (selectedIndex != -1 && widget.buttons[selectedIndex] == button) {
        button = button.copyWith(isHighlightedInitial: true);
      }
      displayedButtons.add(Padding(
        padding: const EdgeInsets.all(5.0),
        child: button,
      ));
    }
    return Listener(
      onPointerDown: (event) {
        selectedIndex = -1;
      },
      child: KeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: (value) {
          if (value is KeyUpEvent || value is KeyRepeatEvent) return;
          if (value.logicalKey == LogicalKeyboardKey.enter ||
              value.logicalKey == LogicalKeyboardKey.space) {
            if (selectedIndex != -1 &&
                widget.buttons[selectedIndex].onTap != null) {
              widget.buttons[selectedIndex].onTap!();
            }
          } else if (value.logicalKey == LogicalKeyboardKey.keyW ||
              value.logicalKey == LogicalKeyboardKey.arrowUp) {
            setState(() {
              selectedIndex--;
              if (selectedIndex < 0) {
                selectedIndex = widget.buttons.length - 1;
              }
            });
          } else if (value.logicalKey == LogicalKeyboardKey.keyS ||
              value.logicalKey == LogicalKeyboardKey.arrowDown) {
            setState(() {
              selectedIndex++;
              if (selectedIndex > widget.buttons.length - 1) {
                selectedIndex = 0;
              }
            });
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: displayedButtons
                    .animate(interval: .05.seconds)
                    // .slideX(
                    //     curve: Curves.easeInOut,
                    //     begin: -1,
                    //     end: 0,
                    //     duration: .4.seconds)
                    .fadeIn(curve: Curves.easeInOut, duration: .4.seconds),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
