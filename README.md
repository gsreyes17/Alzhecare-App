name: alzhecare
description: "A new Flutter project."
publish_to: "none"
version: 1.0.0

environment:
  sdk: ^3.8.1

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.5+1
  shared_preferences: ^2.5.3
  image_picker: ^1.2.0
  http: ^1.5.0
  intl: ^0.20.2

  image_picker_for_web: any
  cross_file: ^0.3.3
  flutter_launcher_icons: ^0.14.4
  cached_network_image: ^3.4.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
assets:
  - assets/images/
  - assets/images/icon.png

flutter:
  uses-material-design: true

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/icon.png"
  adaptive_icon_background: "#2563EB"
  adaptive_icon_foreground: "assets/images/icon.png"


flutter pub run flutter_launcher_icons

android/app/src/main/AndroidManifest.xml
  <manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="Alzhecare CNN"