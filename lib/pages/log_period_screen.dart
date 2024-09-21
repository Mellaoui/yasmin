import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class LogPeriodScreen extends StatefulWidget {
  const LogPeriodScreen({super.key});

  @override
  _LogPeriodScreenState createState() => _LogPeriodScreenState();
}

class _LogPeriodScreenState extends State<LogPeriodScreen> {
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now();
  bool _isPeriodStartToday = false;
  DateTime? _periodStartDate;
  DateTime? _periodEndDate;
  int _periodLength = 5; // Default period length

  @override
  void initState() {
    super.initState();
    _updatePeriodDates();
  }

  void _logPeriod() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a start date for the period.')),
      );
      return;
    }
    print('Logged period start date: $_selectedDate');
    Navigator.of(context).pop();
  }

  void _updatePeriodDates() {
    setState(() {
      if (_isPeriodStartToday) {
        _selectedDate = DateTime.now();
        _periodStartDate = DateTime.now();
        _periodEndDate =
            _periodStartDate?.add(Duration(days: _periodLength - 1));
      } else {
        _selectedDate = null;
        _periodStartDate = null;
        _periodEndDate = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Period'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TableCalendar(
              firstDay: DateTime(2000),
              lastDay: DateTime(2101),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDay = focusedDay;
                  if (_isPeriodStartToday) {
                    _periodStartDate = selectedDay;
                    _periodEndDate =
                        selectedDay.add(Duration(days: _periodLength - 1));
                  } else {
                    _periodStartDate = null;
                    _periodEndDate = null;
                  }
                  _isPeriodStartToday = isSameDay(selectedDay, DateTime.now());
                });
              },
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                selectedDecoration: const BoxDecoration(
                  color: Colors.pink,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.pink.shade200,
                  shape: BoxShape.circle,
                ),
                rangeStartDecoration: BoxDecoration(
                  color: Colors.pink.shade100,
                  shape: BoxShape.rectangle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: Colors.pink.shade100,
                  shape: BoxShape.rectangle,
                ),
                rangeHighlightColor: Colors.pink.shade50,
              ),
              calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, date, _) => Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: const BoxDecoration(
                    color: Colors.pink,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                todayBuilder: (context, date, _) => Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                rangeStartBuilder: (context, date, _) => Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade100,
                    shape: BoxShape.rectangle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                rangeEndBuilder: (context, date, _) => Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade100,
                    shape: BoxShape.rectangle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
              rangeStartDay: _periodStartDate,
              rangeEndDay: _periodEndDate,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Start period today:',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: _isPeriodStartToday,
                  onChanged: (value) {
                    _isPeriodStartToday = value;
                    _updatePeriodDates();
                  },
                  activeColor: Colors.pink,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Period Length (days):',
                  style: TextStyle(fontSize: 16),
                ),
                DropdownButton<int>(
                  value: _periodLength,
                  items: List.generate(10, (index) => index + 1)
                      .map((length) => DropdownMenuItem<int>(
                            value: length,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _periodLength == length
                                    ? Colors.pink.shade100
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Text(
                                length.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _periodLength == length
                                      ? Colors.pink
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (length) {
                    setState(() {
                      _periodLength = length!;
                      _updatePeriodDates();
                    });
                  },
                  style: const TextStyle(color: Colors.black),
                  underline: Container(
                    height: 2,
                    color: Colors.pink,
                  ),
                  dropdownColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logPeriod,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'LOG PERIOD',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
