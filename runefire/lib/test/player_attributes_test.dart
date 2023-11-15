import 'package:flame/components.dart';
import 'package:runefire/game/hexed_forest_game.dart';
import 'package:runefire/game/menu_game.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:test/expect.dart';
import 'package:test/test.dart';

void main() {
  final menuGame = MenuGame();
  final player = Player(
    PlayerData(),
    enviroment: menuGame,
    isDisplay: false,
    eventManagement: MenuGameEventManagement(menuGame),
    initialPosition: Vector2.zero(),
  );
  playerTest(player);
}

void playerTest(Player player) {
  group('Elemental Attribute Group', () {
    elementalForceTest(player);
  });
}

void elementalForceTest(Player player) {
  test(
      'After the fetch attribute function is called, the force flag should be null',
      () {
    for (final damageType in DamageType.values) {
      DamageType? result;

      void checkerWrapper(
        double modifyAmount,
        double shouldBe,
        bool expectDamageType,
      ) {
        player.modifyElementalPower(damageType, modifyAmount);

        result = player.shouldForceElementalAttribute();
        expect(expectDamageType ? damageType : null, result);

        result = player.shouldForceElementalAttribute();
        expect(null, result);

        expect(player.elementalPower[damageType], shouldBe);
      }

      checkerWrapper(-.1, 0, false);
      checkerWrapper(.1, .1, false);
      checkerWrapper(.25, .35, true);
      checkerWrapper(.25, .60, true);
      checkerWrapper(.25, .85, true);
      checkerWrapper(.25, 1, true);
      checkerWrapper(5, 1, false);
    }
  });
}
