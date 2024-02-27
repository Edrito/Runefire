import 'package:flame/components.dart';

mixin UpdateFunctionsThenRemove on Component {
  final List<void Function(double dt)> _updateFunctions = [];

  void addTemporaryUpdateFunction(void Function(double dt) function) {
    _updateFunctions.add(function);
  }

  @override
  void update(double dt) {
    for (final function in _updateFunctions) {
      function(dt);
    }
    _updateFunctions.clear();
    super.update(dt);
  }
}
