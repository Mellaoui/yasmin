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
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyC2hevZLEl7a61irWuotrmD-Y0ipCf91OM',
    appId: '1:772703011244:web:776eb9ef89dc5572617a09',
    messagingSenderId: '772703011244',
    projectId: 'yasmin-test',
    authDomain: 'yasmin-test.firebaseapp.com',
    storageBucket: 'yasmin-test.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCtTbMKuRje2faX_NgRQk7wbzOBkpwNPNs',
    appId: '1:772703011244:android:8329e0af7f664263617a09',
    messagingSenderId: '772703011244',
    projectId: 'yasmin-test',
    storageBucket: 'yasmin-test.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC3W2XttVDKMSYcgS62FugSuKm61K3EyDw',
    appId: '1:772703011244:ios:253c55eedbbac9ee617a09',
    messagingSenderId: '772703011244',
    projectId: 'yasmin-test',
    storageBucket: 'yasmin-test.appspot.com',
    iosBundleId: 'com.example.imraatun',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC3W2XttVDKMSYcgS62FugSuKm61K3EyDw',
    appId: '1:772703011244:ios:253c55eedbbac9ee617a09',
    messagingSenderId: '772703011244',
    projectId: 'yasmin-test',
    storageBucket: 'yasmin-test.appspot.com',
    iosBundleId: 'com.example.imraatun',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC2hevZLEl7a61irWuotrmD-Y0ipCf91OM',
    appId: '1:772703011244:web:06227027406afe41617a09',
    messagingSenderId: '772703011244',
    projectId: 'yasmin-test',
    authDomain: 'yasmin-test.firebaseapp.com',
    storageBucket: 'yasmin-test.appspot.com',
  );
}