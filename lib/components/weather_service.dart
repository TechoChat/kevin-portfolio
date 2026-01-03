import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherModel {
  final String temperature;
  final String condition;
  final String iconCode;
  final String cityName; // Added city name just in case you want to show it

  WeatherModel({
    required this.temperature, 
    required this.condition, 
    required this.iconCode,
    required this.cityName,
  });
}

class WeatherService {
  // 🔴 REPLACE THIS WITH YOUR OPENWEATHER API KEY
  static const String _apiKey = String.fromEnvironment('OPEN_WEATHER_API_KEY');
  
  static const String _weatherUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const String _locationUrl = 'https://ipwho.is/'; // Free IP Geolocation API

  Future<WeatherModel?> getWeather() async {
    try {
      // 1. Get Approximate Location (IP-based, No Permissions needed)
      final locationResponse = await http.get(Uri.parse(_locationUrl));
      
      if (locationResponse.statusCode != 200) {
        //print("Location API Error: ${locationResponse.statusCode}");
        return null;
      }

      final locationData = jsonDecode(locationResponse.body);
      
      // Check if the IP API succeeded
      if (locationData['success'] != true) {
        //print("Could not detect location from IP");
        return null;
      }

      final double lat = locationData['latitude'];
      final double lon = locationData['longitude'];
      // final String city = locationData['city'];

      // 2. Get Weather for that Location
      final weatherResponse = await http.get(Uri.parse(
        '$_weatherUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'
      ));

      if (weatherResponse.statusCode == 200) {
        final data = jsonDecode(weatherResponse.body);
        return WeatherModel(
          temperature: data['main']['temp'].round().toString(),
          condition: data['weather'][0]['main'],
          iconCode: data['weather'][0]['icon'],
          cityName: data['name'], // This comes from OpenWeatherMap's response
        );
      } else {
        //print("Weather API Error: ${weatherResponse.statusCode}");
        return null;
      }
    } catch (e) {
      //print("Error fetching weather: $e");
      return null;
    }
  }

  // Helper to map API Icon code to Flutter Icons
  IconData getWeatherIcon(String code) {
    switch (code) {
      case '01d': return Icons.wb_sunny;        // Clear day
      case '01n': return Icons.nights_stay;     // Clear night
      case '02d': 
      case '02n': return Icons.cloud_queue;     // Few clouds
      case '03d': 
      case '03n': 
      case '04d': 
      case '04n': return Icons.cloud;           // Cloudy
      case '09d': 
      case '09n': 
      case '10d': 
      case '10n': return Icons.grain;           // Rain
      case '11d': 
      case '11n': return Icons.flash_on;        // Thunderstorm
      case '13d': 
      case '13n': return Icons.ac_unit;         // Snow
      default: return Icons.wb_cloudy;
    }
  }
}