import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ResultsScreen extends StatefulWidget {
  final File? imageFile;
  final dynamic liveN;
  final dynamic liveP;
  final dynamic liveK;
  final dynamic livePh;
  final dynamic liveMoisture;
  final dynamic liveTemp;
  final dynamic liveEc;

  const ResultsScreen({
    Key? key,
    this.imageFile,
    required this.liveN,
    required this.liveP,
    required this.liveK,
    required this.livePh,
    required this.liveMoisture,
    this.liveTemp = 0,
    this.liveEc = 0,
  }) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool isAnalyzing = true;
  String plantType = "";
  String diagnosis = "";
  String confidence = "";
  String recommendation = "";

  @override
  void initState() {
    super.initState();
    if (widget.imageFile != null) {
      _runAIAnalysis();
    }
  }

  Future<void> _runAIAnalysis() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('ALERT: API Key not found in .env file!');
      setState(() {
        plantType = "Unknown";
        diagnosis = "Analysis Failed";
        recommendation = "API Key missing. Please check your .env file.";
        isAnalyzing = false;
      });
      return;
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      final imageBytes = await widget.imageFile!.readAsBytes();
      final prompt = TextPart("""
You are a helpful, beginner-friendly plant care assistant.
Step 1: Identify the exact type or species of plant in the photo (e.g., Kalanchoe, Cactus, Pechay, Snake Plant, Tomato). If the image is not a plant, set Plant to 'None' and Disease to 'Not a plant'.
Step 2: Check the plant's visual health AND evaluate the live soil sensor readings based on what THIS SPECIFIC PLANT SPECIES actually needs (for example, cacti and succulents like Kalanchoe prefer drier soil and should not be watered just because moisture is around 20-30%, whereas tropical or leafy plants need higher moisture):
- Soil Moisture: ${widget.liveMoisture}%
- Soil Temperature: ${widget.liveTemp}°C
- Soil EC (Salts/Nutrients): ${widget.liveEc} µS/cm

Step 3: Write a clear, natural 2-sentence explanation in Recommendation that names the plant, mentions the relevant soil sensor reading(s) (like moisture ${widget.liveMoisture}%), explains whether that reading is good or bad for this specific plant type, and gives simple next-step care advice. Avoid long paragraphs.

Respond STRICTLY in this exact format with no extra text:
Plant: [Common name of the plant]
Disease: [Short condition name or 'Healthy']
Confidence: [Percentage, e.g., 88%]
Recommendation: [2 clear, friendly sentences referencing the plant type and exact soil sensor numbers]
""");

      final imagePart = DataPart('image/jpeg', imageBytes);
      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final output = response.text ?? "";
      final parsedPlant = _extractLine(output, "Plant:");
      final parsedDiagnosis = _extractLine(output, "Disease:");
      final parsedConfidence = _extractLine(output, "Confidence:");
      final parsedRecommendation = _extractLine(output, "Recommendation:");

      setState(() {
        plantType = parsedPlant.isEmpty ? "Detected Plant" : parsedPlant;
        diagnosis = parsedDiagnosis;
        confidence = parsedConfidence;
        recommendation = parsedRecommendation;
        isAnalyzing = false;
      });

      if (!parsedDiagnosis.contains("Analysis Failed") &&
          !parsedDiagnosis.contains("Unknown") &&
          !parsedDiagnosis.contains("Not a plant")) {
        final DatabaseReference historyRef =
            FirebaseDatabase.instance.ref('scanHistory');

        final Map<String, dynamic> currentLiveSoilData = {
          "moisture": widget.liveMoisture,
          "temperature": widget.liveTemp,
          "ec": widget.liveEc,
          "nitrogen": widget.liveN,
          "phosphorus": widget.liveP,
          "potassium": widget.liveK,
          "ph": widget.livePh,
        };

        await historyRef.push().set({
          'plant_type': plantType,
          'diagnosis': parsedDiagnosis,
          'confidence': parsedConfidence,
          'recommendation': parsedRecommendation,
          'timestamp': DateTime.now().toIso8601String(),
          'soil_snapshot': currentLiveSoilData,
        });
      }
    } catch (e) {
      print("AI Error: $e");
      setState(() {
        plantType = "Unknown";
        diagnosis = "Analysis Failed";
        recommendation = "Please check your internet connection and try again.";
        isAnalyzing = false;
      });
    }
  }

  String _extractLine(String text, String prefix) {
    try {
      final lines = text.split('\n');
      final targetLine = lines.firstWhere(
        (line) => line.startsWith(prefix),
        orElse: () => "",
      );
      return targetLine.replaceAll(prefix, "").trim();
    } catch (e) {
      return "Unknown";
    }
  }

  Widget _buildMiniReading(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F9F6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2EBE4)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF135A3B)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2923),
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isHealthy = diagnosis.toLowerCase().contains("healthy");

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E2923)),
        title: const Text(
          "Scan Result",
          style: TextStyle(
            color: Color(0xFF1E2923),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: widget.imageFile == null
          ? const Center(
              child: Text(
                "No image found.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // --- PHOTO FRAME ---
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFC8E6C9),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF135A3B).withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.file(
                          widget.imageFile!,
                          height: 225,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (isAnalyzing) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFF135A3B),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Identifying plant & checking soil...",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF135A3B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // --- PLANT & DIAGNOSIS CARD ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isHealthy
                                ? [
                                    const Color(0xFFE8F5E9),
                                    const Color(0xFFD7EED9),
                                  ]
                                : [
                                    const Color(0xFFFFF8E1),
                                    const Color(0xFFFFECB3),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isHealthy
                                ? const Color(0xFFA5D6A7)
                                : const Color(0xFFFFD54F),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Identified Plant Pill
                            if (plantType.isNotEmpty &&
                                plantType.toLowerCase() != "none" &&
                                plantType.toLowerCase() != "unknown")
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      LucideIcons.sprout,
                                      size: 14,
                                      color: Color(0xFF135A3B),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      plantType,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF135A3B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Text(
                              diagnosis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E2923),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF135A3B),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    LucideIcons.sparkles,
                                    size: 13,
                                    color: Color(0xFFA5D6A7),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Match: $confidence",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- CARE TIP & SOIL SNAPSHOT CARD ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2EBE4)),
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
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    LucideIcons.leaf,
                                    size: 16,
                                    color: Color(0xFF135A3B),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Plant & Soil Insight",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E2923),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Compact Soil Sensor Readings Row
                            Row(
                              children: [
                                _buildMiniReading(
                                  LucideIcons.droplets,
                                  "Moisture",
                                  "${widget.liveMoisture}%",
                                ),
                                const SizedBox(width: 8),
                                _buildMiniReading(
                                  LucideIcons.thermometer,
                                  "Temp",
                                  "${widget.liveTemp}°C",
                                ),
                                const SizedBox(width: 8),
                                _buildMiniReading(
                                  LucideIcons.zap,
                                  "EC",
                                  "${widget.liveEc} µS",
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            Text(
                              recommendation,
                              style: const TextStyle(
                                height: 1.55,
                                fontSize: 15,
                                color: Color(0xFF2D332F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}