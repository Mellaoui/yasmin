import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imraatun/providers/day_status_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class LogPeriodScreen extends StatefulWidget {
  const LogPeriodScreen({super.key});

  @override
  _LogPeriodScreenState createState() => _LogPeriodScreenState();
}

class _LogPeriodScreenState extends State<LogPeriodScreen>
    with SingleTickerProviderStateMixin {
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now();
  DateTime? _periodStartDate;
  DateTime? _expectedEndDate;
  DateTime? _ovulationDate; // Added for ovulation prediction
  int _periodLength = 5;
  bool _isFinalized = false;
  bool _isNewPeriod = true;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(
        parent: _buttonAnimationController, curve: Curves.easeInOut));
    loadOngoingOrLatestPeriod();
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> loadOngoingOrLatestPeriod() async {
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
        _periodStartDate = (periodData['startDate'] as Timestamp).toDate();
        _expectedEndDate = (periodData['endDate'] as Timestamp).toDate();
        _isFinalized = periodData['isFinalized'] ?? false;

        if (!_isFinalized) {
          setState(() {
            _selectedDate = _periodStartDate;
            _isNewPeriod = false;
          });
        } else {
          setState(() {
            _isNewPeriod = true;
          });
        }

        // Calculate the ovulation date as 14 days before the expected end of the cycle
        if (_expectedEndDate != null) {
          setState(() {
            _ovulationDate = _expectedEndDate!.subtract(Duration(days: 14));
          });
        }
      }
    } catch (e) {
      print("Failed to load period data: $e");
    }
  }

  Future<void> _logNewPeriodInFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedDate == null) return;

    try {
      final periodData = {
        'startDate': _selectedDate,
        'endDate': _expectedEndDate,
        'periodLength': _periodLength,
        'isFinalized': false,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('periods')
          .add(periodData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.logPeriodButton)),
      );

      Provider.of<DayStatusProvider>(context, listen: false)
          .updatePeriodData(_selectedDate!, _periodLength);

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to log period: $e")),
      );
    }
  }

  Future<void> _finalizePeriodInFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedDate == null) return;

    try {
      final periodDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('periods')
          .where('startDate', isEqualTo: _periodStartDate)
          .limit(1);

      await periodDoc.get().then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.first.reference.update({
            'actualEndDate': _expectedEndDate,
            'isFinalized': true,
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.periodFinalized)),
      );

      Provider.of<DayStatusProvider>(context, listen: false)
          .updatePeriodData(_selectedDate!, _periodLength);

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to finalize period: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _isNewPeriod
              ? localizations.logPeriodTitle
              : localizations.finalizePeriodTitle,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 80.0, left: 20.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCalendar(localizations),
                  const SizedBox(height: 20),
                  _buildPeriodLengthSlider(localizations),
                  const SizedBox(height: 20),
                  _buildLogOrFinalizeButton(localizations),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 248, 245, 246).withOpacity(0.4),
            Colors.pink.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(color: Colors.white.withOpacity(0.1)),
      ),
    );
  }

  Widget _buildCalendar(AppLocalizations localizations) {
    return TableCalendar(
      locale: Localizations.localeOf(context).toString(),
      firstDay: DateTime(2000),
      lastDay: DateTime(2101),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
          _focusedDay = focusedDay;
          _expectedEndDate =
              _selectedDate!.add(Duration(days: _periodLength - 1));
        });
      },
      calendarFormat: CalendarFormat.month,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextFormatter: (date, locale) => _formatMonthYear(date),
        titleTextStyle: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.black),
        rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.black),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekendStyle: TextStyle(color: Colors.grey),
        weekdayStyle: TextStyle(color: Colors.black),
      ),
      calendarStyle: CalendarStyle(
        isTodayHighlighted: true,
        defaultTextStyle: const TextStyle(color: Colors.black),
        weekendTextStyle: const TextStyle(color: Colors.grey),
        outsideDaysVisible: false,
      ),
      rangeStartDay: _isFinalized ? null : _periodStartDate,
      rangeEndDay: _isFinalized ? null : _expectedEndDate,
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (_ovulationDate != null && isSameDay(day, _ovulationDate)) {
            return Positioned(
              bottom: 1,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.blueAccent, // Ovulation date color
                  shape: BoxShape.circle,
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPeriodLengthSlider(AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(localizations.periodLength,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        Slider(
          value: _periodLength.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: _periodLength.toString(),
          activeColor: Colors.pink,
          inactiveColor: Colors.grey,
          onChanged: (value) {
            setState(() {
              _periodLength = value.toInt();
              _expectedEndDate =
                  _selectedDate?.add(Duration(days: _periodLength - 1));
            });
          },
        ),
      ],
    );
  }

  Widget _buildLogOrFinalizeButton(AppLocalizations localizations) {
    return GestureDetector(
      onTapDown: (_) => _buttonAnimationController.forward(),
      onTapUp: (_) => _buttonAnimationController.reverse(),
      onTapCancel: () => _buttonAnimationController.reverse(),
      child: ScaleTransition(
        scale: _buttonScale,
        child: ElevatedButton(
          onPressed: _selectedDate != null
              ? (_isNewPeriod
                  ? _logNewPeriodInFirebase
                  : _finalizePeriodInFirebase)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            _isNewPeriod
                ? localizations.logPeriodButton
                : localizations.finalizePeriodButton,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  String _formatMonthYear(DateTime date) {
    final monthName =
        DateFormat.MMMM(Localizations.localeOf(context).toString())
            .format(date);
    final year = DateFormat.y('en').format(date);
    return '$monthName $year';
  }
}
