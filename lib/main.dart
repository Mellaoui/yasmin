import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imraatun/firebase_options.dart';
import 'package:imraatun/l10n/l10n.dart';
import 'package:imraatun/pages/spalsh_screen.dart';
import 'package:imraatun/providers/mode_provider.dart';
import 'package:imraatun/providers/day_status_provider.dart'
    as providers; // Import your DayStatusProvider with a prefix
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ModeProvider()),
        ChangeNotifierProvider(
            create: (context) => providers.DayStatusProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ar'); // Default to English

  // Function to change language
  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

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
      locale: _locale, // Use the selected locale
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
      home: SplashScreen(
        onLanguageChanged:
            _changeLanguage, // Pass language change function to SplashScreen
      ),
    );
  }
}
