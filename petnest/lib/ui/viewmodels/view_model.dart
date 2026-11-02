import 'package:flutter/foundation.dart';

/// ChangeNotifier that ignores notifications after dispose, so async API
/// callbacks that finish after the screen closed don't throw.
abstract class ViewModel extends ChangeNotifier {
  bool _disposed = false;

  @protected
  void notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
