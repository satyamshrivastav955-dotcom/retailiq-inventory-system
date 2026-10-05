# ShelfSense — Firebase Setup Guide

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project** → name it `ShelfSense`
3. Enable Google Analytics (optional) → Click **Create project**

## 2. Register Android App

1. In Firebase Console → click **Add app** → select **Android**
2. Enter package name: `com.example.k11_project`
3. Enter app nickname: `ShelfSense`
4. Click **Register app**
5. Download `google-services.json`
6. Place it in: `android/app/google-services.json`

## 3. Enable Firebase Services

### Authentication
1. Go to **Build → Authentication → Get Started**
2. Enable **Email/Password** provider
3. Create your owner account:
   - Click **Add user**
   - Enter your email and password

### Cloud Firestore
1. Go to **Build → Firestore Database → Create database**
2. Choose **Start in test mode** (for development)
3. Select nearest region → click **Enable**

### Create Owner User Document
After creating your auth account, add a user document in Firestore:

1. Go to Firestore → click **Start collection**
2. Collection ID: `users`
3. Document ID: paste your user UID from Authentication
4. Add fields:
   - `user_id` (string): your UID
   - `name` (string): your name
   - `email` (string): your email
   - `role` (string): `owner`
   - `created_at` (timestamp): now

### Firebase Cloud Messaging (Optional)
1. Go to **Engage → Messaging**
2. Follow setup for push notifications if needed

## 4. Run the App

```bash
flutter pub get
flutter run
```

Run from the repository root (where `pubspec.yaml` lives).

To run unit tests (no Firebase needed):

```bash
flutter test
```

## 5. Firestore Security Rules (Production)

Replace default rules with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /sales/{saleId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }
  }
}
```
