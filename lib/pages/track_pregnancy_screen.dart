import 'package:flutter/material.dart';

class TrackPregnancyScreen extends StatelessWidget {
  const TrackPregnancyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Pregnancy'),
        backgroundColor:
            const Color.fromARGB(255, 249, 234, 250), // Custom purple
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _showStartModal(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color.fromARGB(255, 218, 0, 238), // Custom purple
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Start',
              style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }

  // Function to show the modal bottom sheet
  void _showStartModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('coming soon!'),
        );
      },
    );
  }
}
