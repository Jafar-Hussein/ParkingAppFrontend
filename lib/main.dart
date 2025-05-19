import 'package:flutter/material.dart';
import 'package:flutter_application/bloc/vehicle/vehicle_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import './bloc/authentication/auth_bloc.dart';
import './bloc/authentication/auth_event.dart';
import './bloc/authentication/auth_state.dart';
import './repository/AuthRepository.dart';
import './bloc/vehicle/vehicle_bloc.dart';
import './repository/vehicleRepository.dart';

import 'MapScreen.dart';
import './pages/ParkingPage.dart';
import './pages/ParkingSpacePage.dart';
import './pages/VehiclePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    BlocProvider(
      create: (context) => AuthBloc(AuthRepository()),
      child: const MyApp(),
    ),
  );
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
  String? loggedInUser;
  String? loggedInUserUid;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showLoginDialog({required bool isRegister}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isRegister ? 'Registrera' : 'Logga in'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Användarnamn',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Personnummer',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                final namn = _usernameController.text.trim();
                final pnr = _passwordController.text.trim();

                if (namn.isNotEmpty && pnr.isNotEmpty) {
                  if (isRegister) {
                    context.read<AuthBloc>().add(RegisterEvent(namn, pnr));
                  } else {
                    context.read<AuthBloc>().add(LoginEvent(namn, pnr));
                  }
                }
              },
              child: Text(isRegister ? 'Registrera' : 'Logga in'),
            ),
          ],
        );
      },
    );
  }

  void navigateToPage(String page) {
    if (!isLoggedIn || loggedInUser == null || loggedInUserUid == null) {
      _showLoginDialog(isRegister: false);
      return;
    }

    late Widget nextPage;

    switch (page) {
      case 'Parking':
        nextPage = ParkingPage(
          isDarkMode: widget.isDarkMode,
          toggleTheme: widget.toggleTheme,
          ownerName: loggedInUser!,
          ownerUid: loggedInUserUid!,
        );
        break;
      case 'Vehicle':
        nextPage = BlocProvider(
          create:
              (_) =>
                  VehicleBloc(VehicleRepository())
                    ..add(LoadVehiclesEvent(loggedInUserUid!)),
          child: VehiclePage(
            isDarkMode: widget.isDarkMode,
            toggleTheme: widget.toggleTheme,
            ownerName: loggedInUser!,
            ownerUid: loggedInUserUid!,
          ),
        );
        break;
      case 'ParkingSpace':
        nextPage = ParkingSpacePage(
          isDarkMode: widget.isDarkMode,
          toggleTheme: widget.toggleTheme,
          ownerName: loggedInUser!,
          ownerUid: loggedInUserUid!,
        );
        break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => nextPage));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          setState(() {
            isLoggedIn = true;
            loggedInUser = state.person['namn'];
            loggedInUserUid = state.person['uid'];
          });
          Navigator.of(context).pop();
        } else if (state is AuthErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: Column(children: [Expanded(child: MapScreen())]),
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
                    isLoggedIn
                        ? const Offset(80, -120)
                        : const Offset(50, -110),
                onSelected: (String result) {
                  switch (result) {
                    case 'Login':
                      _showLoginDialog(isRegister: false);
                      break;
                    case 'Register':
                      _showLoginDialog(isRegister: true);
                      break;
                    case 'Logout':
                      setState(() {
                        isLoggedIn = false;
                        loggedInUser = null;
                        loggedInUserUid = null;
                        _usernameController.clear();
                        _passwordController.clear();
                      });
                      break;
                    case 'isDarkMode':
                      widget.toggleTheme(!widget.isDarkMode);
                      break;
                  }
                },
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      if (!isLoggedIn) ...[
                        const PopupMenuItem<String>(
                          value: 'Login',
                          child: Text('Logga in'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Register',
                          child: Text('Registrera'),
                        ),
                      ],
                      if (isLoggedIn) ...[
                        const PopupMenuItem<String>(
                          value: 'isDarkMode',
                          child: Text('Byt tema'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Logout',
                          child: Text('Logga ut'),
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
