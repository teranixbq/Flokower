import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration loaded from environment variables.
///
/// Run the app with:
///   flutter run --dart-define-from-file=.env
///
/// Or manually:
///   flutter run \
///     --dart-define=FIREBASE_API_KEY=xxx \
///     --dart-define=FIREBASE_APP_ID=xxx \
///     --dart-define=FIREBASE_MESSAGING_SENDER_ID=xxx \
///     --dart-define=FIREBASE_PROJECT_ID=flokower \
///     --dart-define=FIREBASE_STORAGE_BUCKET=xxx \
///     --dart-define=FIREBASE_AUTH_DOMAIN=xxx

class DefaultFirebaseOptions {
  // Read from --dart-define at compile time
  static const String _apiKey = String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
  static const String _appId = String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '');
  static const String _senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '');
  static const String _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'flokower');
  static const String _storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: '');
  static const String _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: '');

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError('Windows not supported');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux not supported');
      case TargetPlatform.fuchsia:
        throw UnsupportedError('Fuchsia not supported');
    }
  }

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _senderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
  );

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _senderId,
    projectId: _projectId,
    authDomain: _authDomain,
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _senderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _senderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
  );
}
