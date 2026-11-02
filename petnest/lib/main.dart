import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // On Android the options come from android/app/google-services.json
  await Firebase.initializeApp();
  runApp(const PetNestApp());
}
