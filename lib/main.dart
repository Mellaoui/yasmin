import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imraatun/pages/home_screen.dart';
import 'package:imraatun/providers/mode_provider.dart';
import 'package:imraatun/providers/day_status_provider.dart'
    as providers; // Import your DayStatusProvider with a prefix
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ModeProvider()),
        ChangeNotifierProvider(
            create: (context) => providers
                .DayStatusProvider()), // Add DayStatusProvider with prefix
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set the system UI overlay style for a light AppBar (white theme)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness:
          Brightness.dark, // Dark icons for light status bar background
      statusBarBrightness: Brightness.light, // Light status bar for iOS
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Period Tracker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Set AppBar to white color
          iconTheme:
              IconThemeData(color: Colors.black), // Dark icons for AppBar
          titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold), // Dark text for AppBar title
          systemOverlayStyle: SystemUiOverlayStyle
              .dark, // Dark status bar icons for light AppBar
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
