import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'MapScreen.dart';
import './pages/ParkingPage.dart';
import './pages/ParkingSpacePage.dart';
import './pages/VehiclePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  ThemeData customDarkTheme() {
    ThemeData base = ThemeData.dark();
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
      theme: ThemeData.light(),
      darkTheme: customDarkTheme(),
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
  bool isLoggedIn = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? loggedInUser;
  int? loggedInUserId;

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (_usernameController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty) {
                  final res = await http.get(
                    Uri.parse(
                      'http://10.0.2.2:8081/persons/namn/${_usernameController.text}',
                    ),
                  );

                  if (res.statusCode == 200) {
                    final person = jsonDecode(res.body);
                    setState(() {
                      isLoggedIn = true;
                      loggedInUser = person['namn'];
                      loggedInUserId = person['id'];
                    });
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Användare hittades inte.")),
                    );
                  }
                } else {
                  print("Please enter both username and password.");
                }
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  void navigateToPage(String page) {
    if (!isLoggedIn || loggedInUser == null) {
      _showLoginDialog();
      return;
    }

    Widget nextPage;

    switch (page) {
      case 'Parking':
        nextPage = ParkingPage(
          isDarkMode: widget.isDarkMode,
          toggleTheme: widget.toggleTheme,
        );
        break;
      case 'Vehicle':
        nextPage = VehiclePage(
          isDarkMode: widget.isDarkMode,
          toggleTheme: widget.toggleTheme,
          ownerName: loggedInUser!,
        );
        break;
      case 'ParkingSpace':
        nextPage = ParkingSpacePage(
          isDarkMode: widget.isDarkMode,
          toggleTheme: widget.toggleTheme,
        );
        break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => nextPage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [Expanded(flex: 1, child: MapScreen())]),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(FontAwesomeIcons.parking, color: Colors.white),
              onPressed: () => navigateToPage('Parking'),
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.car, color: Colors.white),
              onPressed: () => navigateToPage('Vehicle'),
            ),
            IconButton(
              icon: const Icon(
                FontAwesomeIcons.mapMarkerAlt,
                color: Colors.white,
              ),
              onPressed: () => navigateToPage('ParkingSpace'),
            ),
            PopupMenuButton<String>(
              icon: const Icon(FontAwesomeIcons.user, color: Colors.white),
              offset:
                  isLoggedIn ? const Offset(80, -160) : const Offset(50, -70),
              onSelected: (String result) {
                switch (result) {
                  case 'Login':
                    _showLoginDialog();
                    break;
                  case 'Logout':
                    setState(() => isLoggedIn = false);
                    break;
                  case 'isDarkMode':
                    widget.toggleTheme(!widget.isDarkMode);
                    break;
                }
              },
              itemBuilder:
                  (BuildContext context) => <PopupMenuEntry<String>>[
                    if (!isLoggedIn)
                      const PopupMenuItem<String>(
                        value: 'Login',
                        child: Text('Login'),
                      ),
                    if (isLoggedIn) ...[
                      const PopupMenuItem<String>(
                        value: 'Profile',
                        child: Text('Profile'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'isDarkMode',
                        child: Text('Toggle Dark Mode'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Logout',
                        child: Text('Logout'),
                      ),
                    ],
                  ],
            ),
          ],
        ),
      ),
    );
  }
}
