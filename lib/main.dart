import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:mautorcare/firebase_options.dart';
import 'package:mautorcare/src/Components/navbar.dart';
import 'package:mautorcare/src/Components/welcome_custom_scaffold.dart';
import 'package:mautorcare/src/Constants/theme_manager.dart';
import 'package:mautorcare/src/Screens/Auth/welcome_screen.dart';
import 'package:mautorcare/src/Screens/QR_Scanner/qr_code.dart';
import 'package:mautorcare/src/Screens/QR_Scanner/qr_screen.dart';

Future<void> main() async {
  Gemini.init(apiKey: 'AIzaSyCnriOplIP7i55ji-6XBsbBKswKLNnwlt0');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: themeNotifier, // Listen for changes in themeNotifier
        builder: (context, ThemeMode mode, _) {
          return MaterialApp(
            themeMode: mode, // Use the current theme mode
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            routes: {
              "/generate": (context) => const QrCode(),
              "/scan": (context) => const QrScreen()
            },
            debugShowCheckedModeBanner: false,
            home: const WelcomeScreen(),
          );
        });
  }
}
