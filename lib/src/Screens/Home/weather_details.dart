import 'package:flutter/material.dart';
import 'package:mautorcare/src/Components/weather_widget.dart';

class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Details'),
      ),
      body: const Center(child: WeatherWidget()
          //Text('Weather details and forecast here...'),
          ),
    );
  }
}


//f8d4afc3eb6bc0dc4b3ac4425156f969
//dd1bf03de617bf289ea5bdd32407d889