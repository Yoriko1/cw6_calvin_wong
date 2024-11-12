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
    apiKey: 'AIzaSyAypnI_0cB9JR3EtnThJviYicwiX1E55pg',
    appId: '1:458441741771:web:85520643c02c577700524e',
    messagingSenderId: '458441741771',
    projectId: 'cw6-calvin-wong',
    authDomain: 'cw6-calvin-wong.firebaseapp.com',
    databaseURL: 'https://cw6-calvin-wong-default-rtdb.firebaseio.com',
    storageBucket: 'cw6-calvin-wong.firebasestorage.app',
    measurementId: 'G-B9DKZPGCX6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDH-1QHRbx3jHbU9JIRtfX9WBYpbk5-lxs',
    appId: '1:458441741771:android:a4519c8ba315a04000524e',
    messagingSenderId: '458441741771',
    projectId: 'cw6-calvin-wong',
    databaseURL: 'https://cw6-calvin-wong-default-rtdb.firebaseio.com',
    storageBucket: 'cw6-calvin-wong.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAypnI_0cB9JR3EtnThJviYicwiX1E55pg',
    appId: '1:458441741771:web:03d813583fbc354600524e',
    messagingSenderId: '458441741771',
    projectId: 'cw6-calvin-wong',
    authDomain: 'cw6-calvin-wong.firebaseapp.com',
    databaseURL: 'https://cw6-calvin-wong-default-rtdb.firebaseio.com',
    storageBucket: 'cw6-calvin-wong.firebasestorage.app',
    measurementId: 'G-8SRTXPPB9V',
  );
}
