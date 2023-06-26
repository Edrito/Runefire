import 'package:flutter/material.dart';
import 'package:game_app/pages/buttons.dart';
import 'package:game_app/pages/menu.dart';
import 'package:game_app/resources/visuals.dart';

import '../main.dart';
import 'enums.dart';

MapEntry<String, Widget Function(BuildContext, GameRouter)> pauseMenu =
    MapEntry('PauseMenu', (context, gameRouter) {
  final size = MediaQuery.of(context).size;

  return Material(
    color: Colors.transparent,
    child: Center(
      child: StatefulBuilder(builder: (context, setState) {
        return ConstrainedBox(
          constraints: const BoxConstraints(
              maxWidth: 325, minHeight: 200, maxHeight: 500, minWidth: 200),
          child: Container(
            width: size.width / 4,
            height: size.height / 4,
            decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                CustomButton(
                  "Resume",
                  gameRef: gameRouter,
                  onTap: () {
                    gameRouter.overlays.remove(pauseMenu.key);
                    gameRouter.resumeEngine();
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButton(
                  "Exit to Main Menu",
                  gameRef: gameRouter,
                  onTap: () {
                    toggleGameStart(null);
                    gameRouter.overlays.remove(pauseMenu.key);
                    gameRouter.resumeEngine();
                  },
                )
              ],
            ),
          ),
        );
      }),
    ),
  );
});

MapEntry<String, Widget Function(BuildContext, GameRouter)> mainMenu =
    MapEntry('MainMenu', (context, gameRouter) {
  return Center(
    child: StatefulBuilder(builder: (context, setState) {
      setStateGame = setState;
      return menuPage.buildPage(gameRouter);
    }),
  );
});

MapEntry<String, Widget Function(BuildContext, GameRouter)> weaponModifyMenu =
    MapEntry('WeaponModifyMenu', (context, gameRouter) {
  Size screenSize = MediaQuery.of(context).size;
  return Material(
    color: Colors.transparent,
    child: Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: (screenSize.width * .2),
            vertical: (screenSize.height * .1)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.brown.shade500,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                height: 50,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    gameRouter.overlays.remove(weaponModifyMenu.key);
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: WeaponType.values.length,
                  itemBuilder: (context, index) {
                    final currentWeaponType = WeaponType.values[index];

                    return Container(
                      color: Colors.brown.shade100,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox.square(
                              dimension: 100,
                              child: Image.asset(
                                "assets/images/${currentWeaponType.icon()}",
                              ),
                            ),
                          ),
                          Expanded(
                              child: SingleChildScrollView(
                                  child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade300,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade300,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade300,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          )))
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
