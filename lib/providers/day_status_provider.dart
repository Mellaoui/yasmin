import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DayStatusProvider extends ChangeNotifier {
  Map<int, String> _dayStatus = {};
  DateTime? latestPeriodStartDate;
  int latestPeriodLength = 0;

  Map<int, String> get dayStatus => _dayStatus;

  // Fetch startDate and periodLength from Firebase
  Future<void> fetchLatestPeriodData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final periodDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('periods')
          .orderBy('startDate', descending: true)
          .limit(1)
          .get();

      if (periodDocs.docs.isNotEmpty) {
        final periodData = periodDocs.docs.first.data();
        latestPeriodStartDate =
            (periodData['startDate'] as Timestamp?)?.toDate();
        latestPeriodLength = periodData['periodLength'] ?? 0;

        notifyListeners(); // Notify listeners that the state has changed
      } else {
        latestPeriodStartDate = null;
        latestPeriodLength = 0;
        notifyListeners();
      }
    } catch (e) {
      print("Failed to fetch period data: $e");
    }
  }

  // Initialize day status with the cycle status
  void initializeDayStatus(Map<DateTime, String> cycleStatus) {
    _dayStatus.clear(); // Clear previous status
    cycleStatus.forEach((date, status) {
      _dayStatus[date.day] = status;
    });
    notifyListeners();
  }

  // Update period data and notify listeners
  void updatePeriodData(DateTime startDate, int periodLength) {
    latestPeriodStartDate = startDate;
    latestPeriodLength = periodLength;
    notifyListeners();
  }

  // Clear all day status and period data (for logout)
  void clearDayStatus() {
    _dayStatus.clear();
    latestPeriodStartDate = null;
    latestPeriodLength = 0;
    notifyListeners();
  }
}
