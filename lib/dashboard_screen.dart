import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http; // The delivery driver!

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- Firebase Variables ---
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref('sensorData');
  String currentSoilMoisture = "--";
  String currentTemperature = "--";
  String currentPhLevel = "--";
  String currentNutrients = "--";

  // --- Weather API Variables ---
  bool isWeatherLoading = true;
  String weatherCondition = "Loading...";
  String weatherTemp = "--";
  String weatherIconUrl = "";

  @override
  void initState() {
    super.initState();
    _activateLiveStream(); // Start listening to Firebase
    _fetchLiveWeather();   // Fetch the weather from the internet
  }

  // --- THE WEATHER FETCHING LOGIC ---
  Future<void> _fetchLiveWeather() async {
    //weather API dito
    const apiKey = '15b5beaa93fa45938b483443261104'; 
    const city = 'Manila'; // Change nalang this kung san mo want
    
    if (apiKey == 'YOUR_WEATHERAPI_KEY_HERE') {
      print("ALERT: Please insert your WeatherAPI key!");
      return;
    }

    final url = Uri.parse('http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city&aqi=no');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        //successfully got the data back, now we chop up the JSON!
        final data = jsonDecode(response.body);
        
        if (mounted) {
          setState(() {
            weatherCondition = data['current']['condition']['text'];
            weatherTemp = data['current']['temp_c'].toString();
            // WeatherAPI sends URLs starting with "//", so we add "https:" to make it a valid link
            weatherIconUrl = "https:${data['current']['condition']['icon']}"; 
            isWeatherLoading = false;
          });
        }
      } else {
        print("Weather API Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching weather: $e");
    }
  }

  // --- FIREBASE LISTENER ---
  void _activateLiveStream() {
    _sensorRef.onValue.listen((event) {
      if (event.snapshot.value == null) return;
      final data = event.snapshot.value as Map<dynamic, dynamic>;

      if (mounted) {
        setState(() {
          if (data['soilMoisture'] != null) currentSoilMoisture = data['soilMoisture'].toString();
          if (data['temperature'] != null) currentTemperature = data['temperature'].toString();
          if (data['phLevel'] != null) currentPhLevel = data['phLevel'].toString();
          if (data['nutrients'] != null) currentNutrients = data['nutrients'].toString();
        });
      }
    });
  }

  // --- UI WIDGET BUILDERS ---
  Widget _buildSensorCard(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D332F))),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Digital Greenhouse", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D332F))),
                      SizedBox(height: 4),
                      Text("LIVE SENSOR STREAM", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF81C784), letterSpacing: 1.2)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE0E0E0))),
                    child: const Icon(Icons.notifications_none, color: Color(0xFF2D332F)),
                  )
                ],
              ),
              const SizedBox(height: 32),

              // --- 2x2 SENSOR GRID ---
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  _buildSensorCard("Soil Moisture", currentSoilMoisture, "%", Icons.water_drop, const Color(0xFF81C784)),
                  _buildSensorCard("Temperature", currentTemperature, "°C", Icons.thermostat, const Color(0xFFFFB74D)),
                  _buildSensorCard("pH Level", currentPhLevel, "pH", Icons.science, const Color(0xFF64B5F6)),
                  _buildSensorCard("Nutrients", currentNutrients, "lvl", Icons.eco, const Color(0xFF8D6E63)),
                ],
              ),
              const SizedBox(height: 32),

              // --- DYNAMIC WEATHER SECTION ---
              const Text("Local Weather Forecast", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D332F))),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                ),
                child: isWeatherLoading 
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Color(0xFF81C784)),
                    ))
                  : Row(
                      children: [
                        // Display the real icon sent from the weather database
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFF6F9F6), borderRadius: BorderRadius.circular(16)),
                          child: weatherIconUrl.isNotEmpty 
                              ? Image.network(weatherIconUrl, width: 48, height: 48, errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud, size: 48))
                              : const Icon(Icons.cloud, size: 48),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("$weatherTemp°C • $weatherCondition", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D332F))),
                              const SizedBox(height: 4),
                              const Text("Live data from Manila.", style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}