# PetNest (Flutter)

Flutter port of the Jetpack Compose app in `../PetNest_Compose`. It has the same
screens and flows. Data lives in Cloud Firestore and Cloud Storage, and users
sign in with Firebase Auth, by email/password or Google. The backend setup,
data model and security rules are in [`../firebase`](../firebase/README.md).

## Running

1. Do the one-time Firebase setup in [`../firebase/README.md`](../firebase/README.md):
   create Firestore and Storage, enable the sign-in methods, add the SHA-1 and
   deploy the rules.
2. Put the downloaded config at `android/app/google-services.json`
   (gitignored). The Android application ID is `be.brianvannimmen.petnest`.
3. Run `flutter run` on an Android device or emulator.

If Google sign-in reports a missing `serverClientId`, either re-download
`google-services.json` after enabling Google sign-in, or pass the web client
ID from the Firebase console:

```sh
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=1234-abc.apps.googleusercontent.com
```

iOS is not configured for Firebase yet (it needs `GoogleService-Info.plist`).

## Signing in

- **Email/password** works as before: register, then log in.
- **Google**: tap *Continue with Google*. A Google account that is not linked
  to PetNest yet goes to *Complete your registration*. There you choose
  customer or vet and fill in the remaining fields (no password needed).
  - Customers go straight into the app.
  - Vets wait for approval, as with email registration.

## Structure

| Compose                          | Flutter                                       |
| -------------------------------- | --------------------------------------------- |
| `network/` (Retrofit + DTOs)     | `lib/data/` (`PetNestRepository`, models)     |
| `ui/theme/`                      | `lib/theme/` (colors, dimens, ThemeData)      |
| `res/values/strings.xml`         | `lib/strings.dart`                            |
| `ui/*Viewmodel/`                 | `lib/ui/viewmodels/{shared,customer,vet}`     |
| `ui/Screens/{Shared,Klant,Arts}` | `lib/ui/screens/{shared,customer,vet}`        |
| `PetNestApp.kt` (NavHost)        | `lib/app.dart` + `lib/routes.dart` (go_router)|

- **Data access.** All Firebase calls go through `PetNestRepository`.
  ViewModels take it as an optional constructor argument, so tests can pass
  one backed by `fake_cloud_firestore`.
- **State.** ViewModels are `ChangeNotifier`s that screens listen to with
  `ListenableBuilder`.
- **Material.** It comes from `package:material_ui`, which go_router also uses.

## Tests

```sh
flutter test
```
