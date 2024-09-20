import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mautorcare/src/Constants/WEATHER/user_location.dart';
import 'package:mautorcare/src/Constants/WEATHER/weather_service.dart';

class WeatherDetailsScreen extends StatefulWidget {
  const WeatherDetailsScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<WeatherDetailsScreen> {
  final WeatherService weatherService = WeatherService();
  final LocationService locationService = LocationService();
  Map<String, dynamic>? currentWeather;
  List<dynamic>? forecast;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    getWeatherData();
  }

  Future<void> getWeatherData() async {
    final position = await locationService.getCurrentLocation();
    final weather = await weatherService.getCurrentWeather(
      position.latitude,
      position.longitude,
    );
    final forecastData = await weatherService.getForecast(
      position.latitude,
      position.longitude,
    );
    setState(() {
      currentWeather = weather;
      forecast = forecastData;
      imagePath = getBackgroundImage(weather);
    });
  }

  String getBackgroundImage(Map<String, dynamic> weatherData) {
    final weatherCondition = weatherData['weather'][0]['main'].toLowerCase();
    final currentTime = weatherData['dt'];
    final sunrise = weatherData['sys']['sunrise'];
    final sunset = weatherData['sys']['sunset'];
    final isDayTime = currentTime >= sunrise && currentTime < sunset;

    // Log to check values
    print(
        'Weather: $weatherCondition, Time: $currentTime, Sunrise: $sunrise, Sunset: $sunset, isDay: $isDayTime');

    return 'assets/backgrounds/${weatherCondition}_${isDayTime ? 'day' : 'night'}.jpg';
  }

  Map<String, List<dynamic>> groupForecastByDay(List<dynamic> forecastData) {
    final groupedForecast = <String, List<dynamic>>{};
    for (var forecastItem in forecastData) {
      final date = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(forecastItem['dt_txt']));
      groupedForecast.putIfAbsent(date, () => []).add(forecastItem);
    }
    return groupedForecast;
  }

  String getIconPath(String weatherCondition, bool isDayTime) {
    final iconMapping = {
      'clear': isDayTime ? 'clear_day.png' : 'clear_night.png',
      'clouds': isDayTime ? 'clouds_day.png' : 'clouds_night.png',
      'overcast': 'overcast.png',
      'rain': isDayTime ? 'rain_day.png' : 'rain_night.png',
      'shower rain': 'shower_rain.png',
      'thunderstorm': 'thunderstorm.png',
      'snow': isDayTime ? 'snow_day.png' : 'snow_night.png',
      'mist': 'mist.png',
      'fog': 'mist.png',
      'haze': 'mist.png',
      'drizzle': isDayTime ? 'drizzle_day.png' : 'drizzle_night.png',
      'wind': 'wind.png',
    };
    return 'assets/icons/${iconMapping[weatherCondition] ?? 'clear_day.png'}'; // Default icon
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          iconSize: 35,
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow
      ),
      body: currentWeather == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Background image depending on weather condition
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Weather information overlay
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    buildWeatherInfoCard(),
                    Expanded(
                      child: buildForecastList(),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget buildWeatherInfoCard() {
    return Container(
      // Add horizontal padding
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
        color: const Color.fromARGB(85, 0, 0, 0),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
        children: [
          Text(
            currentWeather!['name'],
            style: const TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color:
                  Color.fromARGB(255, 255, 255, 255), // Black text for contrast
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${currentWeather!['main']['temp']}°C',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color:
                  Color.fromARGB(255, 255, 255, 255), // Black text for contrast
            ),
          ),
          const SizedBox(height: 10),
          Text(
            currentWeather!['weather'][0]['description'],
            style: const TextStyle(
              fontSize: 24,
              color:
                  Color.fromARGB(255, 255, 255, 255), // Black text for contrast
            ),
          ),
        ],
      ),
    );
  }

  Widget buildForecastList() {
    final groupedForecast = groupForecastByDay(forecast!);
    final forecastDates = groupedForecast.keys.toList();

    return ListView.builder(
      itemCount: forecastDates.length,
      itemBuilder: (context, index) {
        final dailyForecast = groupedForecast[forecastDates[index]]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                DateFormat('E, MMM d')
                    .format(DateTime.parse(forecastDates[index])),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dailyForecast.length,
                itemBuilder: (context, index) {
                  return buildForecastCard(dailyForecast[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildForecastCard(Map<String, dynamic> forecastItem) {
    final forecastTime = DateTime.parse(forecastItem['dt_txt']);
    final timeFormatter = DateFormat('h:mm a');
    final forecastWeather = forecastItem['weather'][0]['main'].toLowerCase();
    final isForecastDayTime = forecastTime.millisecondsSinceEpoch >=
            (currentWeather!['sys']['sunrise'] * 1000) &&
        forecastTime.millisecondsSinceEpoch <
            (currentWeather!['sys']['sunset'] * 1000);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: const Color.fromARGB(255, 10, 38, 61).withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              timeFormatter.format(forecastTime),
              style: const TextStyle(color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Image.asset(
                getIconPath(forecastWeather, isForecastDayTime),
                height: 40,
                width: 70,
              ),
            ),
            Text(
              forecastWeather,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
