import '../view_model.dart';

class ThemeViewModel extends ViewModel {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notify();
  }
}
