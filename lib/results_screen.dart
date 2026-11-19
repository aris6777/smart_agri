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

  const ResultsScreen({
    Key? key,
    this.imageFile,
    required this.liveN,
    required this.liveP,
    required this.liveK,
    required this.livePh,
    required this.liveMoisture,
  }) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool isAnalyzing = true;
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
You are a helpful, concise plant care assistant. Look at this plant image and soil data:
- Nitrogen (N): ${widget.liveN}
- Phosphorus (P): ${widget.liveP}
- Potassium (K): ${widget.liveK}
- pH Level: ${widget.livePh}
- Soil Moisture: ${widget.liveMoisture}%

If the image is not a plant, set Disease to 'Not a plant'.
Keep Recommendation SHORT and simple (1 to 2 brief sentences max, no long paragraphs, no technical jargon).

Respond STRICTLY in this exact format with no extra text:
Disease: [Short name or 'Healthy']
Confidence: [Percentage]
Recommendation: [1-2 short, clear sentences on what to do next]
""");

      final imagePart = DataPart('image/jpeg', imageBytes);
      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final output = response.text ?? "";
      final parsedDiagnosis = _extractLine(output, "Disease:");
      final parsedConfidence = _extractLine(output, "Confidence:");
      final parsedRecommendation = _extractLine(output, "Recommendation:");

      setState(() {
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
          "nitrogen": widget.liveN,
          "phosphorus": widget.liveP,
          "potassium": widget.liveK,
          "ph": widget.livePh,
          "moisture": widget.liveMoisture,
        };

        await historyRef.push().set({
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
                    // --- PHOTO FRAME WITH DECORATIVE BORDER ---
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
                          height: 235,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (isAnalyzing) ...[
                      const SizedBox(height: 20),
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
                              "Reading your plant...",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF135A3B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // --- HIGHLIGHT DIAGNOSIS CARD ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 22,
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
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isHealthy
                                    ? LucideIcons.sprout
                                    : LucideIcons.alertTriangle,
                                color: isHealthy
                                    ? const Color(0xFF1B5E20)
                                    : const Color(0xFFE65100),
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              diagnosis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 23,
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

                      // --- SHORT & FRIENDLY CARE TIP CARD ---
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
                                  "Care Tip",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E2923),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
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