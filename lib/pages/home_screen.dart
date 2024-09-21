import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imraatun/pages/settings/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:vibration/vibration.dart';
import 'package:imraatun/providers/day_status_provider.dart';

class PeriodCycle {
  final int cycleLength;
  final int periodLength;

  PeriodCycle({
    required this.cycleLength,
    required this.periodLength,
  });

  List<DateTime> _getDateRange(DateTime startDate, int length) {
    return List<DateTime>.generate(
      length,
      (index) => startDate.add(Duration(days: index)),
    );
  }

  List<DateTime> calculatePeriodDays(DateTime startDate) {
    return _getDateRange(startDate, periodLength);
  }

  DateTime calculateOvulationDay(DateTime startDate) {
    return startDate.add(Duration(days: (cycleLength / 2).round()));
  }

  List<DateTime> calculateHighConceptionDays(DateTime startDate) {
    DateTime ovulationDay = calculateOvulationDay(startDate);
    return _getDateRange(ovulationDay.subtract(const Duration(days: 2)), 5);
  }

  List<DateTime> calculatePrePeriodDays(DateTime startDate) {
    DateTime prePeriodStartDate =
        startDate.add(Duration(days: cycleLength - 3));
    return _getDateRange(prePeriodStartDate, 3);
  }

  Map<DateTime, String> calculateCycle(DateTime startDate) {
    Map<DateTime, String> cycleMap = {};
    List<DateTime> periodDays = calculatePeriodDays(startDate);
    List<DateTime> highConceptionDays = calculateHighConceptionDays(startDate);
    List<DateTime> prePeriodDays = calculatePrePeriodDays(startDate);
    DateTime ovulationDay = calculateOvulationDay(startDate);

    for (var day in periodDays) {
      cycleMap[day] = 'Period';
    }

    for (var day in highConceptionDays) {
      cycleMap[day] = 'High chance of conception';
    }

    for (var day in prePeriodDays) {
      cycleMap[day] = 'Pre-period';
    }

    cycleMap[ovulationDay] = 'Ovulation';

    return cycleMap;
  }
}

// class DayStatusProvider with ChangeNotifier {
//   Map<int, String> _dayStatus = {};

//   Map<int, String> get dayStatus => _dayStatus;

