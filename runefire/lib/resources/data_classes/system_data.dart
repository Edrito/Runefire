import '../../game/enviroment.dart';
import '../enums.dart';
import 'base.dart';
import 'package:hive/hive.dart';

part 'system_data.g.dart';

class SystemDataComponent extends DataComponent {
  SystemDataComponent(super.dataObject);

  @override
  SystemData get dataObject => super.dataObject as SystemData;
}

@HiveType(typeId: 0)
class SystemData extends DataClass {
  SystemData({this.musicVolume = 0, this.sfxVolume = 0});

  @HiveField(0)
  double musicVolume;

  @HiveField(1)
  double sfxVolume;

  @HiveField(10)
  bool showFPS = false;

  @HiveField(11)
  bool showTimer = false;

  @HiveField(12)
  bool showStaminaHealthText = false;

  set setMusicVolume(double value) {
    musicVolume = value;
    parentComponent?.notifyListeners();
    save();
  }

  set setSFXVolume(double value) {
    sfxVolume = value;
    parentComponent?.notifyListeners();
    save();
  }
}
