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
    apiKey: 'AIzaSyA1Knh5hEMNMNXCg7PjQnO9v7EEbyEqogE',
    appId: '1:303650839386:web:d73dc34251aa8905d5f163',
    messagingSenderId: '303650839386',
    projectId: 'multigameapp-c84fc',
    authDomain: 'multigameapp-c84fc.firebaseapp.com',
    storageBucket: 'multigameapp-c84fc.firebasestorage.app',
    measurementId: 'G-4TRV88Y4QR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC2cabBhzffluJRa0eYsbor1ONBOFStHpE',
    appId: '1:303650839386:android:4890fe30cdc31a2ad5f163',
    messagingSenderId: '303650839386',
    projectId: 'multigameapp-c84fc',
    storageBucket: 'multigameapp-c84fc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCoP1njUyGmlKu1UG1Ld71TCHKrPCsTHUo',
    appId: '1:303650839386:ios:d24bb2e2e0d35fa9d5f163',
    messagingSenderId: '303650839386',
    projectId: 'multigameapp-c84fc',
    storageBucket: 'multigameapp-c84fc.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCoP1njUyGmlKu1UG1Ld71TCHKrPCsTHUo',
    appId: '1:303650839386:ios:d24bb2e2e0d35fa9d5f163',
    messagingSenderId: '303650839386',
    projectId: 'multigameapp-c84fc',
    storageBucket: 'multigameapp-c84fc.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA1Knh5hEMNMNXCg7PjQnO9v7EEbyEqogE',
    appId: '1:303650839386:web:252a85a706d0b94ad5f163',
    messagingSenderId: '303650839386',
    projectId: 'multigameapp-c84fc',
    authDomain: 'multigameapp-c84fc.firebaseapp.com',
    storageBucket: 'multigameapp-c84fc.firebasestorage.app',
    measurementId: 'G-8NRQXVX4ZT',
  );
}
