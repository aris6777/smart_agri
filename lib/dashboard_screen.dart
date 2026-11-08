import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- FIREBASE VARIABLES (7 Parameters + Status) ---
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref('sensorData');
  String currentSoilMoisture = "--";
  String currentTemperature = "--";
  String currentPhLevel = "--";
  String currentEc = "--"; 
  String soilStatus = "Optimal";
  String currentNitrogen = "--"; 
  String currentPhosphorus = "--";
  String currentPotassium = "--";

  // --- OPEN-METEO WEATHER VARIABLES ---
  bool isWeatherLoading = true;
  String weatherCondition = "Loading...";
  String weatherTemp = "--";
  IconData weatherIcon = LucideIcons.cloud; 

  @override
  void initState() {
    super.initState();
    _activateLiveStream();
    _fetchLiveWeather(); 
  }

  // --- 100% FREE LIVE WEATHER FETCH LOGIC (OPEN-METEO) ---
  Future<void> _fetchLiveWeather() async {
    final url = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=14.5995&longitude=120.9842&current=temperature_2m,weather_code');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'];
        final temp = current['temperature_2m'].toString();
        final code = current['weather_code'] as int;

        String condition = "Cloudy";
        IconData icon = LucideIcons.cloud;

        if (code == 0) {
          condition = "Clear Sky";
          icon = LucideIcons.sun;
        } else if (code >= 1 && code <= 3) {
          condition = "Partly Cloudy";
          icon = LucideIcons.cloudSun;
        } else if (code >= 51 && code <= 67 || code >= 80 && code <= 82) {
          condition = "Rainy";
          icon = LucideIcons.cloudRain;
        } else if (code >= 95) {
          condition = "Thunderstorm";
          icon = LucideIcons.cloudLightning;
        }

        if (mounted) {
          setState(() {
            weatherTemp = temp;
            weatherCondition = condition;
            weatherIcon = icon;
            isWeatherLoading = false; 
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() { weatherCondition = "Offline"; isWeatherLoading = false; });
    }
  }

  // --- FIREBASE LIVE STREAM ---
  void _activateLiveStream() {
    _sensorRef.onValue.listen((event) {
      try {
        if (event.snapshot.value == null) return;
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        if (mounted) {
          setState(() {
            if (data['moisture'] != null) currentSoilMoisture = data['moisture'].toString();
            if (data['temperature'] != null) currentTemperature = data['temperature'].toString();
            if (data['ph'] != null) currentPhLevel = data['ph'].toString();
            if (data['ec'] != null) currentEc = data['ec'].toString();
            if (data['nitrogen'] != null) currentNitrogen = data['nitrogen'].toString();
            if (data['phosphorus'] != null) currentPhosphorus = data['phosphorus'].toString();
            if (data['potassium'] != null) currentPotassium = data['potassium'].toString();

            // Soil Status Calculation
            double moisture = double.tryParse(currentSoilMoisture) ?? 0;
            double ph = double.tryParse(currentPhLevel) ?? 7.0;

            if (moisture < 20 || moisture > 80 || ph < 5.5 || ph > 7.5) {
              soilStatus = "Needs Attention";
            } else {
              soilStatus = "Optimal";
            }
          });
        }
      } catch (e) {
        print("Database Error: $e");
      }
    });
  } // <--- FIXED: Properly closed _activateLiveStream() method here

  // --- UI BUILDERS ---
  Widget _buildSoilStatusCard() {
    bool isOptimal = soilStatus == "Optimal";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isOptimal ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isOptimal ? const Color(0xFFA5D6A7) : const Color(0xFFFFCC80), 
          width: 1
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOptimal ? LucideIcons.checkCircle2 : LucideIcons.alertTriangle,
            color: isOptimal ? Colors.green : Colors.orange,
            size: 36,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Overall Soil Status",
                style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                soilStatus,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isOptimal ? Colors.green[800] : Colors.orange[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E2923))),
              const SizedBox(width: 2),
              Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNpkCard(String elementLetter, String elementFull, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Text(elementLetter, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E2923))),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF135A3B))),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(elementFull, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ORGANIC HEADER ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20, 
                left: 24, 
                right: 24, 
                bottom: 40
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F4C30), Color(0xFF1A7A4C)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(LucideIcons.leaf, size: 120, color: Colors.white.withOpacity(0.05)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                            child: const Icon(LucideIcons.sprout, color: Colors.white),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                            child: const Icon(LucideIcons.bell, color: Colors.white),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text("My Digital Farm", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFA3D3B9), letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      const Text("Smart Agriculture", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SOIL STATUS WIDE CARD ---
                  _buildSoilStatusCard(),
                  const SizedBox(height: 24),

                  // --- SENSOR GRID ---
                  GridView.count(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1, 
                    children: [
                      _buildSensorCard("Soil Moisture", currentSoilMoisture, "%", LucideIcons.droplets, const Color(0xFF4CAF50)),
                      _buildSensorCard("Temperature", currentTemperature, "°C", LucideIcons.thermometer, const Color(0xFFFF9800)),
                      _buildSensorCard("pH Level", currentPhLevel, "pH", LucideIcons.flaskConical, const Color(0xFF03A9F4)),
                      _buildSensorCard("EC Level", currentEc, "µS", LucideIcons.zap, const Color(0xFF795548)), 
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- NPK SECTION ---
                  const Text("NPK Macronutrients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E2923))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNpkCard("N", "Nitrogen", currentNitrogen),
                      const SizedBox(width: 12),
                      _buildNpkCard("P", "Phosphorus", currentPhosphorus),
                      const SizedBox(width: 12),
                      _buildNpkCard("K", "Potassium", currentPotassium),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- LIVE WEATHER SECTION ---
                  const Text("Local Climate", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E2923))),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: isWeatherLoading 
                      ? const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: Color(0xFF1A7A4C)),
                        ))
                      : Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(18)),
                              child: Icon(weatherIcon, color: const Color(0xFFFFA000), size: 36),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("$weatherTemp°C • $weatherCondition", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2923))),
                                  const SizedBox(height: 4),
                                  const Text("Live data from Manila.", style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4)),
                                ],
                              ),
                            ),
                          ],
                        ),
                  ),
                  const SizedBox(height: 24), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}