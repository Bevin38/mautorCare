import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:mautorcare/firebase_options.dart';
import 'package:mautorcare/src/Constants/theme_manager.dart';
import 'package:mautorcare/src/Screens/Auth/welcome_screen.dart';
import 'package:mautorcare/src/Screens/Camera/camera_choice_screen.dart';
import 'package:mautorcare/src/Screens/Home/emergency_sound_screen.dart';
import 'package:mautorcare/src/Screens/QR_Scanner/qr_code.dart';
import 'package:mautorcare/src/Screens/QR_Scanner/qr_screen.dart';
import 'package:sensors_plus/sensors_plus.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  Gemini.init(apiKey: 'AIzaSyCnriOplIP7i55ji-6XBsbBKswKLNnwlt0');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final double _shakeThreshold = 50.0;
  DateTime _lastShakeTime = DateTime.now();
  bool _isShakeDetectionEnabled = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeShakeDetection();
  }

  void _initializeShakeDetection() {
    userAccelerometerEventStream().listen(
      (UserAccelerometerEvent event) {
        if (!_isShakeDetectionEnabled) return;

        double acceleration =
            event.x * event.x + event.y * event.y + event.z * event.z;
        double threshold = _shakeThreshold * _shakeThreshold;

        //print('Acceleration: $acceleration'); // Debug print

        if (acceleration > threshold) {
          print('Shake detected');
          // Check for shake interval to avoid multiple triggers
          if (DateTime.now().difference(_lastShakeTime).inMilliseconds > 1000) {
            _lastShakeTime = DateTime.now();
            _openEmergencyScreen();
          }
        }
      },
    );
  }

  void _openEmergencyScreen() {
    print('Navigating to emergency screen');
    navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => const EmergencySoundScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: themeNotifier, // Listen for changes in themeNotifier
        builder: (context, ThemeMode mode, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
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
