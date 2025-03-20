import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      primaryColor:
          Colors
              .blueGrey[800], // This sets the primary color used in various widgets
      colorScheme: base.colorScheme.copyWith(
        primary: Colors.blueGrey[800], // Primary color used by Material widgets
        secondary:
            Colors.tealAccent[700], // Secondary color used by Material widgets
        surface: Colors.grey[850], // Surface color for cards, sheets, etc.
        background:
            Colors.grey[800], // Lighter background color for Scaffold, etc.
        onSurface: Colors.white, // Text/icon color on top of surface colors
        onPrimary: Colors.white, // Text/icon color on top of primary colors
        onSecondary: Colors.black, // Text/icon color on top of secondary colors
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900], // Color of the AppBar
        foregroundColor: Colors.white, // Color of items on the AppBar
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blueGrey[700], // Default button color
        textTheme:
            ButtonTextTheme.primary, // Use the primary color for button text
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.tealAccent[700], // Color for text buttons
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Default light theme
      darkTheme: customDarkTheme(), // Use the custom dark theme
      themeMode:
          _isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light, // Toggle based on the state
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_usernameController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  setState(() {
                    isLoggedIn = true;
                  });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[],
        ),
      ),
      backgroundColor:
          Theme.of(context).colorScheme.background, // Set the background color
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Icon(FontAwesomeIcons.parking, color: Colors.white),
              const Icon(FontAwesomeIcons.car, color: Colors.white),
              const Icon(FontAwesomeIcons.mapMarkerAlt, color: Colors.white),
              PopupMenuButton<String>(
                icon: const Icon(FontAwesomeIcons.user, color: Colors.white),
                offset:
                    isLoggedIn ? const Offset(80, -160) : const Offset(50, -70),
                onSelected: (String result) {
                  if (result == 'Login') {
                    _showLoginDialog();
                  } else if (result == 'Logout') {
                    setState(() {
                      isLoggedIn = false;
                    });
                  } else if (result == 'isDarkMode') {
                    widget.toggleTheme(!widget.isDarkMode);
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
      ),
    );
  }
}
