import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:imraatun/providers/day_status_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:imraatun/pages/get_pregnant_screen.dart';
import 'package:imraatun/pages/home_screen.dart';
import 'package:imraatun/pages/track_pregnancy_screen.dart';
import 'package:imraatun/providers/mode_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged;

  const SettingsScreen({super.key, required this.onLanguageChanged});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAnimating = false;
  int _selectedGoalIndex = 0;
  Locale _selectedLocale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _getSelectedGoalIndex(AppMode currentMode) {
    switch (currentMode) {
      case AppMode.trackCycle:
        return 0;
      case AppMode.getPregnant:
        return 1;
      case AppMode.trackPregnancy:
        return 2;
      default:
        return 0;
    }
  }

  void _switchMode(int index) {
    setState(() {
      _selectedGoalIndex = index;
      _isAnimating = true;
    });

    _controller.forward(from: 0).then((_) {
      final modeProvider = Provider.of<ModeProvider>(context, listen: false);
      Widget targetScreen;

      switch (index) {
        case 0:
          modeProvider.updateMode(AppMode.trackCycle);
          targetScreen = HomeScreen(
            onLanguageChanged: widget.onLanguageChanged,
          );
          break;
        case 1:
          modeProvider.updateMode(AppMode.getPregnant);
          targetScreen = const GetPregnantScreen();
          break;
        case 2:
          modeProvider.updateMode(AppMode.trackPregnancy);
          targetScreen = const TrackPregnancyScreen();
          break;
        default:
          targetScreen = HomeScreen(
            onLanguageChanged: widget.onLanguageChanged,
          );
      }

      setState(() {
        _isAnimating = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      );
    });
  }

  void _onLanguageSelected(Locale locale) {
    setState(() {
      _selectedLocale = locale;
    });
    widget.onLanguageChanged(locale);
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Provider.of<DayStatusProvider>(context, listen: false).clearDayStatus();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  onLanguageChanged: widget.onLanguageChanged,
                )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() {}); // Refresh the UI to show the logout button
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = Provider.of<ModeProvider>(context).currentMode;
    _selectedGoalIndex = _getSelectedGoalIndex(currentMode);
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.settings ?? 'Settings',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGoalsSection(),
                const SizedBox(height: 24),
                _buildSettingsOption(
                    Icons.calendar_today,
                    AppLocalizations.of(context)?.cycleSettings ??
                        'Cycle Settings'),
                const SizedBox(height: 16),
                _buildSettingsOption(Icons.alarm,
                    AppLocalizations.of(context)?.reminders ?? 'Reminders'),
                const SizedBox(height: 24),
                _buildLanguageSelection(),
                const SizedBox(height: 24),
                user == null ? _buildLoginButton() : _buildLogoutButton(),
              ],
            ),
          ),
          if (_isAnimating) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return CustomButton(
      icon: Icons.login,
      label: AppLocalizations.of(context)?.login ?? 'Login with Google',
      onPressed: _signInWithGoogle,
      backgroundColor: const Color.fromARGB(255, 186, 68, 255),
    );
  }

  Widget _buildLogoutButton() {
    return CustomButton(
      icon: Icons.logout,
      label: AppLocalizations.of(context)?.logout ?? 'Logout',
      onPressed: logout,
      backgroundColor: const Color.fromARGB(255, 26, 25, 25),
    );
  }

  Widget _buildGoalsSection() {
    final List<String> goals = [
      AppLocalizations.of(context)?.trackCycle ?? 'Track Cycle',
      AppLocalizations.of(context)?.getPregnant ?? 'Get Pregnant',
      AppLocalizations.of(context)?.trackPregnancy ?? 'Track Pregnancy',
    ];

    return GoalsSection(
      goals: goals,
      selectedIndex: _selectedGoalIndex,
      onGoalSelected: _switchMode,
    );
  }

  Widget _buildSettingsOption(IconData icon, String title) {
    return CustomSettingsOption(
      icon: icon,
      title: title,
      onTap: () {
        // Handle navigation to respective settings screen
      },
    );
  }

  Widget _buildLanguageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.chooseLanguage ?? 'Choose Language',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 218, 0, 238),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildFlagButton('assets/svgs/united-states-svgrepo-com.svg',
                'English', const Locale('en')),
            const SizedBox(width: 20),
            _buildFlagButton('assets/svgs/algeria-algeria-svgrepo-com.svg',
                'العربية', const Locale('ar')),
          ],
        ),
      ],
    );
  }

  Widget _buildFlagButton(
      String assetPath, String languageName, Locale locale) {
    final bool isSelected = _selectedLocale == locale;

    return GestureDetector(
      onTap: () => _onLanguageSelected(locale),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: const Color.fromARGB(255, 218, 0, 238),
                      width: 3,
                    )
                  : null,
            ),
            child: SvgPicture.asset(assetPath, width: 50, height: 50),
          ),
          const SizedBox(height: 8),
          Text(
            languageName,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? const Color.fromARGB(255, 218, 0, 238)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: _controller.duration!,
        builder: (context, value, child) {
          int percentage = (value * 100).toInt();
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 6.0,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 238, 0, 206)),
              ),
              const SizedBox(height: 16),
              Text(
                "$percentage%",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const CustomButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSettingsOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const CustomSettingsOption({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class GoalsSection extends StatelessWidget {
  final List<String> goals;
  final int selectedIndex;
  final Function(int) onGoalSelected;

  const GoalsSection({
    Key? key,
    required this.goals,
    required this.selectedIndex,
    required this.onGoalSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(goals.length, (index) {
            final bool isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onGoalSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color.fromARGB(255, 218, 0, 238)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  goals[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
