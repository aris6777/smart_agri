import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdviceScreen extends StatefulWidget {
  const AdviceScreen({Key? key}) : super(key: key);

  @override
  State<AdviceScreen> createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<AdviceScreen> {
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref('sensorData');
  
  // A list to hold our dynamic alert cards
  List<Widget> activeAlerts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenForIssues();
  }

  void _listenForIssues() {
    _sensorRef.onValue.listen((event) {
      if (!mounted) return;
      
      if (event.snapshot.value == null) {
        setState(() => isLoading = false);
        return;
      }

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      List<Widget> newAlerts = [];

      // 1. Check Soil Moisture (Optimal: 40% - 80%)
      if (data['soilMoisture'] != null) {
        double moisture = double.tryParse(data['soilMoisture'].toString()) ?? 0;
        if (moisture < 40) {
          newAlerts.add(_buildAlertCard("CRITICAL: Dry Soil", "Moisture is at $moisture%. The plants are at risk of wilting. Please initiate irrigation immediately.", Icons.water_drop, const Color(0xFFFFB74D)));
        } else if (moisture > 80) {
          newAlerts.add(_buildAlertCard("WARNING: Waterlogged", "Moisture is extremely high ($moisture%). Stop watering to prevent root rot.", Icons.water_damage, const Color(0xFF64B5F6)));
        }
      }

      // 2. Check Temperature (Optimal: 18°C - 30°C)
      if (data['temperature'] != null) {
        double temp = double.tryParse(data['temperature'].toString()) ?? 0;
        if (temp < 18) {
          newAlerts.add(_buildAlertCard("WARNING: Cold Stress", "Temperature dropped to $temp°C. Plant growth may stunt. Consider turning on greenhouse heaters.", Icons.ac_unit, const Color(0xFF64B5F6)));
        } else if (temp > 30) {
          newAlerts.add(_buildAlertCard("CRITICAL: Heat Stress", "Temperature is too high ($temp°C). Open ventilation systems or turn on cooling fans to prevent leaf burn.", Icons.local_fire_department, const Color(0xFFE57373)));
        }
      }

      // 3. Check pH Level (Optimal: 5.5 - 7.0)
      if (data['phLevel'] != null) {
        double ph = double.tryParse(data['phLevel'].toString()) ?? 0;
        if (ph < 5.5) {
          newAlerts.add(_buildAlertCard("WARNING: Highly Acidic", "pH is $ph. Nutrient lockout may occur. Mix agricultural lime into the soil to neutralize acidity.", Icons.science, const Color(0xFFBA68C8)));
        } else if (ph > 7.0) {
          newAlerts.add(_buildAlertCard("WARNING: Highly Alkaline", "pH is $ph. Plants may struggle to absorb iron. Apply elemental sulfur or acidifying fertilizers.", Icons.science, const Color(0xFFBA68C8)));
        }
      }

      // Update the screen with the new alertch
      setState(() {
        activeAlerts = newAlerts;
        isLoading = false;
      });
    });
  }

  // The design for a single alert box
  Widget _buildAlertCard(String title, String message, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D332F))),
                const SizedBox(height: 8),
                Text(message, style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Automated Advice", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF81C784)))
          : activeAlerts.isEmpty
              ? _buildAllClearScreen()
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: activeAlerts,
                ),
    );
  }

  // What shows up if all sensors are perfectly healthy
  Widget _buildAllClearScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: Color(0xFF81C784), size: 64),
          ),
          const SizedBox(height: 24),
          const Text("Conditions are Optimal", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D332F))),
          const SizedBox(height: 8),
          const Text("No action required. Your plants are thriving!", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}