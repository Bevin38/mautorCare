import 'package:flutter/material.dart';
import 'package:mautorcare/src/Components/weather_widget.dart';
import 'package:mautorcare/src/Models/accident_card.dart';
import 'package:mautorcare/src/Screens/Home/emergency_screen.dart';
import 'package:mautorcare/src/Screens/Home/weather_details_screen.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          title: const Text('HOME'),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 20, top: 5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  backgroundColor: const Color.fromARGB(255, 32, 3, 199)
                      .withOpacity(0.9), // Background color
                  // onPrimary: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WeatherDetailsScreen()),
                  );
                },
                child: const WeatherWidget(),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: 10, // Number of accidents
            itemBuilder: (context, index) {
              return const Accidentcard();
            },
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 206, 32, 41), // Background color of button
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 20,
                    shadowColor: Colors.black.withOpacity(0.9)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EmergencyScreen()),
                  );
                },
                child: const Text(
                  'Emergency Alert',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
