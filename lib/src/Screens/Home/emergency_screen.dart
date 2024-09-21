import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mautorcare/src/Components/navbar.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  static const platform = MethodChannel('com.example.mautorcare/call');
  int _countdown = 10;
  Timer? _timer;
  bool _isFlashing = false;
  bool callMade = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _flashing();

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

  // void _showAlert() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text("Emergency Alert"),
  //       content: Text("Emergency has been contacted."),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //           },
  //           child: Text("OK"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _cancelCountdown() {
    _timer?.cancel();
    Navigator.of(context).pop(); // Navigate back or close the screen
  }

  @override
  void dispose() {
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
