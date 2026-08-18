import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// ⚠️ IMPORTANT: These values are DUMMIES.
/// The actual Firebase configuration is loaded automatically from:
/// - Android: android/app/google-services.json
/// - iOS: Runner/GoogleService-Info.plist
/// - Web: web/firebase-config.js (or inline in index.html)
///
/// This file exists ONLY as a compile-time placeholder to prevent
/// "firebase_options.dart not found" errors. The real config
/// is injected at build time by the Firebase SDK.
///
/// If you see "No Firebase App has been created" error,
/// make sure google-services.json is in the correct location.

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
        throw UnsupportedError('DefaultFirebaseOptions are not supported for Windows.');
      case TargetPlatform.linux:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for Linux.');
      case TargetPlatform.fuchsia:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for Fuchsia.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'DUMMY_KEY_ANDROID',
    appId: '1:000000000000:android:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'flokower',
    storageBucket: 'flokower.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'DUMMY_KEY_WEB',
    appId: '1:000000000000:web:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'flokower',
    authDomain: 'flokower.firebaseapp.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'DUMMY_KEY_IOS',
    appId: '1:000000000000:ios:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'flokower',
    storageBucket: 'flokower.firebasestorage.app',
  );
  
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'DUMMY_KEY_MACOS',
    appId: '1:000000000000:macos:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'flokower',
    storageBucket: 'flokower.firebasestorage.app',
  );
}
