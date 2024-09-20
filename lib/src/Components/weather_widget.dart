import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mautorcare/src/Screens/Home/weather_details.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String weatherIcon = ""; // Default is sunny

  @override
  void initState() {
    super.initState();
    fetchCurrentWeather();
  }

  Future<void> fetchCurrentWeather() async {
    const apiKey =
        'dd1bf03de617bf289ea5bdd32407d889'; // Replace with your weather API key
    const url =
        'https://api.openweathermap.org/data/2.5/weather?q=Port Louis,MU&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          String weather = data['weather'][0]['main'];
          if (weather == 'Clear') {
            weatherIcon = "☀️";
          } else if (weather == 'Clouds') {
            weatherIcon = "☁️";
          } else if (weather == 'Rain') {
            weatherIcon = "🌧️";
          }
        });
      } else {
        print('Failed to load weather');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WeatherDetailScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(0, 60, 19, 172),
        ),
        child: Text(
          weatherIcon,
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}
