import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mautorcare/src/Constants/WEATHER/const.dart';
//import 'package:geolocator/geolocator.dart';

class WeatherService {
  static const apiKey = OPENWEATHER_API_KEY;
  static const baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    final url = '$baseUrl/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey';
    final response = await http.get(Uri.parse(url));
    return json.decode(response.body);
  }

  Future<List<dynamic>> getForecast(double lat, double lon) async {
    final url =
        '$baseUrl/forecast?lat=$lat&lon=$lon&units=metric&cnt=16&appid=$apiKey';
    final response = await http.get(Uri.parse(url));
    return json.decode(response.body)['list'];
  }
}