//   // Initialize day status with the cycle status
//   void initializeDayStatus(Map<DateTime, String> cycleStatus) {
//     _dayStatus = {}; // Clear previous status
//     cycleStatus.forEach((date, status) {
//       _dayStatus[date.day] = status;
//     });
//     notifyListeners(); // Notify listeners after status has been initialized
//   }
// }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _showStatus = true;
  int _highlightedDay = -1;
  String _highlightedStatus = '';

  final GlobalKey _calendarKey = GlobalKey();

  final List<Widget> _screens = [
    const TrackerScreen(),
    const CalendarScreen(),
    const ProfileScreen(),
  ];

  final PeriodCycle periodCycle = PeriodCycle(cycleLength: 28, periodLength: 7);
  DateTime periodStartDate = DateTime.now().subtract(const Duration(days: 10));

  static const Color selectedColor = Color(0xFFFF4081);
  static const Color unselectedColor = Colors.grey;
  static const Color highlightColor = Colors.green;

  @override
  void initState() {
    super.initState();

    // Delay initialization until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDayStatus();
      _showCustomDialog(); // If you're showing a dialog, ensure it's after the build too
    });
  }

  void _initializeDayStatus() {
    final cycleStatus = periodCycle.calculateCycle(periodStartDate);
    // Initialize day status in provider
    Provider.of<DayStatusProvider>(context, listen: false)
        .initializeDayStatus(cycleStatus);
  }

  void _showCustomDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAlertDialog();
      },
    );
  }

  Widget _buildAlertDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          _buildCircularIndicator(),
          const SizedBox(height: 20),
          _buildLegend(),
          const SizedBox(height: 20),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildCircularIndicator() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildDialogDot(selectedColor, const Offset(40, 0)),
          _buildDialogDot(const Color(0xFF4CAF50), const Offset(-40, 0)),
          _buildDialogDot(const Color(0xFFFFEB3B), const Offset(0, -40)),
          _buildDialogDot(const Color(0xFF2196F3), const Offset(0, 40)),
        ],
      ),
    );
  }

  Widget _buildDialogDot(Color color, Offset offset) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          'NEXT',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        _buildLegendItem('The Period', selectedColor),
        _buildLegendItem('Ovulation', const Color(0xFF4CAF50)),
        _buildLegendItem('High chance of conception', const Color(0xFFFFEB3B)),
        _buildLegendItem('Pre-period', const Color(0xFF2196F3)),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(text),
      ],
    );
  }

  Color _getDotColor(int day) {
    String? status =
        Provider.of<DayStatusProvider>(context, listen: false).dayStatus[day];
    switch (status) {
      case 'Period':
        return selectedColor;
      case 'Ovulation':
        return const Color(0xFF4CAF50);
      case 'High chance of conception':
        return const Color(0xFFFFEB3B);
      case 'Pre-period':
        return const Color(0xFF2196F3);
      default:
        return const Color.fromARGB(255, 192, 191, 191);
    }
  }

  void _triggerVibration() {
    if (Vibration.hasVibrator() != null) {
      Vibration.vibrate(duration: 50); // Vibrate for 50ms
    }
  }

  void _updateHighlightedDay(Offset globalPosition) {
    RenderBox? box =
        _calendarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      Offset localPosition = box.globalToLocal(globalPosition);

      double centerX = box.size.width / 2;
      double centerY = box.size.height / 2;
      double radius = 150; // You can adjust this based on your layout

      DateTime now = DateTime.now();
      int daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

      for (int i = 0; i < daysInMonth; i++) {
        final day = i + 1;
        final angle = i * (2 * pi / daysInMonth);
        final offsetX = radius * cos(angle) + centerX;
        final offsetY = radius * sin(angle) + centerY;

        final distance = sqrt(pow(localPosition.dx - offsetX, 2) +
            pow(localPosition.dy - offsetY, 2));

        if (distance < 15 && _highlightedDay != day) {
          setState(() {
            _highlightedDay = day;
            _highlightedStatus =
                Provider.of<DayStatusProvider>(context, listen: false)
                        .dayStatus[day] ??
                    'Normal day';
            _triggerVibration();
          });
          return;
        }
      }

      setState(() {
        _highlightedDay = -1;
        _highlightedStatus = '';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildLogPeriodButton() {
    return ElevatedButton.icon(
      onPressed: _logPeriod,
      icon: const Icon(Icons.edit, color: selectedColor),
      label: const Text('Log Period', style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: selectedColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
    );
  }

  Widget _buildCalendarDots() {
    DateTime now = DateTime.now();
    int daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    return GestureDetector(
      onPanUpdate: (details) {
        _updateHighlightedDay(details.globalPosition);
      },
      onTapDown: (details) {
        _updateHighlightedDay(details.globalPosition);
        _triggerVibration();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          double radius = constraints.maxWidth * 0.4;
          return SizedBox(
            key: _calendarKey,
            width: constraints.maxWidth,
            height: constraints.maxWidth,
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(daysInMonth, (index) {
                final day = index + 1;
                final angle = index * (2 * pi / daysInMonth);
                final offsetX = radius * cos(angle);
                final offsetY = radius * sin(angle);
                String status =
                    Provider.of<DayStatusProvider>(context, listen: false)
                            .dayStatus[day] ??
                        'Normal day';

                return Transform.translate(
                  offset: Offset(offsetX, offsetY),
                  child: _buildCalendarDot(day, _getDotColor(day), status),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarDot(int day, Color color, String status) {
    DateTime now = DateTime.now();
    bool isToday = now.day == day;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isToday ? 30 : 22,
              height: isToday ? 30 : 22,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: highlightColor, width: 2)
                    : null,
              ),
            ),
            Text(
              '$day',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        if (_showStatus) const SizedBox(height: 4),
        if (_showStatus)
          Text(
            status,
            style: const TextStyle(fontSize: 10, color: Colors.black),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildCalendarDots(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        _highlightedDay > 0
                            ? 'Day $_highlightedDay\n$_highlightedStatus'
                            : 'Today',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Log the period for better predictions.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      _buildLogPeriodButton(),
                      _buildToggleSwitch()
                    ],
                  ),
                ],
              ),
            ),
          ),
          _buildScrollableContent(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: SvgPicture.asset(
          'assets/svgs/imraatun.svg',
          height: 148,
          width: 148,
          fit: BoxFit.contain,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildToggleSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Show Status",
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: _showStatus,
            activeColor: selectedColor,
            onChanged: (value) {
              setState(() {
                _showStatus = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String assetPath,
    required EdgeInsets margin,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.25;

    return InkWell(
      onTap: () {
        print('$title card tapped');
      },
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: margin,
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(assetPath, width: 60, height: 60),
              const SizedBox(height: 5),
              Text(title,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFeatureCard(
            title: 'Secret Box',
            assetPath: 'assets/svgs/secret_box.svg',
            margin: const EdgeInsets.all(8),
          ),
          _buildFeatureCard(
            title: 'Prize Contest',
            assetPath: 'assets/svgs/prize.svg',
            margin: const EdgeInsets.all(8),
          ),
          _buildFeatureCard(
            title: 'School Days',
            assetPath: 'assets/svgs/school_days.svg',
            margin: const EdgeInsets.all(8),
          ),
          _buildFeatureCard(
            title: 'BMI',
            assetPath: 'assets/svgs/bmi.svg',
            margin: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: _buildBottomNavBarItems(),
      currentIndex: _selectedIndex,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      onTap: _onItemTapped,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavBarItems() {
    return [
      _buildBottomNavItem(Icons.track_changes, 'Today', 0),
      _buildBottomNavItem(Icons.calendar_today, 'Calendar', 1),
      const BottomNavigationBarItem(
        icon: SizedBox.shrink(),
        label: '',
      ),
      _buildBottomNavItem(Icons.favorite, 'Health', 3),
      _buildBottomNavItem(Icons.person, 'You', 4),
    ];
  }

  BottomNavigationBarItem _buildBottomNavItem(
      IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          icon,
          key: ValueKey<int>(_selectedIndex),
          color: _selectedIndex == index ? selectedColor : unselectedColor,
        ),
      ),
      label: label,
      tooltip: label,
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        _onItemTapped(2);
      },
      backgroundColor: selectedColor,
      elevation: 4,
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }

  // Dummy method to log period (use real authentication in production)
  void _logPeriod() {
    print('Log period button pressed');
  }
}

// Tracker, Calendar, and Profile Screens remain the same
class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker'),
        backgroundColor: Colors.pink,
      ),
      body: const Center(
        child: Text(
          'Tracker Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.pink,
      ),
      body: const Center(
        child: Text(
          'Calendar Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.pink,
      ),
      body: const Center(
        child: Text(
          'Profile Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
