import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imraatun/pages/bmi_screen.dart';
import 'package:imraatun/pages/components/calendar_dots.dart';
import 'package:imraatun/pages/components/symptom_tracker.dart';
import 'package:imraatun/pages/game/game_screen.dart';
import 'package:imraatun/pages/game/tick_tack_screen.dart';
import 'package:imraatun/pages/health_screen.dart';
import 'package:imraatun/pages/log_period_screen.dart';
import 'package:imraatun/pages//profile_screen.dart';
import 'package:imraatun/pages/prices_screen.dart';
import 'package:imraatun/pages/settings/main_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:imraatun/providers/day_status_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  final Function(Locale)
      onLanguageChanged; // Add a callback for language change

  const HomeScreen({super.key, required this.onLanguageChanged});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedIndex = 0;
  int _highlightedDay = -1;
  String _highlightedStatus = '';
  DateTime _selectedDate = DateTime.now();

  List<Color> _gradientColors = [
    const Color.fromARGB(255, 246, 221, 248),
    const Color.fromARGB(255, 255, 255, 255)
  ];

  // final GlobalKey _calendarKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This ensures that _initializeDayStatus() runs whenever the screen is re-inserted into the widget tree.
    _initializeDayStatus();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCustomDialog();
      });
    });
  }

  Future<void> _initializeDayStatus() async {
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
        final bool isFinalized = periodData['isFinalized'] ?? false;

        if (!isFinalized) {
          final DateTime? startDate =
              (periodData['startDate'] as Timestamp?)?.toDate();
          final int periodLength = periodData['periodLength'] ?? 5;

          if (startDate != null) {
            final periodCycle =
                PeriodCycle(cycleLength: 28, periodLength: periodLength);
            final cycleStatus = periodCycle.calculateCycle(context, startDate);

            Provider.of<DayStatusProvider>(context, listen: false)
                .initializeDayStatus(cycleStatus);

            print("Day status initialized successfully.");
          } else {
            print("No valid startDate found in the latest period document.");
          }
        } else {
          print("Period is finalized. Dots will not be highlighted.");
          Provider.of<DayStatusProvider>(context, listen: false)
              .initializeDayStatus({}); // Clear any existing status
        }
      } else {
        print("No period data found for the user.");
      }
    } catch (e) {
      print("Failed to fetch or process the latest period log: $e");
    }
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

  // String _getLocalizedStatus(BuildContext context, String status) {
  //   switch (status) {
  //     case 'period':
  //       return AppLocalizations.of(context)?.period ?? 'Period';
  //     case 'ovulation':
  //       return AppLocalizations.of(context)?.ovulation ?? 'Ovulation';
  //     case 'high_chance':
  //       return AppLocalizations.of(context)?.highChanceOfConception ??
  //           'High chance of conception';
  //     case 'pre_period':
  //       return AppLocalizations.of(context)?.prePeriod ?? 'Pre-period';
  //     default:
  //       return AppLocalizations.of(context)?.normalDay ?? 'Normal day';
  //   }
  // }

  // Callback to update the state when a day is selected
  void _onSelectedDate(int day, String status) {
    setState(() {
      _highlightedDay = day;
      _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, day);

      // Localize the status based on the string passed
      String localizedStatus = _getLocalizedStatus(context, status);

      // Set the localized status and update the UI
      _highlightedStatus = localizedStatus;

      // Update the gradient colors based on the localized status
      _gradientColors = _getGradientColorsForStatus(context, localizedStatus);
    });
  }

  String _getLocalizedStatus(BuildContext context, String status) {
    // Compare against the actual translated values from AppLocalizations
    if (status == (AppLocalizations.of(context)?.period ?? 'Period')) {
      return AppLocalizations.of(context)?.period ?? 'Period';
    } else if (status ==
        (AppLocalizations.of(context)?.ovulation ?? 'Ovulation')) {
      return AppLocalizations.of(context)?.ovulation ?? 'Ovulation';
    } else if (status ==
        (AppLocalizations.of(context)?.highChanceOfConception ??
            'High chance')) {
      return AppLocalizations.of(context)?.highChanceOfConception ??
          'High chance of conception';
    } else if (status ==
        (AppLocalizations.of(context)?.prePeriod ?? 'Pre-period')) {
      return AppLocalizations.of(context)?.prePeriod ?? 'Pre-period';
    } else {
      return AppLocalizations.of(context)?.normalDay ?? 'Normal day';
    }
  }

  List<Color> _getGradientColorsForStatus(BuildContext context, String status) {
    final localizations =
        AppLocalizations.of(context); // Fetch localization instance

    if (status == localizations?.period) {
      return [
        const Color.fromARGB(255, 248, 51, 238),
        const Color.fromARGB(146, 255, 253, 255),
      ];
    } else if (status == localizations?.ovulation) {
      return [
        const Color.fromARGB(255, 130, 245, 22),
        const Color.fromARGB(255, 244, 245, 244),
      ];
    } else if (status == localizations?.highChanceOfConception) {
      return [
        const Color.fromARGB(255, 241, 219, 21),
        const Color.fromARGB(255, 241, 239, 215),
      ];
    } else if (status == localizations?.prePeriod) {
      return [
        const Color.fromARGB(255, 160, 210, 250),
        const Color.fromARGB(255, 248, 248, 248),
      ];
    } else {
      return [
        Colors.pink.withOpacity(0.2),
        const Color.fromARGB(255, 248, 245, 246).withOpacity(0.4),
      ];
    }
  }

  Widget _buildCircularIndicator() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildDialogDot(const Color(0xFFFF4081), const Offset(40, 0)),
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
        HapticFeedback.lightImpact();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF4081),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          AppLocalizations.of(context)?.start ?? 'NEXT', // Localized 'NEXT'
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        _buildLegendItem(AppLocalizations.of(context)?.period ?? 'The Period',
            const Color(0xFFFF4081)),
        _buildLegendItem(AppLocalizations.of(context)?.ovulation ?? 'Ovulation',
            const Color(0xFF4CAF50)),
        _buildLegendItem(
            AppLocalizations.of(context)?.highChanceOfConception ??
                'High chance of conception',
            const Color(0xFFFFEB3B)),
        _buildLegendItem(
            AppLocalizations.of(context)?.prePeriod ?? 'Pre-period',
            const Color(0xFF2196F3)),
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

  // Widget _buildCalendarDots() {
  //   return CalendarDots(
  //     onSelectedDate: _onSelectedDate,
  //   );
  // }

  // Handle navigation on bottom nav bar tap
  void _onItemTapped(int index) {
    if (index == 4) {
      // 'You' Profile screen index
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const ProfileScreen(), // Navigate to ProfileScreen
        ),
      );
    }
    if (index == 3) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const HealthScreen()));
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LogPeriodScreen(),
        ),
      );
      print(index);
    }
  }

  // New method for showing the modal to track symptoms

  Future<void> _logSymptomsForDay(
      DateTime date, List<String> selectedSymptoms) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final symptomData = {
        'date': Timestamp.fromDate(date),
        'symptoms': selectedSymptoms,
        'loggedAt': Timestamp.now(),
      };

      await userRef
          .collection('symptoms')
          .doc(DateFormat('yyyy-MM-dd').format(date))
          .set(symptomData, SetOptions(merge: true));

      print("Symptoms logged successfully for $date");
    } catch (e) {
      print("Failed to log symptoms: $e");
    }
  }

  void _showSymptomModal(BuildContext context, DateTime selectedDate) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User is not logged in, show the login modal
      _showLoginModal(context);
    } else {
      // User is logged in, show the SymptomTracker modal
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return SymptomTracker(
            onSave: (selectedSymptoms) async {
              try {
                // Check for null before logging
                await _logSymptomsForDay(selectedDate, selectedSymptoms);

                // Delay Navigator.pop slightly
                Future.delayed(const Duration(milliseconds: 10), () {
                  Navigator.pop(context);
                });
              } catch (e) {
                print("Error in onSave: $e");
              }
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CalendarDots(onSelectedDate: _onSelectedDate),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          _highlightedDay > 0
                              ? '${AppLocalizations.of(context)?.today ?? 'Day'} $_highlightedDay\n$_highlightedStatus'
                              : AppLocalizations.of(context)?.today ?? 'Today',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        _buildLogPeriodButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildScrollableContent(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showSymptomModal(context, _selectedDate);
        },
        backgroundColor: const Color.fromARGB(255, 25, 25, 26),
        child: const Icon(Icons.mood, color: Colors.white),
      ),
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
          'assets/svgs/yasminsvg.svg',
          height: 148,
          width: 148,
          fit: BoxFit.contain,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings,
              color: Color.fromARGB(255, 15, 15, 15)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  onLanguageChanged: widget.onLanguageChanged, // Pass callback
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogPeriodButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        HapticFeedback.lightImpact();

        if (await isUserLoggedIn()) {
          // User is logged in, navigate to LogPeriodScreen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LogPeriodScreen(),
            ),
          );

          if (result != null) {
            final DateTime? startDate = result['startDate'];
            final int? periodLength = result['periodLength'];

            if (startDate != null && periodLength != null) {
              _updateDayStatusWithNewPeriod(startDate, periodLength);
            }
          }
        } else {
          // User is not logged in, show the login modal
          _showLoginModal(context);
        }
      },
      icon: const Icon(Icons.accessibility,
          color: Color.fromARGB(255, 218, 0, 238)),
      label: Text(AppLocalizations.of(context)?.logPeriod ?? 'Log Period',
          style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color.fromARGB(255, 218, 0, 238)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      ),
    );
  }

  Future<bool> isUserLoggedIn() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    // Check if the user is not null, which indicates they are logged in
    return user != null;
  }

  void _showLoginModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: FractionallySizedBox(
            heightFactor: 0.35,
            widthFactor: 1.0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 218, 0, 238),
                    Color.fromARGB(255, 251, 229, 255)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 24, 24, 24),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${AppLocalizations.of(context)?.login_required}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 12, 12, 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Close the modal before initiating the login
                      Navigator.pop(context);
                      _loginWithGoogle();
                    },
                    icon: _isLoggingIn
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.login, color: Colors.white),
                    label: Text(
                      _isLoggingIn ? 'Logging in...' : 'Login with Google',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 19, 19, 19),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isLoggingIn = false;

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoggingIn = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          _isLoggingIn = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _initializeDayStatus();
        Provider.of<DayStatusProvider>(context, listen: false)
            .notifyListeners();
        // Navigator.pop(context);
      }
    } catch (error) {
      setState(() {
        _isLoggingIn = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  void _updateDayStatusWithNewPeriod(DateTime startDate, int periodLength) {
    final periodCycle =
        PeriodCycle(cycleLength: 28, periodLength: periodLength);
    final cycleStatus = periodCycle.calculateCycle(context, startDate);
    Provider.of<DayStatusProvider>(context, listen: false)
        .initializeDayStatus(cycleStatus);

    setState(() {
      _highlightedDay = -1;
      _highlightedStatus = '';
    });
  }

  Widget _buildScrollableContent() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFeatureCard(
            title: AppLocalizations.of(context)?.secretBox ?? 'Secret Box',
            assetPath: 'assets/svgs/secret_box.svg',
            margin: const EdgeInsets.all(8),
            onTap: () {
              // Navigate to a game screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const GameScreen(), // Replace with your game screen
                ),
              );
            },
          ),
          _buildFeatureCard(
            title:
                AppLocalizations.of(context)?.prizeContest ?? 'Prize Contest',
            assetPath: 'assets/svgs/prize.svg',
            margin: const EdgeInsets.all(8),
            onTap: () {
              // Navigate to a game screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ContestsAndPrizesScreen(), // Replace with your game screen
                ),
              );
            },
          ),
          _buildFeatureCard(
            title: AppLocalizations.of(context)?.title_tic_tac ?? 'Tic Tac Toe',
            assetPath: 'assets/svgs/tic-tac.svg',
            margin: const EdgeInsets.all(8),
            onTap: () {
              // Handle school days action
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const TicTacToeScreen(), // Replace with your game screen
                ),
              );
              print("School Days clicked");
            },
          ),
          _buildFeatureCard(
            title: AppLocalizations.of(context)?.bmi ?? 'BMI',
            assetPath: 'assets/svgs/bmi.svg',
            margin: const EdgeInsets.all(8),
            onTap: () {
              // Navigate to BMI screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const BMIScreen(), // Replace with your BMI screen
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String assetPath,
    required EdgeInsets margin,
    required VoidCallback onTap,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.25;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: margin,
        width: cardWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.2), // Light border for effect
          ),
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 8, 7, 7).withOpacity(0.2),
              const Color.fromARGB(255, 10, 10, 10).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(assetPath, width: 60, height: 60),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(
                          255, 65, 64, 64), // White text for contrast
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: _buildBottomNavBarItems(),
      currentIndex: _selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 17, 17, 17),
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      elevation: 20,
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavBarItems() {
    return [
      _buildBottomNavItem(Icons.track_changes,
          AppLocalizations.of(context)?.today ?? 'Today', 0),
      _buildBottomNavItem(Icons.calendar_today,
          AppLocalizations.of(context)?.calendar ?? 'Calendar', 1),
      const BottomNavigationBarItem(
        icon: SizedBox.shrink(),
        label: '',
      ),
      _buildBottomNavItem(
          Icons.favorite, AppLocalizations.of(context)?.health ?? 'Health', 3),
      _buildBottomNavItem(
          Icons.person, AppLocalizations.of(context)?.you ?? 'You', 4),
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
          color: _selectedIndex == index
              ? const Color.fromARGB(255, 218, 0, 238)
              : Colors.grey,
        ),
      ),
      label: label,
      tooltip: label,
    );
  }
}

// Define your PeriodCycle class and DayStatusProvider class separately.

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

  // Pass BuildContext to access localized strings
  Map<DateTime, String> calculateCycle(
      BuildContext context, DateTime startDate) {
    Map<DateTime, String> cycleMap = {};
    List<DateTime> periodDays = calculatePeriodDays(startDate);
    List<DateTime> highConceptionDays = calculateHighConceptionDays(startDate);
    List<DateTime> prePeriodDays = calculatePrePeriodDays(startDate);
    DateTime ovulationDay = calculateOvulationDay(startDate);

    // Use AppLocalizations to get translated status strings
    for (var day in periodDays) {
      cycleMap[day] = AppLocalizations.of(context)?.period ?? 'Period';
    }

    for (var day in highConceptionDays) {
      cycleMap[day] = AppLocalizations.of(context)?.highChanceOfConception ??
          'High chance of conception';
    }

    for (var day in prePeriodDays) {
      cycleMap[day] = AppLocalizations.of(context)?.prePeriod ?? 'Pre-period';
    }

    cycleMap[ovulationDay] =
        AppLocalizations.of(context)?.ovulation ?? 'Ovulation';

    return cycleMap;
  }
}
