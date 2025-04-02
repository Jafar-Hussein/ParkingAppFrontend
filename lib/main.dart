import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'MapScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false; // State to track theme mode

  void toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  ThemeData customDarkTheme() {
    // Start with the default dark theme.
    ThemeData base = ThemeData.dark();

    // Use copyWith to modify only specific aspects of the theme.
    return base.copyWith(
      primaryColor: Colors.blueGrey[800],
      colorScheme: base.colorScheme.copyWith(
        primary: Colors.blueGrey[800],
        secondary: Colors.tealAccent[700],
        surface: Colors.grey[850],
        background: Colors.grey[800],
        onSurface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blueGrey[700],
        textTheme: ButtonTextTheme.primary,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.tealAccent[700]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Default light theme
      darkTheme: customDarkTheme(), // Custom dark theme
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MyHomePage(
        title: 'Parking App',
        toggleTheme: toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  const MyHomePage({
    super.key,
    required this.title,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: MapScreen(), // Embed the MapScreen directly
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Icon(FontAwesomeIcons.parking, color: Colors.white),
            Icon(FontAwesomeIcons.car, color: Colors.white),
            Icon(FontAwesomeIcons.mapMarkerAlt, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
