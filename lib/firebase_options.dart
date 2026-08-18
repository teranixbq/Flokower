import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Firebase configuration that reads from .env file.
///
/// The .env file is loaded in main.dart BEFORE Firebase init:
///   await dotenv.load(fileName: ".env");
///
/// Then this class reads values via dotenv.env['KEY'].
/// No need for --dart-define or run.sh anymore!
/// Just run: flutter run

class DefaultFirebaseOptions {
  static String get _apiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get _appId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  static String get _senderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get _projectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? 'flokower';
  static String get _storageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get _authDomain => dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';

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
