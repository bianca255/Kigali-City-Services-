# Kigali City Services & Places Directory

A Flutter mobile application that helps Kigali residents locate, navigate to,
and manage listings for essential public services and leisure locations across
Kigali City.

---

## Features

| Feature | Details |
|---|---|
| **Authentication** | Email/password via Firebase Auth with mandatory email verification |
| **Directory** | Browse all community listings in real time via Firestore streams |
| **Search & Filter** | Full-text name search + single-category chip filter, updates live |
| **CRUD Listings** | Create, read, update, and delete listings — owner-only edit/delete |
| **Detail + Map** | Embedded Google Map with place marker on every detail page |
| **Turn-by-turn Nav** | "Get Directions" launches Google Maps with the destination pre-filled |
| **My Listings** | Personalised list scoped to the authenticated user's UID |
| **Map View** | Full-screen map showing coloured markers for every listing category |
| **Settings** | Profile display, email-verification badge, notification toggle, sign-out |

---

## Architecture

```
lib/
├── core/
│   ├── constants/          # AppColors, AppStrings, AppCategories
│   └── utils/              # Validators
├── domain/
│   └── entities/           # UserEntity, ListingEntity (pure Dart, no Firebase)
├── data/
│   ├── models/             # UserModel, ListingModel  (Firestore ↔ entity mappers)
│   └── services/           # AuthService, ListingService  (all Firebase calls live here)
└── presentation/
    ├── providers/          # Riverpod StateNotifierProviders + StreamProviders
    ├── screens/            # auth / directory / my_listings / map_view / settings
    ├── widgets/            # ListingCard, CategoryFilterChips, LoadingOverlay
    └── app.dart            # MaterialApp + _AuthGate + _MainScaffold (BottomNav)
```

> **No direct Firestore calls in UI widgets.**  
> All database access goes through `AuthService` / `ListingService`, which are
> injected into Riverpod notifiers and exposed as streams/futures to the UI.

---

## State Management — Riverpod

| Provider | Type | Purpose |
|---|---|---|
| `authServiceProvider` | `Provider` | Singleton `AuthService` |
| `firebaseAuthStreamProvider` | `StreamProvider<User?>` | Raw Firebase auth state |
| `userProfileProvider` | `StateNotifierProvider<UserProfileNotifier>` | Full profile + auth methods |
| `listingServiceProvider` | `Provider` | Singleton `ListingService` |
| `allListingsStreamProvider` | `StreamProvider<List<ListingModel>>` | Live stream of all listings |
| `myListingsStreamProvider` | `StreamProvider<List<ListingModel>>` | Live stream filtered by UID |
| `filteredListingsProvider` | `Provider` (derived) | Search + category filter applied |
| `searchQueryProvider` | `StateProvider<String>` | Current search text |
| `selectedCategoryProvider` | `StateProvider<String?>` | Active category chip |
| `listingNotifierProvider` | `StateNotifierProvider<ListingNotifier>` | Create / update / delete ops |

---

## Firestore Database Structure

```
firestore/
├── users/
│   └── {uid}/
│       ├── email               : String
│       ├── displayName         : String
│       ├── emailVerified       : Boolean
│       ├── createdAt           : Timestamp
│       └── notificationsEnabled: Boolean
│
└── listings/
    └── {listingId}/
        ├── name            : String
        ├── category        : String      (Hospital | Police Station | …)
        ├── address         : String
        ├── contactNumber   : String
        ├── description     : String
        ├── location        : Map
        │     ├── lat       : Number
        │     └── lng       : Number
        ├── createdBy       : String      (uid)
        ├── createdByName   : String
        ├── createdAt       : Timestamp
        └── updatedAt       : Timestamp?
```

**Composite index required** (create in Firebase Console or `firestore.indexes.json`):
- Collection: `listings` — fields: `createdBy ASC`, `createdAt DESC`

---

## Setup & Configuration

### 1. Prerequisites
- Flutter SDK ≥ 3.10
- A Firebase project with **Authentication** (Email/Password) and **Cloud Firestore** enabled
- A Google Cloud project with the **Maps SDK for Android** and **Maps SDK for iOS** APIs enabled

### 2. Firebase configuration

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Inside the project root
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

This overwrites `lib/firebase_options.dart` with your real credentials.

### 3. Google Maps API Key

**Android** — edit `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

**iOS** — edit `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```
Also add the key to `ios/Runner/Info.plist` under `GMSApiKey`.

### 4. Install dependencies & run

```bash
flutter pub get
flutter run
```

### 5. Firestore Security Rules

Deploy `firestore.rules` via the Firebase Console (**Firestore > Rules**) or:
```bash
firebase deploy --only firestore:rules
```

---

## Categories

Hospital · Police Station · Library · Restaurant · Café · Park · Tourist Attraction · Utility Office

---

## Screenshots

> *(Add screenshots here after building)*

---

## License

MIT
