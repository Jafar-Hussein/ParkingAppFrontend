import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'MapScreen.dart'; // Ensure this import is correct for your directory structure
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
  bool isLoggedIn = false; // Define isLoggedIn here
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

  void navigateToPage(String page) {
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
            IconButton(
              icon: Icon(FontAwesomeIcons.parking, color: Colors.white),
              onPressed: () => navigateToPage('Parking'),
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.car, color: Colors.white),
              onPressed: () => navigateToPage('Vehicle'),
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.mapMarkerAlt, color: Colors.white),
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
