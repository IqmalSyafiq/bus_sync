// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBJzzLpuHPXsHLoh0PRrgyzkNNSCWBIkjM',
    appId: '1:264018204613:web:93be5f79c809502aa55dac',
    messagingSenderId: '264018204613',
    projectId: 'bussync',
    authDomain: 'bussync.firebaseapp.com',
    storageBucket: 'bussync.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAwSxjg6xIkYGH6Apm6vNma4cr6tRBTXZk',
    appId: '1:264018204613:android:dce26eeeb1d5a0daa55dac',
    messagingSenderId: '264018204613',
    projectId: 'bussync',
    storageBucket: 'bussync.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDdgZfD3xpx4uRobrQYvVviT5EgY-aS73A',
    appId: '1:264018204613:ios:d04bcaafa4f6246ba55dac',
    messagingSenderId: '264018204613',
    projectId: 'bussync',
    storageBucket: 'bussync.appspot.com',
    iosBundleId: 'com.example.busSync',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDdgZfD3xpx4uRobrQYvVviT5EgY-aS73A',
    appId: '1:264018204613:ios:d66c6ec9279acb29a55dac',
    messagingSenderId: '264018204613',
    projectId: 'bussync',
    storageBucket: 'bussync.appspot.com',
    iosBundleId: 'com.example.busSync.RunnerTests',
  );
}