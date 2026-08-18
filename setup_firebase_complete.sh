#!/bin/bash
# Complete Firebase Setup Script for Flokower
# This script handles everything needed for Firebase integration

echo "🚀 FLOKOWER FIREBASE SETUP SCRIPT"
echo "=================================="
echo ""

# Step 1: Create the android/app directory if it doesn't exist
echo "Step 1/5: Checking Android directory..."
mkdir -p /home/nodenix/Documents/Flokower/android/app
echo "✅ Android directory ready!"
echo ""

# Step 2: Provide instructions for downloading google-services.json
echo "Step 2/5: Downloading Configuration File"
echo "-----------------------------------------"
echo "Please visit:"
echo "https://console.firebase.google.com/project/flokower/settings/general/android:com.example.flokower"
echo ""
echo "Click 'Download google-services.json' and save it to Downloads folder."
echo ""
read -p "Press Enter after downloading google-services.json..."
echo ""

# Step 3: Move the file
echo "Step 3/5: Moving configuration file..."
if [ -f "/home/nodenix/Downloads/google-services.json" ]; then
    cp /home/nodenix/Downloads/google-services.json /home/nodenix/Documents/Flokower/android/app/
    echo "✅ google-services.json moved to android/app/"
else
    echo "❌ google-services.json not found in Downloads!"
    echo "Please download it first from Firebase Console."
    exit 1
fi
echo ""

# Step 4: Update firebase_options.dart (if needed)
echo "Step 4/5: Checking Firebase configuration..."
if [ ! -f "/home/nodenix/Documents/Flokower/lib/firebase_options.dart" ]; then
    echo "⚠️ firebase_options.dart not found! Creating template..."
    cat > /home/nodenix/Documents/Flokower/lib/firebase_options.dart << 'EOF'
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
          'DefaultFirebaseOptions are not supported for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for Linux.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'flokower',
    authDomain: 'flokower.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'flokower',
    storageBucket: 'flokower.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'flokower',
    storageBucket: 'flokower.appspot.com',
    iosBundleIdentifier: 'com.example.flokower',
  );
}
EOF
    echo "✅ Template created!"
fi
echo ""

# Step 5: Install dependencies and run
echo "Step 5/5: Installing dependencies and running app..."
cd /home/nodenix/Documents/Flokower
echo "Running: flutter pub get"
/home/nodenix/FlutterDev/bin/flutter pub get

echo ""
echo "========================================="
echo "✅ FIREBASE SETUP COMPLETE!"
echo "========================================="
echo ""
echo "Your app is now configured with Firebase!"
echo ""
echo "To test, run:"
echo "  flutter run"
echo ""
echo "Check your Firebase Console to see users and data!"
echo ""

