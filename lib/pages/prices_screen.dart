import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContestsAndPrizesScreen extends StatelessWidget {
  const ContestsAndPrizesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppLocalizations.of(context)?.prizeContest} '),
        centerTitle: true,
      ),
      body: Center(
        child: Lottie.asset(
          'assets/animations/empty.json', // Replace with your Lottie file path
          width: 300,
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
