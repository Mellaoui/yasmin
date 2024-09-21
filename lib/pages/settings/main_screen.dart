import 'package:flutter/material.dart';
import 'package:imraatun/providers/mode_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAnimating = false;
  int _selectedGoalIndex = 0;

  final List<String> _goals = [
    'Track Cycle',
    'Get Pregnant',
    'Track Pregnancy',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Duration for the loading
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
    // Immediate UI update to reflect button change
    setState(() {
      _selectedGoalIndex = index;
      _isAnimating = true;
    });

    // Start the animation for loading percentage
    _controller.forward(from: 0).then((_) {
      setState(() {
        final modeProvider = Provider.of<ModeProvider>(context, listen: false);
        if (index == 0) {
          modeProvider.updateMode(AppMode.trackCycle);
        } else if (index == 1) {
          modeProvider.updateMode(AppMode.getPregnant);
        } else if (index == 2) {
          modeProvider.updateMode(AppMode.trackPregnancy);
        }
        _isAnimating = false;
        Navigator.of(context).pop(); // Close the settings screen
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current mode from the provider
    final currentMode = Provider.of<ModeProvider>(context).currentMode;
    _selectedGoalIndex = _getSelectedGoalIndex(currentMode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildGoalsSection(),
                const SizedBox(height: 30),
                _buildModeContent(), // Content for the selected mode
              ],
            ),
          ),
          if (_isAnimating) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Goal',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Select the goal you want to focus on:',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsSection() {
    return SizedBox(
      height: 52, // Increase height for better touch targets
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _goals.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bool isSelected = _selectedGoalIndex == index;
          return GestureDetector(
            onTap: () {
              _switchMode(index); // Switch mode when a goal is selected
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300), // Shortened duration
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 24), // Increased padding
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF4081) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF4081)
                      : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: const Color(0xFFFF4081).withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  _goals[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _getModeContentWidget(),
    );
  }

  Widget _getModeContentWidget() {
    switch (_selectedGoalIndex) {
      case 0:
        return _buildTrackCycleContent();
      case 1:
        return _buildGetPregnantContent();
      case 2:
        return _buildTrackPregnancyContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTrackCycleContent() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Track Cycle Mode Content',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildGetPregnantContent() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Get Pregnant Mode Content',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildTrackPregnancyContent() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Track Pregnancy Mode Content',
        style: TextStyle(fontSize: 18),
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
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFFF4081)),
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
