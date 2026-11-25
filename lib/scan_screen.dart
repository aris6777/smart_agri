import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'results_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();

  final Query _historyQuery =
      FirebaseDatabase.instance.ref('scanHistory').limitToLast(5);

  // --- CAMERA & GALLERY LOGIC WITH EXPLICIT SENSOR CHOICE ---
  Future<void> _pickImage(
    ImageSource source, {
    required bool withSensor,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null && mounted) {
        Map<String, dynamic> liveData = {};

        if (withSensor) {
          final snapshot =
              await FirebaseDatabase.instance.ref('sensorData').get();
          if (snapshot.exists && snapshot.value != null) {
            liveData = Map<String, dynamic>.from(snapshot.value as Map);
          }
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              imageFile: File(pickedFile.path),
              includeSensorData: withSensor,
              liveN: withSensor ? (liveData['nitrogen'] ?? 0) : null,
              liveP: withSensor ? (liveData['phosphorus'] ?? 0) : null,
              liveK: withSensor ? (liveData['potassium'] ?? 0) : null,
              livePh: withSensor ? (liveData['ph'] ?? 0.0) : null,
              liveMoisture: withSensor ? (liveData['moisture'] ?? 0) : null,
              liveTemp: withSensor ? (liveData['temperature'] ?? 0) : null,
              liveEc: withSensor ? (liveData['ec'] ?? 0) : null,
            ),
          ),
        );
      }
    } catch (e) {
      print("Image picker error: $e");
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return "${date.month}/${date.day}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Recent";
    }
  }

  Widget _buildModeButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isPrimary ? const Color(0xFF135A3B) : const Color(0xFFF6F9F6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isPrimary
                  ? const Color(0xFF135A3B)
                  : const Color(0xFFD5E2D8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isPrimary ? Colors.white : const Color(0xFF135A3B),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isPrimary ? Colors.white : const Color(0xFF135A3B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanSectionCard({
    required String title,
    required String subtitle,
    required IconData badgeIcon,
    required bool withSensor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: withSensor
              ? const Color(0xFFA5D6A7)
              : const Color(0xFFE0E0E0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: withSensor
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFF1F5F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  badgeIcon,
                  size: 18,
                  color: withSensor
                      ? const Color(0xFF135A3B)
                      : const Color(0xFF455A64),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2923),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildModeButton(
                label: "Camera",
                icon: LucideIcons.camera,
                isPrimary: withSensor,
                onTap: () =>
                    _pickImage(ImageSource.camera, withSensor: withSensor),
              ),
              const SizedBox(width: 12),
              _buildModeButton(
                label: "Gallery",
                icon: LucideIcons.imagePlus,
                isPrimary: false,
                onTap: () =>
                    _pickImage(ImageSource.gallery, withSensor: withSensor),
              ),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Plant Scanner",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- WITH SENSOR & WITHOUT SENSOR BUTTON CARDS ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              children: [
                _buildScanSectionCard(
                  title: "Scan With Soil Sensor",
                  subtitle: "Combines plant photo with live moisture, temp & EC",
                  badgeIcon: LucideIcons.cpu,
                  withSensor: true,
                ),
                const SizedBox(height: 12),
                _buildScanSectionCard(
                  title: "Scan Without Soil Sensor",
                  subtitle: "Analyzes the plant photo only (no sensor data)",
                  badgeIcon: LucideIcons.leaf,
                  withSensor: false,
                ),
              ],
            ),
          ),

          // --- DIVIDER ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Recent Scans",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D332F),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // --- BOTTOM SECTION: HISTORY LIST ---
          Expanded(
            child: StreamBuilder(
              stream: _historyQuery.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF81C784)),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(
                    child: Text(
                      "No scans yet. Take a photo to get started!",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                Map<dynamic, dynamic> map =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<dynamic> historyList = map.values.toList();
                historyList.sort(
                    (a, b) => b['timestamp'].compareTo(a['timestamp']));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 8.0),
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    var item = historyList[index];
                    bool isHealthy = item['diagnosis']
                        .toString()
                        .toLowerCase()
                        .contains('healthy');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isHealthy
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isHealthy
                                  ? Icons.check_circle_outline
                                  : Icons.warning_amber_rounded,
                              color: isHealthy
                                  ? const Color(0xFF81C784)
                                  : const Color(0xFFFFB74D),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['diagnosis'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF2D332F),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(item['timestamp']),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            item['confidence'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF135A3B),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}