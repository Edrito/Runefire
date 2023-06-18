import 'package:flame/components.dart';

import 'package:hive/hive.dart';

abstract class DataClass extends HiveObject {
  DataComponent? parentComponent;
}

abstract class DataComponent extends Component with Notifier {
  DataComponent(this._dataObject) {
    _dataObject.parentComponent = this;
  }
  final DataClass _dataObject;

  DataClass get dataObject => _dataObject;
}
