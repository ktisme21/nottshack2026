# **ESG Supply Chain Platform**

A Flutter + Firebase web frontend for ESG reporting, investor marketplace, and verified supply chain analytics.

---

## **Overview**

This project is a Flutter web application for submitting ESG reports from companies and allowing investors to discover and purchase verified reports. The app integrates with Firebase for authentication, Firestore storage, and hosting.

### Key features
- Company-facing dashboard to submit ESG data for reporting
- Investor marketplace to browse verified ESG reports
- Report purchase flow for investors
- Firestore-backed report storage and real-time updates
- Firebase Hosting deployment for web

---

## **Project Structure**

```
frontend/
├── android/               # Android platform configuration (ignore)
├── ios/                   # iOS platform configuration (ignore)
├── macos/                 # macOS platform configuration (ignore)
├── linux/                 # Linux platform configuration (ignore)
├── windows/               # Windows platform configuration (ignore)
├── web/                   # Flutter web entrypoint and PWA assets (We only deal with this!!!!!!!!!!!!)
│   ├── index.html         # Web host page
│   ├── manifest.json      # PWA metadata
│   └── icons/             # Web icons
├── lib/
│   ├── main.dart          # App bootstrap + Firebase initialization
│   ├── firebase_options.dart # FlutterFire generated config
│   ├── models/            # Data model classes
│   │   ├── company.dart
│   │   ├── esg_report.dart
│   │   └── purchase.dart
│   ├── services/          # Firestore and API services
│   │   ├── api_service.dart
│   │   ├── firestore_service.dart
│   │   └── mock_payment.dart
│   ├── screens/           # App UI screens
│   │   ├── company_dashboard.dart
│   │   ├── investor_marketplace.dart
│   │   ├── report_viewer.dart
│   │   └── role_select_screen.dart
│   └── widgets/           # Shared UI widgets
├── test/                  # Widget tests
├── pubspec.yaml           # Flutter dependencies and metadata
├── firebase.json          # Firebase deployment config
├── firestore.rules        # Firestore security rules
├── firestore.indexes.json # Firestore composite indexes config
└── build/                 # Generated Flutter build outputs
```

---

## **Dependencies**

The app uses the following key packages:

- `flutter`
- `firebase_core`
- `cloud_firestore`
- `google_fonts`
- `fl_chart`
- `intl`
- `provider`

---

## **Getting Started**

1. Open a terminal in the `frontend` folder.
2. Fetch dependencies:

```bash
flutter pub get
```

3. Run the app locally in Chrome:

```bash
flutter run -d chrome
```

---

## **Firebase Setup**

This app is configured for the Firebase project `esg-supply-chain`.

- `firebase.json` points hosting to `build/web`
- `firestore.rules` defines Firestore access rules
- `firestore.indexes.json` defines required composite indexes

To initialize Firebase locally, use:

```bash
firebase login
firebase use esg-supply-chain
```

---

## **Build and Deploy**

Build the web app and deploy to Firebase Hosting:

```bash
flutter build web --release
firebase deploy --only hosting
```
