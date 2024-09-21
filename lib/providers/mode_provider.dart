import 'package:flutter/material.dart';

enum AppMode { trackCycle, getPregnant, trackPregnancy }

class ModeProvider extends ChangeNotifier {
  AppMode _currentMode = AppMode.trackCycle;

  AppMode get currentMode => _currentMode;

  void updateMode(AppMode mode) {
    _currentMode = mode;
    notifyListeners();
  }
}
