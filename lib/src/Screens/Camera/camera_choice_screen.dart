import 'package:flutter/material.dart';
import 'package:mautorcare/src/Screens/Camera/AI_Camera/ai_camera_screen.dart';

class CameraChoiceScreen extends StatelessWidget {
  const CameraChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:
          // Allow content to be scrollable
          Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Upper button for posting a picture
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Text(
                  'PRESS ICON TO POST ACCIDENT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: Image.asset(
                    'assets/camera_icon/post_picture.png',
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
                  ), // Replace with your icon file
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AiCameraScreen()));
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),

            const Divider(
              thickness: 10,
              color: Color.fromARGB(255, 34, 3, 150),
            ),
            const SizedBox(height: 100), // Space between the two buttons

            // Lower button for scanning QR codes
            Column(
              children: [
                IconButton(
                  iconSize: 30, // Reduced icon size
                  icon: Image.asset(
                    'assets/camera_icon/scan_qr.png',
                    height: 100,
                    width: 100,
                  ), // Replace with your icon file
                  onPressed: () {
                    // Action for scanning QR codes
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'PRESS ICON TO SCAN QR',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
