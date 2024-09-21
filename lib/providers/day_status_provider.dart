import 'package:flutter/material.dart';

class DayStatusProvider extends ChangeNotifier {
  Map<int, String> _dayStatus = {};

  Map<int, String> get dayStatus => _dayStatus;

  // Initialize day status with the cycle status
  void initializeDayStatus(Map<DateTime, String> cycleStatus) {
    _dayStatus = {}; // Clear previous status
    cycleStatus.forEach((date, status) {
      _dayStatus[date.day] = status;
    });
    notifyListeners(); // Notify listeners after status has been initialized
  }
}
