import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mautorcare/src/Components/navbar.dart';

class EmergencySoundScreen extends StatefulWidget {
  const EmergencySoundScreen({super.key});

  @override
  State<EmergencySoundScreen> createState() => _EmergencySoundScreenState();
}

class _EmergencySoundScreenState extends State<EmergencySoundScreen> {
  static const platform = MethodChannel('com.example.mautorcare/call');
  int _countdown = 10;
  Timer? _timer;
  bool _isFlashing = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool callMade = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _flashing();
    _playSound();

    // Listen for call completion to navigate to navBar screen
    platform.setMethodCallHandler((call) async {
      if (call.method == "navigateToNavbar") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Navbar()),
        );
      }
    });
  }

  void backToOne() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Navbar()));
  }

  void _flashing() {
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        if (_countdown > 0) {
          _isFlashing = !_isFlashing;
        }
      });
    });
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
          // Toggle flashing
        } else {
          _timer?.cancel();
          if (!callMade) {
            // Ensure call is made only once
            _makeCall();
            callMade = true;
            backToOne();
            _audioPlayer.stop();
          }
        }
      });
    });
  }

  Future<void> _makeCall() async {
    try {
      await platform.invokeMethod('makeCall', {'phoneNumber': '+2306274404'});
    } on PlatformException catch (e) {
      print("Failed to make call: '${e.message}'.");
    }
  }

  void _cancelCountdown() {
    _timer?.cancel();
    Navigator.of(context).pop(); // Navigate back or close the screen
  }

  Future<void> _playSound() async {
    // Replace 'assets/sound.mp3' with the path to your audio file
    await _audioPlayer.play(AssetSource('alarm/alarm.mp3'));
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // Set looping mode
    _audioPlayer.resume();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 150),
            const Center(
              child: Text(
                "Emergency will be contacted in",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: _isFlashing ? Colors.red : Colors.white,
                  width: 10,
                ),
              ),
              child: Center(
                child: Text(
                  '$_countdown',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w800,
                    color: _isFlashing ? Colors.red : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: _cancelCountdown,
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: 25, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
