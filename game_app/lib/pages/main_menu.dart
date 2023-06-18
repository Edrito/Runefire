import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:game_app/main.dart';
import '../resources/data_classes/system_data.dart';
import 'buttons.dart';
import '../resources/routes.dart' as routes;

enum MainMenuPages { startMenuPage, options }

extension MainMenuPagesExtension on MainMenuPages {
  MainMenuScreen buildPage() {
    switch (this) {
      case MainMenuPages.options:
        return OptionsMenuPage();
      case MainMenuPages.startMenuPage:
        return StartMenuPage();
    }
  }
}

class MainMenu extends PositionComponent {
  MainMenuPages? currentPage;
  MainMenuScreen? currentPageComponent;

  void changePage(MainMenuPages newPage) {
    currentPage = newPage;
    currentPageComponent?.removeWithAnimations();
    currentPageComponent = newPage.buildPage();
    add(currentPageComponent!);
  }

  @override
  Future<void> onLoad() async {
    // anchor = Anchor.center;

    changePage(MainMenuPages.startMenuPage);

    return super.onLoad();
  }
}

class StartMenuPage extends MainMenuScreen {
  late CustomButton startButtonComponent;
  late CustomButton exitButtonComponent;
  late CustomButton optionsButtonComponent;

  @override
  Future<void> onLoad() async {
    // anchor = Anchor.center;

    startButtonComponent = CustomButton(
      "Start Game",
      onPrimaryDownFunction: (p0) {
        game.router.pushNamed(routes.gameplay);
      },
    );
    optionsButtonComponent =
        CustomButton("Options", onPrimaryDownFunction: (_) {
      ancestor.changePage(MainMenuPages.options);
    });
    exitButtonComponent = CustomButton(
      "Exit",
    );

    buttons.add(startButtonComponent);
    buttons.add(optionsButtonComponent);
    buttons.add(exitButtonComponent);

    return super.onLoad();
  }
}

abstract class MainMenuScreen extends PositionComponent
    with HasGameRef<GameRouter>, HasAncestor<MainMenu> {
  List<CustomButton> buttons = [];

  @override
  bool containsLocalPoint(Vector2 point) {
    return true;
  }

  @override
  void onGameResize(Vector2 size) {
    position = game.canvasSize / 2;
    size = game.size;
    super.onGameResize(size);
  }

  @override
  FutureOr<void> onLoad() {
    position = game.canvasSize / 2;
    size = game.size;

    double sizeChunck = size.y / (buttons.length + 8);
    for (var i = 0; i < buttons.length; i++) {
      buttons[i].position = Vector2(
          0, sizeChunck * (i + 1) - ((sizeChunck / 1.5 * buttons.length)));
      buttons[i].scale = Vector2.zero();
      buttons[i]
          .add(ScaleEffect.to(Vector2.all(1), EffectController(duration: .5)));
    }
    addAll(buttons);
    return super.onLoad();
  }

  void removeWithAnimations() async {
    final controller = EffectController(duration: .5, onMax: removeFromParent);

    for (PositionComponent element in children.whereType<PositionComponent>()) {
      element.add(ScaleEffect.to(Vector2.zero(), controller));
    }
  }
}

class OptionsMenuPage extends MainMenuScreen {
  late CustomButton sfxButtonComponent;
  late CustomButton musicButtonComponent;
  late CustomButton exitButtonComponent;

  late double musicVolume;
  bool? incrementingMusic;
  late double sfxVolume;
  bool? incrementingSFX;
  late SystemDataComponent? systemDataComponent;

  String get buildMusicString => "Music: ${musicVolume.round()}";
  String get buildSFXString => "Sound Effects: ${sfxVolume.round()}";

  set incrementSFX(double value) {
    var newValue = (sfxVolume + value);
    if (newValue > 100) newValue = 0;
    // if (newValue < 0) newValue = 100;

    systemDataComponent?.dataObject.setSFXVolume = newValue.clamp(0, 100);
  }

  set incrementMusic(double value) {
    var newValue = (musicVolume + value);
    if (newValue > 100) newValue = 0;
    // if (newValue < 0) newValue = 100;
    systemDataComponent?.dataObject.setMusicVolume = (newValue).clamp(0, 100);
  }

  @override
  Future<void> onLoad() async {
    systemDataComponent = findParent<SystemDataComponent>();
    final systemDataNotifier =
        gameRef.componentsNotifier<SystemDataComponent>();

    systemDataNotifier.addListener(() {
      musicVolume = systemDataNotifier.single?.dataObject.musicVolume ?? 0.0;
      sfxVolume = systemDataNotifier.single?.dataObject.sfxVolume ?? 0.0;
      sfxButtonComponent.updateText(buildSFXString);
      musicButtonComponent.updateText(buildMusicString);
    });

    musicVolume = systemDataComponent?.dataObject.musicVolume ?? 0.0;
    sfxVolume = systemDataComponent?.dataObject.sfxVolume ?? 0.0;

    sfxButtonComponent = buildSFXButton();
    musicButtonComponent = buildMusicButton();

    exitButtonComponent = CustomButton(
      "Back",
      onPrimaryDownFunction: (_) {
        ancestor.changePage(MainMenuPages.startMenuPage);
      },
    );
    buttons.add(sfxButtonComponent);
    buttons.add(musicButtonComponent);
    buttons.add(exitButtonComponent);

    TimerComponent(
            period: durationIncrement,
            onTick: () {
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
            repeat: true)
        .addToParent(this);

    return super.onLoad();
  }

  double durationIncrement = .05;

  CustomButton buildMusicButton() {
    return CustomButton(buildMusicString, onPrimaryDownFunction: (_) {
      incrementMusic = 5;
      incrementingMusic = true;
    }, onPrimaryUpFunction: (_) {
      incrementingMusic = null;
    }, onPrimaryCancelledFunction: () {
      incrementingMusic = null;
    }, onSecondaryCancelledFunction: () {
      incrementingMusic = null;
    }, onSecondaryDownFunction: (_) {
      incrementMusic = -5;
      incrementingMusic = false;
    }, onSecondaryUpFunction: (_) {
      incrementingMusic = null;
    });
  }

  CustomButton buildSFXButton() {
    return CustomButton(buildSFXString, onPrimaryDownFunction: (_) {
      incrementSFX = 5;

      incrementingSFX = true;
    }, onPrimaryUpFunction: (_) {
      incrementingSFX = null;
    }, onPrimaryCancelledFunction: () {
      incrementingSFX = null;
    }, onSecondaryCancelledFunction: () {
      incrementingSFX = null;
    }, onSecondaryDownFunction: (_) {
      incrementSFX = -5;
      incrementingSFX = false;
    }, onSecondaryUpFunction: (_) {
      incrementingSFX = null;
    });
  }
}
