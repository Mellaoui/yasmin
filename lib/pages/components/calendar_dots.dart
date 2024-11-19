import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:imraatun/providers/day_status_provider.dart';
import 'package:provider/provider.dart';

class CalendarDots extends StatefulWidget {
  final Function(int day, String status) onSelectedDate;

  const CalendarDots({super.key, required this.onSelectedDate});

  @override
  _CalendarDotsState createState() => _CalendarDotsState();
}

class _CalendarDotsState extends State<CalendarDots> {
  final GlobalKey _calendarKey = GlobalKey();
  int _highlightedDay = -1;
  String _highlightedStatus = '';
  late List<Offset> _dotOffsets;
  late int _daysInMonth;
  final DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _computeDotPositions();
  }

  void _computeDotPositions() {
    DateTime now = DateTime.now();
    _daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    _dotOffsets = [];

    double radius = 150.0;
    for (int i = 0; i < _daysInMonth; i++) {
      final angle = i * (2 * pi / _daysInMonth);
      final offsetX = radius * cos(angle);
      final offsetY = radius * sin(angle);
      _dotOffsets.add(Offset(offsetX, offsetY));
    }
  }

  void _updateHighlightedDay(
      Offset globalPosition, Map<int, String> dayStatus) {
    RenderBox? box =
        _calendarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      Offset localPosition = box.globalToLocal(globalPosition);
      double centerX = box.size.width / 2;
      double centerY = box.size.height / 2;

      for (int i = 0; i < _daysInMonth; i++) {
        final day = i + 1;
        final Offset dotOffset = _dotOffsets[i] + Offset(centerX, centerY);
        final distance = (localPosition - dotOffset).distance;

        if (distance < 20 && _highlightedDay != day) {
          setState(() {
            _highlightedDay = day;
            _highlightedStatus = dayStatus[day] ??
                (AppLocalizations.of(context)?.normalDay ?? 'Normal day');

            widget.onSelectedDate(_highlightedDay, _highlightedStatus);
            HapticFeedback.lightImpact();
          });
          return;
        }
      }

      setState(() {
        _highlightedDay = -1;
        _highlightedStatus = '';
        widget.onSelectedDate(-1, '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DayStatusProvider>(
      builder: (context, dayStatusProvider, child) {
        final dayStatus = dayStatusProvider.dayStatus;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanUpdate: (details) {
            _updateHighlightedDay(details.globalPosition, dayStatus);
          },
          onTapDown: (details) {
            _updateHighlightedDay(details.globalPosition, dayStatus);
            HapticFeedback.lightImpact();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                key: _calendarKey,
                width: constraints.maxWidth,
                height: constraints.maxWidth,
                child: Stack(
                  alignment: Alignment.center,
                  children: List.generate(_daysInMonth, (index) {
                    final day = index + 1;
                    final Offset offset = _dotOffsets[index];
                    final String status = dayStatus[day] ??
                        (AppLocalizations.of(context)?.normalDay ??
                            'Normal day');

                    return Transform.translate(
                      offset: offset,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _highlightedDay = day;
                            _highlightedStatus = status;
                          });

                          widget.onSelectedDate(day, status);
                          HapticFeedback.lightImpact();
                        },
                        child: _buildCalendarDot(
                            day, _getDotColor(day, dayStatus), status),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getDotColor(int day, Map<int, String> dayStatus) {
    String? status = dayStatus[day];

    if (status == (AppLocalizations.of(context)?.period ?? 'Period')) {
      return const Color(0xFFFF4081); // Period color
    } else if (status ==
        (AppLocalizations.of(context)?.ovulation ?? 'Ovulation')) {
      return const Color.fromARGB(255, 31, 231, 13); // Ovulation color
    } else if (status ==
        (AppLocalizations.of(context)?.highChanceOfConception ??
            'High chance')) {
      return const Color.fromARGB(255, 233, 211, 17); // High chance color
    } else if (status ==
        (AppLocalizations.of(context)?.prePeriod ?? 'Pre-period')) {
      return const Color(0xFF2196F3); // Pre-period color
    } else {
      return const Color.fromARGB(255, 243, 243, 243); // Default color
    }
  }

  Widget _buildCalendarDot(int day, Color color, String status) {
    bool isSelected = _highlightedDay == day;
    bool isToday = day == today.day;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isSelected || isToday ? 34 : 22,
      height: isSelected || isToday ? 34 : 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        gradient: isSelected
            ? LinearGradient(
                colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: [
          if (isSelected || isToday)
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              spreadRadius: 1,
            ),
        ],
        border: Border.all(
          color: isToday
              ? const Color.fromARGB(255, 221, 221, 220)
              : (isSelected
                  ? const Color.fromARGB(255, 123, 1, 204)
                  : Colors.transparent),
          width: isToday || isSelected ? 3 : 0,
        ),
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            color: (color == const Color.fromARGB(255, 243, 243, 243))
                ? const Color.fromARGB(
                    255, 92, 90, 91) // Dark text for default color
                : Colors.white, // White text for status colors
            fontWeight: FontWeight.w400,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
