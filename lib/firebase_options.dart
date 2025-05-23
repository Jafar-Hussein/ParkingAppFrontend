// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCQycoS76ktLficbZAF4prCcNDuNDnnB10',
    appId: '1:915002194184:web:e6587db43e14aecfbf54bd',
    messagingSenderId: '915002194184',
    projectId: 'parkingapp-d0b87',
    authDomain: 'parkingapp-d0b87.firebaseapp.com',
    storageBucket: 'parkingapp-d0b87.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZi_w6fyo-0DTUc73AtpdYnGBRzn-6bBQ',
    appId: '1:915002194184:android:c69fb50665f4ab0bbf54bd',
    messagingSenderId: '915002194184',
    projectId: 'parkingapp-d0b87',
    storageBucket: 'parkingapp-d0b87.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCQycoS76ktLficbZAF4prCcNDuNDnnB10',
    appId: '1:915002194184:web:6f8f0807412984dabf54bd',
    messagingSenderId: '915002194184',
    projectId: 'parkingapp-d0b87',
    authDomain: 'parkingapp-d0b87.firebaseapp.com',
    storageBucket: 'parkingapp-d0b87.firebasestorage.app',
  );

}