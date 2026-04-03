# **PawTrust - Stray Cat Welfare Platform**


---

## **Project Structure**


```
frontend/
├── android/               # Android-specific Gradle project and config (ignore this)
├── ios/                   # iOS-specific Xcode project and config (ignore this)
├── macos/                 # macOS-specific project files (ignore this)
├── linux/                 # Linux runner config (ignore this)
├── windows/               # Windows runner config (ignore this)
├── web/                   # Flutter web entrypoint and PWA assets (Only deal with this)
│   ├── index.html         # main web host page
│   ├── manifest.json
│   └── icons/
├── lib/
│   ├── main.dart          # Flutter app bootstrap + Firebase initialize
│   ├── firebase_options.dart # generated Firebase config (FlutterFire)
│   ├── models/
│   │   └── stray_cat.dart  # Stray cat model definition
│   ├── services/
│   │   └── database_service.dart # Firestore data operations (CRUD)
│   └── screens/
│       ├── home_screen.dart      # Bottom nav and screen container
│       ├── report_stray_screen.dart # Submit report UI + form
│       ├── stray_list_screen.dart   # List of tracked stray cats
│       └── cat_detail_screen.dart   # Cat detail + feeds history
├── test/                  # Widget test(s)
├── pubspec.yaml           # Flutter dependencies and metadata
├── firebase.json          # Firebase project hosting + FlutterFire paths
├── .firebaserc           # Firebase project alias
└── build/                 # Flutter build outputs (ignored)
```


## **Steps to Run on Localhost (Chrome)**

```bash
cd frontend
flutter run -d chrome
