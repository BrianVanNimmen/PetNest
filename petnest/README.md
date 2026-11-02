# PetNest (Flutter)

Flutter port of the Jetpack Compose app in `../PetNest_Compose`. It has the same
screens and flows and talks to the same PHP API (`../Petnest_API`).

## Running

1. Start the API and database: `docker compose up` from the repo root (the API
   listens on port 8080).
2. Put the Firebase config at `android/app/google-services.json`. It is
   gitignored; copy it from `PetNest_Compose/app/`. The Android application ID
   is `be.brianvannimmen.petnest` so that this file matches.
3. Run `flutter run` on an Android emulator.

The API base URL defaults to `http://10.0.2.2:8080/`, which is the host
machine as seen from the Android emulator. To use another address:

```sh
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080/
```

iOS is not configured for Firebase yet (it needs `GoogleService-Info.plist`).

## Structure

The layout follows the Compose project:

| Compose                         | Flutter                                  |
| ------------------------------- | ---------------------------------------- |
| `network/` (Retrofit + DTOs)    | `lib/network/` (`PetNestApi`, models)    |
| `ui/theme/`                     | `lib/theme/` (colors, dimens, ThemeData) |
| `res/values/strings.xml`        | `lib/strings.dart`                       |
| `ui/*Viewmodel/`                | `lib/ui/viewmodels/{shared,customer,vet}`|
| `ui/Screens/{Shared,Klant,Arts}`| `lib/ui/screens/{shared,customer,vet}`   |
| `PetNestApp.kt` (NavHost)       | `lib/app.dart` + `lib/routes.dart` (go_router) |

ViewModels are `ChangeNotifier`s that screens listen to with
`ListenableBuilder`. Material comes from `package:material_ui`, which go_router
also uses.

The code and UI are in English. The API's JSON keys and the appointment type
values (`controle`, `vaccinatie`, `operatie`) are still Dutch because the
backend and database define them.
