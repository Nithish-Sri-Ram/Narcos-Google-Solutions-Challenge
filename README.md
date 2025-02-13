# drug_discovery

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Got the png assets from this website - https://www.pngegg.com/






// The below is as instruction to myself to delete old keystore and generate a new one and generate a sha fingerprint and which can be used in the firebase console 

//Delete the existing - corrupted one
del "%USERPROFILE%\.android\debug.keystore"

// List and see none exists
dir "%USERPROFILE%\.android\debug.keystore"

// Creating a new one
keytool -genkeypair -v -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android -keypass android -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000

// Generating a sha keyword
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

